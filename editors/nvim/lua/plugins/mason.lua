-- Customize Mason tool list

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.run_on_start = false
      -- Note: community packs already register bash-language-server, clangd,
      -- codelldb, docker-language-server, hadolint, json-lsp, lua-language-server,
      -- ruff, selene, shellcheck, shfmt, stylua, taplo, and yaml-language-server.
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        -- Language servers
        "cmake-language-server",
        "pyright",
        "texlab",

        -- Debuggers
        "debugpy",

        -- Formatters & linters
        "prettier",
        "yamllint",
      })
    end,
  },
}
