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

-- Themeing
lvim.colorscheme = "onedarker"
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

-- Format optional
vim.opt.formatoptions = vim.opt.formatoptions
  + "c" -- Auto wrap text in comments
  + "j" -- Auto remove comments
  + "n" -- Indent past formatlistpat
  + "q" -- Allow formating comments with gq
  + "r" -- Insert comment leader in insert mode
  - "2" -- Use indent of first line of paragraph
  - "a" -- No auto formatting
  - "o" -- Do not insert comment leader when hitting o/O in norm
  - "t" -- No auto wrap text

-- Use "rg" for vimgrep
if vim.fn.executable("rg") == 1 then
  vim.o.grepprg = "rg --vimgrep --no-heading --smart-case --hidden"
  vim.o.grepformat = "%f:%l:%c:%m"
end

-- https://sw.kovidgoyal.net/kitty/faq/#using-a-color-theme-with-a-background-color-does-not-work-well-in-vim
if vim.env.TERM == "xterm-kitty" then
  vim.cmd [[let &t_ut='']]
end

------------------------------------------------------------------------------------------------------------------------

-- Load keymaps
require("user.keymap")

-- Load Autocommands
require("user.autocommands")

-- Configure LVIM Builtins
require("user.dashboard")
require("user.treesitter")
require("user.terminal")
require("user.lualine")
require("user.dap")

-- Configure LSP
require("user.lsp")

-- Load plugins
require("user.plugins")
