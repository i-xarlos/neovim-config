-- Configuration to optimize performance with heavy processes

-- Increase update time to reduce the frequency of background operations
-- Default value is 4000ms (4s), but it can be reduced for better responsiveness
vim.o.updatetime = 500  -- 500ms is a good balance between responsiveness and performance

-- Limit the number of messages that Neovim displays to avoid UI freezing
vim.o.shortmess = vim.o.shortmess .. 'c'

-- Configuration for LSP diagnostics
vim.diagnostic.config({
  -- Limit the frequency of diagnostic updates
  update_in_insert = false,  -- Don't update diagnostics in insert mode
  severity_sort = true,      -- Sort diagnostics by severity
  underline = true,
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  -- Limit maximum number of diagnostics to avoid overload
  virtual_lines = false,     -- Don't show virtual lines
})

-- Configuration for LSP timeouts
vim.lsp.buf.hover_options = { focusable = false }

-- Configuration to reduce rendering load
vim.o.lazyredraw = true      -- Don't redraw during macros and scripts
vim.o.ttyfast = true         -- Faster rendering
vim.o.re = 0                 -- Use modern regex engine

-- Limit data sent to LSP server
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
  -- Limit file watching to avoid system overload
  wf._watchfunc = function()
    return function() end
  end
end

return {}
