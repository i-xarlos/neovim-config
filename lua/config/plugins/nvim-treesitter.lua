return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            -- Use pcall to safely require the module
            local status, configs = pcall(require, "nvim-treesitter")
            if not status then
                vim.notify("nvim-treesitter not found", vim.log.levels.WARN)
                return
            end

            configs.setup({
                highlight = {
                    enable = true,
                },
                indent = { enable = true },
                ensure_installed = {},
                sync_install = false,
                auto_install = false,
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
                -- Add textobjects configuration here
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["a="] = {
                                query = "@assignment.outer",
                                desc = "Select outer part of an assignment region",
                            },
                            ["i="] = {
                                query = "@assignment.inner",
                                desc = "Select inner part of an assignment region",
                            },
                            ["a:"] = {
                                query = "@parameter.outer",
                                desc = "Select outer part of a parameter/field region",
                            },
                            ["i:"] = {
                                query = "@parameter.inner",
                                desc = "Select inner part of a parameter/field region",
                            },
                        },
                    },
                },
            })
        end,
    },
}
