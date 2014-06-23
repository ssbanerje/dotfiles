augroup VIMRC_PERL
  au!
  au FileType perl let perl_include_pod = 1
  au FileType perl let perl_extended_vars = 1
  au FileType perl set makeprg=perl\ -c\ %\ $*
  au FileType perl set errorformat=%f:%l:%m
  au FileType perl set autowrite
  au FileType perl set foldenable
  au FileType perl set foldmethod=syntax
  au FileType perl syn region POD start=/^=head[123]/ end=/^=cut/ fold
augroup END
