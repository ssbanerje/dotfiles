-- Use builting LSP installation
lvim.lsp.automatic_servers_installation = true

-- No virtual text. Use trouble instead
lvim.lsp.diagnostics.virtual_text = false

-- Overrides for LVIM
vim.list_extend(lvim.lsp.override, {
  "dockerls",
  "rust_analyzer",
  "sumneko_lua",
  "texlab",
  "yamlls",
})

-- Linters {{{

local linters = require("lvim.lsp.null-ls.linters")
linters.setup({
  {
    exe = "luacheck",
    args = { "-g" },
  },
  {
    exe = "vale",
    filetypes = { "markdown", "tex" },
  },
  {
    exe = "shellcheck",
    filetypes = { "sh", "bash", "zsh" },
  },
  { exe = "chktex" },
  { exe = "vint" },
})

-- }}}

-- Formatters {{{

local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup({
  { exe = "stylua" },
  {
    exe = "prettier",
    filetypes = {
      "css",
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "json",
      "markdown",
      "yaml",
    },
  },
  { exe = "yapf" },
  {
    exe = "isort",
    args = { "--profile", "black" },
  },
  { exe = "rustfmt" },
  { exe = "shfmt" },
})

-- }}}

-- vim:set fdm=marker:
