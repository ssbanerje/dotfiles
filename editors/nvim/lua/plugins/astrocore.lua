local function wipe_registers()
  local regs = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"'
  for i = 1, #regs do
    pcall(vim.fn.setreg, regs:sub(i, i), {})
  end
  vim.notify("Registers wiped", vim.log.levels.INFO)
end

local function replace_buffer_from_clipboard()
  local raw = vim.fn.getreg("+"):gsub("\r\n", "\n"):gsub("\n$", "")
  local lines = vim.split(raw, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
end

local opt = {
  titlestring = "%<%F%=%l/%L - nvim",
  textwidth = 120,
  colorcolumn = "+1",
  scrolloff = 5,
  diffopt = vim.list_extend(vim.opt.diffopt:get(), { "vertical" }),
}

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --hidden"
end

local g = {
  autoformat = false,
  tex_conceal = "",
  loaded_node_provider = 0,
  loaded_perl_provider = 0,
  loaded_python3_provider = 0,
  loaded_ruby_provider = 0,
}

if
  vim.fn.has("macunix") == 0
  and vim.fn.has("wsl") == 0
  and not vim.env.DISPLAY
  and not vim.env.WAYLAND_DISPLAY
  and not vim.env.TMUX
then
  g.clipboard = "osc52"
end

local mappings = {
  n = {
    -- Consistent forward/backward search navigation (centered) regardless of / or ?
    n = { "'Nn'[v:searchforward] . 'zzzv'", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward] . 'zzzv'", expr = true, desc = "Previous search match" },

    -- Custom mappings
    Q = { "<cmd>close<cr>", desc = "Close window", silent = true },
    ["<"] = { "<<_", desc = "Indent left" },
    [">"] = { ">>_", desc = "Indent right" },
    vv = { "^v$", desc = "Select line" },

    -- Undo picker & privileged save
    U = {
      function()
        require("snacks").picker.undo()
      end,
      desc = "Undo history",
    },
    ["<Leader>W"] = { "<cmd>SudaWrite<cr>", desc = "Write with sudo" },

    -- F-keys (Outline, File Tree)
    ["<F2>"] = { "<cmd>AerialToggle<cr>", desc = "Outline Toggle", silent = true },
    ["<F3>"] = { "<cmd>Neotree toggle<cr>", desc = "Neotree Toggle", silent = true },

    -- Registers (<Leader>r)
    ["<Leader>r"] = { desc = "Registers" },
    ["<Leader>rw"] = { wipe_registers, desc = "Wipe all registers" },

    -- UI Toggles (<Leader>u)
    ["<Leader>uo"] = { "<cmd>setlocal cursorcolumn!<cr>", desc = "Toggle cursor column" },
    ["<Leader>uR"] = { "<cmd>setlocal readonly!<cr>", desc = "Toggle read only" },

    -- Buffer extras (<Leader>b)
    ["<Leader>bP"] = { replace_buffer_from_clipboard, desc = "Replace buffer from clipboard" },
    ["<Leader>b="] = { "<cmd>normal! gg=G``<cr>", desc = "Reindent buffer" },
    ["<Leader>by"] = { "<cmd>%y+<cr>", desc = "Copy buffer to clipboard" },

    -- Windows (<Leader>w)
    ["<Leader>w"] = { false, desc = "Windows" },
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
    ["<Leader>wm"] = {
      function()
        require("snacks").zen.zoom()
      end,
      desc = "Maximize window",
    },
    ["<Leader>ws"] = { "<cmd>split<cr>", desc = "Split horizontal" },
    ["<Leader>wt"] = { "<cmd>tabnew<cr>", desc = "Create new tab" },
    ["<Leader>wv"] = { "<cmd>vsplit<cr>", desc = "Split vertical" },
    ["<Leader>ww"] = {
      function()
        local win = require("window-picker").pick_window()
        if win then
          vim.api.nvim_set_current_win(win)
        end
      end,
      desc = "Pick window",
    },
  },
  x = {
    n = { "'Nn'[v:searchforward]", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward]", expr = true, desc = "Previous search match" },
    ["/"] = { 'y/<C-R>"<cr>', desc = "Search highlighted" },
    p = { "P", desc = "Paste over selection" },
  },
  o = {
    n = { "'Nn'[v:searchforward]", expr = true, desc = "Next search match" },
    N = { "'nN'[v:searchforward]", expr = true, desc = "Previous search match" },
  },
  t = {
    jk = { [[<C-\><C-n>]], desc = "Normal mode" },
  },
}

-- Direct numeric window jumps (<M-1..9> and <Leader>1..9)
for i = 1, 9 do
  local function goto_win()
    if #vim.api.nvim_list_wins() >= i then
      vim.cmd(i .. "wincmd w")
    end
  end
  mappings.n["<M-" .. i .. ">"] = { goto_win, desc = "Goto window " .. i }
  mappings.n["<Leader>" .. i] = { goto_win, desc = "Goto window " .. i }
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = opt,
      g = g,
    },
    mappings = mappings,
    treesitter = {
      -- Let VimTeX own `.tex` syntax/math zones while keeping `latex` active for Markdown math injections.
      highlight = function(lang, bufnr)
        return lang ~= "latex" or vim.bo[bufnr].filetype ~= "tex"
      end,
      -- Core AstroNvim + imported community packs already install bash, c, lua,
      -- markdown, markdown_inline, python, query, vim, vimdoc, dockerfile, rust,
      -- toml, and yaml.
      ensure_installed = {
        "bibtex",
        "cpp",
        "html",
        "json",
        "latex",
        "regex",
      },
      textobjects = {
        select = {
          select_textobject = {
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
          callback = function(ev)
            if vim.bo[ev.buf].buftype ~= "" then
              return
            end
            if vim.wo.number and vim.fn.mode() ~= "i" then
              vim.wo.relativenumber = true
            end
            vim.wo.cursorline = true
          end,
        },
        {
          event = { "BufLeave", "FocusLost", "InsertEnter", "WinLeave" },
          pattern = "*",
          callback = function(ev)
            if vim.bo[ev.buf].buftype ~= "" then
              return
            end
            if vim.wo.number then
              vim.wo.relativenumber = false
            end
            vim.wo.cursorline = false
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
            vim.keymap.set("x", "gd", '"zy:h <C-R>z<cr>', { buffer = ev.buf, silent = true })
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
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        if opts.treesitter and opts.treesitter.textobjects then
          opts.treesitter.textobjects.move = nil
          opts.treesitter.textobjects.swap = nil
        end
      end,
    },
  },
}
