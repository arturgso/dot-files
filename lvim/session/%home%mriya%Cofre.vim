let SessionLoad = 1
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/Cofre
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +123 Fisiopatologia/Aula\ 6.md
badd +143 Fisiopatologia/Aula\ 6\ -\ V2.md
badd +100 Fisiopatologia/Aula\ 7.md
badd +108 Fisiopatologia/Aula\ 7\ -\ V2.md
badd +40 Fisiopatologia/Aula\ 8.md
badd +53 Fisiopatologia/Aula\ 8\ -\ V2.md
badd +56 Fisiopatologia/Aula\ 9.md
badd +72 Fisiopatologia/Aula\ 9\ -\ V2.md
badd +58 Fisiopatologia/Aula\ 10\ -\ V2.md
argglobal
%argdel
$argadd .
edit Fisiopatologia/Aula\ 10\ -\ V2.md
argglobal
balt Fisiopatologia/Aula\ 9\ -\ V2.md
setlocal fdm=manual
setlocal fde=
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
silent! normal! zE
let &fdl = &fdl
let s:l = 77 - ((39 * winheight(0) + 20) / 40)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 77
normal! 069|
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0 && getbufvar(s:wipebuf, '&buftype') isnot# 'terminal'
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
set hlsearch
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
