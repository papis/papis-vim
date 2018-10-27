function! s:yank_to_register(data)
  let @" = a:data
  silent! let @* = a:data
  silent! let @+ = a:data
endfunction

function! s:get_reference(line)
  let l:pat='@\v(.*)$'
  return substitute(matchlist(a:line, l:pat)[1], "/", "", "g")
endfunction

function! s:inside_cite_body()
  execute "silent! normal mq?\\\\cite\\|}\r"
  let l:inbody = getline('.')[col('.')-1: col('.') + 3] ==# '\cite'
  execute "normal `q"
  return l:inbody
endfunction

function! s:handler(a)
  let l:lines = a:a
  if l:lines == [] || l:lines == ['','','']
    return
  endif
  " Expect at least 2 elements, `query` and `keypress`, which may be empty
  " strings.
  let l:keypress = l:lines[1]
  let l:citations = l:lines[2:]
  let l:candidates = []

  " Making list of the things to cite
  for l:line in l:citations
    call add(l:candidates, s:get_reference(l:line))
  endfor

  " it is possible to yank the doc id using the ctrl-y keypress
  if l:keypress ==? "ctrl-y"
    execute s:yank_to_register(join(l:candidates, "\n"))
    " this will insert \cite{id} command for all selected citations
  else
    " If you are already in a \cite{} body
    if s:inside_cite_body()
      execute "normal \/\}\rgea, " . join(l:candidates, ", ") ."\e"
    " start a fresh \cite{} body
    else
      execute "normal a\\cite{" . join(l:candidates, ", ") . "}\e"
    endif
  endif
endfunction

let g:PapisFormat = '"{doc[author]}: {doc[title]}'

command! -bang -nargs=* Papis
      \ call fzf#run(fzf#wrap({'source': 'papis list <args> --format ' . g:PapisFormat . ' @{doc[ref]}"', 'sink*': function('<sid>handler'), 'options': '--multi --expect=ctrl-y --print-query'}))
