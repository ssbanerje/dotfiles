function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
end

lvim.autocommands.custom_groups = {
	-- Style when leaving and entering buffers
	{ "BufEnter,FocusGained,InsertLeave,WinEnter", "*", 'if &nu && mode() != "i" | set rnu | endif' },
  { "BufEnter,FocusGained,InsertLeave,WinEnter", "*", "set cursorline" },
	{ "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "if &nu | set nornu | endif" },
  { "BufLeave,FocusLost,InsertEnter,WinLeave", "*", "set nocursorline" },
  -- Resize windows
  { "VimResized", "*", "tabdo wincmd =" },
  -- Reload file on change
  { "FocusGained", "*", ":checktime" },
  -- Windows to close on q
  { "Filetype", "help,man", "nnoremap <buffer><silent> q <cmd>close<cr>" },
  -- Terminal keymaps
  { "TermOpen", "term://*", "lua set_terminal_keymaps()" }
}
