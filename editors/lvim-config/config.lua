-- Lunarvim Settings
lvim.log.level = "warn"
lvim.leader = "space"
lvim.format_on_save = false

-- Confirm before quit
vim.opt.confirm = true

-- Backup files
vim.opt.backup = false
vim.opt.writebackup = true
vim.opt.swapfile = true
vim.opt.undofile = true
vim.opt.undolevels = 1000
vim.opt.undodir = vim.fn.stdpath "cache" .. "/undo"

-- Themeing
vim.opt.cmdheight = 1
local status_ok, _ = pcall(require, "lualine.themes.tokyonight")
if status_ok then
  lvim.colorscheme = "tokyonight-night"
end
vim.tbl_extend("force", lvim.builtin.theme.tokyonight.options, { on_colors = function(c) c.border = c.fg_gutter end })
vim.opt.title = true
vim.opt.titlestring = "%<%F%=%l/%L - nvim"

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

-- Wrap around search
vim.opt.wrapscan = true

-- Open new windows at the bottom and right
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Show result of substitution commands
vim.opt.inccommand = "nosplit"

-- Dont conceal chars
vim.opt.conceallevel = 0

-- Reload files that have been changed on disk
vim.opt.autoread = true

-- Format optional
vim.opt.formatoptions = vim.opt.formatoptions
  + "c" -- Auto wrap text in comments
  + "j" -- Auto remove comments
  + "n" -- Indent past formatlistpat
  + "q" -- Allow formating comments with gq
  + "r" -- Insert comment leader in insert mode
  + "l" -- Line breaks
  + "v"
  - "2" -- Use indent of first line of paragraph
  - "a" -- No auto formatting
  - "o" -- Do not insert comment leader when hitting o/O in norm
  - "t" -- No auto wrap text

--Use "rg" for vimgrep
if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden"
  vim.opt.grepformat = "%f:%l:%c:%m"
end

-- https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
if vim.env.TERM == "xterm-kitty" then
  vim.cmd([[let &t_ut='']])
end

------------------------------------------------------------------------------------------------------------------------

-- Load keymaps
require("user.keymap")

-- Load autocmds
require("user.autocmds")

-- Configure LVIM builtin plugins
require("user.cmp")
require("user.dap")
require("user.lualine")
require("user.terminal")
require("user.treesitter")

-- Configure LSP
require("user.lsp")

-- Load plugins
require("user.plugins")
