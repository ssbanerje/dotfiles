-- Helper Functions {{{

-- Filter commands for linters and formatters
local function check_execs(exes)
  for k, exe in pairs(exes) do
    if vim.fn.executable(exe.exe) ~= 1 then
      exes[k] = nil
    end
  end
  return exes
end

-- Setup Linters
local function setup_linters(linters)
  for lang, exes in pairs(linters) do
    lvim.lang[lang].linters = check_execs(exes)
  end
end

-- Setup Formatters
local function setup_formatters(formatters)
  for lang, exes in pairs(formatters) do
    lvim.lang[lang].formatters = check_execs(exes)
  end
end

-- }}}

-- LSP Settings {{{

-- Use builting LSP installation
lvim.lsp.automatic_servers_installation = true

-- No virtual text. Use trouble instead
lvim.lsp.diagnostics.virtual_text = false

-- Overrides for LVIM
lvim.lsp.override = { "dockerls", "rust_analyzer", "sumneko_lua", "texlab", "yamlls" }

local custom_lsp_configs = {
  -- DockerLS {{{
  dockerls = {
    root_dir = function(fname)
      return require("lspconfig").util.root_pattern(".git")(fname) or require("lspconfig").util.path.dirname(fname)
    end,
    filetypes = { "Dockerfile*", "dockerfile*" }
  },
  -- }}}
  -- Sumneko_Lua {{{
  sumneko_lua = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "lvim", "hs" },
        },
        workspace = {
          library = {
            [require("lvim.utils").join_paths(get_runtime_dir(), "lvim", "lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
            ["/Applications/Hammerspoon.app/Contents/Resources/extensions/hs"] = (vim.fn.has("macunix") == 1)
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
        telemetry = { enable = false },
      },
    },
  },
  -- }}}
  -- YamlLS {{{
  yamlls = {
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
          ["http://json.schemastore.org/gitlab-ci"] = "/*lab-ci.{yml,yaml}",
        },
      },
    }
  },
  -- }}}
}

-- Configure overriden servers
local lsp_manager = require("lvim.lsp.manager")
for _, server in pairs(lvim.lsp.override) do
  if custom_lsp_configs[server] then
    lsp_manager.setup(server, custom_lsp_configs[server])
  end
end

-- }}}

-- Linters {{{

setup_linters {
  css = { { exe = "eslint_d" } },
  javascript = { { exe = "eslint_d" } },
  javascriptreact = { { exe = "eslint_d" } },
  lua = { { exe = "luacheck", args = { "-g" } } },
  markdown = {
    { exe = "markdownlint" },
    { exe = "vale" },
  },
  sh = { { exe = "shellcheck" } },
  tex = {
    { exe = "chktex" },
    { exe = "vale" },
  },
  typescript = { { exe = "eslint_d" } },
  typescriptreact = { { exe = "eslint_d" } },
  vim = { { exe = "vint" } },
}

-- }}}

-- Formatters {{{

setup_formatters {
  asm = { { exe = "asmfmt" } },
  cmake = { { exe = "cmake_format" } },
  css = { { exe = "prettierd" } },
  dockerfile = { { exe = "hadolint" } },
  go = { { exe = "goimports" } },
  html = { { exe = "prettierd" } },
  javascript = { { exe = "prettierd" } },
  javascriptreact = { { exe = "prettierd" } },
  json = { { exe = "prettierd" } },
  lua = { { exe = "stylua" } },
  markdown = { { exe = "prettierd" } },
  python = {
    { exe = "yapf" },
    { exe = "isort", args = { "--profile", "black" } },
  },
  rust = { { exe = "rustfmt" } },
  sh = { { exe = "shfmt", args = { "-i", "2", "-ci" } } },
  typescript = { { exe = "prettierd" } },
  typescriptreact = { { exe = "prettierd" } },
  yaml = { { exe = "prettierd" } },
}

-- }}}

-- vim:set fdm=marker:
