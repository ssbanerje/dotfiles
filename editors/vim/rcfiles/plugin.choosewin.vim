" use overlay feature
let g:choosewin_overlay_enable = 1

" workaround for overlay font broken on mutibyte buffer.
let g:choosewin_overlay_clear_multibyte = 1

" tmux like overlay color
let g:choosewin_color_overlay = {
      \ 'gui': ['DodgerBlue3', 'DodgerBlue3'],
      \ 'cterm': [25, 25]
      \ }
let g:choosewin_color_overlay_current = {
      \ 'gui': ['firebrick1', 'firebrick1'],
      \ 'cterm': [124, 124]
      \ }

