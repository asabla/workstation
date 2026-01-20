return {
  -- Core DAP
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio', -- required by dap-ui
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      {
        '<leader>dc',
        function()
          require('dap').continue()
        end,
        desc = 'DAP Continue',
      },
      {
        '<leader>do',
        function()
          require('dap').step_over()
        end,
        desc = 'DAP Step Over',
      },
      {
        '<leader>di',
        function()
          require('dap').step_into()
        end,
        desc = 'DAP Step Into',
      },
      {
        '<leader>dO',
        function()
          require('dap').step_out()
        end,
        desc = 'DAP Step Out',
      },
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'DAP Toggle Breakpoint',
      },
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input 'Condition: ')
        end,
        desc = 'DAP Conditional Breakpoint',
      },
      {
        '<leader>dr',
        function()
          require('dap').repl.open()
        end,
        desc = 'DAP REPL',
      },
      {
        '<leader>dl',
        function()
          require('dap').run_last()
        end,
        desc = 'DAP Run Last',
      },
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      dapui.setup()
      require('nvim-dap-virtual-text').setup()

      -- Auto-open/close UI
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },

  -- Bridge Mason <-> nvim-dap, installs debug adapters like "python" -> "debugpy"
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = { 'williamboman/mason.nvim', 'mfussenegger/nvim-dap' },
    config = function()
      require('mason-nvim-dap').setup {
        ensure_installed = { 'python' }, -- maps to debugpy
        automatic_installation = true,
      }
    end,
  },

  -- Python convenience layer (configs + test helpers)
  {
    'mfussenegger/nvim-dap-python',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      -- Use Mason's debugpy *adapter* Python to host the adapter:
      local mason_path = vim.fn.stdpath 'data'
      local debugpy_python = mason_path .. '/mason/packages/debugpy/venv/bin/python'

      -- require('dap-python').setup(debugpy_python)
      require('dap-python').setup 'uv'

      -- Make launched programs use your PROJECT interpreter (venv) for imports.
      local dap = require 'dap'
      dap.configurations.python = dap.configurations.python or {}

      local function pick_python()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
          return cwd .. '/.venv/bin/python'
        elseif vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
          return cwd .. '/venv/bin/python'
        else
          return 'python3'
        end
      end

      -- Override/append a common “Launch file” config
      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'launch',
        name = 'Launch file (venv)',
        program = '${file}',
        pythonPath = pick_python,
        console = 'integratedTerminal',
        justMyCode = true,
      })

      -- Optional: attach to an already-running debugpy server
      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'attach',
        name = 'Attach (debugpy @ localhost:5678)',
        connect = { host = '127.0.0.1', port = 5678 },
        mode = 'remote',
      })
    end,
  },

  -- Go-specific configs + helpers (debug test, etc.)
  {
    'leoluz/nvim-dap-go',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('dap-go').setup()
      -- Optional helpers:
      -- vim.keymap.set("n", "<leader>dt", function() require("dap-go").debug_test() end, { desc = "Debug Go test" })
      -- vim.keymap.set("n", "<leader>dT", function() require("dap-go").debug_last_test() end, { desc = "Debug last Go test" })
    end,
  },
}
