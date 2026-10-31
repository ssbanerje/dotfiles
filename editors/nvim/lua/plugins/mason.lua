-- Customize Mason

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.run_on_start = false
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        -- Language servers
        "bash-language-server",
        "clangd",
        "cmake-language-server",
        "dockerfile-language-server",
        "json-lsp",
        "lua-language-server",
        "pyright",
        "texlab",
        "vim-language-server",
        "yaml-language-server",

        -- Debuggers
        "codelldb",
        "debugpy",

        -- Formatters
        "isort",
        "prettier",
        "shfmt",
        "stylua",
        "yapf",

        -- Linters
        "shellcheck",
        "vint",
        "yamllint",
      })
    end,
  },
}
