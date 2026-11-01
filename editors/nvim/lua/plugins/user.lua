---@type LazySpec
return {
  -- Disable better-escape to avoid conflicts with terminal jk mapping
  { "max397574/better-escape.nvim", enabled = false },

  -- VimTeX compilation & PDF viewer settings (replaces archived texmagic.nvim)
  {
    "lervag/vimtex",
    init = function()
      if vim.fn.has("macunix") == 1 then
        vim.g.vimtex_view_method = "skim"
      else
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "okular"
        vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
      end
      vim.g.vimtex_compiler_latexmk = { out_dir = "build" }
    end,
  },

  -- Privileged reads/writes
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite", "W" },
    config = function()
      vim.api.nvim_create_user_command("W", "SudaWrite", {})
    end,
  },

  -- Interactive text alignment via `ga` / `gA` (replaces godlygeek/tabular)
  {
    "nvim-mini/mini.align",
    event = "User AstroFile",
    opts = {},
  },

  -- Subword camelCase / snake_case motions (replaces chaoren/vim-wordmotion
  -- directly without astrocommunity's heavy luarocks.nvim build step)
  {
    "chrisgrieser/nvim-spider",
    keys = {
      { "w", function() require("spider").motion("w") end, mode = { "n", "o", "x" }, desc = "Next subword" },
      { "e", function() require("spider").motion("e") end, mode = { "n", "o", "x" }, desc = "Next end of subword" },
      { "b", function() require("spider").motion("b") end, mode = { "n", "o", "x" }, desc = "Previous subword" },
      { "ge", function() require("spider").motion("ge") end, mode = { "n", "o", "x" }, desc = "Previous end of subword" },
    },
    opts = {},
  },

  -- Tokyo Night theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      on_colors = function(c) c.border = c.fg_gutter end,
    },
  },
}
