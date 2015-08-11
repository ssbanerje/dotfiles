" ██████╗ ███████╗███╗   ██╗███████╗██████╗ ██╗ ██████╗
"██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██║██╔════╝
"██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝██║██║
"██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██║██║
"╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║╚██████╗
" ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝

" Undo upto 1000 actions
set undolevels=1000

" Show matching brackets
set showmatch

" Show full names for completion in insert mode
set showfulltag

" Set listmode off and change listmode characters
func! ListChars()
  set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
  set showbreak=↪
  set list
endfunc
" Use L to toggle list mode
command! L call ListChars()

" Color the column after textwidth
set cc=+1
hi ColorColumn ctermbg=lightgrey guibg=lightgrey

" Paste with indent
nnoremap <leader>p p
nnoremap <leader>P P
nnoremap p p'[v']=

" Textmate style indentation
nmap <leader> >>
vmap <D-]> >gv
imap <D-]> <C-0>>>

" Delete the trailing the white spaces on source code files
func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
augroup VIMRC_PROG
  au!
  autocmd BufWrite *.tex,*.bib,*.c,*.cpp,*.cc,*.h,*.m,*.js,*.py,*.pl,*.pm :call DeleteTrailingWS()
augroup END

"██╗      █████╗ ███╗   ██╗ ██████╗ ██╗   ██╗ █████╗  ██████╗ ███████╗
"██║     ██╔══██╗████╗  ██║██╔════╝ ██║   ██║██╔══██╗██╔════╝ ██╔════╝
"██║     ███████║██╔██╗ ██║██║  ███╗██║   ██║███████║██║  ███╗█████╗
"██║     ██╔══██║██║╚██╗██║██║   ██║██║   ██║██╔══██║██║   ██║██╔══╝
"███████╗██║  ██║██║ ╚████║╚██████╔╝╚██████╔╝██║  ██║╚██████╔╝███████╗
"╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

" Git
source ~/.vim/rcfiles/git.vim

" C/C++
source ~/.vim/rcfiles/cpp.vim

" LaTeX
source ~/.vim/rcfiles/tex.vim

" Perl
source ~/.vim/rcfiles/perl.vim

" WebDev
source ~/.vim/rcfiles/webdev.vim

" Python
source ~/.vim/rcfiles/python.vim

