return {
  {
    'ramilito/kubectl.nvim',
    config = function()
      require('kubectl').setup()
    end,
    keys = {
      { 'dd', '<Plug>(kubectl.kill)', ft = 'k8s_*' },
    },
  },
}
