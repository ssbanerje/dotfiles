-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "gbprod/none-ls-shellcheck.nvim",
  },
  opts = function(_, opts)
    local null_ls = require("null-ls")
    local sources = {}

    -- Diagnostics / linters
    if vim.fn.executable("vale") == 1 then
      table.insert(sources, null_ls.builtins.diagnostics.vale)
    end
    if vim.fn.executable("vint") == 1 then
      table.insert(sources, null_ls.builtins.diagnostics.vint)
    end
    if vim.fn.executable("yamllint") == 1 then
      table.insert(sources, null_ls.builtins.diagnostics.yamllint)
    end
    if vim.fn.executable("shellcheck") == 1 then
      local ok_diag, sc_diag = pcall(require, "none-ls-shellcheck.diagnostics")
      if ok_diag then table.insert(sources, sc_diag) end
      local ok_act, sc_act = pcall(require, "none-ls-shellcheck.code_actions")
      if ok_act then table.insert(sources, sc_act) end
    end

    -- Formatters
    if vim.fn.executable("stylua") == 1 then
      table.insert(sources, null_ls.builtins.formatting.stylua)
    end
    if vim.fn.executable("prettier") == 1 then
      table.insert(sources, null_ls.builtins.formatting.prettier)
    end
    if vim.fn.executable("yapf") == 1 then
      table.insert(sources, null_ls.builtins.formatting.yapf)
    end
    if vim.fn.executable("isort") == 1 then
      table.insert(sources, null_ls.builtins.formatting.isort)
    end
    if vim.fn.executable("shfmt") == 1 then
      table.insert(sources, null_ls.builtins.formatting.shfmt)
    end

    opts.sources = require("astrocore").list_insert_unique(opts.sources, sources)
  end,
}
