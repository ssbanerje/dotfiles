"--------------------------------------------------------------------------------------------------------------------------
"
"VIMRC file
"Author = Subho Sankar Banerjee
"Date = Sun Aug 26 10:12:18 IST 2012
"
"---------------------------------------------------------------------------------------------------------------------------

set nocp                                  "No copatibility with vi
if has("syntax")                          "Turn on syntax
	syntax on
endif

if executable('/bin/zsh')                 "Because bash is so old school
	set shell=/bin/zsh
endif

"Pathogen {
	call pathogen#infect()                  "Set up pathogen
	call pathogen#helptags()
"}

"General_Settings {
	let g:mapleader=","                     "Change mapleader from \ to ,
	let mapleader=","                       "Change mapleader from \ to ,
	let g:maplocalleader = "\\"             "Set localleader to \
	let maplocalleader = "\\"               "Set localleader to \
	set title                               "Set title in terminal
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
	set wildmode=list,longest               "Emulate terminal for auto complete
	set wildignore=.svn,CVS,.git,.hg,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif,.DS_Store,*.aux,*.out,*.toc,*.pyc
	set hidden                              "Switch buffers without saving
	set backspace=indent,eol,start          "Handle backspaces better
	set wildmenu                            "Smarter command line
	set wildmode=list:longest,full
	set gdefault                            "Smarter substitution
	set clipboard=unnamed                   "Default yank goes to mac clipboard"
	set dictionary=/usr/share/dict/words    "Set dictionary
	set backupskip=/tmp/*,/private/tmp/*    "Edit crontab files
	set lbr                                 "Set default line width
	set tw=500
	set pastetoggle=<F2>

	"GUI Settings {
		let g:molokai_original=1
		colorscheme molokai
		set background=dark
		if has('gui_running')
			set guioptions-=T                   "remove the toolbar
			set guioptions+=e
			set lines=40                        "40 lines of text instead of 24
			set guitablabel=%M\ %t
			set fuoptions=maxvert,maxhorz
		else
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
		au VimResized * :wincmd =             "Resize split screens on window resize
		autocmd bufwritepost .vimrc call Pl#Load()
	"}

	"Powerline {
		set laststatus=2                      "Status line configuration
		"let g:Powerline_colorscheme='skwp'
		call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo') "Get trailing whitespace
		if has('gui_running')
			if has("gui_gtk2")
				set guifont=Monaco\ for\ Powerline\ 12
			else
				set guifont=Monaco\ for\ Powerline:h12
			endif
			let g:Powerline_symbols = 'fancy'
		else
			set t_Co=256
			let g:Powerline_symbols = 'unicode'
		endif
	"}

	"Supertab {
		let g:SuperTabDefaultCompletionType="context"
		set completeopt=menuone,longest,preview
	"}

	"Minibuffer {
		let g:miniBufExplMapWindowNavVim = 1
		let g:miniBufExplMapWindowNavArrows = 1
		let g:miniBufExplMapCTabSwitchBufs = 1
		let g:miniBufExplModSelTarget = 1
	"}

	"Yank Ring {
		let g:yankring_history_dir = '~/.vim/vim_backups'
		let g:yankring_replace_n_pkey = '<leader>['
		let g:yankring_replace_n_nkey = '<leader>]'
		nmap <leader>y :YRShow<cr>
	"}

	"Align {
		let g:DrChipTopLvlMenu= ""
	"}

	"NerdTree {
		let NERDTreeIgnore=['\.vim$', '\~$', '\.pyc$', '\.swp$']
		let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$',  '\~$']
		let NERDTreeShowHidden=1
		autocmd WinEnter * call s:CloseIfOnlyNerdTreeLeft()
		func! s:CloseIfOnlyNerdTreeLeft()
			if exists("t:NERDTreeBufName")
				if bufwinnr(t:NERDTreeBufName) != -1
					if winnr("$") == 1
						q
					endif
				endif
			endif
		endfunc
	"}

	"Conque {
		let g:ConqueTerm_ReadUnfocused = 1
	"}

	"vimrc {
		au BufWritePost .vimrc so ~/.vimrc          "Reload vimrc automatically when changes are written
	"}

	"LocateOpen {
		let g:locateopen_smartcase = 1
	"}

	"Rainbow Parenthesis {
		nnoremap <leader>rp :RainbowParenthesesToggle<CR>
		au Syntax * RainbowParenthesesToggle
		au Syntax * RainbowParenthesesLoadRound
		au Syntax * RainbowParenthesesLoadSquare
		au Syntax * RainbowParenthesesLoadBraces
		au Syntax * RainbowParenthesesLoadChevrons
	"}

	"Notes {
		let g:notes_directory = '~/Documents/Notes'
		let g:notes_suffix = '.txt'
	"}

	"Headlights {
		let g:headlights_spillover_menus = 1
		let g:headlights_show_functions = 1
	"}

	"Tabman {
		let g:tabman_toggle = '<leader>tt'
		let g:tabman_focus = '<leader>tf'
	"}

	"CTags {
		map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
		map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
		map <C-]> :split <CR>:exec("tag ".expand("<cword>"))<CR>
	"}

	"Syntatstic {
		let g:syntastic_enable_signs=1
		let g:syntastic_auto_loc_list=1
	"}

	"Some remaps {
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
		vmap <S-Down> xp`[V`]	"Bubble lines
	"}

	"Convenience {
		"Stop highlighting search
		noremap <silent>., :nohlsearch<CR>
		"Start a zsh session
		noremap <silent>,k :ConqueTerm zsh<CR>
		"Start commandT
		noremap <silent>,; :CommandT<CR>
		"Toggle Nerdtree
		noremap <silent>,m :NERDTreeToggle<cr>
		"Toggle tagbar
		noremap <silent>,. :TagbarToggle<CR>
		"Split window horizontally
		noremap <silent>ss :split<CR>
		"Split window vertically
		noremap <silent>vv :vsplit<CR>
		"Toggle gundo
		noremap <silent>,u :GundoToggle<CR>
		"Spell Check
		map <leader>s :setlocal spell!<CR>
		"Windows file endings
		noremap <Leader>w mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm
		"Open cope
		"map <leader>x :botright cope<CR>
	"}
"}

"Programming {
	filetype plugin on                      "Set file type plugins
	filetype indent on
	set ofu=syntaxcomplete#Complete
	set undolevels=1000                     "Maximum size of command buffer
	set showmatch                           "Show matching brackets
	set nu                                  "Show line numbers
	set showfulltag                         "Set details about how tags are used
	nnoremap <leader>p p                    "Autoindent after pasting
	nnoremap <leader>P P
	nnoremap p p'[v']=
	set colorcolumn=800
	nmap <D-]> >>                           "Textmate style indent
	vmap <D-]> >gv
	imap <D-]> <C-0>>>
	func! DeleteTrailingWS()
		exe "normal mz"
		%s/\s\+$//ge
		exe "normal `z"
	endfunc
	autocmd BufWrite *.tex,*.bib,*.c,*.cpp,*.cc,*.h,*.m,*.js,*.py,*.pl,*.pm :call DeleteTrailingWS()

	"Git {
		match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'
		if has('autocmd') "Git commit mesages have spell-check + insert mode
			if has('spell')
				au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell
			endif
			au BufNewFile,BufRead COMMIT_EDITMSG call feedkeys('ggi', 't')
		endif
	"}

	func! ListChars()
		set list
		set listchars=tab:▸\ ,eol:¬,trail:⋅,extends:❯,precedes:❮
		set showbreak=↪
	endfunc
	command! L call ListChars()

	"C/C++ {
		let g:clang_complete_copen = 1
		let g:clang_use_library = 1
		let g:clang_complete_patterns = 1
		let g:clang_complete_macros = 1
		let g:syntastic_c_check_header = 1
		let g:syntastic_cpp_check_header = 1
		let g:syntastic_cpp_compiler = 'clang++'
		au FileType c,cpp se cin                               "Indentation for C/C++
		au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
		au FileType c,cpp set completeopt=menuone,menu,longest,preview
	"}

	"LaTeX {
		au FileType tex set tw=150
		au FileType tex set grepprg=grep\ -nH\ $*
		au FileType tex let g:tex_flavor='latex'
	"}

	"Perl {
		au FileType perl let perl_include_pod = 1
		au FileType perl let perl_extended_vars = 1
		au FileType perl set makeprg=perl\ -c\ %\ $*
		au FileType perl set errorformat=%f:%l:%m
		au FileType perl set autowrite
		au FileType perl set foldenable
		au FileType perl set foldmethod=syntax
		au FileType perl syn region POD start=/^=head[123]/ end=/^=cut/ fold
	"}

	"Javascript {
		au FileType javascript setl fen
		au FileType javascript setl nocindent
		au BufRead,BufNewFile *.json set filetype=json
		au FileType javascript set dictionary+=$HOME/.vim/bundle/vim-node/dict/node.dict
		au FileType html,xml let g:html_indent_inctags = "html,body,head,tbody"
		au FileType html,xml let g:html_indent_script1 = "inc"
		au FileType html,xml let g:html_indent_style1 = "inc"
	"}

	"Python {
		let python_highlight_all = 1
		let g:pymode_doc_key = 'D'
		let g:pymode_folding = 0
		let g:pymode_lint_checker = "pyflakes"             "pep8 and others!
		let g:pydoc_open_cmd = 'split'
		let g:pydoc_cmd = 'python -m pydoc'
		au FileType python syn keyword pythonDecorator True None False self
		au BufNewFile,BufRead *.jinja set syntax=htmljinja
		au BufNewFile,BufRead *.mako set ft=mako
		au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
		au FileType python set omnifunc=RopeOmni
		"au FileType python set omnifunc=pythoncomplete#Complete
	"}
"}

