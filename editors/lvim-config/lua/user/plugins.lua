lvim.plugins = {
  -- Motions and Text Objects {{{
  { "tpope/vim-surround", event = "BufRead" },
  -- }}}

  -- LSP {{{
  -- Trouble
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
  -- Rust-tools {{{
  {
    "simrat39/rust-tools.nvim",
    config = function()
      -- Get server
      local _, server = require("nvim-lsp-installer.servers").get_server("rust_analyzer")

      -- Setup rust-tools
      require("rust-tools").setup({
        tools = {
          inlay_hints = {
            parameter_hints_prefix = " ",
            other_hints_prefix = " ",
          },
        },
        server = {
          cmd = server._default_options.cmd,
          on_attach = require("lvim.lsp").common_on_attach,
          on_init = require("lvim.lsp").common_on_init,
          capabilities = require("lvim.lsp").capabilities,
          flags = require("lvim.lsp").flags,
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
      lvim.builtin.which_key.mappings.l.X = {
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
    end,
    depends = { "nvim-lsp-installer" },
    ft = { "rust" },
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

      -- Setup forward search for Mac and Linux
      local forward_search_exe
      local forward_search_args
      if vim.fn.has("macunix") then
        forward_search_exe = "/Applications/Skim.app/Contents/SharedSupport/displayline"
        forward_search_args = { "%l", "%p", "%f" }
      else
        forward_search_exe = "okular"
        forward_search_args = { "--unique", "file:%p#src:%l%f" }
      end

      -- Start LSP server
      local _, server = require("nvim-lsp-installer.servers").get_server("texlab")

      server:setup({
        on_attach = require("lvim.lsp").common_on_attach,
        on_init = require("lvim.lsp").common_on_init,
        capabilities = require("lvim.lsp").capabilities,
        flags = require("lvim.lsp").flags,
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
      lvim.builtin.which_key.mappings.l.X = {
        name = "TeX",
        b = { "<cmd>TexlabBuild<cr>", "Build document" },
        f = { "<cmd>TexlabForward<cr>", "Forward search preview" },
      }
    end,
    requires = "nvim-lsp-installer",
    ft = { "bib", "tex" },
  },
  -- }}}
  -- Symbols Outline {{{
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup({
        auto_preview = false,
        symbols = {
          Array = { icon = " ", hl = "TSConstant" },
          Boolean = { icon = "⊨ ", hl = "TSBoolean" },
          Class = { icon = " ", hl = "TSType" },
          Constant = { icon = " ", hl = "TSConstant" },
          Constructor = { icon = " ", hl = "TSConstructor" },
          Enum = { icon = " ", hl = "TSType" },
          EnumMember = { icon = " ", hl = "TSField" },
          Event = { icon = "", hl = "TSType" },
          Field = { icon = " ", hl = "TSField" },
          File = { icon = " ", hl = "TSURI" },
          Function = { icon = "", hl = "TSFunction" },
          Interface = { icon = "蘒", hl = "TSType" },
          Key = { icon = " ", hl = "TSType" },
          Method = { icon = "", hl = "TSMethod" },
          Module = { icon = " ", hl = "TSNamespace" },
          Namespace = { icon = " ", hl = "TSNamespace" },
          Null = { icon = "NULL", hl = "TSType" },
          Number = { icon = " ", hl = "TSNumber" },
          Object = { icon = "綠", hl = "TSType" },
          Operator = { icon = " ", hl = "TSOperator" },
          Package = { icon = " ", hl = "TSNamespace" },
          Property = { icon = " ", hl = "TSMethod" },
          String = { icon = " ", hl = "TSString" },
          Struct = { icon = " ", hl = "TSType" },
          TypeParameter = { icon = "<>", hl = "TSParameter" },
          Variable = { icon = "[]", hl = "TSConstant" },
        },
      })
    end,
    cmd = "SymbolsOutline",
  },
  -- }}}
  -- }}}

  -- Treesitter {{{
  { "nvim-treesitter/nvim-treesitter-textobjects", branch = "0.5-compat" },
  { "RRethy/nvim-treesitter-textsubjects" },
  { "nvim-treesitter/playground", after = "nvim-treesitter", cmd = "TSPlaygroundToggle" },
  -- }}}

  -- Utils {{{
  { "editorconfig/editorconfig-vim", event = "BufRead" },
  { "godlygeek/tabular", cmd = "Tabularize" },
  { "simnalamburt/vim-mundo", cmd = "MundoToggle" },
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaWrite", "W" },
    config = function()
      vim.api.nvim_command("command! W SudaWrite")
    end,
  },
  --}}}

  -- UI {{{
  { "t9md/vim-choosewin", cmd = "ChooseWin", fn = "choosewin#start" },
  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        filetype_exclude = { "help", "terminal", "dashboard", "packer", "lspinfo", "qf" },
        buftype_exclude = { "terminal", "nofile" },
        show_current_context = true,
        show_trailing_blankline_indent = false,
      })
    end,
    event = "BufRead",
  },
  { "norcalli/nvim-colorizer.lua", cmd = "ColorizerToggle" },
  { "folke/tokyonight.nvim" },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end,
  },
  -- }}}

  -- Markdown {{{
  {
    "iamcco/markdown-preview.nvim",
    -- run = "cd app && npm install",
    run = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g.mkdp_page_title = "${name}"
    end,
    ft = "markdown",
    cmd = "MarkdownPreview",
  },
  -- }}}

  -- DAP {{{
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
