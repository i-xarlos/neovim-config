return {
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "zbirenbaum/copilot.lua" },
    event = "InsertEnter",
    config = function()
      local ok_source, source = pcall(require, "copilot_cmp.source")
      if ok_source and type(source.is_available) == "function" then
        source.is_available = function(self)
          if not self.client or self.client.name ~= "copilot" or self.client:is_stopped() then
            return false
          end

          local get_source_client = function()
            if vim.lsp.get_clients == nil then
              return vim.lsp.get_active_clients({
                bufnr = vim.api.nvim_get_current_buf(),
                id = self.client.id,
              })
            end
            return vim.lsp.get_clients({
              bufnr = vim.api.nvim_get_current_buf(),
              id = self.client.id,
            })
          end

          return next(get_source_client()) ~= nil
        end
      end

      require("copilot_cmp").setup({
        fix_pairs = true,
      })
    end,
  },
}