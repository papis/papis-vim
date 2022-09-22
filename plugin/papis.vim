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
  execute "silent! normal! mq?\\\\cite\\|}\r"
  let l:inbody = getline('.')[col('.')-1: col('.') + 3] ==# '\cite'
  execute "normal! `q"
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
      execute "normal! \/\}\rgea, " . join(l:candidates, ", ") ."\e"
    " start a fresh \cite{} body
    else
      execute "normal! a\\cite{" . join(l:candidates, ", ") . "}\e"
    endif
  endif
endfunction

let g:PapisFormat = '"{doc[author]}: {doc[title]}'
let g:PapisBackend = ''

function! s:getPapisBackend()
  if g:PapisBackend ==# ''
    let g:PapisBackend = systemlist('papis config database-backend')[0]
  endif
  return g:PapisBackend
endfunction

function! s:Papis(searchline)
  let l:searchinp = a:searchline
  if l:searchinp ==# ''
    if s:getPapisBackend() ==# "whoosh"
      let l:searchinp = '"*"'
    endif
  endif
  call fzf#run(fzf#wrap({'source': 'papis list ' . l:searchinp . ' --format ' . g:PapisFormat . ' @{doc[ref]}"', 'sink*': function('s:handler'), 'options': '--multi --expect=ctrl-y --print-query'}))
endfunction

command! -bang -nargs=* Papis call s:Papis('<args>')

function! s:get_citeref(cite, full_list)
  for l:ref in a:full_list
    if a:cite ==# substitute(l:ref, "/", "", "g")
      return l:ref
    endif
  endfor
endfunction

function! s:get_all_citerefs()
  return systemlist('papis list "ref:*" --format "{doc[ref]}" --all')
endfunction

function! s:get_cite_under_cursor()
  if s:inside_cite_body()
    if getline('.')[col('.') -1] ==# ','
      return
    endif

    execute "silent! normal! mq/[}{]\r"
    if getline('.')[col('.') -1] ==# '{'
      execute "silent! normal! `q"
      return
    endif

    execute "silent! normal! `q"
    execute "silent! normal! ?[{,]\rwv/[,}]\rge\"qy`q"
    return @q
  endif
endfunction

function! s:PapisView()
  if s:getPapisBackend() !=# "whoosh"
    echom "PapisView only works for Papis with whoosh as database-backend at the moment"
    return
  endif

  let l:cite = s:get_cite_under_cursor()
  if l:cite ==# ""
    return
  endif

  let l:full_list = s:get_all_citerefs()
  let l:ref = s:get_citeref(l:cite, l:full_list)
  call system('papis open "ref:' . l:ref . '"')
endfunction

command! -bang PapisView call s:PapisView()
