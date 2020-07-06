"=============================================================================
" undotree.vim --- undotree layer file for SpaceVim
" Copyright (c) 2016-2020 Subho Banerjee
" Author: Subho Banerjee <ssbaner2@illinois.edu>
" URL: https://spacevim.org
" License: MIT
"=============================================================================

""
" @section undotree, layer-undotree
" @parentsection layers
" This is doc for this layer:
"
" @subsection Key Binding
" >
" Mode      Key     Function
" -----------------------------------
" normal    <F4>    Toggle undotree
" <
"
" @subsection Layer Options
" >
" Name                 Description                  Default
" ----------------------------------------------------------
" windows_layout      Window layout for undotree    4
" split_width         Width of undootree window     30
" diff_panel_height   Height of the diff panel      10
" <
"
" @subsection Global Options
" See [mbbill/undootree](https://github.com/mbbill/undotree/blob/master/plugin/undotree.vim)
"

let s:windows_layout = 4
let s:split_width = 30
let s:diff_panel_height = 10


function! SpaceVim#layers#undotree#plugins() abort
  let plugins = []
  call add(plugins, ['mbbill/undotree', {'merged': 0, 'on_cmd': ['UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus']}])
  return plugins
endfunction


function! SpaceVim#layers#undotree#config() abort
  " Set global options
  let g:undotree_WindowLayout = s:windows_layout
  let g:undotree_SplitWidth = s:split_width
  let g:undotree_DiffpanelHeight = s:diff_panel_height
  let g:undotree_SetFocusWhenToggle = 1

  " Add mappings
  noremap <silent> <F4> :UndotreeToggle<CR>

  " Setup autocmds
  augroup spacevim_layer_undotree
    autocmd!
    autocmd FileType undotree nnoremap <buffer><silent> q :call undotree#UndotreeHide()<CR>
    autocmd FileType diff nnoremap <buffer><silent> q :call undotree#UndotreeHide()<CR>
  augroup end
endfunction

function! SpaceVim#layers#undotree#set_variable(var) abort
  let s:windows_layout = get(a:var, 'windows_layout', s:windows_layout)
  let s:split_width = get(a:var, 'split_width', s:split_width)
  let s:diff_panel_height = get(a:var, 'diff_panel_height', s:diff_panel_height)
endfunction

