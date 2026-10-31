-- Async buffer formatting via conform.nvim (replaces none-ls formatting)

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false },
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  {
    "stevearc/conform.nvim",
    opts = {
      -- Note: `lua` (stylua) and `python` (ruff) are configured by community packs.
      formatters_by_ft = {
        bash = { "shfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        json = { "prettier" },
        jsonc = { "prettier" },
        markdown = { "prettier" },
        sh = { "shfmt" },
        yaml = { "prettier" },
        zsh = { "shfmt" },
      },
    },
  },
}
