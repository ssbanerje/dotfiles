let g:startify_list_order = [
      \ ['MRU files:'],
      \ 'files',
      \ ['MRU files in current directory:'],
      \ 'dir',
      \ ['Sessions:'],
      \ 'sessions',
      \ ['Bookmarks:'],
      \ 'bookmarks',
      \ ]

let g:startify_skiplist = ['COMMIT_EDITMSG']

let g:startify_custom_header = [
                \ '                    ██╗   ██╗██╗'                    ,
                \ '                    ██║   ██║██║'                    ,
                \ '                    ██║   ██║██║'                    ,
                \ '                    ╚██╗ ██╔╝██║'                    ,
                \ '                     ╚████╔╝ ██║'                    ,
                \ '                      ╚═══╝  ╚═╝'                    ]

hi StartifyBracket ctermfg=240
hi StartifyFile    ctermfg=147
hi StartifyFooter  ctermfg=240
hi StartifyHeader  ctermfg=114
hi StartifyNumber  ctermfg=215
hi StartifyPath    ctermfg=245
hi StartifySlash   ctermfg=240
hi StartifySpecial ctermfg=240
