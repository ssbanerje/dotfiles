-- Use builting LSP installation
lvim.lsp.installer.automatic_servers_installation = true

-- No virtual text. Use trouble instead
lvim.lsp.diagnostics.virtual_text = false
lvim.lsp.diagnostics.float.focusable = false
lvim.lsp.float.focusable = true
lvim.lsp.diagnostics.float.source = "if_many"

-- Enable code lens refresh
lvim.lsp.code_lens_refresh = true

-- Overrides for LVIM
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "texlab" })

-- Null-LS Settings {{{

-- Helper Functions {{{
local function filter(exes)
  for k, v in pairs(exes) do
    if vim.fn.executable(v.exe) ~= 1 then
      exes[k] = nil
    end
  end
  return exes
end
-- }}}

require("lvim.lsp.null-ls.linters").setup(filter {
  {
    exe = "luacheck",
    args = { "-g" },
  },
  {
    exe = "vale",
    filetypes = {
      "markdown",
      "tex"
    },
  },
  {
    exe = "shellcheck",
    filetypes = {
      "sh",
      "bash",
      "zsh"
    },
  },
  { exe = "chktex" },
  { exe = "vint" },
})

require("lvim.lsp.null-ls.formatters").setup(filter {
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
