match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

augroup VIMRC_GIT
  au!
  au BufNewFile,BufRead COMMIT_EDITMSG setlocal spell
  au BufNewFile,BufRead COMMIT_EDITMSG call feedkeys('ggi', 't')
  au FileType gitcommit DiffGitCached
  au FileType gitrebase nnoremap P :Pick<CR>
  au FileType gitrebase nnoremap S :Squash<CR>
  au FileType gitrebase nnoremap C :Cycle<CR>
  au FileType gitrebase nnoremap R :Reword<CR>
augroup END

