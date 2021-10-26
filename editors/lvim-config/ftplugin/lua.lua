require("lvim.lsp.manager").setup("sumneko_lua", {
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
          ["/Applications/Hammerspoon.app/Contents/Resources/extensions/hs"] = (vim.fn.has("macunix") == 1),
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      telemetry = { enable = false },
    },
  },
})
