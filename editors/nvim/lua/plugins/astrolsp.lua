_G.TeXMagicBuildConfig = _G.TeXMagicBuildConfig or {}

local forward_search_exe
local forward_search_args
if vim.fn.has("macunix") == 1 then
  forward_search_exe = "/Applications/Skim.app/Contents/SharedSupport/displayline"
  forward_search_args = { "%l", "%p", "%f" }
else
  forward_search_exe = "okular"
  forward_search_args = { "--unique", "file:%p#src:%l%f" }
end

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
for _, entry in ipairs({
  { server = "clangd", bin = "clangd" },
  { server = "texlab", bin = "texlab" },
}) do
  if vim.fn.executable(entry.bin) == 1 then
    table.insert(servers, entry.server)
  end
end

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = false,
      },
      disabled = {
        "lua_ls",
      },
      timeout_ms = 1000,
    },
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
            check = {
              command = "clippy",
            },
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
        on_new_config = function(new_config)
          if type(_G.TeXMagicBuildConfig) == "table" and next(_G.TeXMagicBuildConfig) ~= nil then
            new_config.settings.texlab.build = _G.TeXMagicBuildConfig
          end
        end,
        settings = {
          texlab = {
            auxDirectory = "build",
            bibtexFormatter = "texlab",
            build = _G.TeXMagicBuildConfig,
            chktex = {
              onOpenAndSave = true,
              onEdit = true,
            },
            formatterLineLength = 120,
            forwardSearch = {
              executable = forward_search_exe,
              args = forward_search_args,
            },
          },
        },
      },
    },
    handlers = {
      -- default handlers
    },
    autocmds = {
      lsp_codelens_refresh = {
        cond = "textDocument/codeLens",
        {
          event = { "InsertLeave", "BufEnter" },
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.enable(true, { bufnr = args.buf }) end
          end,
        },
      },
    },
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client:supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
        ["<Leader>lX"] = {
          desc = "TeX",
          cond = function(client) return client.name == "texlab" end,
        },
        ["<Leader>lXb"] = {
          function() vim.cmd(vim.fn.exists(":LspTexlabBuild") == 2 and "LspTexlabBuild" or "TexlabBuild") end,
          desc = "Build document",
          cond = function(client) return client.name == "texlab" end,
        },
        ["<Leader>lXf"] = {
          function() vim.cmd(vim.fn.exists(":LspTexlabForward") == 2 and "LspTexlabForward" or "TexlabForward") end,
          desc = "Forward search preview",
          cond = function(client) return client.name == "texlab" end,
        },
      },
    },
    on_attach = function(client, _bufnr)
      if client.name == "texlab" and type(_G.TeXMagicBuildConfig) == "table" and next(_G.TeXMagicBuildConfig) ~= nil then
        client.config.settings.texlab.build = _G.TeXMagicBuildConfig
        client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
      end
    end,
  },
}
