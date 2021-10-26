-- Helpers {{{

_G.user_autocmd_actions = {}

--- Define or udpate an augroup
-- @param name Name of the autogroup
local function augroup(name)
  return function(entries)
    if lvim.autocommands[name] == nil or #lvim.autocommands[name] == 0 then
      lvim.autocommands[name] = entries
    else
      vim.list_extend(lvim.autocommands[name], entries)
    end
  end
end

--- Define an autocommand
-- @param trigger Events for which the auto command will be triggered
-- @param pattern Inputs to events for triggering the command
-- @param action String command or Lua function corresponding to the action
local function autocmd(trigger, pattern, action)
  local action_str
  if type(action) == "function" then
    local id = #_G.user_autocmd_actions + 1
    _G.user_autocmd_actions[id] = action
    action_str = "lua _G.user_autocmd_actions[" .. id .. "]()"
  else
    action_str = action
  end
  return { trigger, pattern, action_str }
end

-- Get folder for lvim config files
local config_folder = vim.fn.fnamemodify(vim.fn.resolve(require("lvim.config"):get_user_config_path()), ":p:h")

-- }}}

-- Reset builtins
lvim.autocommands._formatoptions = nil

augroup "_general_settings" {
  -- Reload config
  autocmd("BufWritePost", config_folder .. "/lua/user/*", "lua require('lvim.config'):reload()"),
}

augroup "custom_theme" {
  -- Style when entering buffers
  autocmd("BufEnter,FocusGained,InsertLeave,WinEnter", "*", function()
    if vim.opt.nu and vim.fn.mode() ~= "i" then
      vim.opt.rnu = true
    end
    vim.opt.cursorline = true
  end),

  -- Style when leaving buffers
  autocmd("BufLeave,FocusLost,InsertEnter,WinLeave", "*", function()
    if vim.opt.nu then
      vim.opt.rnu = false
    end
    vim.opt.cursorline = false
  end),
}

augroup "vim_help_navigation" {
  -- Navigate vim help
  autocmd("Filetype", "help", "nnoremap <buffer><silent> gd :h <C-R><C-W><cr>"),
  autocmd("Filetype", "help", 'vnoremap <buffer><silent> gd "*y:h <C-R>*<cr>'),
}

augroup "_git" {
  -- Git rebase
  autocmd("FileType", "gitrebase", function()
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
  end),

  -- Git undofiles
  autocmd("BufWritePre", "COMMIT_EDITMSG,MERGE_MSG", "setlocal noundofile"),
}

-- vim:set fdm=marker:
