-- init.lua
-- Neovim configuration entry point

-- Set leader key (must be before plugins)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Load configuration
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.lazy')

-- Neovide-specific settings
if vim.g.neovide then
  vim.g.neovide_input_macos_option_key_is_meta = 'both'
end

-- vim: ts=2 sts=2 sw=2 et
