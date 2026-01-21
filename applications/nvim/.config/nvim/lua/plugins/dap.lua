-- dap.lua
-- Debug Adapter Protocol (DAP) configuration for Go and Python

return {
  -- Core DAP
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      { '<F5>', function() require('dap').continue() end, desc = 'Debug: Continue' },
      { '<F1>', function() require('dap').step_into() end, desc = 'Debug: Step Into' },
      { '<F2>', function() require('dap').step_over() end, desc = 'Debug: Step Over' },
      { '<F3>', function() require('dap').step_out() end, desc = 'Debug: Step Out' },
      { '<F7>', function() require('dapui').toggle() end, desc = 'Debug: Toggle UI' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug: Toggle [B]reakpoint' },
      { '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end, desc = '[D]ebug: Conditional [B]reakpoint' },
      { '<leader>dc', function() require('dap').continue() end, desc = '[D]ebug: [C]ontinue' },
      { '<leader>di', function() require('dap').step_into() end, desc = '[D]ebug: Step [I]nto' },
      { '<leader>do', function() require('dap').step_over() end, desc = '[D]ebug: Step [O]ver' },
      { '<leader>dO', function() require('dap').step_out() end, desc = '[D]ebug: Step [O]ut' },
      { '<leader>dr', function() require('dap').repl.open() end, desc = '[D]ebug: [R]EPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = '[D]ebug: Run [L]ast' },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      -- Setup DAP UI
      dapui.setup({
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      })

      -- Setup virtual text
      require('nvim-dap-virtual-text').setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },

  -- Mason DAP bridge
  {
    'jay-babu/mason-nvim-dap.nvim',
    dependencies = {
      'mason-org/mason.nvim',
      'mfussenegger/nvim-dap',
    },
    opts = {
      ensure_installed = { 'delve', 'python' },
      automatic_installation = true,
      handlers = {},
    },
  },

  -- Go debugging
  {
    'leoluz/nvim-dap-go',
    dependencies = { 'mfussenegger/nvim-dap' },
    opts = {
      delve = {
        detached = vim.fn.has('win32') == 0,
      },
    },
  },

  -- Python debugging
  {
    'mfussenegger/nvim-dap-python',
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      -- Use uv for Python debugging
      require('dap-python').setup('uv')

      local dap = require('dap')
      dap.configurations.python = dap.configurations.python or {}

      -- Helper to find project venv
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

      -- Launch file with venv
      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'launch',
        name = 'Launch file (venv)',
        program = '${file}',
        pythonPath = pick_python,
        console = 'integratedTerminal',
        justMyCode = true,
      })

      -- Attach to running debugpy
      table.insert(dap.configurations.python, {
        type = 'python',
        request = 'attach',
        name = 'Attach (debugpy @ localhost:5678)',
        connect = { host = '127.0.0.1', port = 5678 },
        mode = 'remote',
      })
    end,
  },
}
