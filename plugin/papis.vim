function! s:yank_to_register(data)
  let @" = a:data
  silent! let @* = a:data
  silent! let @+ = a:data
endfunction


function! s:handler(a)
  let lines = a:a
  if lines == [] || lines == ['','','']
    return
  endif
  " Expect at least 2 elements, `query` and `keypress`, which may be empty
  " strings.
  let query    = lines[0]
  let keypress = lines[1]
  let cmd = "normal a"
  let pat = '@\v(.{-})$'
  " it is possible to yank the doc id using the ctrl-y keypress
  if keypress ==? "ctrl-y"
    let hashes = join(filter(map(lines[2:], 'matchlist(v:val, pat)[1]'), 'len(v:val)'), "\n")
    return s:yank_to_register(hashes)
    " this will insert \cite{id} command for all selected citations
  else
    let citations = lines[2:]
    let candidates = []
    for line in citations
      let id = matchlist(line, pat)[1]
      call add(candidates, "\\cite{". id . "}")
    endfor
  endif

  for candidate in candidates
    execute join([cmd, candidate])
  endfor

endfunction


command! -bang -nargs=* Papis
      \ call fzf#run(fzf#wrap({'source': 'papis list <args> --format "{doc[author]}: {doc[title]} @{doc[ref]}"', 'sink*': function('<sid>handler'), 'options': '--multi --expect=ctrl-y --print-query'}))

