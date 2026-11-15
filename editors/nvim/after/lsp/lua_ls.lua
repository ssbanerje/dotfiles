local hs_lib = "/Applications/Hammerspoon.app/Contents/Resources/extensions/hs"

if vim.fn.has("macunix") == 1 and vim.fn.isdirectory(hs_lib) == 1 then
  ---@type vim.lsp.Config
  return {
    settings = {
      Lua = {
        diagnostics = { globals = { "hs" } },
        workspace = { library = { hs_lib } },
      },
    },
  }
end

---@type vim.lsp.Config
return {}
