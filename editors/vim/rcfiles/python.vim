let python_highlight_all = 1
let g:pymode_options = 1
let g:pymode_doc_key = 'D'
let g:pydoc_cmd = 'python -m pydoc'
let g:pymode_folding = 0
let g:pymode_virtualenv = 1
let g:pymode_trim_whitespaces = 1
let g:pymode_indent = 1
let g:pymode_lint_checkers = ['pyflakes']             "pep8 and others!
let g:pydoc_open_cmd = 'split'
let g:pymode_rope = 1
let g:pymode_rope_autoimport_generate = 1
let g:pymode_rope_autoimport_underlineds = 0
let g:pymode_rope_codeassist_maxfixes = 10
let g:pymode_rope_sorted_completions = 1
let g:pymode_rope_extended_complete = 1
let g:pymode_rope_autoimport_modules = ["os","shutil","datetime"]
let g:pymode_rope_vim_completion = 1
let g:pymode_rope_guess_project = 1
let g:pymode_rope_goto_def_newwin = ""
let g:pymode_rope_always_show_complete_menu = 0

augroup VIMRC_PYTHON
  au!
  au FileType python syn keyword pythonDecorator True None False self
  au BufNewFile,BufRead *.jinja set syntax=htmljinja
  au BufNewFile,BufRead *.mako set ft=mako
  au BufRead *.py set smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
  au FileType python set omnifunc=RopeOmni
augroup END
