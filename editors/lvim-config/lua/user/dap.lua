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
    type = "executable",
    command = "python",
    args = { "-m", "debugpy.adapter" },
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
      end,
    },
    {
      name = "Attach to process",
      type = "lldb",
      request = "attach",
      pid = require("dap.utils").pick_process,
      args = {},
    },
  }

  dap.configurations.c = dap.configurations.cpp

  dap.configurations.rust = dap.configurations.cpp

  dap.configurations.python = {
    {
      name = "Launch file",
      type = "python",
      request = "launch",
      program = "${file}",
      pythonPath = function()
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
          return cwd .. "/venv/bin/python"
        elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        else
          return "python"
        end
      end,
    },
  }

  dap.configurations.lua = {
    {
      type = "nlua",
      request = "attach",
      name = "Neovim attach",
      host = function()
        local value = vim.fn.input "Host [127.0.0.1]: "
        if value ~= "" then
          return value
        end
        return "127.0.0.1"
      end,
      port = function()
        local val = tonumber(vim.fn.input "Port: ")
        assert(val, "Please provide a port number")
        return val
      end,
    },
  }

  -- lvim.builtin.which_key.mappings.d.f = { "<cmd>lua require('dapui').float_element()", "Floating element" }
  -- lvim.builtin.which_key.mappings.d.x = { "<cmd>lua require('dapui').toggle()<cr>", "Run DAP-UI" }
  -- lvim.builtin.which_key.vmappings.d.e = { ":lua require('dapui').eval()<cr>", "Evaluate expression" }
end
