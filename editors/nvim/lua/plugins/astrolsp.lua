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
    features = {
      codelens = true,
      inlay_hints = true,
      semantic_tokens = true,
      signature_help = true,
    },
    servers = servers,
  },
}
