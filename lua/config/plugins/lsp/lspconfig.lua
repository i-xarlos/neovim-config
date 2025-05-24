return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		lazy = true,
		init = function()
			vim.g.lsp_zero_extend_cmp = 0
			vim.g.lsp_zero_extend_lspconfig = 0
		end,
	},
	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
		config = function()
			local lsp_zero = require("lsp-zero.api")
			lsp_zero.extend_cmp()

			local cmp = require("cmp")
			local cmp_action = lsp_zero.cmp_action()

			local luasnip = require("luasnip")
			-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				completion = {
					completeopt = "menu,menuone,preview,noselect",
				},
				snippet = { -- configure how nvim-cmp interacts with snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				---- sources for autocompletion
				sources = cmp.config.sources({
					{ name = "copilot" },
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" }, -- text within current buffer
					{ name = "path" }, -- file system paths
					{ name = "spell" },
				}),
				mapping = cmp.mapping.preset.insert({
					-- `Enter` key to confirm completion
					["<CR>"] = cmp.mapping.confirm({ select = false }),

					-- Ctrl+Space to trigger completion menu
					["<C-Space>"] = cmp.mapping.complete(),

					-- Navigate between snippet placeholder
					["<C-f>"] = cmp_action.luasnip_jump_forward(),
					["<C-b>"] = cmp_action.luasnip_jump_backward(),

					-- Scroll up and down in the completion documentation
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end,
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end,
				}),
			})
		end,
	},
	-- LSP
	{
		-- LSP Support
		"neovim/nvim-lspconfig",
		cmd = "LspInfo",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },
		},
		config = function()
			local lsp = require("lsp-zero")
			lsp.extend_lspconfig()			
			lsp.preset("recommended")			
			lsp.on_attach(function()
				-- Modern configuration for diagnostic icons
				local signs = { Error = " ", Warn = " ", Hint = "", Info = " " }
				for type, icon in pairs(signs) do
					local hl = "DiagnosticSign" .. type
					-- Highlighting configuration using the modern API
					vim.api.nvim_set_hl(0, hl, { default = true })
				end
				-- Modern diagnostic configuration with icons
				vim.diagnostic.config({
					virtual_text = true,
					signs = {
						text = {
							[vim.diagnostic.severity.ERROR] = signs.Error,
							[vim.diagnostic.severity.WARN] = signs.Warn,
							[vim.diagnostic.severity.HINT] = signs.Hint,
							[vim.diagnostic.severity.INFO] = signs.Info,
						},
					},
					underline = true,
					severity_sort = true,
				})
			end)

			local keymap = vim.keymap -- for conciseness
			local opts = { noremap = true, silent = true }					local on_attach = function(client, bufnr)
				opts.buffer = bufnr
				
				-- Performance optimizations
				local max_line_count = 5000
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				
				-- Disable LSP for large files
				if line_count > max_line_count then
					client.stop()
					vim.notify("LSP stopped for this file (too large)", vim.log.levels.WARN)
					return
				end
				
				-- Disable heavy LSP features based on client type
				if client.name == "tsserver" or client.name == "ts_ls" then
					-- Limit TypeScript features to improve performance
					client.server_capabilities.documentFormattingProvider = false
					
					-- Use less frequent diagnostics for TypeScript/JavaScript files
					if vim.bo[bufnr].filetype == "typescript" or vim.bo[bufnr].filetype == "javascript" then
						vim.diagnostic.config({update_in_insert = false}, bufnr)
					end
				end
				
				-- Disable inline formatting for heavy clients
				if client.name == "tsserver" or client.name == "ts_ls" or client.name == "eslint" then
					client.server_capabilities.documentRangeFormattingProvider = false
				end

				-- set keybinds
				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

				opts.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

				opts.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
			end

			-- import lspconfig plugin
			local lspconfig = require("lspconfig")
			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- configure html server
			lspconfig["html"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})			-- configure typescript server with plugin
			lspconfig["ts_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				--		root_dir = require("lspconfig.util").root_pattern(".git"),
				root_dir = function(fname)
					return require("lspconfig.util").root_pattern("tsconfig.json", "package.json")(fname)
				end,
				settings = {
					ts_ls = {
						exclude = { "node_modules", "dist", "build", ".git", "coverage", ".next", ".nuxt" },
						-- Reducir la cantidad de información que TypeScript analiza
						suggestionActions = { enabled = false },
						completions = { completeFunctionCalls = false },
						implicitProjectConfiguration = {
							checkJs = false, -- Deshabilitar comprobación de JS si causa problemas de rendimiento
						},
						-- Opciones de optimización para proyectos grandes
						maxTsServerMemory = 3072, -- Limitar memoria del servidor TS a 3GB
						disableAutomaticTypeAcquisition = true, -- Evitar descargas automáticas de tipos
					},
				},
				flags = {
					debounce_text_changes = 250, -- Aumentado de 150 a 250ms
					allow_incremental_sync = true,
				},
			})

			-- configure css server
			lspconfig["cssls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure tailwindcss server
			lspconfig["tailwindcss"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure svelte server
			lspconfig["svelte"].setup({
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)

					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							if client.name == "svelte" then
								client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
							end
						end,
					})
				end,
			})

			-- configure prisma orm server
			lspconfig["prismals"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure graphql language server
			lspconfig["graphql"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			})

			-- configure emmet language server
			lspconfig["emmet_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
			})

			-- configure python server
			lspconfig["pyright"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})

			-- configure lua server (with special settings)
			lspconfig["lua_ls"].setup({
				capabilities = capabilities,
				on_attach = on_attach,
				settings = { -- custom settings for lua
					Lua = {
						-- make the language server recognize "vim" global
						diagnostics = {
							globals = { "vim" },
						},
						workspace = {
							-- make language server aware of runtime files
							library = {
								[vim.fn.expand("$VIMRUNTIME/lua")] = true,
								[vim.fn.stdpath("config") .. "/lua"] = true,
							},
						},
					},
				},
			})
					-- Configuration to close documentation floating windows with Esc
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "help", "markdown" },
				callback = function(event)
					-- Only applies to documentation floating windows
					local win = vim.api.nvim_get_current_win()
					local config = vim.api.nvim_win_get_config(win)
					if config.relative ~= "" then
						-- Map <esc> to close the floating window
						vim.keymap.set("n", "<Esc>", function()
							vim.api.nvim_win_close(win, true)
						end, { buffer = event.buf, silent = true, noremap = true })
					end
				end,
			})
					-- Global autocommand to close floating windows with Esc
			vim.api.nvim_create_autocmd("WinEnter", {
				callback = function()
					local win = vim.api.nvim_get_current_win()
					local config = vim.api.nvim_win_get_config(win)
					if config.relative ~= "" then
						-- If it's a floating window, map Esc to close it
						vim.keymap.set("n", "<Esc>", function()
							vim.api.nvim_win_close(win, true)
						end, { buffer = 0, silent = true, noremap = true })
					end
				end,
			})
			
			-- Optimization for large projects: disable diagnostics in insert mode
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact"},
				callback = function(ev)
					-- Disable diagnostics in insert mode for these file types
					vim.api.nvim_create_autocmd("InsertEnter", {
						buffer = ev.buf,
						callback = function()
							vim.diagnostic.disable(ev.buf)
						end,
					})vim.api.nvim_create_autocmd("InsertLeave", {
						buffer = ev.buf,
						callback = function()
							-- Delay diagnostic reactivation to avoid freezing
							vim.defer_fn(function()
								vim.diagnostic.enable(ev.buf)
							end, 300)
						end,
					})
				end,
			})
			
			-- Circuit breaker for LSP operations when the system is overloaded
			local cpu_usage_threshold = 70 -- percentage
			local last_check_time = 0
			local check_interval = 2000 -- ms
			
			-- Function to check CPU usage before costly operations
			_G.check_system_load = function()
				local current_time = vim.loop.now()
				if current_time - last_check_time < check_interval then
					return true -- allow operation if not enough time has passed
				end
				
				-- In a real implementation, you would check system load here
				-- This is a basic function that always returns true
				-- A plugin like nvim-health could implement this function properly
				
				last_check_time = current_time
				return true
			end
			
			-- Key to manually restart all LSP servers
			vim.api.nvim_set_keymap("n", "<leader>lR", "<cmd>LspRestart all<CR>", {noremap = true, silent = true, desc = "Restart all LSP servers"})
		end,
	},
}
