-- snacks.lua
-- Modern UI utilities from folke/snacks.nvim

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- Faster startup for big files
      bigfile = { enabled = true },
      -- Dashboard on startup
      dashboard = { enabled = false },
      -- Modern input/select UI
      input = { enabled = true },
      -- Notifications
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      -- Quick file opening
      quickfile = { enabled = true },
      -- Better statuscolumn
      statuscolumn = { enabled = false },
      -- Highlight word under cursor
      words = { enabled = true },
    },
    keys = {
      { '<leader>n', function() Snacks.notifier.show_history() end, desc = 'Show [N]otification History' },
      { '<leader>un', function() Snacks.notifier.hide() end, desc = 'Dismiss All Notifications' },
    },
  },
}
