" Called after custom config is loaded {{{
function! myspacevim#before() abort
  " Configure custom shortcuts
  call SpaceVim#custom#SPC('nore', ['r', 'w'], 'for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor', 'wipe all registers', 1)
  call SpaceVim#custom#SPC('nore', ['g', 'p'], 'Gina patch', 'interactively-stage-file', 1)

  " Set timeout for spacevim menus
  set timeoutlen=100
endfunction
" }}}1

" Called after entering autocmd mode {{{
function! myspacevim#after() abort
  " Color column width
  set textwidth=100
  set colorcolumn=+1

  " Diff mode configuration
  set diffopt=vertical

  " Ignore case in search
  set ignorecase smartcase

  " Open new windows at the bottom and right
  set splitbelow splitright

  if has('nvim')
    " Show result of substitution commands
    set inccommand=nosplit
  endif

  " Highlight changes in diff mode
  if &diff
    highlight! link DiffText MatchParen
  endif

  " Dont conceal chars
  set conceallevel=0
  let g:tex_conceal=''
  let g:neosnippet#enable_conceal_markers=0

  " Markdown Preview
  let g:mkdp_page_title = '${name}'

  " Undo behavior
  nnoremap U :MundoToggle<CR>

  " Make Y consistent with C and D -- yank to end of line
  nnoremap Y y$

  " Search visually selected text
  vnoremap / y/<C-R>"<CR>

  " Make n always go forward and N backward in search
  nnoremap <expr> n 'Nn'[v:searchforward]
  nnoremap <expr> N 'nN'[v:searchforward]

  " Make J, K, L, and H move the cursor MORE
  nnoremap H ^
  nnoremap J }
  nnoremap K {
  nnoremap L g_

  " Make <c-h>, <c-j>, <c-k>, <c-l>  for scrolling the screen
  nnoremap <c-h> zh
  nnoremap <c-j> <c-e>
  nnoremap <c-k> <c-y>
  nnoremap <c-l> zl

  " Scroll before hitting the end
  set scrolloff=5
  set sidescroll=1

  " Get coc completion
  inoremap <expr> <C-c> coc#refresh()

  " Remap keys for coc gotos
  nmap gd <Plug>(coc-definition)
  nmap gy <Plug>(coc-type-definition)
  nmap gi <Plug>(coc-implementation)
  nmap gr <Plug>(coc-references)
  nmap gk <SID>show_documentation()

  " Use K to show documentation in preview window
  nnoremap <expr> K <SID>show_documentation()

  " Setup coc colors
  " TODO Can this be taken directly from the vim theme
  hi CocErrorSign ctermfg=15 guifg=#FF5370 guibg=#222222
  hi CocWarningSign ctermfg=121 guifg=#FFCB6B guibg=#222222
  hi CocInfoSign ctermfg=159 guifg=#82AAFF guibg=#222222
  hi CocHintSign ctermfg=11 guifg=#89DDFF guibg=#222222
endfunction

" Show documentation for current word
function! s:show_documentation() abort
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction
" }}}1

" vim:set fdm=marker:
