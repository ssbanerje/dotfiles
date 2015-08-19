let g:syntastic_enable_signs=1
let g:syntastic_check_on_open=1
let g:synstastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_wq=0

" C/C++
let g:syntastic_c_check_header = 1
let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = '-std=c++1y -stdlib=libc++'
