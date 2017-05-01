" Vim global plugin for diffing the diffs on a single line
" Maintainer:	Barry Arthur <barry.arthur@gmail.com>
" License:	Vim License (see :help license)
" Website:	https://github.com/dahu/DiffLine
"
" See DiffLine.txt for help.  This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help DiffLine

" Vimscript Setup: {{{1
" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_DiffLine")
      \ || v:version < 700
      \ || &compatible
  let &cpo = s:save_cpo
  finish
endif
let g:loaded_DiffLine = 1

" Private Functions: {{{1

function! s:init_diffline_tab(lines)
  tabnew
  let t:difflinetab_files = []
  vnew
  for line in a:lines
    call add(t:difflinetab_files, s:writeline(line))
    diffthis
    wincmd w
  endfor
  normal! ]czz
endfunction

function! s:writeline(line)
  call setline(1, a:line)
  let file = tempname()
  exe "write " . file
  return file
endfunction

function! s:getlines(split_pattern)
  let a = split(getline('.'), a:split_pattern)
  wincmd w
  let b = split(getline('.'), a:split_pattern)
  wincmd w
  return [a, b]
endfunction

" Public Interface: {{{1

function! DiffLine(...)
  if &diff
    silent call s:init_diffline_tab(s:getlines(a:0 ? a:1 : '\s\+'))
  else
    echohl  Error
    echomsg "Not in a diff session!"
  endif
endfunction

function! DiffLineClose()
  if exists("t:difflinetab_files")
    for file in t:difflinetab_files
      if filereadable(file)
        call delete(file)
      endif
    endfor
    tabclose
  endif
endfunction

" Maps: {{{1
nnoremap <plug>DiffLine      :<c-u>call DiffLine()<cr>
nnoremap <plug>DiffLineClose :<c-u>call DiffLineClose()<cr>

if !hasmapto('<plug>DiffLine')
  nmap <unique><silent> <leader>dll <plug>DiffLine
endif

if !hasmapto('<plug>DiffLineClose')
  nmap <unique><silent> <leader>dlc <plug>DiffLineClose
endif

" Commands: {{{1
command! -nargs=? -bar DiffLine      call DiffLine(<q-args>)
command! -nargs=0 -bar DiffLineClose call DiffLineClose()

" Teardown: {{{1
" reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
