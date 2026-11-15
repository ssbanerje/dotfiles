-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Fix common Ex-command typos only at command-line position 0
local abbreviations = {
  W1 = "W!",
  w1 = "w!",
  ["Q!"] = "q!",
  Q1 = "q!",
  q1 = "q!",
  ["Qa!"] = "qa!",
  ["Qall!"] = "qall!",
  Wa = "wa",
  Wq = "wq",
  wQ = "wq",
  WQ = "wq",
  wq1 = "wq!",
  Wq1 = "wq!",
  wQ1 = "wq!",
  WQ1 = "wq!",
  Q = "q",
  Qa = "qa",
  qA = "qa",
  Qall = "qall",
}

for k, v in pairs(abbreviations) do
  vim.keymap.set("ca", k, function()
    return vim.fn.getcmdtype() == ":" and vim.fn.getcmdline() == k and v or k
  end, { expr = true })
end

-- Dotfiles CLI (`bin/dot`) integration commands
local function resolve_dot()
  if vim.fn.executable("dot") == 1 then
    return vim.fn.exepath("dot")
  end
  local repo_root = vim.fs.dirname(vim.fs.dirname(vim.fn.resolve(vim.fn.stdpath("config"))))
  for _, candidate in ipairs({
    vim.fn.expand("~/.local/bin/dot"),
    repo_root .. "/bin/dot",
  }) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

local function run_dot(subcmd, extra_args)
  local bin = resolve_dot()
  if not bin then
    require("astrocore").notify("`dot` CLI not found on PATH", vim.log.levels.ERROR)
    return
  end
  local argv = { bin, subcmd }
  if extra_args and extra_args ~= "" then
    vim.list_extend(argv, vim.split(extra_args, "%s+", { trimempty = true }))
  end
  require("astrocore").notify(("Running `dot %s`..."):format(subcmd))
  vim.system(
    argv,
    { text = true },
    vim.schedule_wrap(function(res)
      local out = vim.trim(((res.stdout or "") .. "\n" .. (res.stderr or "")))
      local level = res.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      require("astrocore").notify(
        out ~= "" and out or ("`dot %s` exited with code %d"):format(subcmd, res.code),
        level,
        { title = ("dot %s"):format(subcmd) }
      )
    end)
  )
end

vim.api.nvim_create_user_command("DotDoctor", function(args)
  run_dot("doctor", args.args)
end, { nargs = "*", desc = "Run `dot doctor` health check" })

vim.api.nvim_create_user_command("DotBench", function(args)
  run_dot("bench", args.args)
end, { nargs = "?", desc = "Run `dot bench` startup benchmark" })

vim.api.nvim_create_user_command("DotSync", function(args)
  run_dot("sync", args.args)
end, { nargs = "*", desc = "Run `dot sync` to refresh symlinks and templates" })

-- Machine-local overrides (untracked; auto-discovered by `dot doctor`)
local local_cfg = vim.fn.expand("~/.config/nvim.local.lua")
if (vim.uv or vim.loop).fs_stat(local_cfg) then
  dofile(local_cfg)
end
