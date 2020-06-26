" Register Rust tasks
function! s:cargo_tasks() abort
  if filereadable('Cargo.toml')
    let commands = ['build', 'run', 'test', 'fmt']
    let conf = {}
    for cmd in commands
      call extend(conf, {
            \ cmd : {
              \ 'command': 'cargo',
              \ 'args' : [cmd],
              \ 'isDetected' : 1,
              \ 'detectedName' : 'cargo: '
            \ }
          \ })
    endfor
    return conf
  else
    return {}
  endif
endfunction

" Register make tasks
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

" Called after custom config is loaded
function! myspacevim#before() abort
  " Configure tasks
  call SpaceVim#plugins#tasks#reg_provider(funcref('s:make_tasks'))
  call SpaceVim#plugins#tasks#reg_provider(funcref('s:cargo_tasks'))

  " Set text width to 100
  set tw=100
  set colorcolumn=100
endfunction

" Called after entering autocmd mode
function! myspacevim#after() abort
endfunction

