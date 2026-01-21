-- copilot.lua
-- GitHub Copilot integration

return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    config = function()
      -- Disable tab mapping (use Alt-m instead)
      vim.g.copilot_no_tab_map = true

      vim.keymap.set('i', '<M-m>', 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        desc = 'Accept Copilot suggestion',
      })
    end,
  },
}
