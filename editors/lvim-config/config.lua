local helpers = require("helpers")

-- Options and settings {{{
-- Lunarvim Settings
lvim.log.level = "warn"
lvim.leader = "space"
lvim.format_on_save = false
lvim.colorscheme = "onedarker"

-- Confirm before quit
vim.opt.confirm = true

-- Backup files
vim.opt.backup = false
vim.opt.writebackup = true
vim.opt.swapfile = true
vim.opt.undofile = true
vim.opt.undolevels = 1000

-- Themeing
vim.opt.background = "dark"
vim.opt.cmdheight = 1

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Color column width
vim.opt.tw = 120
vim.opt.colorcolumn = "+1"

-- Diff mode configuration
vim.opt.diffopt = "vertical"

-- Ignore case in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Open new windows at the bottom and right
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Show result of substitution commands
vim.opt.inccommand = "nosplit"

-- Dont conceal chars
vim.opt.conceallevel = 0

-- }}}

-- Key Remapping {{{

local nnoremap = helpers.key.nnoremap
local vnoremap = helpers.key.vnoremap
local which_key = helpers.key.which_key
local which_vkey = helpers.key.which_vkey

-- Indent
nnoremap "<" "<<_"
nnoremap ">" ">>_"

-- Create windows
nnoremap "ss" "<CMD>split<CR>"
nnoremap "sv" "<CMD>vsplit<CR>"

-- Make consistent with C and D
nnoremap "Y" "y$"

-- Easier scrolling
nnoremap "<C-h>" "<C-w>h"
nnoremap "<C-j>" "<C-w>j"
nnoremap "<C-k>" "<C-w>k"
nnoremap "<C-l>" "<C-w>l"

-- Easier scrolling
nnoremap "H" "zh"
nnoremap "J" "<C-e>"
nnoremap "K" "<C-y>"
nnoremap "L" "zl"

-- Select word
nnoremap "vv" "viw"

-- Clear search highlight
nnoremap "<ESC>" ":nohl<CR><ESC>"

-- Cycle Tabs
nnoremap "gt" "<CMD>tabNext<CR>"

-- Undotree
nnoremap "U" "<CMD>MundoToggle<CR>"

-- Tagbar
nnoremap "<F2>" "<CMD>SymbolsOutline<CR>"

-- File tree
nnoremap "<F3>" "<CMD>NvimTreeToggle<CR>"

-- Search highlighted
vnoremap "/" 'y/<C-R>"<CR>'

-- Paste over selected
vnoremap "p" '"_dp'

-- Remove defaults
lvim.builtin.which_key.mappings["e"] = nil -- File tree
lvim.builtin.which_key.mappings["c"] = nil -- Close buffer
lvim.builtin.which_key.mappings["h"] = nil -- No Highlight
lvim.builtin.which_key.mappings["q"] = nil -- Quit
lvim.builtin.which_key.mappings["w"] = nil -- Save
lvim.builtin.which_key.mappings["T"] = nil -- Tresitter

-- Fast window switching
for i = 1, 9 do
	which_key(i) {
		function()
			if #vim.api.nvim_list_wins() >= i then
				vim.api.nvim_command(":" .. i .. "wincmd w")
			end
		end,
		"Goto window " .. i,
	}
end

-- Swtich to last buffer
which_key "<Tab>" { "<CMD>try | b# | catch | endtry<CR>", "Previous buffer" }

-- Copy and paste from system clipboard
which_vkey "Y" { '"+y', "Copy to clipboard" }
which_key "P" { '"+p', "Paste from clipboard" }

-- Buffer
which_key "b" {
	p = { '<CMD>normal ggdG"+P<CR>', "Paste from clipboard" },
	y = { '<CMD>normal ggVG"+y``<CR>', "Copy buffer to clipboard" },
	c = { "<CMD>ColorizerToggle<CR>", "Toggle colorizer" },
	C = { "<CMD>setlocal cursorcolumn!<CR>", "Toggle cursor column" },
	n = { "<CMD>setlocal nonumber! norelativenumber!<CR>", "Toggle line numbers" },
	r = { "<CMD>setlocal readonly!<CR>", "Toogle read only" },
	W = { "<CMD>setlocal wrap!<CR>", "Toggle Wrap" },
}

-- Troulble
which_key "l" {
  a = { "<CMD>Telescope lsp_code_actions<CR>", "Code Action" },
	t = { "<CMD>TroubleToggle<CR>", "Trouble" },
  I = { "<CMD>Telescope lsp_implementations<CR>", "LSP Implementations"},
  R = { "<CMD>Trouble lsp_references<CR>", "Goto References" },
}

-- Windows and Tabs
which_key "w" {
	name = "+Windows",
	["="] = { "<CMD>wincmd =<CR>", "Balance" },
	f = { "<CMD>setlocal scrollbind!", "Toggle follow mode" },
	s = { "<CMD>split<CR>", "Split horizontal" },
	t = { "<CMD>tabnew<CR>", "Create new tab" },
	v = { "<CMD>vsplit<CR>", "Split vertical" },
	w = { "<CMD>ChooseWin<CR>", "Chose window" },
	H = { "<CMD>wincmd H<CR>", "Move far left" },
	J = { "<CMD>wincmd J<CR>", "Move far down" },
	K = { "<CMD>wincmd K<CR>", "Move far up" },
	L = { "<CMD>wincmd L<CR>", "Move far right" },
	h = { "<CMD>wincmd h<CR>", "Move left" },
	j = { "<CMD>wincmd j<CR>", "Move down" },
	k = { "<CMD>wincmd k<CR>", "Move up" },
	l = { "<CMD>wincmd l<CR>", "Move right" },
}

-- Align
which_vkey "a" {
	name = "+Align",
	["<Space>"] = { [[<CMD>Tabularize /\s<CR>]], "Align at space" },
	["o"] = { [[<CMD>Tabularize /&&\|||\|\.\.\|\*\*\|<<\|>>\|\/\/\|[-+*/.%^><&|?]<CR>]], "Align at " },
	["#"] = { [[<CMD>Tabularize /#<CR>]], "Align at #" },
	["%"] = { [[<CMD>Tabularize /%<CR>]], "Align at %" },
	["&"] = { [[<CMD>Tabularize /&<CR>]], "Align at &" },
	["("] = { [[<CMD>Tabularize /(<CR>]], "Align at (" },
	[")"] = { [[<CMD>Tabularize /)<CR>]], "Align at )" },
	[","] = { [[<CMD>Tabularize /,<CR>]], "Align at ," },
	["."] = { [[<CMD>Tabularize /\.<CR>]], "Align at ." },
	[":"] = { [[<CMD>Tabularize /:<CR>]], "Align at :" },
	[";"] = { [[<CMD>Tabularize /;<CR>]], "Align at ;" },
	["="] = {
    [[<CMD>Tabularize /===\|<=>\|\(&&\|||\|<<\|>>\|\/\/\)=\|=\~[#?]\?\|=>\|[:+/*!%^=><&|.?-]\?=[#?]\?<CR>"]],
    "Align at ="
  },
	["["] = { [[<CMD>Tabularize /[<CR>]], "Align at [" },
	["]"] = { [[<CMD>Tabularize /]<CR>]], "Align at ]" },
	["{"] = { [[<CMD>Tabularize /{<CR>]], "Align at {" },
	["|"] = { [[<CMD>Tabularize /|<CR>]], "Align at |" },
	["}"] = { [[<CMD>Tabularize /}<CR>]], "Align at }" },
	["¦"] = { [[<CMD>Tabularize /¦<CR>]], "Align at ¦" },
}

-- Applications
which_key "x" {
  name = "+Execute Apps",
  -- entries in builtin section
}

-- }}}

-- Lunarvim Builtins {{{

-- Dashboard
lvim.builtin.dashboard.active = true
local custom_section = helpers.dashboard.custom_section
custom_section "00" "  <empty buffer>" "ene!"
custom_section "d1" "  Marks" "Telescope marks"

-- Terminal
lvim.builtin.terminal.active = true
lvim.builtin.terminal.open_mapping = [[<C-\>]]
lvim.builtin.terminal.execs = {
  { "lazygit", "gg", "LazyGit" },
  { "lazygit", "xg", "LazyGit" },
  { "ranger", "xr", "Ranger" },
}

-- Lualine
local lualine = helpers.statusline.lualine
local lualine_color = helpers.statusline.lualine_color

local components = require("core.lualine.components")
components.location.icon = ""

lvim.builtin.lualine.options.section_separators = { left = "", right = "" }
lvim.builtin.lualine.options.component_separators = { left = "", right = "" }

lvim.builtin.lualine.options.theme = require("lualine.themes.onedarker")

local colors = {
	black = "#000000",
	white = "#FFFFFF",
	gray = "#3d3d3d",
	blue = "#51AFEF",
	cyan = "#008080",
	darkblue = "#081633",
	green = "#98BE65",
	magenta = "#C678DD",
	orange = "#FF8800",
	red = "#EC5F67",
	violet = "#A9A1E1",
	yellow = "#ECBE7B",
}

lualine_color "a" "normal" { fg = colors.black, bg = colors.blue, gui = "bold" }
lualine_color "a" "insert" { fg = colors.black, bg = colors.green, gui = "bold" }
lualine_color "a" "visual" { fg = colors.black, bg = colors.orange, gui = "bold" }
lualine_color "a" "replace" { fg = colors.black, bg = colors.magenta, gui = "bold" }
lualine_color "a" "command" { fg = colors.black, bg = colors.red, gui = "bold" }
lualine_color "b" "all" { bg = colors.gray }
lualine_color "a" "inactive" { fg = colors.black, bg = colors.violet, gui = "bold" }
lualine_color "b" "inactive" { fg = colors.violet, bg = colors.black }
lualine_color "c" "inactive" { fg = colors.violet, bg = colors.black }

lualine "a" {
	"mode",
	{
		function()
			return vim.fn.winnr()
		end,
		inactive = true,
	},
}
lualine "b" { { "components.filename", inactive = true }, { "components.branch", inactive = true } }
lualine "x" { components.treesitter, components.diagnostics, components.lsp }
lualine "y" {
	components.filetype,
	"fileformat",
	components.encoding,
	{ "components.location", active = false, inactive = true },
	{ "progress", active = false, inactive = true },
}
lualine "z" { components.location, "progress" }

-- TreeSitter
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

-- DAP
lvim.builtin.dap.active = true
lvim.builtin.dap.on_config_done = function(dap)
  -- Setup adapters
  dap.adapters.lldb = {
    type = "executable",
    attach = { pidProperty = "pid", pidSelect = "ask" },
    command = "lldb-vscode",
    name = "lldb",
    env = { LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES" },
  }
  dap.adapters.python = {
    type = 'executable';
    command = 'python';
    args = { '-m', 'debugpy.adapter' };
  }

  -- Setup configurations
  dap.configurations.cpp = {
    {
      name = "Launch executable",
      type = "lldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = true,
      args = {},
      runInTerminal = false,
      env = function()
        local variables = {}
        for k, v in pairs(vim.fn.environ()) do
          table.insert(variables, string.format("%s=%s", k, v))
        end
        return variables
      end
    },
    {
      name = "Attach to process",
      type = 'lldb',
      request = 'attach',
      pid = require('dap.utils').pick_process,
      args = {},
    },
  }
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
  dap.configurations.python = {
  {
    name = "Launch file",
    type = 'python',
    request = 'launch',
    program = "${file}";
    pythonPath = function()
      local cwd = vim.fn.getcwd()
      if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
        return cwd .. '/venv/bin/python'
      elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
        return cwd .. '/.venv/bin/python'
      else
        return 'python'
      end
    end;
  },
}

end

-- }}}

-- LSP Configs {{{

-- No virtual text. Use trouble instead
lvim.lsp.diagnostics.virtual_text = false

-- Overrides
lvim.lsp.override = { "rust", "tex" }

-- Docker LSP
lvim.lang.dockerfile.lsp.setup.filetypes = { "Dockerfile*", "dockerfile*" }
lvim.lang.dockerfile.lsp.setup.root_dir = require("lspconfig").util.root_pattern("Dockerfile*")

-- YAML LSP
lvim.lang.yaml.lsp.setup.settings = {
  yaml = {
    hover = true,
    completion = true,
    validate = true,
    schemaStore = {
      enable = true,
      url = "https://www.schemastore.org/api/json/catalog.json",
    },
    schemas = {
      ["http://json.schemastore.org/github-workflow"] = ".github/workflows/*.{yml,yaml}",
      ["http://json.schemastore.org/github-action"] = ".github/action.{yml,yaml}",
      ["http://json.schemastore.org/gitlab-ci"] = "/*lab-ci.{yml,yaml}",
    },
  },
}

-- Lua LSP
local lua_libs = {}
if helpers.is_mac_os() then  -- Add path to Hammerspoon when on MacOS
  lua_libs["/Applications/Hammerspoon.app/Contents/Resources/extensions/hs/"] = true
  table.insert(lvim.lang.lua.lsp.setup.settings.Lua.diagnostics.globals, "hs")
end
lvim.lang.lua.lsp.setup.settings.Lua.workspace.library = lua_libs

-- Linters
lvim.lang.lua.linters = { { exe = "luacheck", args = { "-g" } } }
lvim.lang.sh.linters = { { exe = "shellcheck" } }
lvim.lang.vim.linters = { { exe = "vint" } }
lvim.lang.tex.linters = { { exe = "vale" }, { exe = "chktex" } }

-- Formatters
lvim.lang.rust.formatters = { { exe = "rustfmt" } }
lvim.lang.lua.formatters = { { exe = "stylua" } }
lvim.lang.python.formatters = { { exe = "yapf" } }

-- }}}

-- Plugins
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
          a = { "<CMD>RustEmitAsm<CR>", "Emit ASM" },
          c = { "<CMD>RustOpenCargo<CR>", "Open Cargo" },
          d = { "<CMD>RustDebuggables<CR>", "Debuggables" },
          h = { "<CMD>RustToggleInlayHints<CR>", "Toggle Hints" },
          j = { "<CMD>RustJoinLines<CR>", "Join Lines" },
          r = { "<CMD>RustRunnables<CR>", "Runnables" },
          m = { "<CMD>RustExpandMacro<CR>", "Expand Macro" },
          p = { "<CMD>RustParentModule<CR>", "Goto Parent Module" },
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
      if require("helpers").is_mac_os() then
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
          b = { "<CMD>TexlabBuild<CR>", "Build document" },
          f = { "<CMD>TexlabForward<CR>", "Forward search preview" },
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
        show_first_indent_level = false,
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

-- Autocommands {{{

function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<ESC>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
end

lvim.autocommands.custom_groups = {
	-- Style when leaving and entering buffers
	{ "BufEnter,FocusGained,InsertLeave,WinEnter", "*", 'if &nu && mode() != "i" | set rnu | endif' },
  { "BufEnter,FocusGained,InsertLeave,WinEnter", "*", "set cursorline" },
	{ "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "if &nu | set nornu | endif" },
  { "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "set nocursorline" },
  -- Reload file on change
  { "FocusGained", "*", ":checktime" },
  -- Windows to close on q
  { "Filetype", "help,man", "nnoremap <buffer><silent> q <CMD>close<CR>" },
  -- Terminal keymaps
  { "TermOpen", "term://*", "lua set_terminal_keymaps()" }
}

-- }}}

-- vim:set fdm=marker:
