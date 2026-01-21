-- editor.lua
-- Core editing plugins

return {
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Comment toggling
  {
    'numToStr/Comment.nvim',
    opts = {
      padding = true,
      toggler = {
        line = '<C-k><C-k>',
      },
      opleader = {
        line = '<C-k><C-k>',
      },
    },
  },

  -- Highlight TODO, NOTE, etc in comments
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
}
