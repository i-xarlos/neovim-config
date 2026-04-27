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
			-- Modern diagnostic configuration with icons
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

			local keymap = vim.keymap -- for conciseness
			local opts = { noremap = true, silent = true }					local on_attach = function(client, bufnr)
				opts.buffer = bufnr
				
				-- Performance optimizations
				local max_line_count = 5000
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				
				-- Disable LSP for large files
				if line_count > max_line_count then
					client:stop()
					vim.notify("LSP stopped for this file (too large)", vim.log.levels.WARN)
					return
				end
				
				-- Disable heavy LSP features based on client type
				if client.name == "tsserver" or client.name == "ts_ls" then
					-- Use less frequent diagnostics for TypeScript/JavaScript files
					if vim.bo[bufnr].filetype == "typescript" or vim.bo[bufnr].filetype == "javascript" then
						vim.diagnostic.config({update_in_insert = false}, bufnr)
					end
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

			-- import cmp-nvim-lsp plugin
			local cmp_nvim_lsp = require("cmp_nvim_lsp")
			-- used to enable autocompletion (assign to every lsp server config)
			local capabilities = cmp_nvim_lsp.default_capabilities()

			-- configure html server using the new vim.lsp.config API
			vim.lsp.config.html = {
				cmd = { 'vscode-html-language-server', '--stdio' },
				filetypes = { 'html' },
				root_markers = { '.git', 'package.json' },
				capabilities = capabilities,
				on_attach = on_attach,
			}			-- configure typescript server with plugin using the new vim.lsp.config API
			vim.lsp.config.ts_ls = {
				cmd = { 'typescript-language-server', '--stdio' },
				filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
				root_markers = { 'tsconfig.json', 'package.json', '.git' },
				capabilities = capabilities,
				on_attach = on_attach,
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
			}

			-- configure css server using the new vim.lsp.config API
			vim.lsp.config.cssls = {
				cmd = { 'vscode-css-language-server', '--stdio' },
				filetypes = { 'css', 'scss', 'less' },
				root_markers = { 'package.json', '.git' },
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- configure tailwindcss server using the new vim.lsp.config API
			vim.lsp.config.tailwindcss = {
				cmd = { 'tailwindcss-language-server', '--stdio' },
				filetypes = { 'html', 'css', 'scss', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue', 'svelte' },
				root_markers = { 'tailwind.config.js', 'tailwind.config.ts', 'tailwind.config.cjs', 'package.json', '.git' },
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- configure svelte server using the new vim.lsp.config API
			vim.lsp.config.svelte = {
				cmd = { 'svelteserver', '--stdio' },
				filetypes = { 'svelte' },
				root_markers = { 'package.json', 'svelte.config.js', 'svelte.config.cjs', 'svelte.config.mjs', '.git' },
				capabilities = capabilities,
				on_attach = function(client, bufnr)
					on_attach(client, bufnr)

					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							if client.name == "svelte" then
								client:notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
							end
						end,
					})
				end,
			}

			-- configure prisma orm server using the new vim.lsp.config API
			vim.lsp.config.prismals = {
				cmd = { 'prisma-language-server', '--stdio' },
				filetypes = { 'prisma' },
				root_markers = { 'schema.prisma', 'package.json', '.git' },
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- configure graphql language server using the new vim.lsp.config API
			vim.lsp.config.graphql = {
				cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
				filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
				root_markers = { '.graphqlrc', '.graphqlrc.json', '.graphqlrc.yaml', '.graphqlrc.yml', 'graphql.config.js', 'graphql.config.ts', 'package.json', '.git' },
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- configure emmet language server using the new vim.lsp.config API
			vim.lsp.config.emmet_ls = {
				cmd = { 'emmet-ls', '--stdio' },
				filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
				root_markers = { 'package.json', '.git' },
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- configure python server using the new vim.lsp.config API
			vim.lsp.config.pyright = {
				cmd = { 'pyright-langserver', '--stdio' },
				filetypes = { 'python' },
				root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'pyrightconfig.json', '.git' },
				capabilities = capabilities,
				on_attach = on_attach,
			}

			-- configure lua server (with special settings) using the new vim.lsp.config API
			vim.lsp.config.lua_ls = {
				cmd = { 'lua-language-server' },
				filetypes = { 'lua' },
				root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
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
			}
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
			local function set_diagnostics_enabled(bufnr, enabled)
				if vim.diagnostic.disable and vim.diagnostic.enable then
					if enabled then
						vim.diagnostic.enable(bufnr)
					else
						vim.diagnostic.disable(bufnr)
					end
					return
				end
				if vim.diagnostic.enable then
					vim.diagnostic.enable(enabled, { bufnr = bufnr })
				end
			end
			
			vim.api.nvim_create_autocmd("FileType", {
				pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact"},
				callback = function(ev)
					-- Disable diagnostics in insert mode for these file types
					vim.api.nvim_create_autocmd("InsertEnter", {
						buffer = ev.buf,
						callback = function()
							set_diagnostics_enabled(ev.buf, false)
						end,
					})
					vim.api.nvim_create_autocmd("InsertLeave", {
						buffer = ev.buf,
						callback = function()
							-- Delay diagnostic reactivation to avoid freezing
							vim.defer_fn(function()
								set_diagnostics_enabled(ev.buf, true)
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
