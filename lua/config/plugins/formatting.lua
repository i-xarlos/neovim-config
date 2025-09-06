return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")
        local slow_format_filetypes = {}

        -- Optimizations for large files
        local max_filesize_format = 500 * 1024 -- 500KB for normal formatting
        local max_filesize_heavy = 200 * 1024 -- 200KB for heavy formatters like prettier
        local max_lines_format = 3000 -- Maximum number of lines for formatting

        conform.setup({
            formatters_by_ft = {
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                svelte = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                graphql = { "prettier" },
                lua = { "stylua" },
                python = { "isort", "black" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                zsh = { "shfmt" },
                ["*"] = { "codespell" }, -- spell-checking for all filetypes
            },

            -- Formatting with performance optimizations
            format_on_save = function(bufnr)
                -- Don't format if buffer isn't loaded or in diff mode
                if not vim.api.nvim_buf_is_loaded(bufnr) or vim.wo.diff then
                    return
                end

                -- Get file information
                local file_path = vim.api.nvim_buf_get_name(bufnr)
                if file_path == "" then
                    return -- Don't format unnamed buffers
                end

                -- Check file size
                local ok, stats = pcall(vim.loop.fs_stat, file_path)
                if not ok or not stats then
                    return
                end
                -- Check if it's a large file
                if stats.size > max_filesize_format then
                    vim.notify(
                        "File too large for automatic formatting",
                        vim.log.levels.INFO
                    )
                    return
                end

                -- Check line count
                local line_count = vim.api.nvim_buf_line_count(bufnr)
                if line_count > max_lines_format then
                    vim.notify(
                        "File has too many lines for automatic formatting",
                        vim.log.levels.INFO
                    )
                    return
                end

                -- Check if it's a heavy formatter like prettier for files that could be problematic
                local filetype = vim.bo[bufnr].filetype
                if
                    (
                        filetype == "javascript"
                        or filetype == "typescript"
                        or filetype == "javascriptreact"
                        or filetype == "typescriptreact"
                    )
                    and stats.size > max_filesize_heavy
                then
                    vim.notify(
                        "Large TypeScript/JavaScript file - skipping automatic formatting",
                        vim.log.levels.INFO
                    )
                    return
                end

                -- Check if formatting was slow previously
                if slow_format_filetypes[filetype] then
                    return
                end

                -- Function to handle timeout errors
                local function on_format(err)
                    if err and err:match("timeout$") then
                        slow_format_filetypes[filetype] = true
                        vim.notify(
                            "Slow formatting detected for "
                                .. filetype
                                .. ". Disabled for future operations.",
                            vim.log.levels.WARN
                        )
                    end
                end
                return {
                    timeout_ms = 1000, -- Shorter timeout to improve performance
                    lsp_fallback = true,
                },
                    on_format
            end,

            -- For files that have been marked as slow, format after save
            format_after_save = function(bufnr)
                if not slow_format_filetypes[vim.bo[bufnr].filetype] then
                    return
                end
                return {
                    lsp_fallback = true,
                    timeout_ms = 3000, -- Longer timeout for post-save formatting
                }
            end,

            -- Configuration of specific formatters with optimizations
            formatters = {
                prettier = {
                    -- Use prettier more efficiently
                    env = {
                        PRETTIERD_DEFAULT_CONFIG = vim.fn.expand(
                            "~/.config/nvim/utils/linter-config/.prettierrc"
                        ),
                    },
                    -- Use prettier daemon for better performance
                    command = "prettierd",
                    args = { "$FILENAME" },
                    range_args = function()
                        return {
                            "$FILENAME",
                            "--range-start",
                            "$START",
                            "--range-end",
                            "$END",
                        }
                    end,
                },
                shfmt = {
                    prepend_args = { "-i", "2", "-ci" },
                },
                stylua = {
                    prepend_args = {
                        "--config-path",
                        vim.fn.expand(
                            "~/.config/nvim/utils/linter-config/stylua.toml"
                        ),
                    },
                },
                black = {
                    prepend_args = { "--line-length", "88", "--quiet" },
                },
                codespell = {
                    -- Only check for obvious errors, don't use the full dictionary to improve performance
                    args = {
                        "--check-hidden",
                        "--builtin",
                        "clear,rare,code",
                        "-",
                    },
                },
            },
        })

        -- Optimized keyboard shortcuts
        vim.keymap.set({ "n", "v" }, "<leader>f", function()
            local bufnr = vim.api.nvim_get_current_buf()
            local file_path = vim.api.nvim_buf_get_name(bufnr)

            -- Check size before manual formatting
            local ok, stats = pcall(vim.loop.fs_stat, file_path)
            if ok and stats and stats.size > max_filesize_format then
                vim.notify(
                    "File too large for formatting: "
                        .. math.floor(stats.size / 1024)
                        .. "KB",
                    vim.log.levels.WARN
                )
                return
            end
            -- Format with a more generous timeout for manual formatting
            conform.format({
                bufnr = bufnr,
                lsp_fallback = true,
                async = false,
                timeout_ms = 3000,
            })
        end, { desc = "Format file or range (in visual mode)" })
        -- Keep the old shortcut for compatibility
        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 3000,
            })
        end, { desc = "Format file or range (in visual mode)" })

        -- Specific autocmd for Lua files to ensure they format correctly
        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*.lua",
            callback = function(args)
                -- Only format if file is not too large
                local file_path = args.file
                local ok, stats = pcall(vim.loop.fs_stat, file_path)

                if ok and stats and stats.size <= max_filesize_format then
                    -- Format with stylua specifically
                    conform.format({
                        bufnr = args.buf,
                        formatters_by_ft = {
                            lua = { "stylua" },
                        },
                        timeout_ms = 1500,
                        async = false,
                    })
                end
            end,
            desc = "Format Lua files on save with StyleLua",
        })
    end,
}
