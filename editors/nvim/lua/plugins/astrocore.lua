local function wipe_registers()
  local regs = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"'
  for i = 1, #regs do
    pcall(vim.fn.setreg, regs:sub(i, i), {})
  end
  vim.notify("Registers wiped", vim.log.levels.INFO)
end

local opt = {
  titlestring = "%<%F%=%l/%L - nvim",
  textwidth = 120,
  colorcolumn = "+1",
  scrolloff = 5,
  diffopt = vim.list_extend(vim.opt.diffopt:get(), { "vertical" }),
}

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case --hidden"
end

local mappings = {
  n = {
    -- Consistent forward/backward search navigation regardless of / or ?
    n = { "'Nn'[v:searchforward]", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward]", expr = true, desc = "Previous search match" },

    -- Custom mappings
    Q = { "<cmd>close<cr>", desc = "Close window", silent = true },
    ["<"] = { "<<_", desc = "Indent left" },
    [">"] = { ">>_", desc = "Indent right" },
    vv = { "^v$", desc = "Select line" },

    -- Undo picker & privileged save
    U = { function() require("snacks").picker.undo() end, desc = "Undo history" },
    ["<Leader>W"] = { "<cmd>SudaWrite<cr>", desc = "Write with sudo" },

    -- F-keys (Outline, File Tree)
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
    ["<Leader>wm"] = { function() require("snacks").zen.zoom() end, desc = "Maximize window" },
    ["<Leader>ws"] = { "<cmd>split<cr>", desc = "Split horizontal" },
    ["<Leader>wt"] = { "<cmd>tabnew<cr>", desc = "Create new tab" },
    ["<Leader>wv"] = { "<cmd>vsplit<cr>", desc = "Split vertical" },
    ["<Leader>ww"] = {
      function()
        local win = require("window-picker").pick_window()
        if win then vim.api.nvim_set_current_win(win) end
      end,
      desc = "Pick window",
    },
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
    treesitter = {
      -- Core AstroNvim + imported community packs already install c, lua,
      -- markdown, markdown_inline, python, vim, vimdoc, dockerfile, rust,
      -- toml, and yaml.
      ensure_installed = {
        "bash",
        "cpp",
        "html",
        "json",
        "latex",
      },
      textobjects = {
        move = false,
        swap = false,
        select = {
          select_textobject = {
            ["af"] = { query = "@function.outer", desc = "Select outer function" },
            ["if"] = { query = "@function.inner", desc = "Select inner function" },
            ["ac"] = { query = "@class.outer", desc = "Select outer class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner class" },
            ["aa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
            ["ia"] = { query = "@parameter.inner", desc = "Select inner parameter" },
            ["ab"] = { query = "@block.outer", desc = "Select outer block" },
            ["ib"] = { query = "@block.inner", desc = "Select inner block" },
            ["al"] = { query = "@loop.outer", desc = "Select outer loop" },
            ["il"] = { query = "@loop.inner", desc = "Select inner loop" },
            ["as"] = { query = "@statement.outer", desc = "Select outer statement" },
            ["is"] = { query = "@statement.inner", desc = "Select inner statement" },
            ["aC"] = { query = "@comment.outer", desc = "Select outer comment" },
            ["iC"] = { query = "@comment.inner", desc = "Select inner comment" },
            ["am"] = { query = "@call.outer", desc = "Select outer call" },
            ["im"] = { query = "@call.inner", desc = "Select inner call" },
          },
        },
      },
    },
    autocmds = {
      formatoptions = {
        {
          event = "FileType",
          pattern = "*",
          callback = function()
            vim.opt_local.formatoptions:append("cjnqrlv")
            vim.opt_local.formatoptions:remove("2aot")
          end,
        },
      },
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
          callback = function(ev)
            vim.keymap.set("n", "gd", ":h <C-R><C-W><cr>", { buffer = ev.buf, silent = true })
            vim.keymap.set("v", "gd", '"*y:h <C-R>*<cr>', { buffer = ev.buf, silent = true })
          end,
        },
      },
      git = {
        {
          event = "FileType",
          pattern = "gitrebase",
          callback = function(ev)
            local remaps = {
              D = "^ciwdrop<esc>",
              E = "^ciwedit<esc>",
              F = "^ciwfixup<esc>",
              P = "^ciwpick<esc>",
              R = "^ciwreword<esc>",
              S = "^ciwsquash<esc>",
            }
            for k, v in pairs(remaps) do
              vim.keymap.set("n", k, v, { buffer = ev.buf })
            end
            vim.bo[ev.buf].undofile = false
          end,
        },
        {
          event = "BufWritePre",
          pattern = { "COMMIT_EDITMSG", "MERGE_MSG" },
          callback = function(ev)
            vim.bo[ev.buf].undofile = false
          end,
        },
      },
    },
  },
}
