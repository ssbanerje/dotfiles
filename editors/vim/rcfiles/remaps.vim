" ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗
"██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║
"██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║
"██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║
"╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗
" ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

" Convenience
nnoremap ; :
cmap Q q
cmap WQ wq
cmap wQ wq
vmap Q gq
nmap Q gqap
cmap Tabe tabe

" Use magic based regex for searching
nnoremap / /\v
vnoremap / /\v
cnoremap %s/ %smagic/
cnoremap \>s/ \>smagic/
nnoremap :g/ :g/\v
nnoremap :g// :g//

" Move around wrapped lines
nnoremap j gj
nnoremap k gk

" Move between bufferes
noremap <leader>bp :bprevious<cr>
noremap <leader>bn :bnext<cr>

"Split window horizontally
noremap <silent>ss :split<CR>

"Split window vertically
noremap <silent>vv :vsplit<CR>

"Window navigation and resizing
map <C-H> <C-W>h
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
map <S-H> <C-W><
map <S-J> <C-W>+
map <S-K> <C-W>-
map <S-L> <C-W>>

"Bubble lines and bocks
nmap <S-Up> ddkP
vmap <S-up> xkp`[v`]
vmap <S-down> xp`[v`]
nmap <S-down> ddp

" Get sudo access to a file
cnoreabbrev <expr> w!!
      \((getcmdtype() == ':' && getcmdline() == 'w!!')
      \?('!sudo tee % >/dev/null'):('w!!'))


"██╗     ███████╗ █████╗ ██████╗ ███████╗██████╗
"██║     ██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗
"██║     █████╗  ███████║██║  ██║█████╗  ██████╔╝
"██║     ██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██╗
"███████╗███████╗██║  ██║██████╔╝███████╗██║  ██║
"╚══════╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝


"Stop highlighting search
noremap <silent>., :nohlsearch<CR>

"Start a zsh session
noremap <leader>k :VimShellPop <CR>

"Toggle Nerdtree
noremap <leader>m :VimFilerExplorer<cr>

"Toggle tagbar
noremap <leader>. :TagbarToggle<CR>

"Toggle gundo
noremap <leader>u :GundoToggle<CR>

"Toggle Spell Check
map <leader>s :setlocal spell!<CR>

" Start unite
nnoremap <leader>q :Unite -buffer-name=unite<cr>

" Find text in current file
nnoremap <leader>f :Unite -buffer-name=find -start-insert line<cr>

" List all buffers currently open
nnoremap <leader>b :Unite -buffer-name=buffer buffer<cr>

" List all tabs currently open
nnoremap <leader>t :Unite -buffer-name=tab tab<cr>

" List all windows currently open
nnoremap <leader>w :Unite -buffer-name=window window<cr>

" Execute a program
nnoremap <leader>x :Unite -buffer-name=launcher -start-insert launcher<cr>

" Recursively search files in the current directory
nnoremap <leader>; :Unite -buffer-name=files  -start-insert file_rec/async:!<cr>

" Show clipboard
nnoremap <leader>y :Unite -buffer-name=yank history/yank<cr>

" Use grep/ack on the current file
nnoremap <leader>a :Unite -buffer-name=grep -start-insert grep:.<cr>

" Execute git commands
nnoremap <leader>g :Unite -buffer-name=git -start-insert giti<cr>

" Change Windows file endings to UNIX
noremap <Leader>W mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm


"███╗   ███╗ █████╗  ██████╗
"████╗ ████║██╔══██╗██╔════╝
"██╔████╔██║███████║██║
"██║╚██╔╝██║██╔══██║██║
"██║ ╚═╝ ██║██║  ██║╚██████╗
"╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝

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

