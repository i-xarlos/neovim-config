-- Visual
vim.o.conceallevel = 0 -- Don't hide quotes in markdown
vim.o.cmdheight = 1
vim.o.pumheight = 10
vim.o.showmode = false
vim.o.showtabline = 2 -- Always show tab line
vim.o.title = true
vim.o.lazyredraw = true
vim.o.encoding = "utf-8"
vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = "yes"
vim.wo.cursorline = true
vim.wo.colorcolumn = "140"

-- Behaviour
vim.o.hlsearch = false
vim.o.ignorecase = true -- Ignore case when using lowercase in search
vim.o.smartcase = true -- But don't ignore it when using upper case
vim.o.smarttab = true
vim.o.smartindent = true
vim.o.expandtab = true -- Convert tabs to spaces.
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.scrolloff = 12 -- Minimum offset in lines to screen borders
vim.o.sidescrolloff = 8
vim.o.mouse = "a"
vim.o.swapfile = false

-- Vim specific
vim.o.hidden = true -- Do not save when switching buffers
vim.o.backup = false
vim.o.swapfile = false -- Don't create Swap Files
vim.o.fileencoding = "utf-8"
vim.opt.spell = true -- Enable spell checking
vim.opt.spelllang = { "en_us" } -- Default to English (auto-detected per file)
vim.opt.spelloptions = "camel"
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0
vim.o.completeopt = "menuone,noinsert,noselect"
vim.o.wildmode = "longest,full" -- Display auto-complete in Command Mode
vim.opt.wildignore:append({ "*/backup/*" })
vim.o.undofile = true -- Save undo history
vim.o.updatetime = 250 -- Decrease update time
vim.o.timeoutlen = 250 -- Time for mapped sequence to complete (in ms)
vim.o.inccommand = "nosplit" -- Incremental live completion
vim.g.do_file_type_lua = 1
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
vim.opt.shortmess:append({ W = true, a = true })
--vim.opt.cursorcolumn     = true
vim.o.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.o.tags = "./tags;/,~/.vimtags"

-- Disable some default plugins
vim.g.loaded_gzip = false
vim.g.loaded_matchit = false
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_tarPlugin = false
vim.g.loaded_zipPlugin = false
vim.g.loaded_man = false
vim.g.loaded_2html_plugin = false
vim.g.loaded_remote_plugins = false
vim.g.did_load_filetypes = false

-- Python providers
--local pynvim_env        = "/.local/bin/pyenv/versions/pynvim/"
--vim.g.python3_host_prog = "C:\Python310\python.exe"
--vim.g.python3_host_prog = os.getenv("HOME")..pynvim_env.."/bin/python"
--vim.g.black_virtualenv  = os.getenv("HOME")..pynvim_env

-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Nvimtree defaults
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 0

-- in millisecond, used for both CursorHold and CursorHoldI,
-- use update time instead if not defined
vim.g.cursorhold_updatetime = 100

-- If the current system shell or the `shell` option is set to /usr/bin/fish then revert to sh
if
    os.getenv("SHELL") == "/usr/bin/fish"
    or vim.opt.shell == "/usr/bin/fish"
then
    vim.opt.shell = "/bin/sh"
else
    -- Else default to the system current shell.
    vim.opt.shell = os.getenv("SHELL")
end

local is_windows = vim.loop.os_uname().version:match("Windows")

--Shell usage
if is_windows then
    vim.opt.shell = "pwsh"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -Command"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
else
    vim.opt.shell = "/bin/bash"
    vim.opt.shellcmdflag = "-c"
end

vim.o.sessionoptions =
    "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Set the background (dark or light)
vim.o.background = "dark"

local function path_exists(path)
    local f = vim.loop.fs_stat(path)
    if f ~= nil then
        return true
    else
        return false
    end
end

-- Add node to path for windows copilot
local node_path = vim.fn.expand("C:\\ProgramData\\nvm\\v24.9.0\\")

if path_exists(node_path) then
    vim.env.PATH = node_path .. ";" .. vim.env.PATH
end
