" Register make tasks {{{
function! s:make_tasks() abort
  if filereadable('Makefile')
    let commands = filter(readfile('Makefile', ''), "v:val=~#'^.PHONY'")
    if !empty(commands)
      call flatten(map(commands, {k, v -> split(v)[1:]}))
      let conf = {}
      for cmd in commands
        call extend(conf, {
              \ cmd: {
                \ 'command': 'make',
                \ 'args': [cmd],
                \ 'isDetected' : 1,
                \ 'detectedName' : 'make: '
              \ }
            \ })
      endfor
      return conf
    else
      return {}
    endif
  else
    return {}
  endif
endfunction
" }}}1

" Called after custom config is loaded {{{
function! myspacevim#before() abort
  " Configure tasks
  call SpaceVim#plugins#tasks#reg_provider(funcref('s:make_tasks'))

  " Configure custom shortcuts
  call SpaceVim#custom#SPC('nore', ['r', 'w'], "for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor", "wipe all registers", 1)
  call SpaceVim#custom#SPC('nore', ['g', 'p'], "Gina patch", "interactively-stage-file", 1)
endfunction
" }}}1

" Called after entering autocmd mode {{{
function! myspacevim#after() abort
  " Color column width
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

  " Prevent vimtex preview
  let g:tex_conceal=""
  set conceallevel=0

  " Markdown Preview
  let g:mkdp_page_title = '${name}'

  " Undo behavior
  nnoremap U :MundoToggle<CR>

  " Make Y consistent with C and D -- yank to end of line
  nnoremap Y y$

  " Search visually selected text
  vnoremap // y/<C-R>"<CR>

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

  " Neomake setting
  let g:neomake_vim_enabled_makers = ['vint']
  let g:neomake_yaml_enabled_makers = ['yamllint']
  let g:neomake_zsh_enabled_makers = ['zsh']
  let g:neomake_text_enabled_makers = ['proselint']
  let g:neomake_markdown_enabled_makers = ['proselint']
endfunction
" }}}1

" vim:set fdm=marker:
