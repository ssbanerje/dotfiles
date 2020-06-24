" Register Rust tasks
function! s:cargo_task() abort
  if filereadable('Cargo.toml')
    let commands = ['build', 'run', 'test', 'fmt']
    let conf = {}
    for cmd in commands
      call extend(conf, {
                  \ cmd : {
                  \ 'command': 'cargo',
                  \ 'args' : [cmd],
                  \ 'isDetected' : 1,
                  \ 'detectedName' : 'cargo:'
                  \ }
                  \ })
    endfor
    return conf
  else
    return {}
  endif
endfunction

" Called after custom config is loaded
function! myspacevim#before() abort
  " Load Rust tasks into the Spacevim
  call SpaceVim#plugins#tasks#reg_provider(funcref('s:cargo_task'))

  " 100 character line
  set tw=100
  set colorcolumn=100
endfunction

" Called after entering autocmd mode
function! myspacevim#after() abort
endfunction


