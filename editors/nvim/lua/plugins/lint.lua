-- Async diagnostics via nvim-lint (replaces none-ls diagnostics)

---@type LazySpec
return {
  "mfussenegger/nvim-lint",
  opts = {
    -- Note: `dockerfile` (hadolint) and `lua` (selene) are configured by
    -- community packs, and AstroCommunity skips linters missing from PATH.
    linters_by_ft = {
      markdown = { "vale" },
      tex = { "vale" },
      text = { "vale" },
      yaml = { "yamllint" },
    },
  },
}
