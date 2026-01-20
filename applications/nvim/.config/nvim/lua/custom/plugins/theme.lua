return {
  -- { -- You can easily change to a different colorscheme.
  --   -- Change the name of the colorscheme plugin below, and then
  --   -- change the command in the config to whatever the name of that colorscheme is.
  --   --
  --   -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  --   'folke/tokyonight.nvim',
  --   priority = 1000, -- Make sure to load this before all the other start plugins.
  --   init = function()
  --     -- Load the colorscheme here.
  --     -- Like many other themes, this one has different styles, and you could load
  --     -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
  --     vim.cmd.colorscheme 'tokyonight-night'
  --
  --     -- You can configure highlights by doing something like:
  --     vim.cmd.hi 'Comment gui=none'
  --   end,
  -- },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    init = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = function()
          local normal_float = vim.api.nvim_get_hl(0, { name = 'NormalFloat', link = false })
          local comment = vim.api.nvim_get_hl(0, { name = 'Comment', link = false })

          vim.api.nvim_set_hl(0, 'FloatBorder', {
            fg = comment.fg or normal_float.fg,
            bg = normal_float.bg,
          })
        end,
      })

      vim.cmd.colorscheme 'catppuccin'
    end,
  },
}
