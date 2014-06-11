augroup VIMRC_WEBDEV
  au!
  au FileType javascript setl fen
  au FileType javascript setl nocindent
  au FileType html setlocal indentkeys-=*<Return>
  au BufRead,BufNewFile,BufWrite {*.js.asp,*.json} set ft=javascript
  au BufRead,BufNewFile,BufWrite {*.less} set ft=css
  au BufRead,BufNewFile,BufWrite {Capfile,Gemfile,Rakefile,Thorfile,config.ru,.caprc,.irbrc,irb_tempfile*} set ft=ruby
  au BufRead,BufNewFile *.ejs set filetype=html
  au FileType javascript set dictionary+=$HOME/.vim/bundle/vim-node/dict/node.dict
  au FileType html,xml let g:html_indent_inctags = "html,body,head,tbody"
  au FileType html,xml let g:html_indent_script1 = "inc"
  au FileType html,xml let g:html_indent_style1 = "inc"
augroup END
