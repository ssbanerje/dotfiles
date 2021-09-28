lvim.plugins = {
  -- Motions and Text Objects {{{
	{ "chaoren/vim-wordmotion" },
	{ "tpope/vim-surround" },
  -- }}}

  -- LSP {{{
  -- Trouble {{{
	{
		"folke/trouble.nvim",
		config = function()
			require("trouble").setup({
				auto_open = true,
				auto_close = true,
        mode = "lsp_document_diagnostics",
			})
		end,
	},
  -- }}}
  -- lua-dev {{{
  {
    "folke/lua-dev.nvim",
    config = function()
      local luadev = require("lua-dev").setup {
        library = {
          vimruntime = true,
          types = true,
          plugins = true,
        },
        lspconfig = lvim.lang.lua.lsp.setup,
      }
      lvim.lang.lua.lsp.setup = luadev
    end,
    ft = { "lua" },
  },
  -- }}}
  -- Rust-tools {{{
  {
    "simrat39/rust-tools.nvim",
    config = function()
      -- Setup rust-tools
      require("rust-tools").setup({
        tools = {
          autoSetHints = true,
          hover_with_actions = true,
          runnables = { use_telescope = true },
          debuggables = { use_telescope = true },
          inlay_hints = {
            only_current_line = false,
            show_parameter_hints = true,
            parameter_hints_prefix = "<-",
            other_hints_prefix = "=>",
            max_len_align = false,
            max_len_align_padding = 1,
            right_align = false,
            right_align_padding = 7,
            highlight = "Comment",
          },
        },
        server = {
          cmd = { vim.fn.stdpath("data") .. "/lspinstall/rust/rust-analyzer" },
          on_attach = require("lsp").common_on_attach,
          on_init = require("lsp").common_on_init,
          capabilities = require("lsp").capabilities,
          flags = require("lsp").flags,
          settings = {
            ["rust-analyzer"] = {
              assist = { importGranularity = "crate" },
              cargo = { allFeatures = true },
              checkOnSave = { allTargets = true, command = "clippy" },
              procMacro = { enable = true },
            },
          },
        },
      })

      -- Setup keymap
      require("helpers").key.which_key "l" {
        X = {
          name = "Rust",
          a = { "<cmd>RustEmitAsm<cr>", "Emit ASM" },
          c = { "<cmd>RustOpenCargo<cr>", "Open Cargo" },
          d = { "<cmd>RustDebuggables<cr>", "Debuggables" },
          h = { "<cmd>RustToggleInlayHints<cr>", "Toggle Hints" },
          j = { "<cmd>RustJoinLines<cr>", "Join Lines" },
          r = { "<cmd>RustRunnables<cr>", "Runnables" },
          m = { "<cmd>RustExpandMacro<cr>", "Expand Macro" },
          p = { "<cmd>RustParentModule<cr>", "Goto Parent Module" },
        }
      }
    end,
    depends = "nvim-lspconfig",
    ft = { "rust", "rs" },
  },
  -- }}}
  -- Texmagic {{{
  {
    "jakewvincent/texmagic.nvim",
    config = function()
      -- Setup Texmagic
      _G.TeXMagicBuildConfig = {}
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
              "%f"
            },
            isContinuous = false
          },
          xelatex = {
            executable = "latexmk",
            args = {
              "-pdf",
              "-xelatex",
              "-outdir=build",
              "-interaction=nonstopmode",
              "-synctex=1",
              "%f"
            },
            isContinuous = false
          },
        }
      })

      -- Start LSP server
      local forward_search_exe
      local forward_search_args
      if vim.fn.has("macunix") then
        forward_search_exe = "/Applications/Skim.app/Contents/SharedSupport/displayline"
        forward_search_args = { "%l", "%p", "%f" }
      else
        forward_search_exe = "okular"
        forward_search_args = { "--unique", "file:%p#src:%l%f" }
      end
      require("lspconfig").texlab.setup({
        cmd = { vim.fn.stdpath "data" .. "/lspinstall/latex/texlab" },
        filetypes = { "tex", "bib" },
        on_attach = require("lsp").common_on_attach,
        on_init = require("lsp").common_on_init,
        capabilities = require("lsp").capabilities,
        flags = require("lsp").flags,
        settings = {
          texlab = {
            auxDirectory = "build",
            bibtexFormatter = "texlab",
            build = _G.TeXMagicBuildConfig,
            linters = { "chktex" },
            chktex = {
              on_open_and_save = true,
              on_edit = true,
            },
            formatterLineLength = 120,
            forwardSearch = {
              executable = forward_search_exe,
              args = forward_search_args,
            },
          },
        },
      })

      -- Bind keys
      require("helpers").key.which_key "l" {
        X = {
          name = "TeX",
          b = { "<cmd>TexlabBuild<cr>", "Build document" },
          f = { "<cmd>TexlabForward<cr>", "Forward search preview" },
        }
      }
    end,
    ft = { "bib", "tex" },
  },
  -- }}}
  -- }}}

  -- Treesitter {{{
  { "nvim-treesitter/nvim-treesitter-textobjects", branch = "0.5-compat", after = "nvim-treesitter" },
  { "RRethy/nvim-treesitter-textsubjects", after = "nvim-treesitter" },
  { "nvim-treesitter/playground", after = "nvim-treesitter", cmd = "TSPlaygroundToggle" },
  -- }}}

  -- Utils {{{
  { "editorconfig/editorconfig-vim" },
	{ "godlygeek/tabular", cmd = "Tabularize" },
  { "simnalamburt/vim-mundo", cmd = "MundoToggle" },
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup({ auto_preview = false })
    end,
    cmd="SymbolsOutline"
  },
	{
		"lambdalisue/suda.vim",
		cmd = { "SudaWrite", "W" },
		config = function()
			vim.api.nvim_command("command! W SudaWrite")
    end,
	},
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    after = "telescope.nvim",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  --}}}

  -- UI {{{
	{ "t9md/vim-choosewin", cmd = "ChooseWin", fn = "choosewin#start" },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        filetype_exclude = { "help", "terminal", "dashboard", "packer" },
        buftype_exclude = { "terminal" },
        show_current_context = true,
        show_trailing_blankline_indent = false,
      })
    end,
    event = "BufRead",
  },
  { "norcalli/nvim-colorizer.lua", cmd = "ColorizerToggle" },
  { "folke/tokyonight.nvim", disable = true },
  -- }}}

  -- Markdown {{{
  {
    "iamcco/markdown-preview.nvim",
    run = function()
      vim.fn['mkdp#util#install']()
    end,
    config = function()
      vim.g.mkdp_page_title = "${name}"
    end,
    ft = "markdown",
    cmd = "MarkdownPreview",
  },
  -- }}}

  -- Debugger {{{
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()
    end,
    ft = { "python", "rust", "cpp", "c" },
    requires = { "mfussenegger/nvim-dap" },
    disable = not lvim.builtin.dap.active,
  },
  -- }}}
}

-- vim:set fdm=marker:
