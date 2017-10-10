scriptencoding utf-8



" Interface {{{1

function! hlparen#highlight(...) abort
  let offset = a:0 ? a:1 : mode() is# 'i' || mode() is# 'R'
  if get(w:, 'hlparen_matchid', 0)
    silent! call matchdelete(w:hlparen_matchid)
    let w:hlparen_matchid = 0
  endif
  let ch = getline('.')[col('.') - offset -1]
  " let close_only = g:hlparen_insmode_trigger is# 'close_only'
  if !has_key(w:hlparen_pairs, ch) " || close_only && offset && has_key(w:hlparen_pairs[ch], 'open')
    return
  endif

  if exists('s:timer_id')
    call timer_stop(s:timer_id)
  endif
  let s:timer_id = timer_start(g:hlparen_highlight_delay,
        \ {timer -> s:highlight(offset, w:hlparen_pairs[ch])})
endfunction


" Internal {{{1

function! s:highlight(offset, pair) abort "{{{
  let cur_pos = [line('.'), col('.') - a:offset]
  let flags = has_key(a:pair, 'open') ? 'nW' : 'nbW'
  let stop = has_key(a:pair, 'open') ? 'w$' : 'w0'
  let pair_pos = a:offset
        \ ? s:save_excursion(cur_pos, function('s:searchpairpos'), [a:pair.start, a:pair.end, flags, stop])
        \ : s:searchpairpos(a:pair.start, a:pair.end, flags, stop)
  if pair_pos[0] > 0
    let lines1 = len(join(getline(1, cur_pos[0]-1), '')) + cur_pos[1]
    let lines2 = len(join(getline(1, pair_pos[0]-1), '')) + pair_pos[1]
    if has_key(a:pair, 'open')
      let size = lines2 - lines1
      let cur_pos += [size]
    else
      let size = lines1 - lines2
      let pair_pos += [size]
    endif
    let w:hlparen_matchid = matchaddpos('HlParenMatch', [cur_pos, pair_pos], 10, 3)
  endif
endfunction "}}}

function! s:save_excursion(cur_pos, func, args) abort "{{{
  let saved_cursor = getcurpos()
  call cursor(a:cur_pos)
  try
    return call(a:func, a:args)
  finally
    call setpos('.', saved_cursor)
  endtry
endfunction "}}}

function! s:skip_expr() abort "{{{
  " borrowed from $VIMRUNTIME/plugin/matchparen.vim

  " Build an expression that detects whether the current cursor position is in
  " certain syntax types (string, comment, etc.), for use as searchpairpos()'s
  " skip argument.
  " We match "escape" for special items, such as lispEscapeSpecial.
  let s_skip = '!empty(filter(map(synstack(line("."), col(".")), ''synIDattr(v:val, "name")''), ' .
	\ '''v:val =~? "\\%(string\\|character\\|singlequote\\|escape\\|comment\\)"''))'
  " If executing the expression determines that the cursor is currently in
  " one of the syntax types, then we want searchpairpos() to find the pair
  " within those syntax types (i.e., not skip).  Otherwise, the cursor is
  " outside of the syntax types and s_skip should keep its value so we skip any
  " matching pair inside the syntax types.
  execute 'if' s_skip '| let s_skip = 0 | endif'

  return s_skip
endfunction "}}}

function! s:searchpairpos(start, end, flags, stopline) abort "{{{
  return searchpairpos(a:start, '', a:end, a:flags, s:skip_expr(), line(a:stopline), 10)
endfunction "}}}


" Initialization {{{1

if expand("%:p") == expand("<sfile>:p")
  highlight clear HlParenMatch
endif

if !exists('HlParenMatch')
  highlight HlParenMatch term=underline,bold cterm=underline,bold gui=underline,bold
endif


" 1}}}
