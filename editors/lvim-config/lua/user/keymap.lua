-- Helpers {{{

-- Replicate the vim nnoremap command
local function nnoremap(key)
  return function(mapping)
    lvim.keys.normal_mode[key] = mapping
  end
end

-- Replicate the vim vnoremap command
local function vnoremap(key)
  return function(mapping)
    lvim.keys.visual_mode[key] = mapping
  end
end

-- Replicate the vim cnoremap command
local function cnoremap(key)
  return function(mapping)
    lvim.keys.command_mode[key] = mapping
  end
end

-- Replicate the vim tnoremap command
local function tnoremap(key)
  return function(mapping)
    lvim.keys.term_mode[key] = mapping
  end
end

-- Internal function set or update which_key mappings
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

-- Install or update which_key normal mode mappings
local function which_key(key)
  return _which_key(key, "mappings")
end

-- Install or update which_key visual mode mappings
local function which_vkey(key)
  return _which_key(key, "vmappings")
end

-- }}}

-- Fix Typos
vim.cmd([[
  cnoreabbrev W1 W!
  cnoreabbrev w1 w!
  cnoreabbrev Q! q!
  cnoreabbrev Q1 q!
  cnoreabbrev q1 q!
  cnoreabbrev Qa! qa!
  cnoreabbrev Qall! qall!
  cnoreabbrev Wa wa
  cnoreabbrev Wq wq
  cnoreabbrev wQ wq
  cnoreabbrev WQ wq
  cnoreabbrev wq1 wq!
  cnoreabbrev Wq1 wq!
  cnoreabbrev wQ1 wq!
  cnoreabbrev WQ1 wq!
  cnoreabbrev Q q
  cnoreabbrev Qa qa
  cnoreabbrev Qall qall
]])

-- Do not use Q for Ex mode
nnoremap "Q" "<cmd>close<cr>"

-- Indent
nnoremap "<" "<<_"
nnoremap ">" ">>_"

-- Create windows
nnoremap "ss" "<cmd>split<cr>"
nnoremap "sv" "<cmd>vsplit<cr>"

-- Make consistent with C and D
nnoremap "Y" "y$"
vnoremap "Y" "<esc>y$gv"

-- Moving split panes
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
nnoremap "<esc>" ":nohl<cr><esc>"

-- Cycle Tabs
nnoremap "gt" "<cmd>tabNext<cr>"

-- Undotree
nnoremap "U" "<cmd>MundoToggle<cr>"

-- Tagbar
nnoremap "<F2>" "<cmd>SymbolsOutline<cr>"

-- File tree
nnoremap "<F3>" "<cmd>NvimTreeToggle<cr>"

-- Search highlighted
vnoremap "/" 'y/<C-R>"<cr>'

-- Paste over selected
vnoremap "p" '"_c<C-R>"<esc>'

-- Moving in command mode
cnoremap "<C-a>" "<home>"
cnoremap "<C-e>" "<end>"

-- Terminal remaps
tnoremap "<esc>" [[<C-\><C-n>]]
tnoremap "jk" [[<C-\><C-n>]]

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
which_key "<Tab>" { "<cmd>try | b# | catch | endtry<cr>", "Previous buffer" }

-- Copy and paste from system clipboard
which_vkey "Y" { '"+y', "Copy to clipboard" }
which_key "P" { '"+p', "Paste from clipboard" }

-- Buffer
which_key "b" {
  C = { "<cmd>setlocal cursorcolumn!<cr>",                "Toggle cursor column" },
  R = { "<cmd>setlocal readonly!<cr>",                    "Toggle read only" },
  W = { "<cmd>setlocal wrap!<cr>",                        "Toggle Wrap" },
  X = { "<cmd>normal gg=G<cr>",                           "Reindent Buffer" },
  c = { "<cmd>ColorizerToggle<cr>",                       "Toggle colorizer" },
  n = { "<cmd>setlocal nonumber! norelativenumber!<cr>",  "Toggle line numbers" },
  p = { '<cmd>normal ggdG"+P<cr>',                        "Paste from clipboard" },
  r = { "<cmd>normal gg=G<cr>",                           "Reindent Buffer" },
  y = { '<cmd>normal ggVG"+y``<cr>',                      "Copy buffer to clipboard" },
}

-- Debug
which_key "d" {
  f = { "<cmd>lua require('dapui').float_element()",      "Floating element" },
  x = { "<cmd>lua require('dapui').toggle()<cr>",         "Run DAP-UI" },
}

which_vkey "d" {
  name = "Debug",
  e = { ":lua require('dapui').eval()<cr>",               "Evaluate expression" },
}

-- Troulble
which_key "l" {
  I = { "<cmd>Telescope lsp_implementations<cr>",         "LSP Implementations"},
  R = { "<cmd>Trouble lsp_references<cr>",                "Goto References" },
  a = { "<cmd>Telescope lsp_code_actions<cr>",            "Code Action" },
  q = { "<cmd>Trouble quickfix<cr>",                      "Quickfix" },
  t = { "<cmd>TroubleToggle<cr>",                         "Trouble" },
}

-- Windows and Tabs
which_key "w" {
  name  = "Windows",
  ["="] = { "<cmd>wincmd =<cr>",                          "Balance" },
  H     = { "<cmd>wincmd H<cr>",                          "Move far left" },
  J     = { "<cmd>wincmd J<cr>",                          "Move far down" },
  K     = { "<cmd>wincmd K<cr>",                          "Move far up" },
  L     = { "<cmd>wincmd L<cr>",                          "Move far right" },
  f     = { "<cmd>setlocal scrollbind!",                  "Toggle follow mode" },
  h     = { "<cmd>wincmd h<cr>",                          "Move left" },
  j     = { "<cmd>wincmd j<cr>",                          "Move down" },
  k     = { "<cmd>wincmd k<cr>",                          "Move up" },
  l     = { "<cmd>wincmd l<cr>",                          "Move right" },
  s     = { "<cmd>split<cr>",                             "Split horizontal" },
  t     = { "<cmd>tabnew<cr>",                            "Create new tab" },
  v     = { "<cmd>vsplit<cr>",                            "Split vertical" },
  w     = { "<cmd>ChooseWin<cr>",                         "Chose window" },
}

-- Align
which_vkey "a" {
  name        = "Align",
  ["<space>"] = { [[:Tabularize /\s<cr>]],                "Align at space" },
  ["#"]       = { [[:Tabularize /#<cr>]],                 "Align at #" },
  ["%"]       = { [[:Tabularize /%<cr>]],                 "Align at %" },
  ["&"]       = { [[:Tabularize /&<cr>]],                 "Align at &" },
  ["("]       = { [[:Tabularize /(<cr>]],                 "Align at (" },
  [")"]       = { [[:Tabularize /)<cr>]],                 "Align at )" },
  [","]       = { [[:Tabularize /,<cr>]],                 "Align at ," },
  ["."]       = { [[:Tabularize /\.<cr>]],                "Align at ." },
  [":"]       = { [[:Tabularize /:<cr>]],                 "Align at :" },
  [";"]       = { [[:Tabularize /;<cr>]],                 "Align at ;" },
  ["="]       = { [[:Tabularize /=<cr>"]],                "Align at =" },
  ["["]       = { [[:Tabularize /[<cr>]],                 "Align at [" },
  ["]"]       = { [[:Tabularize /]<cr>]],                 "Align at ]" },
  ["{"]       = { [[:Tabularize /{<cr>]],                 "Align at {" },
  ["|"]       = { [[:Tabularize /|<cr>]],                 "Align at |" },
  ["}"]       = { [[:Tabularize /}<cr>]],                 "Align at }" },
  ["¦"]       = { [[:Tabularize /¦<cr>]],                 "Align at ¦" },
}

-- Applications
which_key "x" {
  name = "Execute Apps",
  -- Entries from builtins
}

-- vim:set fdm=marker:
