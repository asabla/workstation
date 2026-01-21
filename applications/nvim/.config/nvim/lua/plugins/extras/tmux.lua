-- tmux.lua
-- Tmux navigation integration

return {
  {
    'alexghergh/nvim-tmux-navigation',
    event = 'VeryLazy',
    opts = {
      disable_when_zoomed = false,
      -- Swedish keyboard layout navigation
      keybindings = {
        left = '<M-j>',
        down = '<M-k>',
        up = '<M-l>',
        right = '<M-ö>',
      },
    },
  },
}
