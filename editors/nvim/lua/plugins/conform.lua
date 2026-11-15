-- Async buffer formatting via conform.nvim (replaces none-ls formatting)

local clang_format = { "clang-format" }
local prettier = { "prettier" }

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false },
  {
    "stevearc/conform.nvim",
    opts = {
      -- Note: `lua` (stylua), `python` (ruff), and `sh`/`zsh` (shfmt) are configured by community packs.
      formatters_by_ft = {
        c = clang_format,
        cpp = clang_format,
        json = prettier,
        jsonc = prettier,
        markdown = prettier,
        yaml = prettier,
      },
    },
  },
}
