let g:mapleader=","                     "Change mapleader from \ to ,
let mapleader=","                       "Change mapleader from \ to ,
let g:maplocalleader = "\\"             "Set localleader to \
let maplocalleader = "\\"               "Set localleader to \
set so=7                                "7 lines to cursor

command! T setlocal noexpandtab
command! S setlocal expandtab

set magic                               "Set magic on for regular expressions
set backup                              "Set up location for creating backups of buffers
set backupdir=$HOME/.vim/vim_backups/
set directory=$HOME/.vim/vim_swp/
set incsearch                           "Incremental search
set hlsearch                            "Highlight text being searched for
set smartcase                           "ignore case if input is lowercase in searched
set scrolloff=5                         "Keep buffer between top and bottom of screen
set hidden                              "Switch buffers without saving
set backspace=indent,eol,start          "Handle backspaces better
set wildmenu                            "Autocompletion in opening files
set wildmode=list:longest,full
set wildignore=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,.DS_Store,*.aux,*.out,*.toc,*.pyc
set gdefault                            "Smarter substitution
set dictionary=/usr/share/dict/words    "Set dictionary
set backupskip=/tmp/*,/private/tmp/*    "Edit crontab files
set lbr                                 "Set default line width
set tw=500
set pastetoggle=<F2>
set shiftwidth=2
set expandtab

