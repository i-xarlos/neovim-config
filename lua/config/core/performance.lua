-- Configuration to optimize performance with heavy processes

-- Increase update time to reduce the frequency of background operations
-- Default value is 4000ms (4s), but it can be reduced for better responsiveness
vim.o.updatetime = 500 -- 500ms is a good balance between responsiveness and performance

-- Limit the number of messages that Neovim displays to avoid UI freezing
vim.o.shortmess = vim.o.shortmess .. "c"

-- Configuration for LSP diagnostics
vim.diagnostic.config({
    -- Limit the frequency of diagnostic updates
    update_in_insert = false, -- Don't update diagnostics in insert mode
    severity_sort = true, -- Sort diagnostics by severity
    underline = true,
    virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
    },
    -- Limit maximum number of diagnostics to avoid overload
    virtual_lines = false, -- Don't show virtual lines
})

-- Configuration for LSP timeouts
vim.lsp.buf.hover_options = { focusable = false }

-- Configuration to reduce rendering load
vim.o.lazyredraw = true -- Don't redraw during macros and scripts
vim.o.ttyfast = true -- Faster rendering
vim.o.re = 0 -- Use modern regex engine

-- Temporary workaround for a Neovim 0.12 Tree-sitter async crash:
-- treesitter.lua can throw "attempt to call method 'range' (a nil value)"
-- from scheduled parser callbacks. Keep editor usable until upstream/parsers
-- are fully in sync. Gate this to Neovim 0.12 so it is easy to remove later.
do
    local ts = vim.treesitter
    local is_nvim_012 = vim.fn.has("nvim-0.12") == 1
    if is_nvim_012 and ts and ts.get_range and not vim.g._ts_get_range_guard_enabled then
        local original_get_range = ts.get_range
        ts.get_range = function(node, source, metadata)
            local ok, range = pcall(original_get_range, node, source, metadata)
            if ok then
                return range
            end
            return nil
        end
        vim.g._ts_get_range_guard_enabled = true
    end

    -- Additional guard for Neovim 0.12 runtime errors such as:
    -- _range.lua:137: attempt to get length of local 'r' (a nil value)
    -- bubbling through vim.treesitter.get_node_text() during highlighting.
    if is_nvim_012 and ts and ts.get_node_text and not vim.g._ts_get_node_text_guard_enabled then
        local original_get_node_text = ts.get_node_text
        ts.get_node_text = function(node, source, opts)
            local ok, text = pcall(original_get_node_text, node, source, opts)
            if ok then
                return text
            end
            return ""
        end
        vim.g._ts_get_node_text_guard_enabled = true
    end
end

-- Limit data sent to LSP server
local ok, wf = pcall(require, "vim.lsp._watchfiles")
if ok then
    -- Limit file watching to avoid system overload
    wf._watchfunc = function()
        return function() end
    end
end

return {}
