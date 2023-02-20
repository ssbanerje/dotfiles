require("lvim.lsp.manager").setup("yamlls", {
  settings = {
    yaml = {
      hover = true,
      completion = true,
      validate = true,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = {
        ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
        ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
        ["http://json.schemastore.org/gitlab-ci"] = "*lab-ci.{yml,yaml}",
        ["https://json.schemastore.org/pre-commit-config.json"] = ".pre-commit-config.{yml,yaml}",
        kubernetes = {
          "daemon.{yml,yaml}",
          "manager.{yml,yaml}",
          "restapi.{yml,yaml}",
          "kubectl-edit*.yaml",
        },
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/configmap.json"] = "*onfigma*.{yml,yaml}",
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/deployment.json"] = "*eployment*.{yml,yaml}",
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/service.json"] = "*ervic*.{yml,yaml}",
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/ingress.json"] = "*ngres*.{yml,yaml}",
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/master/secret.json"] = "*ecre*.{yml,yaml}",
      },
    },
  },
})
