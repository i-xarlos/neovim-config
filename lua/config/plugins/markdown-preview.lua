return {
    "ellisonleao/glow.nvim",
    cmd = "Glow",
    config = function()
        require("glow").setup({
            border = "shadow",
            style = "dark",
            pager = false,
            width = 120,
            height = 40,
        })
    end,
}

