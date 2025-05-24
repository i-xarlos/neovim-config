return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "InsertEnter",  -- Load only in insert mode
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false }, -- disables inline suggestions
				panel = { enabled = false },
				filetypes = {
					-- Performance optimizations
					["*"] = true,  -- Enable for all file types
					-- Disable for large files or where not needed
					help = false,
					gitcommit = false,
					gitrebase = false,
					hgcommit = false,
					svn = false,
					cvs = false,
					-- Set limits for heavy files					
                    ["."] = function()
						-- Check if the file is too large
						local max_filesize = 100 * 1024 -- 100KB
						local current_buf = vim.api.nvim_get_current_buf()
						local ok, stats = pcall(vim.loop.fs_stat,vim.api.nvim_buf_get_name(current_buf))
						if ok and stats and stats.size > max_filesize then
							return false  -- Disable for large files
						end
						return true
					end,
				},
				-- Network optimizations
				copilot_node_command = 'node', -- Use system Node.js
				server_opts_overrides = {
					-- Limit memory usage and timeout
					trace = "off",
					inlineSuggestCount = 3,  -- Reduce from 5 to 3
					-- Increase timeout to avoid constant reloading
					suggestionTriggerCharacters = { ".", ">", ":", "=", "(" },
				},
			})
			vim.g.copilot_no_tab_map = true
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = { "zbirenbaum/copilot.lua" },
		config = function()			require("copilot_cmp").setup({
				-- Performance optimizations
				event = { "InsertEnter", "LspAttach" },
				fix_pairs = true,
				clear_after_cursor = true,  -- Reduce false suggestions
				debounce = 150,  -- Increase debounce to 150ms (default is 80ms)
			})
		end,
	},
}
