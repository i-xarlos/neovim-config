-- User commands to enhance workflow

-- Function to detect document language and set spell checker
local function detect_and_set_language()
    local filename = vim.fn.expand("%:t")
    local current_buf = vim.api.nvim_get_current_buf()
    
    -- Check if filename contains language markers (e.g., document.es.md)
    if filename:match("%.es%.") or filename:match("_es%.") then
        vim.opt_local.spelllang = { "es" }
        vim.notify("Spell checker set to Spanish", vim.log.levels.INFO)
        return
    end
    
    -- Check if filename contains English markers
    if filename:match("%.en%.") or filename:match("_en%.") then
        vim.opt_local.spelllang = { "en_us" }
        vim.notify("Spell checker set to English", vim.log.levels.INFO)
        return
    end
    
    -- Detect by analyzing content - check for Spanish words
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, 100, false)
    local content = table.concat(lines, " "):lower()
    
    -- Common Spanish words
    local spanish_words = { "el ", "la ", "de ", "que ", "y ", "es ", "por ", "para ", "con ", "los ", "las " }
    local english_words = { " the ", " and ", " is ", " in ", " to ", " of ", " a ", " for ", " with " }
    
    local spanish_count = 0
    local english_count = 0
    
    for _, word in ipairs(spanish_words) do
        if content:find(word) then spanish_count = spanish_count + 1 end
    end
    
    for _, word in ipairs(english_words) do
        if content:find(word) then english_count = english_count + 1 end
    end
    
    -- Set language based on detection
    if spanish_count > english_count and spanish_count > 3 then
        vim.opt_local.spelllang = { "es" }
        vim.b.detected_language = "spanish"
    else
        vim.opt_local.spelllang = { "en_us" }
        vim.b.detected_language = "english"
    end
end

-- Autocommand to detect language on file open/read
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.md", "*.txt", "*.tex", "*.rst" },
    callback = detect_and_set_language,
    desc = "Auto-detect document language for spell checker",
})

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

        -- Command to manually set spell language
        vim.api.nvim_create_user_command("SetSpellLang", function(opts)
            local lang = opts.args
            if lang == "es" or lang == "spanish" then
                vim.opt_local.spelllang = { "es" }
                vim.notify("Spell checker set to Spanish", vim.log.levels.INFO)
            elseif lang == "en" or lang == "english" then
                vim.opt_local.spelllang = { "en_us" }
                vim.notify("Spell checker set to English", vim.log.levels.INFO)
            else
                vim.notify("Usage: SetSpellLang es|en", vim.log.levels.WARN)
            end
        end, { nargs = 1, desc = "Set spell language (es|en)" })

        -- Command to auto-detect language
        vim.api.nvim_create_user_command("DetectSpellLang", detect_and_set_language, { 
            desc = "Auto-detect and set spell language" 
        })
    end,
})

return {}
