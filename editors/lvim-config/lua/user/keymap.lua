-- Helpers {{{

-- Internal reprensentation of a remap action
local action = {}

--- Create a new remap action
-- @param cmd Command to be exeucted by this remap
function action:new(cmd)
  local obj = {
    cmd,
    {
      noremap = false,
      silent = false,
      expr = false,
      nowait = false,
    }
  }

  setmetatable(obj, self)
  self.__index = self

  return obj
end

--- Create a regular remap action
-- @param cmd Command to be executed
local function map(cmd)
  return action:new(cmd)
end

--- Create a <cmd> remap
-- @param cmd Command to be executed
local function map_cmd(cmd)
  return action:new(("<cmd>%s<cr>"):format(cmd))
end

--- Create a :...<cr> remap
-- @param cmd Co
local function map_cr(cmd)
  return action:new((":%s<CR>"):format(cmd))
end

--- Set the silent flag
function action:silent()
  self[2].silent = true
  return self
end

--- Set the noremap flag
function action:noremap()
  self[2].noremap = true
  return self
end

--- Set the expr flag
function action:expr()
  self[2].expr = true
  return self
end

--- Set the nowait flag
function action:nowait()
  self[2].nowait = true
  return self
end

--- Register Normal mode remaps
-- @param remaps Table containing remaps
local function normal_remaps(remaps)
  lvim.keys.normal_mode = vim.tbl_extend("force", lvim.keys.normal_mode, remaps)
end

--- Register Visual mode remaps
-- @param remaps Table containing remaps
local function visual_remaps(remaps)
  lvim.keys.visual_mode = vim.tbl_extend("force", lvim.keys.visual_mode, remaps)
end

--- Register Term mode remaps
-- @param remaps Table containing remaps
local function term_remaps(remaps)
  lvim.keys.term_mode = vim.tbl_extend("force", lvim.keys.term_mode, remaps)
end

--- Register Command mode remaps
-- @param remaps Table containing remaps
local function command_remaps(remaps)
  lvim.keys.command_mode = vim.tbl_extend("force", lvim.keys.command_mode, remaps)
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

--- Install or update which_key normal mode mappings
-- @param key Key on which the mapping will be activated
-- @param mapping Table containing the mappings for the key
local function which_key(key)
  return _which_key(key, "mappings")
end

--- Install or update which_key visual mode mappings
-- @param key Key on which the mapping will be activated
-- @param mapping Table containing the mappings for the key
local function which_vkey(key)
  return _which_key(key, "vmappings")
end

--- Maximize the current pane
_G.maximize_toggle = coroutine.create(function()
  local session
  local hidden
  local toggle_state = false
  while true do
    if not toggle_state then
      hidden = vim.opt.hidden
      session = vim.fn.tempname()
      vim.opt.hidden = true
      vim.cmd("mksession! "..session)
      vim.cmd("only")
      toggle_state = true
    else
      vim.cmd("source "..session)
      vim.opt_local.hidden = hidden
      session = nil
      hidden = nil
      toggle_state = false
    end
    coroutine.yield()
  end
end)

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
  cnoreabbrev qA qa
  cnoreabbrev Qall qall
]])

-- Remove defaults
lvim.keys.normal_mode["<S-h>"] = nil
lvim.keys.normal_mode["<S-l>"] = nil

-- -- Remove default LSP mappings
lvim.lsp.buffer_mappings.normal_mode["K"] = nil
lvim.lsp.buffer_mappings.normal_mode["gh"] = { "<cmd>lua vim.lsp.buf.hover()<CR>", "Show LSP hover" }

normal_remaps {
  -- Do not use Q for Ex mode
  Q         = map_cmd("close"):silent(),
  -- Indent
  ["<"]     = map("<<_"):noremap(),
  [">"]     = map(">>_"):noremap(),
  -- Create windows
  ss        = map_cmd("split"):silent(),
  sv        = map_cmd("vsplit"):silent(),
  -- Make Y consistent with C and D
  Y         = map("y$"):noremap(),
  -- Moving buffers
  ["[b"]    = map_cmd("BufferPrevious"):silent(),
  ["]b"]    = map_cmd("BufferNext"):silent(),
  -- Easier scrolling
  H         = map("zh"):noremap(),
  J         = map("<C-e>"):noremap(),
  K         = map("<C-y>"):noremap(),
  L         = map("zl"):noremap(),
  -- Select word
  vv        = map("viw"):noremap(),
  -- Clear search highlight
  ["\\"]    = map_cr("nohl"):silent(),
  -- Undotree
  U         = map_cmd("MundoToggle"):silent(),
  -- Tagbar
  ["<F2>"]  = map_cmd("SymbolsOutline"):silent(),
  -- File tree
  ["<F3>"]  = map_cmd("NvimTreeToggle"):silent(),
}

visual_remaps {
  -- Make Y consistent with C and D
  Y         = map("<esc>y$gv"):noremap(),
  -- Search highlighted
  ["/"]     = map('y/<C-R>"<cr>'):noremap(),
  -- Paste over selected
  p         = map('"_c<C-R>"<esc>'):noremap(),
}

command_remaps {
  -- Move cursor to begining or end of line
  ["<C-a>"] = map("<home><Left>"):noremap(),
  ["<C-e>"] = map("<end><Right>"):noremap(),
}

term_remaps {
  -- Go to normal mode
  ["<esc>"] = map([[<C-\><C-n>]]):silent():noremap(),
  jk        = map([[<C-\><C-n>]]):silent():noremap(),
}

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

-- Switching buffers
which_key "<Space>" { ":BufferPick<cr>", "Pick buffer" }

-- Copy and paste from system clipboard
which_vkey "Y" { '"+y', "Copy to clipboard" }
which_key "P" { '"+p', "Paste from clipboard" }

-- Buffer
which_key "b" {
  C = { "<cmd>setlocal cursorcolumn!<cr>", "Toggle cursor column" },
  R = { "<cmd>setlocal readonly!<cr>", "Toggle read only" },
  W = { "<cmd>setlocal wrap!<cr>", "Toggle Wrap" },
  X = { "<cmd>normal gg=G<cr>", "Reindent Buffer" },
  c = { "<cmd>ColorizerToggle<cr>", "Toggle colorizer" },
  n = { "<cmd>setlocal nonumber! norelativenumber!<cr>", "Toggle line numbers" },
  p = { '<cmd>normal ggdG"+P<cr>', "Paste from clipboard" },
  r = { "<cmd>normal gg=G<cr>", "Reindent Buffer" },
  s = { "<cmd>set spell!<cr>", "Togggle spell checking" },
  y = { '<cmd>normal ggVG"+y``<cr>', "Copy buffer to clipboard" },
}

-- Debug
which_key "d" {
  f = { "<cmd>lua require('dapui').float_element()", "Floating element" },
  x = { "<cmd>lua require('dapui').toggle()<cr>", "Run DAP-UI" },
}

which_vkey "d" {
  name = "Debug",
  e = { ":lua require('dapui').eval()<cr>", "Evaluate expression" },
}

-- Trouble
which_key "l" {
  I = { "<cmd>Telescope lsp_implementations<cr>", "Implementations"},
  R = { "<cmd>Trouble lsp_references<cr>", "Goto References" },
  Q = { "<cmd>Trouble quickfix<cr>", "Quickfix" },
  t = { "<cmd>TroubleToggle<cr>", "Trouble" },
}

-- Windows and Tabs
which_key "w" {
  name  = "Windows",
  ["="] = { "<cmd>wincmd =<cr>", "Balance" },
  H     = { "<cmd>wincmd H<cr>", "Move far left" },
  J     = { "<cmd>wincmd J<cr>", "Move far down" },
  K     = { "<cmd>wincmd K<cr>", "Move far up" },
  L     = { "<cmd>wincmd L<cr>", "Move far right" },
  f     = { "<cmd>setlocal scrollbind!", "Toggle follow mode" },
  h     = { "<cmd>wincmd h<cr>", "Move left" },
  j     = { "<cmd>wincmd j<cr>", "Move down" },
  k     = { "<cmd>wincmd k<cr>", "Move up" },
  l     = { "<cmd>wincmd l<cr>", "Move right" },
  m     = {
    function()
      coroutine.resume(maximize_toggle)
    end,
    "Maximize window",
  },
  s     = { "<cmd>split<cr>", "Split horizontal" },
  t     = { "<cmd>tabnew<cr>","Create new tab" },
  v     = { "<cmd>vsplit<cr>","Split vertical" },
  w     = { "<cmd>ChooseWin<cr>", "Chose window" },
}

-- Align
which_vkey "a" {
  name        = "Align",
  ["<space>"] = { [[:Tabularize /\s<cr>]], "Align at space" },
  ["#"]       = { [[:Tabularize /#<cr>]], "Align at #" },
  ["%"]       = { [[:Tabularize /%<cr>]], "Align at %" },
  ["&"]       = { [[:Tabularize /&<cr>]], "Align at &" },
  ["("]       = { [[:Tabularize /(<cr>]], "Align at (" },
  [")"]       = { [[:Tabularize /)<cr>]], "Align at )" },
  [","]       = { [[:Tabularize /,<cr>]], "Align at ," },
  ["."]       = { [[:Tabularize /\.<cr>]], "Align at ." },
  [":"]       = { [[:Tabularize /:<cr>]], "Align at :" },
  [";"]       = { [[:Tabularize /;<cr>]], "Align at ;" },
  ["="]       = { [[:Tabularize /=<cr>"]], "Align at =" },
  ["["]       = { [[:Tabularize /[<cr>]], "Align at [" },
  ["]"]       = { [[:Tabularize /]<cr>]], "Align at ]" },
  ["{"]       = { [[:Tabularize /{<cr>]], "Align at {" },
  ["|"]       = { [[:Tabularize /|<cr>]], "Align at |" },
  ["}"]       = { [[:Tabularize /}<cr>]], "Align at }" },
  ["¦"]       = { [[:Tabularize /¦<cr>]], "Align at ¦" },
}

-- Applications
which_key "x" {
  name = "Execute Apps",
  -- Entries from builtins
}

-- vim:set fdm=marker:
