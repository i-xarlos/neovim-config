return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master", -- Use the stable master branch (main is a breaking rewrite)
        build = ":TSUpdate",
        lazy = false,
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
        opts = {
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
        },
    },
}
