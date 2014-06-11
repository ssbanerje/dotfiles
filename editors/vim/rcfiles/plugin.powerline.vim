set rtp+=~/.powerline/powerline/bindings/vim
set laststatus=2 " Always display the statusline in all windows
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
if has('gui_running')
  if has("gui_gtk2")
    set guifont=Monaco\ for\ Powerline\ 10
  else
    set guifont=Monaco\ for\ Powerline:h12
  endif
else
  if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
    set t_Co=256
  endif
endif
