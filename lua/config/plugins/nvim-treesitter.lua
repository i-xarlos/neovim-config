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
        },
    },
}
