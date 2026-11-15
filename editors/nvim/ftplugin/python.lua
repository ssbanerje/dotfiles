local function project_root()
  return vim.fs.root(0, { "pyproject.toml", "pytest.ini", "setup.cfg", ".git" }) or vim.fn.getcwd()
end

local function run_pytest(target)
  local root = project_root()
  local cmd
  if vim.fn.executable("uv") == 1 and (vim.uv or vim.loop).fs_stat(root .. "/pyproject.toml") then
    cmd = { "uv", "run", "pytest", "-v", target }
  else
    cmd = { "pytest", "-v", target }
  end
  require("snacks").terminal.open(cmd, { cwd = root, auto_close = false })
end

local function nearest_pytest_target()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return nil
  end

  local func_name, class_name
  local ok, node = pcall(vim.treesitter.get_node)
  if ok and node then
    local cur = node
    while cur do
      local t = cur:type()
      if t == "function_definition" and not func_name then
        local name_node = cur:field("name")[1]
        if name_node then
          func_name = vim.treesitter.get_node_text(name_node, 0)
        end
      elseif t == "class_definition" and not class_name then
        local name_node = cur:field("name")[1]
        if name_node then
          class_name = vim.treesitter.get_node_text(name_node, 0)
        end
      end
      cur = cur:parent()
    end
  end

  if not func_name then
    local row = vim.api.nvim_win_get_cursor(0)[1]
    for i = row, 1, -1 do
      local line = vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1] or ""
      local fn = line:match("^%s*async%s+def%s+([%w_]+)") or line:match("^%s*def%s+([%w_]+)")
      if fn and not func_name then
        func_name = fn
      end
      local cls = line:match("^class%s+([%w_]+)")
      if cls then
        class_name = cls
        break
      end
    end
  end

  if class_name and func_name then
    return ("%s::%s::%s"):format(file, class_name, func_name)
  elseif func_name then
    return ("%s::%s"):format(file, func_name)
  end
  return file
end

local function switch_alt_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return
  end
  local root = project_root()
  local base = vim.fs.basename(file)
  local is_test = base:match("^test_(.+)%.py$") or base:match("^(.+)_test%.py$")

  if is_test then
    local target = is_test .. ".py"
    local matches = vim.fs.find(function(name, path)
      if path:find("/%.venv/") or path:find("/venv/") or path:find("/tests?/") then
        return false
      end
      return name == target
    end, { path = root, type = "file", limit = 5 })
    if matches[1] then
      vim.cmd.edit(vim.fn.fnameescape(matches[1]))
    else
      require("astrocore").notify(("No implementation file found for %s"):format(target), vim.log.levels.WARN)
    end
    return
  end

  local stem = base:gsub("%.py$", "")
  local candidates = { ("test_%s.py"):format(stem), ("%s_test.py"):format(stem) }
  local matches = vim.fs.find(function(name, path)
    if path:find("/%.venv/") or path:find("/venv/") then
      return false
    end
    return vim.tbl_contains(candidates, name)
  end, { path = root, type = "file", limit = 5 })

  if matches[1] then
    vim.cmd.edit(vim.fn.fnameescape(matches[1]))
  else
    local fallback = ("%s/tests/test_%s.py"):format(root, stem)
    vim.cmd.edit(vim.fn.fnameescape(fallback))
  end
end

local function toggle_repl()
  local cmd = vim.fn.executable("ipython") == 1 and { "ipython", "--TerminalInteractiveShell.editing_mode=vi" }
    or { "python3" }
  require("snacks").terminal.toggle(cmd, { cwd = project_root() })
end

vim.api.nvim_buf_create_user_command(0, "PyTestFunc", function()
  local target = nearest_pytest_target()
  if target then
    run_pytest(target)
  end
end, { desc = "Run nearest pytest test function/class" })

vim.api.nvim_buf_create_user_command(0, "PyTestFile", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    run_pytest(file)
  end
end, { desc = "Run pytest on current file" })

vim.api.nvim_buf_create_user_command(0, "PyAlt", switch_alt_file, {
  desc = "Toggle between Python module and test file",
})

vim.api.nvim_buf_create_user_command(0, "PyRepl", toggle_repl, {
  desc = "Toggle Python / IPython REPL",
})

vim.keymap.set("n", "<LocalLeader>tf", "<Cmd>PyTestFunc<CR>", { buffer = 0, desc = "Pytest nearest function" })
vim.keymap.set("n", "<LocalLeader>tt", "<Cmd>PyTestFile<CR>", { buffer = 0, desc = "Pytest current file" })
vim.keymap.set("n", "<LocalLeader>a", "<Cmd>PyAlt<CR>", { buffer = 0, desc = "Alternate module/test file" })
vim.keymap.set("n", "<LocalLeader>r", "<Cmd>PyRepl<CR>", { buffer = 0, desc = "Toggle IPython REPL" })
