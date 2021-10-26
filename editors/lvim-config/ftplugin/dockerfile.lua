require("lvim.lsp.manager").setup("dockerls", {
  root_dir = function(fname)
    return require("lspconfig").util.root_pattern(".git")(fname) or require("lspconfig").util.path.dirname(fname)
  end,
})
