---@type vim.lsp.Config
return {
  settings = {
    yaml = {
      schemas = {
        kubernetes = { "*.k8s.yml", "*.k8s.yaml" },
      },
    },
  },
}
