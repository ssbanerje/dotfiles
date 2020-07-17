"=============================================================================
" my_motions.vim --- Custom motion layer for SpaceVim
" Copyright (c) 2016-2020 Subho Banerjee
" Author: Subho Banerjee <ssbaner2@illinois.edu>
" URL: https://spacevim.org
" License: MIT
"=============================================================================

function! SpaceVim#layers#my_motions#plugins() abort
  let plugins = []
  call add(plugins, ['xerus2000/argtextobj.vim', {'merged': 0}])
  call add(plugins, ['chaoren/vim-wordmotion', {'merged': 0}])
  return plugins
endfunction

function! SpaceVim#layers#undotree#config() abort
  " Restore vim behavior
  nmap dw de
  nmap dW dE
  nmap cw ce
  nmap cW cE
endfunction

