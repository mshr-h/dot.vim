scriptencoding utf-8

let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))

" Use English interface.
if s:is_windows
  " For Windows.
  language message en
else
  " For Linux.
  language message C
endif

if s:is_windows
  " Exchange path separator.
  set shellslash
endif

" In Windows/Linux, take in a difference of '.vim' and '$VIM/vimfiles'.
let $DOTVIM = expand('$HOME/.vim')
set runtimepath+=$HOME/.vim,$HOME/.vim/after

silent! if plug#begin('~/.plugged')
  if !s:is_windows
    Plug 'Shougo/vimproc.vim', { 'do': 'make' }
  endif

  Plug 'itchyny/lightline.vim'
  Plug  'tyru/restart.vim'

  " Browsing
  Plug 'Shougo/unite.vim' | Plug 'Shougo/neomru.vim'
  Plug 'Shougo/unite.vim' | Plug 'Shougo/vimfiler'
  Plug 'Shougo/unite.vim' | Plug 'Shougo/vimshell'
  Plug 'haya14busa/incsearch.vim'

  " Git
  Plug 'Shougo/unite.vim' | Plug 'kmnk/vim-unite-giti'

  " Colors
  Plug 'chriskempson/vim-tomorrow-theme'
  Plug 'kien/rainbow_parentheses.vim'

  " Edit
  Plug 'junegunn/vim-easy-align'
  Plug 'Yggdroot/indentLine'
  Plug 'scrooloose/nerdcommenter'
  Plug 'tpope/vim-surround'
  Plug 'osyo-manga/vim-over'
  Plug 'jceb/vim-hier'
  Plug 'KazuakiM/vim-qfstatusline'

  " Lang
  Plug 'fatih/vim-go'
  Plug 'rhysd/vim-crystal', { 'for': 'crystal' }
  Plug 'plasticboy/vim-markdown'
  Plug 'kannokanno/previm'
  Plug 'tyru/open-browser.vim'
  
  if exists('##QuitPre')
    Plug 'thinca/vim-quickrun'
    Plug 'osyo-manga/shabadou.vim'
    Plug 'osyo-manga/vim-watchdogs'
  endif
  
  if(has('lua'))
    Plug 'Shougo/neocomplete' | Plug 'Shougo/neosnippet'
    Plug 'Shougo/neocomplete' | Plug 'Shougo/neosnippet-snippets'
  endif

  call plug#end()
endif

" ============================================================================
" BASIC SETTINGS {{{
" ============================================================================
colorscheme Tomorrow-Night-Eighties
set autoindent
set smartindent
set lazyredraw
set laststatus=2
set number
set showcmd
set visualbell
set nowritebackup
set nobackup
set backupdir-=.
set noswapfile
set noundofile
set matchpairs+=<:>
set backspace=indent,eol,start
set timeoutlen=500
set whichwrap+=h,l,<,>,[,],b,s,~
set shortmess=aIT
set hlsearch " CTRL-L / CTRL-R W
set incsearch
set hidden
set ignorecase smartcase
set wildmenu
set wildmode=full
set tabstop=2
set shiftwidth=2
set expandtab smarttab
set scrolloff=5
set encoding=utf-8
set list
set listchars=tab:>-,trail:-
set virtualedit=block
set nojoinspaces
set autoread
set wrap
set t_vb=
set novisualbell
set history=500
set cmdheight=2
set title
set titlelen=95
set softtabstop=2
set modeline
set t_Co=256
set nf="hex"
set clipboard=unnamed,autoselect
set foldlevelstart=99
set grepformat=%f:%l:%c:%m,%f:%l:%m
set completeopt=menuone,preview,longest
set nocursorline
set nrformats=hex
set formatoptions+=1
set completeopt-=preview
if has('patch-7.3.541')
  set formatoptions+=j
endif
if has('patch-7.4.338')
  let &showbreak = '↳ '
  set breakindent
  set breakindentopt=sbr
endif

" Visualize Full-width space, spaces at the end of the line and tabs.
if has("syntax")
  syntax on
  " PODバグ対策
  syn sync fromstart
  function! ActivateInvisibleIndicator()
    " 下の行の"　"は全角スペース
    syntax match InvisibleJISX0208Space "　" display containedin=ALL
    highlight InvisibleJISX0208Space term=underline ctermbg=1 guibg=darkgray gui=underline
  endfunction
  augroup invisible
    autocmd! invisible
    autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
  augroup END
endif
" }}}

" ----------------------------------------------------------------------------
" Keymappings
" ----------------------------------------------------------------------------
" Smart space mapping.
nnoremap <Space>   <Nop>
xnoremap <Space>   <Nop>
" Clear highlight.
nnoremap <Esc><Esc> :nohlsearch<CR>
" Disable ZZ and ZQ.
nnoremap ZZ <Nop>
nnoremap ZQ <Nop>
nnoremap <Leader>c :<C-u>setlocal cursorline! cursorcolumn!<CR>
" Command-line mode keymappings:"{{{
" <C-a>, A: move to head.
cnoremap <C-a>          <Home>
" <C-b>: previous char.
cnoremap <C-b>          <Left>
" <C-d>: delete char.
cnoremap <C-d>          <Del>
" <C-e>, E: move to end.
cnoremap <C-e>          <End>
" <C-f>: next char.
cnoremap <C-f>          <Right>
" <C-n>: next history.
cnoremap <C-n>          <Down>
" <C-p>: previous history.
cnoremap <C-p>          <Up>
" <C-k>, K: delete to end.
cnoremap <C-k> <C-\>e getcmdpos() == 1 ?
      \ '' : getcmdline()[:getcmdpos()-2]<CR>
" <C-y>: paste.
cnoremap <C-y>          <C-r>*
"}}}
" Easily edit .vimrc and .gvimrc "{{{
nnoremap <silent> <Space>ev  :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> <Space>eg  :<C-u>edit $MYGVIMRC<CR>
"}}}
" Change current directory. "{{{
nnoremap <silent> <Space>cd :<C-u>CD<CR>
command! -nargs=? -complete=dir -bang CD  call s:ChangeCurrentDir('<args>', '<bang>') 
function! s:ChangeCurrentDir(directory, bang)
  if a:directory == ''
    lcd %:p:h
  else
    execute 'lcd' . a:directory
  endif

  if a:bang == ''
    pwd
  endif
endfunction

" ----------------------------------------------------------------------------
" Encoding
" ----------------------------------------------------------------------------
set encoding=utf-8
" Setting of terminal encoding.
if !has('gui_running')
  if &term ==# 'win32' &&
        \ (v:version < 703 || (v:version == 703 && has('patch814')))
    " Setting when use the non-GUI Japanese console.

    " Garbled unless set this.
    set termencoding=cp932
    " Japanese input changes itself unless set this. Be careful because the
    " automatic recognition of the character code is not possible!
    set encoding=japan
  else
    if $ENV_ACCESS ==# 'linux'
      set termencoding=euc-jp
    elseif $ENV_ACCESS ==# 'colinux'
      set termencoding=utf-8
    else  " fallback
      set termencoding= " same as 'encoding'
    endif
  endif
elseif s:is_windows
  " For system.
  set termencoding=cp932
endif

if !exists('did_encoding_settings') && has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'

  " Does iconv support JIS X 0213?
  if iconv('\x87\x64\x87\x6a', 'cp932', 'euc-jisx0213') ==# '\xad\xc5\xad\xcb'
    let s:enc_euc = 'euc-jisx0213,euc-jp'
    let s:enc_jis = 'iso-2022-jp-3'
  endif

  " Build encodings.
  let &fileencodings = 'ucs-bom'
  if &encoding !=# 'utf-8'
    let &fileencodings = &fileencodings . ',' . 'ucs-2le'
    let &fileencodings = &fileencodings . ',' . 'ucs-2'
  endif
  let &fileencodings = &fileencodings . ',' . s:enc_jis

  if &encoding ==# 'utf-8'
    let &fileencodings = &fileencodings . ',' . s:enc_euc
    let &fileencodings = &fileencodings . ',' . 'cp932'
  elseif &encoding =~# '^euc-\%(jp\|jisx0213\)$'
    let &encoding = s:enc_euc
    let &fileencodings = &fileencodings . ',' . 'utf-8'
    let &fileencodings = &fileencodings . ',' . 'cp932'
  else " cp932
    let &fileencodings = &fileencodings . ',' . 'utf-8'
    let &fileencodings = &fileencodings . ',' . s:enc_euc
  endif
  let &fileencodings = &fileencodings . ',' . &encoding

  unlet s:enc_euc
  unlet s:enc_jis

  let did_encoding_settings = 1
 endif

if has('kaoriya')
  " For Kaoriya only.
  set fileencodings=guess
endif

" Default fileformat.
set fileformat=unix
" Automatic recognition of a new line cord.
set fileformats=unix,dos,mac
" A fullwidth character is displayed in vim properly.
set ambiwidth=double

" Open in UTF-8 again.
command! -bang -bar -complete=file -nargs=? Utf8 edit<bang> ++enc=utf-8 <args>
" Open in iso-2022-jp again.
command! -bang -bar -complete=file -nargs=? Iso2022jp edit<bang> ++enc=iso-2022-jp <args>
" Open in Shift_JIS again.
command! -bang -bar -complete=file -nargs=? Cp932 edit<bang> ++enc=cp932 <args>
" Open in EUC-jp again.
command! -bang -bar -complete=file -nargs=? Euc edit<bang> ++enc=euc-jp <args>
" Open in UTF-16 again.
command! -bang -bar -complete=file -nargs=? Utf16 edit<bang> ++enc=ucs-2le <args>
" Open in UTF-16BE again.
command! -bang -bar -complete=file -nargs=? Utf16be edit<bang> ++enc=ucs-2 <args>

" Aliases.
command! -bang -bar -complete=file -nargs=? Jis Iso2022jp<bang> <args>
command! -bang -bar -complete=file -nargs=? Sjis Cp932<bang> <args>
command! -bang -bar -complete=file -nargs=? Unicode Utf16<bang> <args>

" Tried to make a file note version.
" Don't save it because dangerous.
command! WUtf8 setl fenc=utf-8 command! WIso2022jp setl fenc=iso-2022-jp
command! WCp932 setl fenc=cp932
command! WEuc setl fenc=euc-jp
command! WUtf16 setl fenc=ucs-2le
command! WUtf16be setl fenc=ucs-2
" Aliases.
command! WJis WIso2022jp
command! WSjis WCp932
command! WUnicode WUtf16

if has('multi_byte_ime')
  set iminsert=0 imsearch=0
endif

" ----------------------------------------------------------------------------
" Language
" ----------------------------------------------------------------------------
" Vim
let g:vimsyntax_noerror = 1

" Python
let g:python_highlight_all = 1
function! Preserve(command)
  " Save the last search.
  let search = @/
  " Save the current cursor position.
  let cursor_position = getpos('.')
  " Save the current window position.
  normal! H
  let window_position = getpos('.')
  call setpos('.', cursor_position)
  " Execute the command.
  execute a:command
  " Restore the last search.
  let @/ = search
  " Restore the previous window position.
  call setpos('.', window_position)
  normal! zt
  " Restore the previous cursor position.
  call setpos('.', cursor_position)
endfunction

function! Autopep8()
  call Preserve(':silent %!autopep8 --indent-size 2 -')
endfunction

augroup Python
  autocmd! Python
  autocmd FileType python nnoremap <S-f> :call Autopep8()<CR>
augroup END

" Golang
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'}


" markdown
let g:netrw_nogx = 1
nmap gx <Plug>(openbrowser-smart-search)
vmap gx <Plug>(openbrowser-smart-search)

" ----------------------------------------------------------------------------
" Autocommands
" ----------------------------------------------------------------------------
augroup MyAutoCmd
  autocmd!

  autocmd BufWritePost *.vim,.vimrc source $MYVIMRC
  autocmd BufRead,BufNewFile *.vim,.vimrc setl foldmethod=marker
  autocmd BufRead,BufNewFile *.v setl suffixesadd=.v
  autocmd BufRead,BufNewFile *.py setl shiftwidth=2 cin tw=79
  autocmd BufRead,BufNewFile *.py setl fdm=indent fdn=2 fdl=1
  autocmd BufWritePre *.py call Autopep8()
  autocmd BufRead,BufNewFile *.hs setl nofoldenable
  autocmd BufRead,BufNewFile *.c,*.cpp,*.h setl noexpandtab
  autocmd BufRead,BufNewFile *.c,*.cpp,*.h setl shiftwidth=4
  autocmd BufRead,BufNewFile *.c,*.cpp,*.h setl tabstop=4
  autocmd BufRead,BufNewFile *.c,*.cpp,*.h setl listchars=tab:\|\ ,trail:-
  autocmd BufRead,BufNewFile *.go setl noexpandtab shiftwidth=4 tabstop=4
  autocmd BufRead,BufNewFile *.go setl listchars=tab:\|\ ,trail:-
  autocmd BufRead,BufNewFile *.v setl noexpandtab shiftwidth=2 tabstop=2
  autocmd BufRead,BufNewFile *.v setl listchars=tab:\|\ ,trail:-

  autocmd FileType css setl omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setl omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setl omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setl omnifunc=pythoncomplete#Complete
  autocmd FileType xml setl omnifunc=xmlcomplete#CompleteTags
augroup END


" ----------------------------------------------------------------------------
" vim-plug
" ----------------------------------------------------------------------------
let g:plug_window='new'

" ----------------------------------------------------------------------------
" vimproc
" ----------------------------------------------------------------------------
if has('win64')
  let g:vimproc_dll_path = $DOTVIM . '/vimproc_win64.dll'
elseif has('win32')
  let g:vimproc_dll_path = $DOTVIM . '/vimproc_win32.dll'
endif

" ----------------------------------------------------------------------------
" <Enter> | vim-easy-align
" ----------------------------------------------------------------------------

" Start interactive EasyAlign in visual mode (e.g. vip<Enter>)
vmap <Enter> <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
nmap gaa ga_

" ----------------------------------------------------------------------------
" unite.vim
" ----------------------------------------------------------------------------
let g:unite_enable_start_insert=1
let g:unite_source_history_yank_enable = 1
" use vimfiler to open directory
call unite#custom_default_action("source/bookmark/directory", "vimfiler")
call unite#custom_default_action("directory", "vimfiler")
call unite#custom_default_action("directory_mru", "vimfiler")
" matcher をデフォルトにする
call unite#custom#source('file', 'matchers', ["matcher_default"])
function! s:unite_settings()
  imap <buffer> <Esc><Esc> <Plug>(unite_exit)
  nmap <buffer> <Esc> <Plug>(unite_exit)
  imap <buffer> <C-j> <Plug>(unite_select_next_line)
  imap <buffer> <C-k> <Plug>(unite_select_previous_line)
endfunction
augroup Unite
  autocmd! Unite
  autocmd FileType unite call s:unite_settings()
augroup END

" The prefix key.
nnoremap    [unite]   <Nop>
xnoremap    [unite]   <Nop>
nmap    <Space>u [unite]
xmap    <Space>u [unite]
" Unite-grep
nnoremap <silent> [unite]s
      \ :<C-u>Unite grep -buffer-name=search
      \ -auto-preview -no-quit -resume<CR>
" yank history.
nnoremap <silent> [unite]y :<C-u>Unite history/yank<CR>
" vim-unite-giti.
nnoremap <silent> [unite]g :<C-u>Unite giti<CR>
" All.
nnoremap <silent> [unite]a :<C-u>Unite buffer file_mru bookmark file<CR>

" ----------------------------------------------------------------------------
" VimFiler
" ----------------------------------------------------------------------------
nnoremap <silent> <Space>v  :<C-u>VimFiler -find<CR>
nnoremap <silent> <Space>ff :<C-u>VimFilerExplorer<CR>
let g:vimfiler_as_default_explorer = 1
let g:vimfiler_enable_clipboard = 0
let g:vimfiler_safe_mode_by_default = 0

let g:vimfiler_detect_drives = s:is_windows ? [
      \ 'C:/', 'D:/', 'E:/', 'F:/', 'G:/', 'H:/', 'I:/',
      \ 'J:/', 'K:/', 'L:/', 'M:/', 'N:/', 'U:/'] :
      \ split(glob('/mnt/*'), '\n') + split(glob('/media/*'), '\n') +
      \ split(glob('/Users/*'), '\n')

if s:is_windows
  " Use trashbox.
  let g:unite_kind_file_use_trashbox = 1
endif

function! s:vimfiler_my_settings()
  call vimfiler#set_execute_file('vim', ['vim', 'notepad'])
  call vimfiler#set_execute_file('txt', 'vim')

  " Overwrite settings.
  nnoremap <silent><buffer> J
        \ <C-u>:Unite -buffer-name=files -default-action=lcd directory_mru<CR>

  nmap <buffer> O <Plug>(vimfiler_sync_with_another_vimfiler)
  nnoremap <silent><buffer><expr> gy vimfiler#do_action('tabopen')
  nmap <buffer> <Tab> <Plug>(vimfiler_switch_to_other_window)

endfunction

augroup VimFiler
  autocmd! VimFiler
  autocmd FileType vimfiler call s:vimfiler_my_settings()
augroup END

 " ----------------------------------------------------------------------------
 " VimShell
 " ----------------------------------------------------------------------------
 nmap <Space>s :<C-u>VimShell<CR>
 nnoremap <silent> <Space>; :<C-u>VimShellPop<CR>

" ----------------------------------------------------------------------------
" incsearch.vim
" ----------------------------------------------------------------------------
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)

" ----------------------------------------------------------------------------
" indentLine
" ----------------------------------------------------------------------------
let g:indentLine_faster = 1
let g:indentLine_color_term = 111
let g:indentLine_color_gui = '#708090'
let g:indentLine_char = '|'
let g:indentLine_fileTypeExclude = ['help', 'vimfiler', 'unite']

" ----------------------------------------------------------------------------
" lightline.vim
" ----------------------------------------------------------------------------
let g:lightline = {
      \ 'colorscheme': 'Tomorrow_Night_Eighties',
      \ 'mode_map': {'c': 'NORMAL'},
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['filename']
      \   ],
      \   'right': [
      \     ['lineinfo'],
      \     ['percent'],
      \     [ 'syntaxcheck' ],
      \     ['charcode', 'fileformat', 'fileencoding', 'filetype']
      \   ]
      \ },
      \ 'component_function': {
      \   'charcode'     : 'MyCharCode',
      \   'fileencoding' : 'MyFileencoding',
      \   'fileformat'   : 'MyFileformat',
      \   'filename'     : 'MyFilename',
      \   'filetype'     : 'MyFiletype',
      \   'mode'         : 'MyMode',
      \   'modified'     : 'MyModified',
      \   'readonly'     : 'MyReadonly',
      \   'syntastic'    : 'SyntasticStatuslineFlag',
      \ },
      \ 'component_expand': {
      \   'syntaxcheck': 'qfstatusline#Update',
      \ },
      \ 'component_type': {
      \   'syntaxcheck': 'error',
      \ },
      \ }

function! MyModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! MyReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &ro ? '⭤' : ''
endfunction

function! MyFilename()
  return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? substitute(b:vimshell.current_dir,expand('~'),'~','') :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction

function! MyFileformat()
  return winwidth('.') > 70 ? &fileformat : ''
endfunction

function! MyFiletype()
  return winwidth('.') > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! MyFileencoding()
  return winwidth('.') > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! MyMode()
  return winwidth('.') > 60 ? lightline#mode() : ''
endfunction

function! MyCharCode()
  if winwidth('.') <= 70
    return ''
  endif

  " Get the output of :ascii
  redir => ascii
  silent! ascii
  redir END

  if match(ascii, 'NUL') != -1
    return 'NUL'
  endif

  " Zero pad hex values
  let nrformat = '0x%02x'

  let encoding = (&fenc == '' ? &enc : &fenc)

  if encoding == 'utf-8'
    " Zero pad with 4 zeroes in unicode files
    let nrformat = '0x%04x'
  endif

  " Get the character and the numeric value from the return value of :ascii
  " This matches the two first pieces of the return value, e.g.
  " '<F> 70' => char: 'F', nr: '70'
  let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

  " Format the numeric value
  let nr = printf(nrformat, nr)

  return "'". char ."'" . nr
endfunction

" ----------------------------------------------------------------------------
" Restart.vim
" ----------------------------------------------------------------------------
let g:restart_save_window_values=0
nnoremap <silent> <Space>re  :<C-u>Restart<CR>

" ----------------------------------------------------------------------------
" nerdcommenter
" ----------------------------------------------------------------------------
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
nmap <Leader>/ <Plug>NERDCommenterToggle
vmap <Leader>/ <Plug>NERDCommenterToggle

" ----------------------------------------------------------------------------
" vim-go
" ----------------------------------------------------------------------------
let g:go_fmt_command='goimports'
let g:go_fmt_autosave = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:gocomplete#system_function = 'vimproc#system'

" ----------------------------------------------------------------------------
" neocomplete
" ----------------------------------------------------------------------------
" <TAB>: completion.
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"
" ファイル名補完
inoremap <C-x><C-f> <C-x><C-f><C-p>
inoremap <expr><C-g> neocomplete#undo_completion()
inoremap <expr><C-l> neocomplete#complete_common_string()

let g:neocomplete#enable_at_startup=1
let g:neocomplete#enable_ignore_case=1
let g:neocomplete#enable_smart_case=1
let g:neocomplete#enable_fuzzy_completion=1
let g:neocomplete#sources#syntax#min_keyword_length=4
let g:neocomplete#auto_completion_start_length=3
let g:neocomplete#skip_auto_completion_time='0.3'
let g:neocomplete#enable_auto_select=0
let g:neocomplete#sources#buffer#disabled_pattern=
      \ '\.log\|\.log\.\|\.jax\|Log.txt'
" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries={
      \ 'default' : '',
      \ 'vimshell' : '~/.vimshell/command-history'
      \ }
" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns={}
endif
let g:neocomplete#keyword_patterns['default']='\h\w*'
let g:neocomplete#keyword_patterns['gosh-repl']="[[:alpha:]+*/@$_=.!?-][[:alnum:]+*/@$_:=.!?-]*"

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns={}
endif
if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns={}
endif
let g:neocomplete#force_omni_input_patterns.c=
      \ '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?'

" ----------------------------------------------------------------------------
" neosnippet
" ----------------------------------------------------------------------------
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory='~/.vim/snippets/'

" Plugin key-mappings.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>"
      \ : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)"
      \ : "\<TAB>"
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
inoremap <silent><C-u> <ESC>:<C-U>Unite neosnippet<CR>

if has('conceal')
  set conceallevel=2 concealcursor=i
endif

" ----------------------------------------------------------------------------
" over.vim
" ----------------------------------------------------------------------------
" 0 以外が設定されていれば :/ or :? 時にそのパータンをハイライトする。
let g:over#command_line#search#enable_incsearch = 1
" 0 以外が設定されていれば :/ or :? 時にそのパータンへカーソルを移動する。
let g:over#command_line#search#enable_move_cursor = 0

cnoreabb <silent><expr>s getcmdtype()==':' && getcmdline()=~'^s' ? 'OverCommandLine<CR><C-u>%s/<C-r>=get([], getchar(0), '')<CR>': 's'

" ----------------------------------------------------------------------------
" vim-watchdogs
" ----------------------------------------------------------------------------
if exists('##QuitPre')
  let g:watchdogs_check_BufWritePost_enable = 1
  if !exists("g:quickrun_config")
    let g:quickrun_config = {}
  endif

  let g:quickrun_config["watchdogs_checker/_"] = {
        \ "outputter/quickfix/open_cmd" : "",
        \ "hook/qfstatusline_update/enable_exit" : 1,
        \ "hook/qfstatusline_update/priority_exit" : 4,
        \ }

  call watchdogs#setup(g:quickrun_config)
endif

" ----------------------------------------------------------------------------
" vim-qfstatusline
" ----------------------------------------------------------------------------
let g:Qfstatusline#UpdateCmd = function('lightline#update')

" ----------------------------------------------------------------------------
" matchit.vim
" ----------------------------------------------------------------------------
runtime macros/matchit.vim

" ----------------------------------------------------------------------------
" rainbow_parentheses.vim
" ----------------------------------------------------------------------------
let g:rbpt_loadcmd_toggle=1
augroup RainbowParentheses
  autocmd!
  autocmd Syntax * RainbowParenthesesToggleAll
augroup END

" ----------------------------------------------------------------------------
" Read local setting.
" ----------------------------------------------------------------------------
if filereadable(expand('$HOME/.vimrc_local'))
  source $HOME/.vimrc_local
endif

