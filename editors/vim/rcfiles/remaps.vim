nnoremap ; :
nnoremap j gj
nnoremap k gk
noremap <leader>bp :bprevious<cr>
noremap <leader>bn :bnext<cr>
cmap WQ wq
cmap wQ wq
vmap Q gq
nmap Q gqap
cmap Tabe tabe
vnoremap / /\v
cnoreabbrev <expr> w!!
      \((getcmdtype() == ':' && getcmdline() == 'w!!')
      \?('!sudo tee % >/dev/null'):('w!!'))
nnoremap / /\v
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
nmap <S-Down> ddp
vmap <S-Up> xkP`[V`]
vmap <S-Down> xp`[V`]  "Bubble lines
"}

"Stop highlighting search
noremap <silent>., :nohlsearch<CR>
"Start a zsh session
noremap <leader>k :VimShellPop <CR>
"Toggle Nerdtree
noremap <leader>m :VimFilerExplorer<cr>
"Toggle tagbar
noremap <leader>. :TagbarToggle<CR>
"Open Unite file viewer
nnoremap <leader>; :<C-u>Unite -buffer-name=files  -start-insert file_rec/async:!<cr>
nnoremap <leader>y :<C-u>Unite -buffer-name=yank history/yank<cr>
nnoremap <leader>b :<C-u>Unite -buffer-name=buffer buffer<cr>
nnoremap <leader>a :<C-u>Unite grep:.<cr>

"Split window horizontally
noremap <silent>ss :split<CR>
"Split window vertically
noremap <silent>vv :vsplit<CR>
"Toggle gundo
noremap <leader>u :GundoToggle<CR>
"Spell Check
map <leader>s :setlocal spell!<CR>
"Windows file endings
noremap <Leader>w mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm

