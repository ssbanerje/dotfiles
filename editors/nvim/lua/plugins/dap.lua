local function resolve_python_path()
  local venv = os.getenv("VIRTUAL_ENV")
  if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
    return venv .. "/bin/python"
  end

  local cwd = vim.fn.getcwd()
  if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
    return cwd .. "/.venv/bin/python"
  end
  if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
    return cwd .. "/venv/bin/python"
  end

  local mason_py = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
  if vim.fn.executable(mason_py) == 1 then
    return mason_py
  end

  if vim.fn.executable("python3") == 1 then
    return vim.fn.exepath("python3")
  end
  return "python"
end

---@type LazySpec
return {
  "mfussenegger/nvim-dap",
  optional = true,
  config = function(plugin, opts)
    local astro_dap = pcall(require, "astronvim.plugins.configs.nvim-dap")
    if astro_dap then
      require("astronvim.plugins.configs.nvim-dap")(plugin, opts)
    end

    local dap = require("dap")

    -- Python (debugpy)
    local adapter_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    if vim.fn.executable(adapter_python) ~= 1 then
      local uv_debugpy = vim.fn.expand("~/.local/share/uv/tools/debugpy/bin/python")
      if vim.fn.executable(uv_debugpy) == 1 then
        adapter_python = uv_debugpy
      else
        adapter_python = vim.fn.executable("python3") == 1 and vim.fn.exepath("python3") or "python"
      end
    end
    dap.adapters.python = {
      type = "executable",
      command = adapter_python,
      args = { "-m", "debugpy.adapter" },
    }
    dap.configurations.python = {
      {
        type = "python",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        pythonPath = resolve_python_path,
      },
    }

    -- C / C++ / Rust (codelldb, lldb-dap, or lldb-vscode)
    local adapter_name = nil
    local mason_codelldb = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
    local codelldb = vim.fn.executable(mason_codelldb) == 1 and mason_codelldb
      or (vim.fn.executable("codelldb") == 1 and vim.fn.exepath("codelldb") or nil)
    if codelldb then
      adapter_name = "codelldb"
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = codelldb,
          args = { "--port", "${port}" },
        },
      }
    else
      local lldb_bin = (vim.fn.executable("lldb-dap") == 1 and vim.fn.exepath("lldb-dap"))
        or (vim.fn.executable("lldb-vscode") == 1 and vim.fn.exepath("lldb-vscode"))
        or nil
      if lldb_bin then
        adapter_name = "lldb"
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_bin,
          name = "lldb",
        }
      end
    end

    if adapter_name then
      local native_configs = {
        {
          name = "Launch file",
          type = adapter_name,
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Attach to process",
          type = adapter_name,
          request = "attach",
          pid = require("dap.utils").pick_process,
          args = {},
        },
      }
      dap.configurations.c = native_configs
      dap.configurations.cpp = native_configs
      dap.configurations.rust = native_configs
    end
  end,
}
