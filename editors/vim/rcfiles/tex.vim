let g:tex_comment_nospell=1
let g:tex_no_error=1
let g:tex_conceal="agdms"

set cole=2	"conceal level

augroup VIMRC_TEX
  au!
  au FileType tex let g:tex_flavor='latex'
  au FileType tex set tw=100
  au FileType tex set grepprg=grep\ -nH\ $*
  au FileType tex	setl spl=en_us spell
augroup END
