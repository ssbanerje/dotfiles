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

local opt = {
  relativenumber = true,
  number = true,
  spell = false,
  signcolumn = "yes",
  wrap = false,
  confirm = true,
  backup = false,
  writebackup = true,
  swapfile = true,
  undofile = true,
  undolevels = 1000,
  undodir = vim.fn.stdpath "cache" .. "/undo",
  cmdheight = 1,
  title = true,
  titlestring = "%<%F%=%l/%L - nvim",
  tw = 120,
  colorcolumn = "+1",
  scrolloff = 5,
  diffopt = "vertical",
  ignorecase = true,
  smartcase = true,
  wrapscan = true,
  splitright = true,
  splitbelow = true,
  inccommand = "nosplit",
  conceallevel = 0,
  autoread = true,
}

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden"
  opt.grepformat = "%f:%l:%c:%m"
end

local mappings = {
  n = {
    -- Default buffer nav
    ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
    ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },
    ["<Leader>bd"] = {
      function()
        require("astroui.status.heirline").buffer_picker(
          function(bufnr) require("astrocore.buffer").close(bufnr) end
        )
      end,
      desc = "Close buffer from tabline",
    },

    -- Consistent forward/backward search navigation regardless of / or ?
    n = { "'Nn'[v:searchforward]", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward]", expr = true, desc = "Previous search match" },

    -- Custom mappings
    Q = { "<cmd>close<cr>", desc = "Close window", silent = true },
    ["<"] = { "<<_", desc = "Indent left" },
    [">"] = { ">>_", desc = "Indent right" },
    ss = { "<cmd>split<cr>", desc = "Horizontal split", silent = true },
    sv = { "<cmd>vsplit<cr>", desc = "Vertical split", silent = true },
    Y = { "y$", desc = "Yank to end of line" },
    vv = { "^v$", desc = "Select line" },

    -- Mundo
    U = { "<cmd>MundoToggle<cr>", desc = "Mundo Toggle", silent = true },

    -- F-keys (Outline & File Tree)
    ["<F2>"] = { "<cmd>AerialToggle<cr>", desc = "Outline Toggle", silent = true },
    ["<F3>"] = { "<cmd>Neotree toggle<cr>", desc = "Neotree Toggle", silent = true },

    -- Clipboard (Normal)
    P = { '"+p', desc = "Paste from clipboard" },

    -- Registers (<Leader>r)
    ["<Leader>r"] = { desc = "Registers" },
    ["<Leader>rw"] = { wipe_registers, desc = "Wipe all registers" },

    -- UI Toggles (<Leader>u)
    ["<Leader>uo"] = { "<cmd>setlocal cursorcolumn!<cr>", desc = "Toggle cursor column" },
    ["<Leader>uR"] = { "<cmd>setlocal readonly!<cr>", desc = "Toggle read only" },

    -- Buffer mappings (<Leader>b)
    ["<Leader>b"] = { desc = "Buffers" },
    ["<Leader>bX"] = { "<cmd>normal gg=G<cr>", desc = "Reindent Buffer" },
    ["<Leader>bp"] = { '<cmd>normal ggdG"+P<cr>', desc = "Truncate file and paste from clipboard" },
    ["<Leader>br"] = { "<cmd>normal gg=G<cr>", desc = "Reindent Buffer" },
    ["<Leader>by"] = { '<cmd>normal ggVG"+y``<cr>', desc = "Copy buffer to clipboard" },

    -- LSP (<Leader>l)
    ["<Leader>l"] = { desc = "LSP" },
    ["<Leader>lI"] = { function() require("snacks").picker.lsp_implementations() end, desc = "Implementations" },
    ["<Leader>lW"] = { "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
    ["<Leader>lD"] = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics" },
    ["<Leader>lR"] = { "<cmd>Trouble lsp toggle focus=false<cr>", desc = "Goto References" },
    ["<Leader>lT"] = { function() vim.lsp.buf.type_definition() end, desc = "Type Definition" },
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
    ["<Leader>ww"] = { "<cmd>ChooseWin<cr>", desc = "Choose window" },
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
    -- Visual maps
    Y = { '"+y', desc = "Copy to clipboard" },
    ["/"] = { 'y/<C-R>"<cr>', desc = "Search highlighted" },
    p = { '"_c<C-R>"<esc>', desc = "Paste over selected" },

    -- Align (Visual Leader a)
    ["<Leader>a"] = { desc = "Align" },
    ["<Leader>a<space>"] = { [[:Tabularize /\s<cr>]], desc = "Align at space" },
    ["<Leader>a#"] = { [[:Tabularize /#<cr>]], desc = "Align at #" },
    ["<Leader>a%"] = { [[:Tabularize /%<cr>]], desc = "Align at %" },
    ["<Leader>a&"] = { [[:Tabularize /&<cr>]], desc = "Align at &" },
    ["<Leader>a("] = { [[:Tabularize /(<cr>]], desc = "Align at (" },
    ["<Leader>a)"] = { [[:Tabularize /)<cr>]], desc = "Align at )" },
    ["<Leader>a,"] = { [[:Tabularize /,<cr>]], desc = "Align at ," },
    ["<Leader>a."] = { [[:Tabularize /\.<cr>]], desc = "Align at ." },
    ["<Leader>a:"] = { [[:Tabularize /:<cr>]], desc = "Align at :" },
    ["<Leader>a;"] = { [[:Tabularize /;<cr>]], desc = "Align at ;" },
    ["<Leader>a="] = { [[:Tabularize /=<cr>]], desc = "Align at =" },
    ["<Leader>a["] = { [[:Tabularize /[<cr>]], desc = "Align at [" },
    ["<Leader>a]"] = { [[:Tabularize /]<cr>]], desc = "Align at ]" },
    ["<Leader>a{"] = { [[:Tabularize /{<cr>]], desc = "Align at {" },
    ["<Leader>a|"] = { [[:Tabularize /|<cr>]], desc = "Align at |" },
    ["<Leader>a}"] = { [[:Tabularize /}<cr>]], desc = "Align at }" },
    ["<Leader>a¦"] = { [[:Tabularize /¦<cr>]], desc = "Align at ¦" },
  },
  t = {
    -- Terminal maps
    ["<esc>"] = { [[<C-\><C-n>]], desc = "Normal mode" },
    jk = { [[<C-\><C-n>]], desc = "Normal mode" },
  },
}

-- Add window numbers to mappings
for i = 1, 9 do
  mappings.n[tostring(i)] = {
    function()
      if #vim.api.nvim_list_wins() >= i then
        vim.api.nvim_command(":" .. i .. "wincmd w")
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
      autopairs = true,
      cmp = true,
      diagnostics = true,
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = false,
      virtual_lines = false,
      underline = true,
    },
    options = {
      opt = opt,
      g = {
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
