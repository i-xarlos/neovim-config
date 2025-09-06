-- User commands to enhance workflow

-- Define commands when VimEnter to ensure all plugins are loaded
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        -- Command to format Lua file with StyleLua
        vim.api.nvim_create_user_command("StyleLua", function()
            local file = vim.api.nvim_buf_get_name(0)
            local output = vim.fn.system({
                "stylua",
                "--config-path",
                vim.fn.expand("~/.config/nvim/utils/linter-config/stylua.toml"),
                file,
            })

            if vim.v.shell_error ~= 0 then
                vim.notify("StyleLua error: " .. output, vim.log.levels.ERROR)
            else
                vim.notify(
                    "Successfully formatted with StyleLua",
                    vim.log.levels.INFO
                )
                vim.cmd.edit() -- Reload the file
            end
        end, { desc = "Format current Lua file with StyleLua" })

        -- Command to check StyleLua configuration
        vim.api.nvim_create_user_command("StyleLuaConfig", function()
            local file =
                vim.fn.expand("~/.config/nvim/utils/linter-config/stylua.toml")
            if vim.fn.filereadable(file) == 1 then
                vim.cmd.edit(file)
            else
                vim.notify(
                    "StyleLua config file not found: " .. file,
                    vim.log.levels.ERROR
                )
            end
        end, { desc = "Edit StyleLua configuration file" })
    end,
})

return {}
