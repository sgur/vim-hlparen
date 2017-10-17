scriptencoding utf-8



" Interface {{{1

function! hlparen#highlight(...) abort
  if get(w:, 'hlparen_matchid', 0)
    silent! call matchdelete(w:hlparen_matchid)
    let w:hlparen_matchid = 0
  endif

  if exists('s:timer_id')
    call timer_stop(s:timer_id)
  endif

  let offset = a:0 ? a:1 : mode() is# 'i' || mode() is# 'R'
  let s:timer_id = timer_start(g:hlparen_highlight_delay,
        \ {timer -> s:highlight(offset)})
endfunction


" Internal {{{1

function! s:highlight(offset) abort "{{{
  let ch = getline('.')[col('.') - a:offset -1]
  let close_only = g:hlparen_insmode_trigger is# 'close_only'
  if !has_key(w:hlparen_pairs, ch) || close_only && a:offset && w:hlparen_pairs[ch].attr is# 'open'
    return
  endif
  let pair = w:hlparen_pairs[ch]

  let skip_expr = s:skip_expr_for_cursor()
  if skip_expr is# 0 " skip in String/Character/Quote/Escape/Comment syntaxes
    return
  endif

  let is_open_paren = pair.attr is# 'open'
  let flags = is_open_paren ? 'nW' : 'nbW'
  let stop = is_open_paren ? 'w$' : 'w0'
  let cur_pos = [line('.'), col('.') - a:offset]
  let pair_pos = a:offset
        \ ? s:save_excursion(cur_pos, function('searchpairpos'), [pair.start, '', pair.end, flags, skip_expr, stop])
        \ : searchpairpos(pair.start, '', pair.end, flags, skip_expr, stop)
  if pair_pos[0] > 0
    let middle = []
    if g:hlparen_highlight_style == 'expression'
      let [cur_pos, pair_pos] = s:calc_expression_range(cur_pos, pair_pos, is_open_paren)
      let middle = s:intermediate_expressions(cur_pos, pair_pos)
    endif
    let w:hlparen_matchid = matchaddpos('HlParenMatch', [cur_pos] + middle + [pair_pos], 10, 3)
  endif
endfunction "}}}

function! s:calc_expression_range(cur_pos, pair_pos, is_opened) abort "{{{
  if a:cur_pos[0] == a:pair_pos[0]
    let len1 = len(join(getline(1, a:cur_pos[0]-1), '')) + a:cur_pos[1]
    let len2 = len(join(getline(1, a:pair_pos[0]-1), '')) + a:pair_pos[1]
    return a:is_opened ? [a:cur_pos + [len2 - len1], a:pair_pos] : [a:cur_pos, a:pair_pos + [len1 - len2]]
  endif

  if a:is_opened
    let pair_pos = s:opposite_pos(a:pair_pos)
    let cur_len = s:cursor_expression_length(a:cur_pos)
    return [a:cur_pos + [cur_len], pair_pos]
  else
    let cur_pos = s:opposite_pos(a:cur_pos)
    let pair_len = s:cursor_expression_length(a:pair_pos)
    return [cur_pos, a:pair_pos + [pair_len]]
  endif
endfunction "}}}

function! s:intermediate_expressions(pos1, pos2) abort "{{{
  let middle = []
  let intermediates = abs(a:pos1[0] - a:pos2[0]) - 1
  if 0 < intermediates && intermediates < 7
    let start = min([a:pos1[0], a:pos2[0]]) + 1
    let end = max([a:pos1[0], a:pos2[0]]) - 1
    for i in range(start, end)
      let line = getline(i)
      let match = match(line, '^\s*\zs')
      let middle += [[i, match + 1 , len(line) - match]]
    endfor
  endif
  return middle
endfunction "}}}

function! s:cursor_expression_length(pos) abort "{{{
  return len(getline(a:pos[0])) + 1 - a:pos[1]
endfunction "}}}

function! s:opposite_pos(pos) abort "{{{
  let line = getline(a:pos[0])
  let match = match(line, '^\s*\zs')
  return [a:pos[0], match + 1, a:pos[1] - match]
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

" borrowed from $VIMRUNTIME/plugin/matchparen.vim
function! s:skip_expr_for_cursor() abort "{{{
  return eval(s:skip_expr) ? 0 : s:skip_expr
endfunction "}}}

function! s:init_highlight_group() abort "{{{
  highlight default HlParenMatch term=underline,bold cterm=underline,bold gui=underline,bold
endfunction "}}}


" Initialization {{{1

call s:init_highlight_group()
autocmd! ColorScheme *  call s:init_highlight_group()

let s:skip_expr = "
      \ !empty(
      \   filter(
      \     map(synstack(line('.'), col('.')),
      \       'synIDattr(synIDtrans(v:val),''name'')'),
      \     'index([''String'', ''Character'', ''Quote'', ''Escape'', ''Comment''], v:val) != -1'))
      \ "

" 1}}}
