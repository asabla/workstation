-- trouble.lua
-- Diagnostics list and quickfix

return {
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'Trouble',
    keys = {
      { '<leader>tt', '<cmd>Trouble diagnostics toggle<cr>', desc = '[T]oggle [T]rouble' },
      { '<leader>tq', '<cmd>Trouble quickfix toggle<cr>', desc = '[T]oggle Trouble [Q]uickfix' },
      { '<leader>tl', '<cmd>Trouble loclist toggle<cr>', desc = '[T]oggle Trouble [L]oclist' },
      { '<leader>ts', '<cmd>Trouble symbols toggle focus=false<cr>', desc = '[T]oggle [S]ymbols' },
    },
    opts = {
      action_keys = {
        close = 'q',
        hover = 'K',
        -- Swedish layout navigation
        previous = 'l',
        next = 'k',
      },
    },
  },
}
