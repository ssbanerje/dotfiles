---@type vim.lsp.Config
return {
  settings = {
    texlab = {
      auxDirectory = "build",
      bibtexFormatter = "texlab",
      chktex = {
        onOpenAndSave = true,
        onEdit = true,
      },
      formatterLineLength = 120,
    },
  },
}
