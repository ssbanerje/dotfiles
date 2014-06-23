" Make shell window show below the current window.
let g:vimshell_no_default_keymappings = 0
let g:vimshell_prompt_expr =
    \ 'escape($USER . ":". fnamemodify(getcwd(), ":~")."%", "\\[]()?! ")." "'
let g:vimshell_prompt_pattern = '^\%(\f\)\+\:\%(\f\|\\.\)\+% '
let g:vimshell_split_command = ''
let g:vimshell_enable_transient_user_prompt = 1

function! s:vimshell_settings()
  " custom mappings
  " Use ctrl-L to clear in insert mode.
  imap <buffer> <c-l> <ESC><Plug>(vimshell_clear)i
  " Initialize execute file list.
  nnoremap <silent><buffer> <C-j>
    \ :<C-u>Unite -buffer-name=files -default-action=lcd directory_mru<CR>
endfunction

augroup VIMRC_VIMSHELL
  au!
  autocmd FileType vimshell call s:vimshell_settings()
augroup END
