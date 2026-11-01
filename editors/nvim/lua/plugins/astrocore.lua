local maximize_toggle = coroutine.create(function()
  local session
  local hidden
  local toggle_state = false
  while true do
    if not toggle_state then
      hidden = vim.opt.hidden
      session = vim.fn.tempname()
      vim.opt.hidden = true
      vim.cmd("mksession! " .. session)
      vim.cmd("only")
      toggle_state = true
    else
      if session and vim.fn.filereadable(session) == 1 then
        vim.cmd("source " .. session)
        vim.fn.delete(session)
      end
      vim.opt_local.hidden = hidden
      session = nil
      hidden = nil
      toggle_state = false
    end
    coroutine.yield()
  end
end)

local function wipe_registers()
  local regs = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"'
  for i = 1, #regs do
    pcall(vim.fn.setreg, regs:sub(i, i), {})
  end
  vim.notify("Registers wiped", vim.log.levels.INFO)
end

local function pick_window()
  local win = require("window-picker").pick_window()
  if win then vim.api.nvim_set_current_win(win) end
end

local function undo_history() require("snacks").picker.undo() end

local opt = {
  writebackup = true,
  undolevels = 1000,
  cmdheight = 1,
  titlestring = "%<%F%=%l/%L - nvim",
  textwidth = 120,
  colorcolumn = "+1",
  scrolloff = 5,
  diffopt = vim.list_extend(vim.opt.diffopt:get(), { "vertical" }),
}

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m"
end

local mappings = {
  n = {
    -- Consistent forward/backward search navigation regardless of / or ?
    n = { "'Nn'[v:searchforward]", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward]", expr = true, desc = "Previous search match" },

    -- Custom mappings
    Q = { "<cmd>close<cr>", desc = "Close window", silent = true },
    ["-"] = { pick_window, desc = "Pick window" },
    ["<"] = { "<<_", desc = "Indent left" },
    [">"] = { ">>_", desc = "Indent right" },
    ss = { "<cmd>split<cr>", desc = "Horizontal split", silent = true },
    sv = { "<cmd>vsplit<cr>", desc = "Vertical split", silent = true },
    vv = { "^v$", desc = "Select line" },

    -- Undo picker & privileged save
    U = { undo_history, desc = "Undo history" },
    ["<Leader>W"] = { "<cmd>SudaWrite<cr>", desc = "Write with sudo" },

    -- F-keys (Outline, File Tree, Undo History)
    ["<F2>"] = { "<cmd>AerialToggle<cr>", desc = "Outline Toggle", silent = true },
    ["<F3>"] = { "<cmd>Neotree toggle<cr>", desc = "Neotree Toggle", silent = true },
    ["<F5>"] = { undo_history, desc = "Undo history" },

    -- Clipboard (Normal)
    P = { '"+p', desc = "Paste from clipboard" },

    -- Registers (<Leader>r)
    ["<Leader>r"] = { desc = "Registers" },
    ["<Leader>rw"] = { wipe_registers, desc = "Wipe all registers" },

    -- UI Toggles (<Leader>u)
    ["<Leader>uo"] = { "<cmd>setlocal cursorcolumn!<cr>", desc = "Toggle cursor column" },
    ["<Leader>uR"] = { "<cmd>setlocal readonly!<cr>", desc = "Toggle read only" },

    -- Buffer extras (<Leader>b)
    ["<Leader>bp"] = { '<cmd>normal ggdG"+P<cr>', desc = "Truncate file and paste from clipboard" },
    ["<Leader>br"] = { "<cmd>normal gg=G<cr>", desc = "Reindent buffer" },
    ["<Leader>by"] = { '<cmd>normal ggVG"+y``<cr>', desc = "Copy buffer to clipboard" },

    -- LSP / Trouble (<Leader>l)
    ["<Leader>lI"] = { function() require("snacks").picker.lsp_implementations() end, desc = "Implementations" },
    ["<Leader>lW"] = { "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
    ["<Leader>lD"] = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics" },
    ["<Leader>lR"] = { "<cmd>Trouble lsp toggle focus=false<cr>", desc = "Goto References" },
    ["<Leader>lt"] = { "<cmd>Trouble<cr>", desc = "Trouble" },

    -- Windows (<Leader>w)
    ["<Leader>w"] = { desc = "Windows" },
    ["<Leader>w="] = { "<cmd>wincmd =<cr>", desc = "Balance" },
    ["<Leader>wH"] = { "<cmd>wincmd H<cr>", desc = "Move far left" },
    ["<Leader>wJ"] = { "<cmd>wincmd J<cr>", desc = "Move far down" },
    ["<Leader>wK"] = { "<cmd>wincmd K<cr>", desc = "Move far up" },
    ["<Leader>wL"] = { "<cmd>wincmd L<cr>", desc = "Move far right" },
    ["<Leader>wf"] = { "<cmd>setlocal scrollbind!<cr>", desc = "Toggle follow mode" },
    ["<Leader>wh"] = { "<cmd>wincmd h<cr>", desc = "Move left" },
    ["<Leader>wj"] = { "<cmd>wincmd j<cr>", desc = "Move down" },
    ["<Leader>wk"] = { "<cmd>wincmd k<cr>", desc = "Move up" },
    ["<Leader>wl"] = { "<cmd>wincmd l<cr>", desc = "Move right" },
    ["<Leader>wm"] = { function() coroutine.resume(maximize_toggle) end, desc = "Maximize window" },
    ["<Leader>ws"] = { "<cmd>split<cr>", desc = "Split horizontal" },
    ["<Leader>wt"] = { "<cmd>tabnew<cr>", desc = "Create new tab" },
    ["<Leader>wv"] = { "<cmd>vsplit<cr>", desc = "Split vertical" },
    ["<Leader>ww"] = { pick_window, desc = "Pick window" },
  },
  x = {
    n = { "'Nn'[v:searchforward]", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward]", expr = true, desc = "Previous search match" },
  },
  o = {
    n = { "'Nn'[v:searchforward]", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward]", expr = true, desc = "Previous search match" },
  },
  v = {
    Y = { '"+y', desc = "Copy to clipboard" },
    ["/"] = { 'y/<C-R>"<cr>', desc = "Search highlighted" },
    p = { '"_c<C-R>"<esc>', desc = "Paste over selected" },
  },
  t = {
    ["<esc>"] = { [[<C-\><C-n>]], desc = "Normal mode" },
    jk = { [[<C-\><C-n>]], desc = "Normal mode" },
  },
}

-- Direct numeric window jumps (1..9)
for i = 1, 9 do
  mappings.n[tostring(i)] = {
    function()
      if #vim.api.nvim_list_wins() >= i then
        vim.cmd(i .. "wincmd w")
      end
    end,
    desc = "Goto window " .. i,
  }
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
    },
    diagnostics = {
      virtual_text = false,
      virtual_lines = false,
      underline = true,
    },
    options = {
      opt = opt,
      g = {
        autoformat = false,
        tex_conceal = "",
      },
    },
    mappings = mappings,
    autocmds = {
      custom_theme = {
        {
          event = { "BufEnter", "FocusGained", "InsertLeave", "WinEnter" },
          pattern = "*",
          callback = function()
            if vim.opt.number:get() and vim.fn.mode() ~= "i" then
              vim.opt.relativenumber = true
            end
            vim.opt.cursorline = true
          end,
        },
        {
          event = { "BufLeave", "FocusLost", "InsertEnter", "WinLeave" },
          pattern = "*",
          callback = function()
            if vim.opt.number:get() then
              vim.opt.relativenumber = false
            end
            vim.opt.cursorline = false
          end,
        },
      },
      diff_mode = {
        {
          event = { "VimEnter", "WinEnter" },
          pattern = "*",
          callback = function()
            if vim.wo.diff then
              vim.api.nvim_set_hl(0, "DiffText", { link = "Visual" })
            end
          end,
        },
        {
          event = "OptionSet",
          pattern = "diff",
          callback = function()
            if vim.wo.diff then
              vim.api.nvim_set_hl(0, "DiffText", { link = "Visual" })
            end
          end,
        },
      },
      vim_help_navigation = {
        {
          event = "FileType",
          pattern = "help",
          command = "nnoremap <buffer><silent> gd :h <C-R><C-W><cr>",
        },
        {
          event = "FileType",
          pattern = "help",
          command = 'vnoremap <buffer><silent> gd "*y:h <C-R>*<cr>',
        },
      },
      git = {
        {
          event = "FileType",
          pattern = "gitrebase",
          callback = function()
            local remaps = {
              D = "^ciwdrop<esc>",
              E = "^ciwedit<esc>",
              F = "^ciwfixup<esc>",
              P = "^ciwpick<esc>",
              R = "^ciwreword<esc>",
              S = "^ciwsquash<esc>",
            }
            for k, v in pairs(remaps) do
              vim.api.nvim_buf_set_keymap(0, "n", k, v, { noremap = true })
            end
            vim.bo.undofile = false
          end,
        },
        {
          event = "BufWritePre",
          pattern = { "COMMIT_EDITMSG", "MERGE_MSG" },
          command = "setlocal noundofile",
        },
      },
    },
  },
}
