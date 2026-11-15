-- Async diagnostics via nvim-lint (replaces none-ls diagnostics)

local MAX_LINT_BYTES = 1024 * 1024

local function toggle_buffer_lint()
  require("lazy").load({ plugins = { "nvim-lint" } })
  local lint = require("lint")
  local buf = vim.api.nvim_get_current_buf()
  local enabled = vim.b[buf].lint_enabled == false
  vim.b[buf].lint_enabled = enabled
  if enabled then
    lint.try_lint()
  else
    for name, _ in pairs(lint.linters) do
      pcall(vim.diagnostic.reset, lint.get_namespace(name), buf)
    end
  end
  require("astrocore").notify(("Buffer linting %s"):format(enabled and "enabled" or "disabled"))
end

local function show_lint_info()
  require("lazy").load({ plugins = { "nvim-lint" } })
  local lint = require("lint")
  local ft = vim.bo.filetype
  local configured = lint.linters_by_ft[ft] or {}
  local active = lint._resolve_linter_by_ft(ft)
  local state = vim.b.lint_enabled == false and "disabled" or "enabled"
  local lines = {
    ("Filetype: %s (buffer linting %s)"):format(ft ~= "" and ft or "<none>", state),
    ("Configured: %s"):format(#configured > 0 and table.concat(configured, ", ") or "none"),
    ("Executable: %s"):format(#active > 0 and table.concat(active, ", ") or "none"),
  }
  require("astrocore").notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "nvim-lint" })
end

---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  init = function()
    require("astrocore").on_load("nvim-lint", function()
      local lint = require("lint")
      lint.try_lint = require("astrocore").patch_func(lint.try_lint, function(orig, ...)
        local buf = vim.api.nvim_get_current_buf()
        if vim.b[buf].lint_enabled == false then
          return
        end
        local name = vim.api.nvim_buf_get_name(buf)
        local stat = name ~= "" and (vim.uv or vim.loop).fs_stat(name) or nil
        if stat and stat.size > MAX_LINT_BYTES then
          return
        end
        return orig(...)
      end)
    end)
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        commands = {
          LintToggle = { toggle_buffer_lint, desc = "Toggle nvim-lint for current buffer" },
          LintInfo = { show_lint_info, desc = "Show active nvim-lint linters for current buffer" },
        },
        mappings = {
          n = {
            ["<Leader>uT"] = { toggle_buffer_lint, desc = "Toggle buffer linting" },
          },
        },
      },
    },
  },
  opts = {
    -- Note: `dockerfile` (hadolint), `lua` (selene), and `sh`/`zsh` (shellcheck)
    -- are configured by community packs, and AstroCommunity skips linters missing from PATH.
    linters_by_ft = {
      markdown = { "vale" },
      tex = { "vale" },
      text = { "vale" },
      yaml = { "yamllint" },
    },
  },
}
