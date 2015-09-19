" ██████╗ ███████╗███╗   ██╗███████╗██████╗ ██╗ ██████╗
"██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██║██╔════╝
"██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝██║██║
"██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██║██║
"╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║╚██████╗
" ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝

" Enable syntax highlighting
syntax enable

" Highlight the current line being edited
set cursorline

" Enable use of a mouse
set mouse=a
set mousehide

" Set TTY type and color schemes
set ttyfast
set term=xterm
if exists('$TMUX')
  set term=screen-256color
endif

" Save and load fold information
augroup VIMRC_GUI_FOLDS
  let &viewdir=expand("$HOME") . "/.vim/viewdir"
  if !isdirectory(expand(&viewdir))
    call mkdir(expand(&viewdir), "p", 451)
  endif
  au!
  au BufWrite * mkview
  au BufRead * silent loadview
augroup END

" Resize panes on window resize
augroup VIMRC_GUI_RESIZE
  au VimResized * :wincmd =
augroup END

" Settings for the choosewin plugin
source ~/.vim/rcfiles/plugin.choosewin.vim

" ██████╗ ██████╗ ██╗      ██████╗ ██████╗ ███████╗
"██╔════╝██╔═══██╗██║     ██╔═══██╗██╔══██╗██╔════╝
"██║     ██║   ██║██║     ██║   ██║██████╔╝███████╗
"██║     ██║   ██║██║     ██║   ██║██╔══██╗╚════██║
"╚██████╗╚██████╔╝███████╗╚██████╔╝██║  ██║███████║
" ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

" Define the colorscheme currently in use
let my_vim_colorscheme = "gruvbox"

" Settings for the different colorschemes
if my_vim_colorscheme ==? "molokai"
 let g:molokai_original=1
 colorscheme molokai
elseif my_vim_colorscheme ==? "gruvbox"
  let g:gruvbox_italic=0
  let g:gruvbox_bold=0
  let g:gruvbox_underline=0
  colorscheme gruvbox
  set background=dark
endif

" ██████╗ ██╗   ██╗██╗███╗   ███╗
"██╔════╝ ██║   ██║██║████╗ ████║
"██║  ███╗██║   ██║██║██╔████╔██║
"██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
"╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
" ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

if has('gui_running')
  set guioptions-=T                   "remove the toolbar
  set guioptions+=e
  set guitablabel=%M\ %t
endif


"███╗   ███╗ █████╗  ██████╗
"████╗ ████║██╔══██╗██╔════╝
"██╔████╔██║███████║██║
"██║╚██╔╝██║██╔══██║██║
"██║ ╚═╝ ██║██║  ██║╚██████╗
"╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝

if has("mac")
  " Enable Mac full screen mode for MacVIM
  set fuoptions=maxvert,maxhorz

  "Drag and drop support for mac terminal
  if $TERM_PROGRAM == "Apple_Terminal" && $TERM_PROGRAM_VERSION >= 297
    set title titlestring=%(%m\ %)%((%{expand(\"%:~:h\")})%)%a
    set icon iconstring=%{&t_IE}]7;file://%{hostname()}%{expand(\"%:p\")}%{&t_IS}
    set iconstring+=VIM
  endif

  "Different cursors for iterm under tmux
  if exists('$ITERM_PROFILE')
    if exists('$TMUX')
      let &t_SI = "\<Esc>[3 q"
      let &t_EI = "\<Esc>[0 q"
    else
      let &t_SI = "\<Esc>]50;CursorShape=1\x7"
      let &t_EI = "\<Esc>]50;CursorShape=0\x7"
    endif
  endif
endif
