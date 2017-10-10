" hlparen
" Version: 0.0.1
" Author: sgur
" License: MIT License

if exists('g:loaded_hlparen')
  finish
endif
let g:loaded_hlparen = 1
let g:loaded_matchparen = -1

let s:save_cpo = &cpoptions
set cpoptions&vim


if pumvisible() || (&t_Co < 8 && !has("gui_running"))
      \ || !exists('##CursorMoved')
      \ || !exists('##TextChanged')
      \ || !exists('*getcurpos')
      \ || !exists('*matchaddpos')
  finish
endif

augroup hlparen
  autocmd! CursorMoved,CursorMovedI,WinEnter *
        \ call hlparen#highlight()
  autocmd! TextChanged,TextChangedI *
        \ call hlparen#highlight()
  autocmd! InsertEnter * call hlparen#highlight(1)
  autocmd! InsertLeave * call hlparen#highlight(0)
  autocmd! VimEnter,WinEnter,BufWinEnter,FileType *  call s:init()
  autocmd! OptionSet matchpairs  call s:init()
augroup END

function! s:init() abort "{{{
  let w:hlparen_pairs = get(w:, 'hlparen_pairs', {})
  for [open, close] in map(split(&l:matchpairs, ','), 'split(v:val, '':'')')
    let start = escape(open, '[]')
    let end = escape(close, '[]')
    let w:hlparen_pairs[open] = {'start': start, 'end': end, 'open': 1}
    let w:hlparen_pairs[close] = {'start': start, 'end': end}
  endfor
endfunction "}}}

let g:hlparen_insmode_trigger = get(g:, 'hlparen_insmode_trigger', 'close_only') " 'close_only'
let g:hlparen_highlight_delay = get(g:, 'hlparen_highlight_delay', 150) " msec
let g:hlparen_highlight_style = get(g:, 'hlparen_highlight_style', 'parenthesis') " 'expression'

let &cpoptions = s:save_cpo
unlet s:save_cpo

" vim:set et:
