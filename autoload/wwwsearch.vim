" wwwsearch - Search WWW easily from Vim
" Version: 0.0.0
" Copyright (C) 2009 kana <http://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
function! wwwsearch#add(search_engine_name, uri_template)  "{{{2
  let s:search_engines[a:search_engine_name] = a:uri_template
  return
endfunction




function! wwwsearch#search(keyword, ...)  "{{{2
  let search_engine_name = s:normalize_search_engine_name(1 <= a:0
  \                                                       ?  a:1
  \                                                       : '-default')

  if !exists('g:wwwsearch_command_to_open_uri')
    let g:wwwsearch_command_to_open_uri = s:default_command_to_open_uri()
  endif
  if g:wwwsearch_command_to_open_uri == ''
    echomsg 'You have to set g:wwwsearch_command_to_open_uri.'
    echomsg 'See :help g:wwwsearch_command_to_open_uri for the details'
    return 0
  endif

  execute '!' g:wwwsearch_command_to_open_uri
  \           shellescape(s:uri_to_search(a:keyword, search_engine_name))
  return !0
endfunction








" Misc.  "{{{1
" Variables  "{{{2

let s:search_engines = {}  " search-engine-name => uri-template




" Default set of search engines  "{{{2

" FIXME: Add more search engines.

call wwwsearch#add('default', 'http://www.google.com/search?q={keyword}')
call wwwsearch#add('google', 'http://www.google.com/search?q={keyword}')
" call wwwsearch#add('vim', '...')
" call wwwsearch#add('wikipedia', '...')
" ...




function! wwwsearch#cmd_Wwwsearch(args)  "{{{2
  if args[0][:0] == '-'
    return wwwsearch#search(join(args[1:]), args[0])
  else
    return wwwsearch#search(join(args))
  endif
endfunction




function! wwwsearch#cmd_Wwwsearch_complete(arglead, cmdline, cursorpos)  "{{{2
  " FIXME: context-aware completion
  return sort(keys(s:search_engines))
endfunction




function! wwwsearch#_sid_prefix()  "{{{2
  return s:SID_PREFIX()
endfunction

function! s:SID_PREFIX()  
  return matchstr(expand('<sfile>'), '\%(^\|\.\.\)\zs<SNR>\d\+_')
endfunction




function! s:default_command_to_open_uri()  "{{{2
  if has('mac') || has('macunix') || system('uname') =~? '^darwin'
    return 'open {uri}'
  elseif has('win32') || has('win64')
    return 'start {uri}'
  else
    return ''
  endif
endfunction




function! s:uri_escape(s)  "{{{2
  if s:safe_map is 0
    let safe_chars = ('ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    \                 . 'abcdefghijklmnopqrstuvwxyz'
    \                 . '0123456789'
    \                 . '_.-'
    \                 . '/')
    unlet s:safe_map
    let s:safe_map = {}
    for i in range(256)
      let c = nr2char(i)
      let s:safe_map[i] = 0 <= stridx(safe_chars, c) ? c : printf('%%%02X', i)
    endfor
  endif
  return join(map(range(len(a:s)), 's:safe_map[char2nr(a:s[v:val])]'), '')
endfunction

let s:safe_map = 0




function! s:uri_to_search(keyword, search_engine_name)  "{{{2
  let uri_template = get(s:search_engines, a:search_engine_name, '')
  let uri_escaped_keyword = s:uri_escape(a:keyword)
  return substitute(uri_template, '{keyword}', uri_escaped_keyword, 'g')
endfunction








" __END__  "{{{1
" vim: foldmethod=marker
