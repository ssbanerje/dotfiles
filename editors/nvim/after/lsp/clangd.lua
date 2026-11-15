---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "-j=4",
    "--all-scopes-completion",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--pch-storage=memory",
  },
}
