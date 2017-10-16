scriptencoding utf-8



" Interface {{{1

function! hlparen#highlight(...) abort
  let offset = a:0 ? a:1 : mode() is# 'i' || mode() is# 'R'
  if get(w:, 'hlparen_matchid', 0)
    silent! call matchdelete(w:hlparen_matchid)
    let w:hlparen_matchid = 0
  endif
  let ch = getline('.')[col('.') - offset -1]
  let close_only = g:hlparen_insmode_trigger is# 'close_only'
  if !has_key(w:hlparen_pairs, ch) || close_only && offset && has_key(w:hlparen_pairs[ch], 'open')
    return
  endif

  if exists('s:timer_id')
    call timer_stop(s:timer_id)
  endif
  let s:timer_id = timer_start(g:hlparen_highlight_delay,
        \ {timer -> s:highlight(w:hlparen_pairs[ch], offset)})
endfunction


" Internal {{{1

function! s:highlight(pair, offset) abort "{{{
  let skip_expr = s:skip_expr_for_cursor()
  if skip_expr is# 0 " skip in String/Character/Quote/Escape/Comment syntaxes
    return
  endif

  let is_open_paren = has_key(a:pair, 'open')
  let flags = is_open_paren ? 'nW' : 'nbW'
  let stop = is_open_paren ? 'w$' : 'w0'
  let cur_pos = [line('.'), col('.') - a:offset]
  let pair_pos = a:offset
        \ ? s:save_excursion(cur_pos, function('searchpairpos'), [a:pair.start, '', a:pair.end, flags, skip_expr, stop])
        \ : searchpairpos(a:pair.start, '', a:pair.end, flags, skip_expr, stop)
  if pair_pos[0] > 0
    if g:hlparen_highlight_style == 'expression'
      let [cur_pos, pair_pos] += s:calc_expression_range(cur_pos, pair_pos, is_open_paren)
    endif
    let w:hlparen_matchid = matchaddpos('HlParenMatch', [cur_pos, pair_pos], 10, 3)
  endif
endfunction "}}}

function! s:calc_expression_range(cur_pos, pair_pos, is_opened) abort "{{{
  let len1 = len(join(getline(1, a:cur_pos[0]-1), '')) + a:cur_pos[1]
  let len2 = len(join(getline(1, a:pair_pos[0]-1), '')) + a:pair_pos[1]
  return a:is_opened ? [[len2 - len1], []] : [[], [len1 - len2]]
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
