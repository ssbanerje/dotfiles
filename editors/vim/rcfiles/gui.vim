let g:molokai_original=1
colorscheme molokai
set background=dark

if has('gui_running')
  set guioptions-=T                   "remove the toolbar
  set guioptions+=e
  set lines=40                        "40 lines of text instead of 24
  set guitablabel=%M\ %t
  if has("mac")
    set fuoptions=maxvert,maxhorz
  endif
else
  set ttyfast
  set term=xterm                      "Make arrow and other keys work
  "Drag and drop support for mac terminal
  if $TERM_PROGRAM == "Apple_Terminal" && $TERM_PROGRAM_VERSION >= 297
    set title titlestring=%(%m\ %)%((%{expand(\"%:~:h\")})%)%a
    set icon iconstring=%{&t_IE}]7;file://%{hostname()}%{expand(\"%:p\")}%{&t_IS}
    set iconstring+=VIM
  endif
endif

if has("mac")
  nnoremap <D-≠>      16<C-w>>
  inoremap <D-≠> <C-o>16<C-w>>
  nnoremap <D-–>      16<C-w><
  inoremap <D-–> <C-o>16<C-w><
  nnoremap <D-±>      8<C-w>+
  inoremap <D-±> <C-o>8<C-w>+
  nnoremap <D-—>      8<C-w>-
  inoremap <D-—> <C-o>8<C-w>-
endif

set mouse=a                           "Use mouse everywhere (even in terminal)
set mousehide                         "Hide mouse while typing
set cursorline                        "Show current line (useful in terminal)
syntax enable                         "Color scheme for vim

augroup VIMRC_GUI
  au!
  au VimResized * :wincmd =             "Resize split screens on window resize
  au BufWrite * mkview             "Save and load folds
  au BufRead * silent loadview
augroup END

if $TMUX == ''
  set clipboard=unnamed                   "Default yank goes to mac clipboard
endif
