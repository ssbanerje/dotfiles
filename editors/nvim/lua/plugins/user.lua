---@type LazySpec
return {
  -- Disable better-escape to avoid conflicts with custom jk mappings
  { "max397574/better-escape.nvim", enabled = false },

  -- Texmagic
  {
    "jakewvincent/texmagic.nvim",
    config = function()
      _G.TeXMagicBuildConfig = _G.TeXMagicBuildConfig or {}
      vim.g.texflavor = "latex"
      require("texmagic").setup({
        engines = {
          pdflatex = {
            executable = "latexmk",
            args = {
              "-pdf",
              "-pdflatex",
              "-outdir=build",
              "-interaction=nonstopmode",
              "-synctex=1",
              "%f",
            },
            isContinuous = false,
          },
          xelatex = {
            executable = "latexmk",
            args = {
              "-pdf",
              "-xelatex",
              "-outdir=build",
              "-interaction=nonstopmode",
              "-synctex=1",
              "%f",
            },
            isContinuous = false,
          },
        },
      })
    end,
    ft = { "bib", "tex" },
  },

  -- Mundo
  { "simnalamburt/vim-mundo", cmd = "MundoToggle" },

  -- Suda
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaWrite", "W" },
    config = function()
      vim.api.nvim_create_user_command("W", "SudaWrite", {})
    end,
  },

  -- Choosewin
  { "t9md/vim-choosewin", cmd = "ChooseWin" },

  -- Tabular
  { "godlygeek/tabular", cmd = "Tabularize" },

  -- CamelCase / snake_case word motions
  { "chaoren/vim-wordmotion", event = "User AstroFile" },

  -- Tokyonight Theme
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
