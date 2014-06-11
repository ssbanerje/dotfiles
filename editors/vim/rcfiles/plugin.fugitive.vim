augroup VIMRC_fugitive
  au!
  au BufEnter index let Tlist_Auto_Update = 0
  au BufLeave index let Tlist_Auto_Update = 1
  au BufEnter fugitive://* let Tlist_Auto_Update = 0
  au BufLeave fugitive://* let Tlist_Auto_Update = 1
augroup END

