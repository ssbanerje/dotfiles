filetype plugin on
filetype indent on

set undolevels=1000
set showmatch
set nu!
set showfulltag
set nolist
set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
set colorcolumn=800

" Paste with indent
nnoremap <leader>p p
nnoremap <leader>P P
nnoremap p p'[v']=
" Textmate style indentation
nmap <D-]> >>
vmap <D-]> >gv
imap <D-]> <C-0>>>

func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc

func! ListChars()
  set list
  set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
  set showbreak=↪
endfunc
command! L call ListChars()

augroup VIMRC_PROG
  au!
  autocmd BufWrite *.tex,*.bib,*.c,*.cpp,*.cc,*.h,*.m,*.js,*.py,*.pl,*.pm :call DeleteTrailingWS()
augroup END

"Git {
  source ~/.vim/rcfiles/git.vim
"}

"C/C++ {
  source ~/.vim/rcfiles/cpp.vim
"}

"LaTeX {
  source ~/.vim/rcfiles/tex.vim
"}

"Perl {
  source ~/.vim/rcfiles/perl.vim
"}

"WebDev {
  source ~/.vim/rcfiles/webdev.vim
"}

"Python {
  source ~/.vim/rcfiles/python.vim
"}
