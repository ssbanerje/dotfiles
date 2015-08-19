"CTags
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
map <C-]> :split <CR>:exec("tag ".expand("<cword>"))<CR>

augroup VIMRC_CPP
  au!
  au FileType c,cpp se cin
  au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
  au FileType c,cpp set completeopt=menuone,menu,longest,preview
augroup END

" Enable enhanced syntax highlighting for C++
let g:cpp_class_scope_highlight = 1
let g:cpp_experimental_template_highlight = 1
