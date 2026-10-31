-- Customize Mason tool list

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.run_on_start = false
      -- Note: community packs already register lua-language-server, stylua,
      -- ruff, codelldb, yaml-language-server, docker-language-server, hadolint.
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        -- Language servers
        "bash-language-server",
        "clangd",
        "cmake-language-server",
        "json-lsp",
        "pyright",
        "texlab",
        "vim-language-server",

        -- Debuggers
        "debugpy",

        -- Formatters
        "prettier",
        "shfmt",

        -- Linters
        "shellcheck",
        "yamllint",
      })
    end,
  },
}
