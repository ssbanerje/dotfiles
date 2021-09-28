lvim.builtin.dap.active = true

lvim.builtin.dap.on_config_done = function(dap)
  -- Setup adapters
  dap.adapters.lldb = {
    type = "executable",
    attach = { pidProperty = "pid", pidSelect = "ask" },
    command = "lldb-vscode",
    name = "lldb",
    env = { LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES" },
  }
  dap.adapters.python = {
    type = 'executable';
    command = 'python';
    args = { '-m', 'debugpy.adapter' };
  }

  -- Setup configurations
  dap.configurations.cpp = {
    {
      name = "Launch executable",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = true,
      args = {},
      runInTerminal = false,
      env = function()
        local variables = {}
        for k, v in pairs(vim.fn.environ()) do
          table.insert(variables, string.format("%s=%s", k, v))
        end
        return variables
      end
    },
    {
      name = "Attach to process",
      type = 'lldb',
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
    },
  }
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
  dap.configurations.python = {
    {
      name = "Launch file",
      type = 'python',
      request = 'launch',
      program = "${file}";
      pythonPath = function()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
          return cwd .. '/venv/bin/python'
        elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
          return cwd .. '/.venv/bin/python'
        else
          return 'python'
        end
      end;
    },
  }

  -- Setup signs
  -- TODO FIX Delete when signs are mergerd into Lunarvim
  vim.fn.sign_define("DapStopped", {
    text = "",
    texthl = "LspDiagnosticsDefaultHint",
    linehl = "DiagnosticUnderlineInfo",
    numhl = "LspDiagnosticsDefaultHint",
  })
end
