-- kubectl.lua
-- Kubernetes management

return {
  {
    'ramilito/kubectl.nvim',
    keys = {
      { '<leader>k', '<cmd>lua require("kubectl").toggle()<cr>', desc = 'Toggle [K]ubectl' },
      { 'dd', '<Plug>(kubectl.kill)', ft = 'k8s_*' },
    },
    opts = {},
  },
}
