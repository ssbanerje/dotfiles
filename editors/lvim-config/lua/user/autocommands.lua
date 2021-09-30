function _G.git_rebase_mappings()
  local remaps = {
    p = "^ciwpick<esc>",
    r = "^ciwreword<esc>",
    e = "^ciwedit<esc>",
    s = "^ciwsquash<esc>",
    f = "^ciwfixup<esc>",
    d = "^ciwdrop<esc>",
  }
  for k, v in pairs(remaps) do
    vim.api.nvim_buf_set_keymap(0, "n", k, v, { noremap = true })
  end
end

local config_folder = vim.fn.fnamemodify(vim.fn.resolve(require("config").path), ":p:h")

lvim.autocommands.custom_groups = {
  -- Reload config
  { "BufWritePost", config_folder .. "/lua/user/plugins.lua", "PackerCompile" },
  { "BufWritePost", config_folder .. "/lua/user/*", "lua require('utils').reload_lv_config()" },

  -- Style when leaving and entering buffers
  { "BufEnter,FocusGained,InsertLeave,WinEnter", "*", 'if &nu && mode() != "i" | set rnu | endif' },
  { "BufEnter,FocusGained,InsertLeave,WinEnter", "*", "set cursorline" },
  { "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "if &nu | set nornu | endif" },
  { "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "set nocursorline" },

  -- Resize windows
  { "VimResized", "*", "tabdo wincmd =" },

  -- Reload file on change
  { "FocusGained", "*", "checktime" },

  -- Windows to close on q
  { "Filetype", "help,man,qf", "nnoremap <buffer><silent> q <cmd>close<cr>" },

  -- Git Rebase
  { "FileType", "gitrebase", "lua git_rebase_mappings()" },
}
