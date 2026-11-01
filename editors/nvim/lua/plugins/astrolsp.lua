local lua_ls_settings = {
  format = { enable = false },
  telemetry = { enable = false },
}
if vim.fn.has("macunix") == 1 then
  local hs_lib = "/Applications/Hammerspoon.app/Contents/Resources/extensions/hs"
  if vim.fn.isdirectory(hs_lib) == 1 then
    lua_ls_settings.diagnostics = { globals = { "hs" } }
    lua_ls_settings.workspace = { library = { hs_lib } }
  end
end

local servers = {}
for _, bin in ipairs({ "clangd", "texlab" }) do
  if vim.fn.executable(bin) == 1 then
    table.insert(servers, bin)
  end
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    servers = servers,
    ---@diagnostic disable: missing-fields
    config = {
      clangd = {
        cmd = {
          "clangd",
          "-j=4",
          "--all-scopes-completion",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--pch-storage=memory",
        },
      },
      lua_ls = {
        settings = {
          Lua = lua_ls_settings,
        },
      },
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              kubernetes = { "*.k8s.yml", "*.k8s.yaml" },
            },
          },
        },
      },
      rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              autoreload = true,
            },
            checkOnSave = true,
            lens = {
              enable = true,
            },
            inlayHints = {
              enable = true,
              showParameterNames = true,
              parameterHintsPrefix = "<- ",
              otherHintsPrefix = "=> ",
            },
          },
        },
      },
      texlab = {
        settings = {
          texlab = {
            auxDirectory = "build",
            bibtexFormatter = "texlab",
            chktex = {
              onOpenAndSave = true,
              onEdit = true,
            },
            formatterLineLength = 120,
          },
        },
      },
    },
  },
}
