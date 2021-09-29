lvim.builtin.treesitter.ensure_installed = "maintained"

lvim.builtin.treesitter.matchup.enable = true

lvim.builtin.treesitter.highlight.disable = {}

lvim.builtin.treesitter.textobjects = {
  lookahead = true,
  select = {
    enable = true,
    keymaps = {
      ["af"] = "@function.outer",
      ["if"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
      ["ab"] = "@block.outer",
      ["ib"] = "@block.inner",
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",
      ["as"] = "@statement.outer",
      ["is"] = "@statement.inner",
      ["aC"] = "@comment.outer",
      ["iC"] = "@comment.inner",
      ["am"] = "@call.outer",
      ["im"] = "@call.inner",
    },
  },
  swap = { enable = false },
  move = { enable = false },
  lsp_interop = { enable = true },
}

lvim.builtin.treesitter.textsubjects = {
  enable = true,
  keymaps = {
    ["."] = "textsubjects-smart",
    [";"] = "textsubjects-container-outer",
  },
}

lvim.builtin.treesitter.playground.enable = true
