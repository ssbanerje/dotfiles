let g:unite_source_history_yank_enable = 1
let g:unite_prompt = '>>> '
let g:unite_marked_icon = '✓'
let g:unite_update_time = 200
let g:unite_source_buffer_time_format = '(%d-%m-%Y %H:%M:%S) '
let g:unite_source_file_mru_time_format = '(%d-%m-%Y %H:%M:%S) '
let g:unite_source_directory_mru_time_format = '(%d-%m-%Y %H:%M:%S) '

call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])

function! s:unite_settings()
  " Enable navigation with control-j and control-k in insert mode
  imap <buffer> <C-j> <Plug>(unite_select_next_line)
  imap <buffer> <C-k> <Plug>(unite_select_previous_line)
endfunction

augroup VIMRC_UNITE
  au!
  autocmd FileType unite call s:unite_settings()
augroup END

let g:unite_source_menu_menus = {}

let g:unite_source_menu_menus.jumptoany= {
  \ 'description' : 'Jump to anything',
\}
let g:unite_source_menu_menus.jumptoany.command_candidates = [
  \['YcmCompleter GoTo Anything', 'YcmCompleter GoTo'],
  \['YcmCompleter GoTo Declaration', 'YcmCompleter GoToDeclaration'],
  \['YcmCompleter GoTo Definition', 'YcmCompleter GoToDefinition'],
  \['YcmCompleter GoTo Imprecise', 'YcmCompleter GoToImprecise'],
  \['YcmCompleter GoTo Implementation', 'YcmCompleter GoToImplementation'],
  \['YcmCompleter GoTo Implementation or Declaration', 'YcmCompleter GoToImplementationElseDeclaration'],
  \['YcmCompleter GetType', 'YcmCompleter GetType'],
  \['YcmCompleter GetDoc', 'YcmCompleter GetDoc'],
  \['YcmCompleter GetParent', 'YcmCompleter GetParent'],
\]



" Interface for Git
let g:unite_source_menu_menus.git = {
  \ 'description' : 'Fugitive interface',
  \}
let g:unite_source_menu_menus.git.command_candidates = [
  \[' git status', 'Gstatus'],
  \[' git diff', 'Gvdiff'],
  \[' git commit', 'Gcommit'],
  \[' git stage/add', 'Gwrite'],
  \[' git checkout', 'Gread'],
  \[' git rm', 'Gremove'],
  \[' git cd', 'Gcd'],
  \[' git push', 'exe "Git! push -u origin " input("branch: ")'],
  \[' git pull', 'exe "Git! pull " input("branch: ")'],
  \[' git fetch', 'Gfetch'],
  \[' git merge', 'Gmerge'],
  \[' git browse', 'Gbrowse'],
  \[' git head', 'Gedit HEAD^'],
  \[' git parent', 'edit %:h'],
  \[' git log commit buffers', 'Glog --'],
  \[' git log current file', 'Glog -- %'],
  \[' git log last n commits', 'exe "Glog -" input("num: ")'],
  \[' git log first n commits', 'exe "Glog --reverse -" input("num: ")'],
  \[' git log until date', 'exe "Glog --until=" input("day: ")'],
  \[' git log grep commits',  'exe "Glog --grep= " input("string: ")'],
  \[' git log pickaxe',  'exe "Glog -S" input("string: ")'],
  \[' git index', 'exe "Gedit " input("branchname\:filename: ")'],
  \[' git mv', 'exe "Gmove " input("destination: ")'],
  \[' git grep',  'exe "Ggrep " input("string: ")'],
  \[' git prompt', 'exe "Git! " input("command: ")'],
\]
