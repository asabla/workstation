-- rest.lua
-- REST client for HTTP requests

return {
  {
    'rest-nvim/rest.nvim',
    ft = 'http',
    keys = {
      { '<leader>rr', '<cmd>Rest run<cr>', desc = '[R]est [R]un request' },
      { '<leader>rl', '<cmd>Rest run last<cr>', desc = '[R]est Run [L]ast' },
    },
    opts = {},
  },
}
