-- No virtual text. Use trouble instead
lvim.lsp.diagnostics.virtual_text = false

-- Overrides
lvim.lsp.override = { "rust", "tex" }

-- Docker LSP
lvim.lang.dockerfile.lsp.setup.filetypes = { "Dockerfile*", "dockerfile*" }
lvim.lang.dockerfile.lsp.setup.root_dir = require("lspconfig").util.root_pattern("Dockerfile*")

-- YAML LSP
lvim.lang.yaml.lsp.setup.settings = {
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

-- Lua LSP
local lua_libs = {}
if vim.fn.has("macunix") then  -- Add path to Hammerspoon when on MacOS
  lua_libs["/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/"] = true
  table.insert(lvim.lang.lua.lsp.setup.settings.Lua.diagnostics.globals, "hs")
end
lvim.lang.lua.lsp.setup.settings.Lua.workspace.library = lua_libs

-- Filter commands for linters and formatters
local function check_execs(exes)
  local val = {}
  for _, exe in pairs(exes) do
    if vim.fn.executable(exe.exe) == 1 then
      table.insert(val, exe)
    end
  end
  return val
end

-- Linters
lvim.lang.lua.linters = check_execs({
  { exe = "luacheck", args = { "-g" } }
})
lvim.lang.sh.linters = check_execs({
  { exe = "shellcheck" }
})
lvim.lang.vim.linters = check_execs({
  { exe = "vint" }
})
lvim.lang.tex.linters = check_execs({
  { exe = "proselint" },
  { exe = "chktex" }
})

-- Formatters
lvim.lang.rust.formatters = check_execs({
  { exe = "rustfmt" }
})
lvim.lang.lua.formatters = check_execs({
  { exe = "stylua" }
})
lvim.lang.python.formatters = check_execs({
  { exe = "yapf" }
})

