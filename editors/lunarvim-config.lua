-- Lunarvim Settings {{{

lvim.log.level = "warn"
lvim.leader = "space"
lvim.format_on_save = true
lvim.colorscheme = "onedarker"

-- Lunarvim Builtins {{{

-- Dashboard {{{
lvim.builtin.dashboard.active = true
lvim.builtin.dashboard.custom_section["0"] = {
  description = { "  <empty buffer>     " },
  command = "ene!",
}
-- }}}

-- Terminal {{{
lvim.builtin.terminal.active = true
lvim.builtin.terminal.open_mapping = [[<C-\>]]
lvim.builtin.terminal.shell = "zsh"
-- }}}

-- Lualine {{{

local components = require "core.lualine.components"

-- Helper functions {{{
local function lualine_color(section)
  return function(mode)
    return function(color)
      -- Set mode
      if type(mode) == "string" then
        if mode == "all" then
          mode = { "normal", "command", "replace", "visual" }
        else
          mode = { mode }
        end
      end

      -- Set color
      for _, m in pairs(mode) do
        lvim.builtin.lualine.options.theme[m][section] = color
      end
    end
  end
end

local function lualine(section)
  return function(config)
    local cfg = {}
    local cfg_in = {}
    for _, v in pairs(config) do
      -- Clean components
      if type(v[1]) == "string" and v[1]:find("components.", 1, true) == 1 then
        local a = v.active
        local i = v.inactive
        v = components[string.sub(v[1], #"components." + 1)]
        v["active"] = a
        v["inactive"] = i
      end

      -- Load active
      if v.active == nil or v.active then
        table.insert(cfg, v)
      end

      -- Load inactive
      if v.inactive then
        table.insert(cfg_in, v)
      end
    end
    lvim.builtin.lualine.sections["lualine_" .. section] = cfg
    lvim.builtin.lualine.inactive_sections["lualine_" .. section] = cfg_in
  end
end
-- }}}

-- Set separators
lvim.builtin.lualine.options.section_separators = { left = "", right = "" }
lvim.builtin.lualine.options.component_separators = { left = "", right = "" }

-- Setup theme for lualine
lvim.builtin.lualine.options.theme = require "lualine.themes.onedarker"

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

-- Lualine sections
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
  components.encoding,
  "fileformat",
  { "location", active = false, inactive = true },
  { "progress", active = false, inactive = true },
}
lualine "z" { components.location, "progress" }

-- }}}

-- NvimTree {{{
lvim.builtin.nvimtree.side = "left"
lvim.builtin.nvimtree.show_icons.git = true
-- }}}

-- TreeSitter {{{
lvim.builtin.treesitter.ensure_installed = "maintained"
lvim.builtin.treesitter.highlight.enabled = true
-- }}}

-- DAP {{{
lvim.builtin.dap.active = true
-- }}}
-- }}}

-- }}}

-- VIM Options {{{

-- Backup files
vim.opt.backup = false
vim.opt.writebackup = true
vim.opt.swapfile = true

-- Background
vim.opt.background = "dark"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Color column width
vim.opt.tw = 100
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

-- Helper functions {{{
local function nnoremap(key)
  return function(mapping)
    lvim.keys.normal_mode[key] = mapping
  end
end

local function vnoremap(key)
  return function(mapping)
    lvim.keys.visual_mode[key] = mapping
  end
end

local function _which_key(key, ty)
  if type(key) ~= "string" then
    key = tostring(key)
  end
  return function(mapping)
    if lvim.builtin.which_key[ty][key] == nil then
      lvim.builtin.which_key[ty][key] = mapping
    else
      for k, v in pairs(mapping) do
        lvim.builtin.which_key[ty][key][k] = v
      end
    end
  end
end

local function which_key(key)
  return _which_key(key, "mappings")
end

local function which_vkey(key)
  return _which_key(key, "vmappings")
end
-- }}}

-- Normal Mode Remapping {{{
-- Indent
nnoremap ">" ">>_"
nnoremap "<" "<<_"

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
nnoremap "gt" ":tabNext<CR>"

-- Undotree
nnoremap "U" ":UndotreeToggle<CR>"

-- Tagbar
nnoremap "<F2>" ":TagbarToggle<CR>"

-- File tree
nnoremap "<F3>" ":NvimTreeToggle<CR>"
-- }}}

-- Visual Mode Remapping {{{
-- Search highlighted
vnoremap "/" 'y/<C-R>"<CR>'

-- Paste over selected
vnoremap "p" '"_dp'
-- }}}

-- Which-key Remapping {{{
-- Remove defaults
lvim.builtin.which_key.mappings["e"] = nil
lvim.builtin.which_key.mappings["c"] = nil
lvim.builtin.which_key.mappings["h"] = nil
lvim.builtin.which_key.mappings["q"] = nil
lvim.builtin.which_key.mappings["w"] = nil
lvim.builtin.which_key.mappings["s"] = nil

-- Fast window switching
for i = 1, 9 do
  which_key(i) {
    function()
      if #vim.api.nvim_list_wins() >= i then
        vim.cmd(":" .. i .. "wincmd w")
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
  c = { "<CMD>setlocal cursorcolumn!<CR>", "Toggle cursor column" },
  n = { "<CMD>setlocal nonumber! norelativenumber!<CR>", "Toggle line numbers" },
  r = { "<CMD>setlocal readonly!<CR>", "Toogle read only" },
  W = { "<CMD>setlocal wrap!<CR>", "Toggle Wrap" },
}

-- Troulble
which_key "l" {
  t = { "<cmd>TroubleToggle", "Trouble" },
}

-- Windows and Tabs
which_key "w" {
  name = "+Windows",
  b = { "<CMD>wincmd =<CR>", "Balance" },
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
  ["<Space>"] = { "<CMD>Tabularize /\\s<CR>", "Align at space" },
  ["o"] = { "<CMD>Tabularize /&&\\|||\\|\\.\\.\\|\\*\\*\\|<<\\|>>\\|\\/\\/\\|[-+*/.%^><&|?]<CR>", "Align at " },
  ["#"] = { "<CMD>Tabularize /#<CR>", "Align at #" },
  ["%"] = { "<CMD>Tabularize /%<CR>", "Align at %" },
  ["&"] = { "<CMD>Tabularize /&<CR>", "Align at &" },
  ["("] = { "<CMD>Tabularize /(<CR>", "Align at (" },
  [")"] = { "<CMD>Tabularize /)<CR>", "Align at )" },
  [","] = { "<CMD>Tabularize /,<CR>", "Align at ," },
  ["."] = { "<CMD>Tabularize /\\.<CR>", "Align at ." },
  [":"] = { "<CMD>Tabularize /:<CR>", "Align at :" },
  [";"] = { "<CMD>Tabularize /;<CR>", "Align at ;" },
  ["="] = {
    "<CMD>Tabularize /===\\|<=>\\|\\(&&\\|||\\|<<\\|>>\\|\\/\\/\\)=\\|=\\~[#?]\\?\\|=>\\|[:+/*!%^=><&|.?-]\\?=[#?]\\?<CR>",
    "Align at =",
  },
  ["["] = { "<CMD>Tabularize /[<CR>", "Align at [" },
  ["]"] = { "<CMD>Tabularize /]<CR>", "Align at ]" },
  ["{"] = { "<CMD>Tabularize /{<CR>", "Align at {" },
  ["|"] = { "<CMD>Tabularize /|<CR>", "Align at |" },
  ["}"] = { "<CMD>Tabularize /}<CR>", "Align at }" },
  ["¦"] = { "<CMD>Tabularize /¦<CR>", "Align at ¦" },
}
-- }}}

-- }}}

-- Language specific settings {{{

lvim.lsp.diagnostics.virtual_text = false

-- you can set a custom on_attach function that will be used for all the language servers
-- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
-- end
-- you can overwrite the null_ls setup table (useful for setting the root_dir function)
-- lvim.lsp.null_ls.setup = {
--   root_dir = require('lspconfig').util.root_pattern('Makefile', '.git', 'node_modules'),
-- }
-- or if you need something more advanced
-- lvim.lsp.null_ls.setup.root_dir = function(fname)
--   if vim.bo.filetype == 'javascript' then
--     return require('lspconfig/util').root_pattern('Makefile', '.git', 'node_modules')(fname)
--       or require('lspconfig/util').path.dirname(fname)
--   elseif vim.bo.filetype == 'php' then
--     return require('lspconfig/util').root_pattern('Makefile', '.git', 'composer.json')(fname) or vim.fn.getcwd()
--   else
--     return require('lspconfig/util').root_pattern('Makefile', '.git')(fname) or require('lspconfig/util').path.dirname(fname)
--   end
-- end

-- set a formatter if you want to override the default lsp one (if it exists)
-- lvim.lang.python.formatters = {
--   {
--     exe = 'black',
--   }
-- }
-- set an additional linter
-- lvim.lang.python.linters = {
--   {
--     exe = 'flake8',
--   }
-- }

-- Linters
lvim.lang.sh.linters = { { exe = "shellcheck" } }

-- Formatters
lvim.lang.lua.formatters = { { exe = "stylua" } }
-- }}}

-- Plugins {{{
lvim.plugins = {
  -- Tagbar
  { "preservim/tagbar", cmd = "TagbarToggle" },
  -- LSP diagnostics
  {
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup {
        auto_open = true,
        auto_close = true,
      }
    end,
  },

  -- Matching words
  {
    "andymass/vim-matchup",
    event = "CursorMoved",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },
  -- Surround motion
  { "tpope/vim-surround" },
  -- Argument text onjects
  { "xerus2000/argtextobj.vim" },
  -- Word motions (Camel case, snake case)
  { "chaoren/vim-wordmotion" },
  -- Text objects
  { "wellle/targets.vim" },

  -- Align tables
  { "godlygeek/tabular", cmd = "Tabularize" },
  -- Chose windows
  { "t9md/vim-choosewin", cmd = "ChooseWin", fn = "choosewin#start" },
  -- Undotree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_SplitWidth = 35
    end,
  },
  -- Sudo write
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaWrite", "W" },
    config = function()
      vim.api.nvim_command "command! W SudaWrite"
    end,
  },

  -- ColorScheme
  { "folke/tokyonight.nvim" },
  { "arcticicestudio/nord-vim" },
  { "hzchirs/vim-material" },
}
-- }}}

-- Autocommands {{{
lvim.autocommands.custom_groups = {
  -- Toggle line numbering style
  { "BufEnter,FocusGained,InsertLeave,WinEnter", "*", 'if &nu && mode() != "i" | set rnu | endif' },
  { "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "if &nu | set nornu | endif" },
}
-- }}}

-- vim:set fdm=marker:
