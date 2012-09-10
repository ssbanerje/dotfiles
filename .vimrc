"--------------------------------------------------------------------------------------------------------------------------
"
"VIMRC file
"Author = Subho Sankar Banerjee
"Date = Sun Aug 26 10:12:18 IST 2012
"
"---------------------------------------------------------------------------------------------------------------------------

set nocp                                    "No copatibility with vi
if has("syntax")                            "Turn on syntax
	syntax on
endif


"Pathogen {
	call pathogen#infect()                  "Set up pathogen
	call pathogen#helptags()
"}

"General_Settings {
	let g:mapleader=","                     "Change mapleader from \ to ,
	let mapleader=","                       "Change mapleader from \ to ,
	set title                               "Set title in terminal
	set so=7                                "7 lines to cursor
	set expandtab                           "Insert spaces instead of a tab character
	set softtabstop=2                       "Set indentation
	set tabstop=2
	set shiftwidth=2
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
	set wildignore=*.swp,*.bak,*.pyc,*.class,*.o
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
		else
			set term=xterm                      "Make arrow and other keys work
		endif
		set mouse=a                           "Use mouse everywhere (even in terminal)
		set mousehide                         "Hide mouse while typing
		set cursorline                        "Show current line (useful in terminal)
		syntax enable                         "Color scheme for vim
		au VimResized * :wincmd =             "Resize split screens on window resize
	"}

	"Powerline {
		set laststatus=2                      "Status line configuration
		autocmd bufwritepost .vimrc call Pl#Load()
		"let g:Powerline_colorscheme='skwp'
		call Pl#Theme#InsertSegment('ws_marker', 'after', 'lineinfo') "Get trailing whitespace
		if has('gui_running')
			set guifont=Monaco\ for\ Powerline:h12
			let g:Powerline_symbols = 'fancy'
		else
			set t_Co=256
			let g:Powerline_symbols = 'unicode'
		endif
	"}
	
	"Supertab{
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
	"}

	"NerdTree {
		let NERDTreeIgnore=['\.vim$', '\~$', '\.pyc$', '\.swp$']
		let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$',  '\~$']
		"autocmd VimEnter * NERDTree
		"autocmd VimEnter * wincmd p
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

	"Notes{
		let g:notes_directory = '~/Documents/Notes'
		let g:notes_suffix = '.txt'
	"}

	"CTags{
		map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
		map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
		map <C-]> :split <CR>:exec("tag ".expand("<cword>"))<CR>
	"}

	"Some remaps {
		nnoremap ; :
		nnoremap j gj
		nnoremap k gk
		cmap WQ wq
		cmap wQ wq
		vmap Q gq
		nmap Q gqap
		cmap Tabe tabe
		map <C-J> <C-W>j
		map <C-K> <C-W>k
		map <C-L> <C-W>l
		map <C-H> <C-W>h
		map <C-K> <C-W>k
		nnoremap / /\v
		vnoremap / /\v
		cnoreabbrev <expr> w!!
					\((getcmdtype() == ':' && getcmdline() == 'w!!')
					\?('!sudo tee % >/dev/null'):('w!!'))
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
	autocmd BufWrite *.c,*.cpp,*.cc,*.h,*.m,*.js,*.py,*.pl,*.pm :call DeleteTrailingWS()

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
		au FileType python set modeline ts=4 sw=4 tw=78 sts=4 et smarttab noexpandtab
		au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
		au FileType python set omnifunc=pythoncomplete#Complete
	"}

	"VIM {
		au FileType vim set noexpandtab
	"}
"}

