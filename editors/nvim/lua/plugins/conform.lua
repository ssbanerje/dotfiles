-- Async buffer formatting via conform.nvim (replaces none-ls formatting)

local clang_format = { "clang-format" }
local prettier = { "prettier" }
local shfmt = { "shfmt" }

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  {
    "stevearc/conform.nvim",
    opts = {
      -- Note: `lua` (stylua), `python` (ruff), and `yaml` (prettier) are configured by community packs.
      formatters_by_ft = {
        bash = shfmt,
        c = clang_format,
        cpp = clang_format,
        json = prettier,
        jsonc = prettier,
        markdown = prettier,
        sh = shfmt,
        zsh = shfmt,
      },
    },
  },
}
