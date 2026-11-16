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

  -- Privileged writes (`:W` alias; `<Leader>W` and cmd lazy-loading come from astrocommunity)
  {
    "lambdalisue/suda.vim",
    optional = true,
    cmd = { "W" },
    init = function()
      vim.api.nvim_create_user_command("W", function(args)
        vim.cmd(("SudaWrite%s %s"):format(args.bang and "!" or "", args.args))
      end, { bang = true, nargs = "*", complete = "file", desc = "Write with sudo" })
    end,
  },

  -- Seamless Neovim <-> Kitty / tmux navigation & Alt+hjkl resize
  {
    "mrjones2014/smart-splits.nvim",
    optional = true,
    lazy = (vim.env.TMUX == nil and vim.env.KITTY_LISTEN_ON == nil),
    opts = {
      at_edge = "stop",
    },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<M-h>"] = {
                function()
                  require("smart-splits").resize_left()
                end,
                desc = "Resize split left",
              },
              ["<M-j>"] = {
                function()
                  require("smart-splits").resize_down()
                end,
                desc = "Resize split down",
              },
              ["<M-k>"] = {
                function()
                  require("smart-splits").resize_up()
                end,
                desc = "Resize split up",
              },
              ["<M-l>"] = {
                function()
                  require("smart-splits").resize_right()
                end,
                desc = "Resize split right",
              },
            },
            t = {
              ["<M-h>"] = {
                function()
                  require("smart-splits").resize_left()
                end,
                desc = "Resize split left",
              },
              ["<M-j>"] = {
                function()
                  require("smart-splits").resize_down()
                end,
                desc = "Resize split down",
              },
              ["<M-k>"] = {
                function()
                  require("smart-splits").resize_up()
                end,
                desc = "Resize split up",
              },
              ["<M-l>"] = {
                function()
                  require("smart-splits").resize_right()
                end,
                desc = "Resize split right",
              },
            },
          },
        },
      },
    },
  },

  -- Keep Visual `S` for nvim-surround; move Visual Flash Treesitter to `<C-S>`
  {
    "folke/flash.nvim",
    optional = true,
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            x = {
              ["S"] = false,
              ["<C-S>"] = {
                function()
                  require("flash").treesitter()
                end,
                desc = "Flash Treesitter",
              },
            },
          },
        },
      },
    },
  },

  -- Markdown rendering toggle (`<Leader>um`)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>um"] = { "<Cmd>RenderMarkdown toggle<CR>", desc = "Toggle Markdown render" },
            },
          },
        },
      },
    },
  },

  -- Multi-file Git diff & file-history views (`<Leader>gD`, `<Leader>gH`)
  {
    "sindrets/diffview.nvim",
    optional = true,
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    specs = {
      {
        "AstroNvim/astrocore",
        opts = {
          mappings = {
            n = {
              ["<Leader>gD"] = { "<Cmd>DiffviewOpen<CR>", desc = "Git Diffview" },
              ["<Leader>gH"] = { "<Cmd>DiffviewFileHistory %<CR>", desc = "Git file history (Diffview)" },
            },
          },
        },
      },
    },
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
      {
        "w",
        function()
          require("spider").motion("w")
        end,
        mode = { "n", "o", "x" },
        desc = "Next subword",
      },
      {
        "e",
        function()
          require("spider").motion("e")
        end,
        mode = { "n", "o", "x" },
        desc = "Next end of subword",
      },
      {
        "b",
        function()
          require("spider").motion("b")
        end,
        mode = { "n", "o", "x" },
        desc = "Previous subword",
      },
      {
        "ge",
        function()
          require("spider").motion("ge")
        end,
        mode = { "n", "o", "x" },
        desc = "Previous end of subword",
      },
    },
    opts = {},
  },

  -- Tokyo Night theme (variant selected via astroui.lua `colorscheme = "tokyonight-night"`)
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      on_colors = function(c)
        c.border = c.fg_gutter
      end,
    },
  },
}
