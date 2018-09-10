" SpaceVim Options: {{{
let g:spacevim_enable_debug = 1
let g:spacevim_realtime_leader_guide = 1
let g:spacevim_buffer_index_type = 0
let g:spacevim_enable_os_fileformat_icon = 1
let g:spacevim_enable_tabline_filetype_icon = 1
let g:spacevim_enable_statusline_display_mode = 0
let g:spacevim_enable_vimfiler_welcome = 1
let g:spacevim_github_username = 'ssbanerje'
let g:spacevim_auto_disable_touchpad = 1
" }}}

" SpaceVim Layers: {{{
call SpaceVim#layers#load('git')
call SpaceVim#layers#load('github')
call SpaceVim#layers#load('unite')
call SpaceVim#layers#load('tags')
call SpaceVim#layers#load('autocomplete', {
        \ 'auto-completion-return-key-behavior' : 'nil',
        \ 'auto-completion-tab-key-behavior' : 'smart',
        \ 'auto-completion-complete-with-key-sequence' : 'nil',
        \ 'auto-completion-complete-with-key-sequence-delay' : 0.1,
        \ })
call SpaceVim#layers#load('shell')

call SpaceVim#layers#load('lang#c')
call SpaceVim#layers#load('lang#go')
call SpaceVim#layers#load('lang#python')
call SpaceVim#layers#load('lang#vim')
call SpaceVim#layers#load('lang#toml')
call SpaceVim#layers#load('lang#markdown')
call SpaceVim#layers#load('lang#rust')
call SpaceVim#layers#load('lang#java')
call SpaceVim#layers#load('lang#scala')
call SpaceVim#layers#load('lang#tmux')
call SpaceVim#layers#load('lsp', {
    \ 'filetypes' : ['rust', 'python' ],
    \ })
" }}}

" My Privite Config: {{{
" }}}

