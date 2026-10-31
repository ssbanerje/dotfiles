---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      -- Core AstroNvim + imported community packs already install c, lua,
      -- markdown, markdown_inline, python, vim, vimdoc, dockerfile, rust,
      -- toml, and yaml.
      ensure_installed = {
        "bash",
        "cpp",
        "html",
        "json",
        "latex",
      },
      textobjects = {
        move = false,
        swap = false,
        select = {
          select_textobject = {
            ["af"] = { query = "@function.outer", desc = "Select outer function" },
            ["if"] = { query = "@function.inner", desc = "Select inner function" },
            ["ac"] = { query = "@class.outer", desc = "Select outer class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner class" },
            ["aa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
            ["ia"] = { query = "@parameter.inner", desc = "Select inner parameter" },
            ["ab"] = { query = "@block.outer", desc = "Select outer block" },
            ["ib"] = { query = "@block.inner", desc = "Select inner block" },
            ["al"] = { query = "@loop.outer", desc = "Select outer loop" },
            ["il"] = { query = "@loop.inner", desc = "Select inner loop" },
            ["as"] = { query = "@statement.outer", desc = "Select outer statement" },
            ["is"] = { query = "@statement.inner", desc = "Select inner statement" },
            ["aC"] = { query = "@comment.outer", desc = "Select outer comment" },
            ["iC"] = { query = "@comment.inner", desc = "Select inner comment" },
            ["am"] = { query = "@call.outer", desc = "Select outer call" },
            ["im"] = { query = "@call.inner", desc = "Select inner call" },
          },
        },
      },
    },
  },
}
