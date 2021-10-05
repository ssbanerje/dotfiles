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
-- @param evt Events for which the auto command will be triggered
-- @param file Inputs to events for triggering the command
-- @param action String command or Lua function corresponding to the action
local function autocmd(evt, file, action)
  local action_str
  if type(action) == "function" then
    local id = #_G.user_autocmd_actions + 1
    _G.user_autocmd_actions[id] = action
    action_str = "lua _G.user_autocmd_actions[" .. id .. "]()"
  else
    action_str = action
  end
  return { evt, file, action_str }
end

-- Get folder for lvim config files
local config_folder = vim.fn.fnamemodify(vim.fn.resolve(require("config").path), ":p:h")

-- }}}

-- Reload config
augroup "_general_settings" {
  autocmd("BufWritePost", config_folder .. "/lua/user/*", "lua require('utils').reload_lv_config()"),
}

-- Reload plugins
augroup "_packer_compile" {
  autocmd("BufWritePost", config_folder .. "/lua/user/plugins.lua", "PackerCompile"),
}

augroup "custom_groups" {
  -- Command window
  autocmd("CmdWinEnter", "*", "close"),

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

  -- Resize windows
  autocmd("VimResized", "*", "tabdo wincmd ="),

  -- Reload file on change
  autocmd("FocusGained", "*", "checktime"),

  -- Windows to close on q
  autocmd("Filetype", "help,man,qf,null-ls-info", "nnoremap <buffer><silent> q <cmd>close<cr>"),

  -- Git rebase
  autocmd("FileType", "gitrebase", function()
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
    vim.bo.undofile = false
  end),

  -- Git undofiles
  autocmd("BufWritePre", "COMMIT_EDITMSG,MERGE_MSG", "setlocal noundofile"),
}

-- vim:set fdm=marker:
