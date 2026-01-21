-- options.lua
-- Neovim options configuration

-- Nerd Font support (enable for better icons)
vim.g.have_nerd_font = true

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Mouse support
vim.opt.mouse = 'a'

-- Don't show mode (shown in statusline)
vim.opt.showmode = false

-- Sync clipboard with OS
vim.opt.clipboard = 'unnamedplus'

-- Indentation
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0 -- Use tabstop value
vim.opt.softtabstop = -1 -- Use shiftwidth value
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Persistent undo
vim.opt.undofile = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- UI
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Whitespace display
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Live substitution preview
vim.opt.inccommand = 'split'

-- Disable line wrap
vim.opt.wrap = false

-- Folding (treesitter-based)
vim.opt.foldenable = false
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldnestmax = 99
