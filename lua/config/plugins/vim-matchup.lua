return {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
        -- Workaround for Neovim 0.12 Treesitter runtime crash:
        -- ...vim/treesitter/_range.lua:137: attempt to get length of local 'r' (a nil value)
        -- triggered from treesitter-matchup on CursorMoved.
        vim.g.matchup_treesitter_enabled = 0
        vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
}
