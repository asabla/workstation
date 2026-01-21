-- ui.lua
-- UI plugins: theme, statusline, which-key, indent guides

return {
  -- Colorscheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    init = function()
      -- Fix FloatBorder to match colorscheme
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

  -- Icons
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Which-key for keybinding hints
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {},
    config = function()
      local wk = require 'which-key'
      wk.setup()
      wk.add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ebug/DAP' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]orkspace' },
      }
      wk.add({
        { '<leader>h', group = 'Git [H]unk' },
      }, { mode = 'v' })
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Mini.nvim modules
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      require('mini.ai').setup { n_lines = 500 }

      -- Statusline
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- Custom cursor location format
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}
