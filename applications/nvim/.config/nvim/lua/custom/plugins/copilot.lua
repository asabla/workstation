return {
  {
    'github/copilot.vim',
    config = function()
      -- Makes sure we're able to accept suggestions with M-m instead of tab
      vim.g.copilot_no_tab_map = true

      vim.keymap.set('i', '<M-m>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })
    end,
  },
}
