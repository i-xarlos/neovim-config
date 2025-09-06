return {
  "olimorris/onedarkpro.nvim",
  priority = 1000, -- Ensure it loads first
  lazy = false, -- Make sure it is loaded during startup
  config = function()
    require("onedarkpro").setup({
      styles = {
        types = "NONE",
        methods = "NONE",
        numbers = "NONE",
        strings = "NONE",
        comments = "italic",
        keywords = "bold,italic",
        constants = "NONE",
        functions = "italic",
        operators = "NONE",
        variables = "NONE",
        parameters = "NONE",
        conditionals = "italic",
        virtual_text = "NONE",
      },
      colors = {
        onedark = { bg = "#FFFF00" }, -- yellow
        onelight = { bg = "#00FF00" }, -- green
        onedark_dark = { bg = "#222222" }, -- yellow
      }
    })

local has_truecolor = os.getenv("COLORTERM") == "truecolor"
                    or os.getenv("TERM_PROGRAM") == "iTerm.app"
                    or os.getenv("TERM_PROGRAM") == "Apple_Terminal" and false 

if has_truecolor then
  vim.opt.termguicolors = true
  vim.cmd("colorscheme onedark_dark")
else
  vim.opt.termguicolors = false
  -- Fallback a un tema 256-colors amigable
  -- vim.cmd.colorscheme("default")
  -- Si quieres algo más bonito en 256:
  vim.cmd.colorscheme("industry")
  -- vim.cmd.colorscheme("elflord")
end

  end,
}
