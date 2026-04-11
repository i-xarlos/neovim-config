return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false }, -- disable inline suggestions
      panel = { enabled = false }, -- disable Copilot panel
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
}