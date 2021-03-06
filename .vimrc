scriptencoding utf-8

" automatically download vimproc.dll
let g:vimproc#download_windows_dll = 1

let s:is_windows = has('win16') || has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))

" Use English interface.
if s:is_windows
  language message en
else
  language message C
endif

" Exchange path separator.
if s:is_windows
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
  Plug 'Shougo/unite.vim' | Plug 'Shougo/vimshell'
  Plug 'Shougo/unite.vim' | Plug 'Shougo/neoyank.vim'
  Plug 'Shougo/unite.vim' | Plug 'Shougo/vimfiler.vim'
  Plug 'haya14busa/incsearch.vim'
  Plug 'itchyny/vim-cursorword'

  " Git
  Plug 'Shougo/unite.vim' | Plug 'kmnk/vim-unite-giti'
  Plug 'tpope/vim-fugitive'

  " Colors
  Plug 'chriskempson/vim-tomorrow-theme'
  Plug 'kien/rainbow_parentheses.vim'
  Plug 'joshdick/onedark.vim'
  Plug 'hallzy/lightline-onedark'
  Plug 'jacoborus/tender'

  " Edit
  Plug 'junegunn/vim-easy-align'
  Plug 'scrooloose/nerdcommenter'
  Plug 'tpope/vim-surround'
  Plug 'osyo-manga/vim-over'
  Plug 'jceb/vim-hier'
  Plug 'KazuakiM/vim-qfstatusline'

  " Lang
  Plug 'fatih/vim-go'
  Plug 'tpope/vim-markdown'
  Plug 'elzr/vim-json'
  Plug 'tell-k/vim-autopep8'
  Plug 'rhysd/vim-clang-format'
  Plug 'rust-lang/rust.vim'
  Plug 'rhysd/unite-go-import.vim'

  if(has('lua'))
    Plug 'Shougo/neocomplete' | Plug 'Shougo/neosnippet'
    Plug 'Shougo/neocomplete' | Plug 'Shougo/neosnippet-snippets'
  endif

  call plug#end()
endif

" ============================================================================
" BASIC SETTINGS
"
colorscheme tender
set autoindent
set smartindent
set breakindent
set lazyredraw
set laststatus=2
set number
set showcmd
set visualbell
set backup
set backupdir=~/var/vim/backup//
set writebackup
set swapfile
set directory=~/var/vim/swap//
set undofile
set undodir=~/var/vim/undo//
set undolevels=1000
set matchpairs+=<:>
set backspace=indent,eol,start
set timeoutlen=500
set whichwrap+=h,l,<,>,[,],b,s,~
set shortmess=aIT
set hlsearch " CTRL-L / CTRL-R W
set incsearch
set hidden
set ignorecase
set smartcase
set wildmenu
set wildmode=full
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
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
set modeline
set t_Co=256
set nf="hex"
set foldlevelstart=99
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
set grepformat=%f:%l:%c:%m,%f:%l:%m
if executable('jvgrep')
  set grepprg=jvgrep
endif

" ----------------------------------------------------------------------------
" Keymappings
"
" Smart space mapping.
nnoremap <Space>   <Nop>
xnoremap <Space>   <Nop>
" Command-line mode keymappings
" <C-a>, A: move to head.
cnoremap <C-a> <Home>
" <C-b>: previous char.
cnoremap <C-b> <Left>
" <C-d>: delete char.
cnoremap <C-d> <Del>
" <C-e>, E: move to end.
cnoremap <C-e> <End>
" <C-f>: next char.
cnoremap <C-f> <Right>
" <C-n>: next history.
cnoremap <C-n> <Down>
" <C-p>: previous history.
cnoremap <C-p> <Up>
" <C-k>, K: delete to end.
cnoremap <C-k> <C-\>e getcmdpos() == 1 ?
      \ '' : getcmdline()[:getcmdpos()-2]<CR>
" <C-y>: paste.
cnoremap <C-y> <C-r>*

" Easily edit .vimrc and .gvimrc
nnoremap <silent> <Space>ev  :<C-u>edit $HOME/.vim/.vimrc<CR>
nnoremap <silent> <Space>eg  :<C-u>edit $HOME/.vim/.gvimrc<CR>

" Change current directory.
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
"
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
"
" Vim
let g:vimsyntax_noerror = 1

" Python
let g:autopep8_disable_show_diff=1
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

" Java
let g:java_highlight_all=1
let g:java_highlight_debug=1
let g:java_allow_cpp_keywords=1
let g:java_space_errors=1
let g:java_highlight_functions=1

" json
let g:vim_json_syntax_conceal = 0

" Golang
nmap gs <Plug>(go-def-split)
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

" ----------------------------------------------------------------------------
" Autocommands
"
augroup MyAutoCmd
  autocmd!
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd FileType c,cpp,objc setl noexpandtab
  autocmd FileType c,cpp,objc setl shiftwidth=4
  autocmd FileType c,cpp,objc setl tabstop=4
  autocmd FileType go setl noexpandtab
  autocmd FileType go setl shiftwidth=4
  autocmd FileType go setl tabstop=4
  autocmd FileType go setl listchars=tab:\|\ ,trail:-
  autocmd FileType haskell setl nofoldenable
  autocmd FileType java setl noexpandtab
  autocmd FileType java setl tabstop=2
  autocmd FileType python setl cin
  autocmd FileType python setl noexpandtab
  autocmd FileType python setl nofoldenable
  autocmd FileType python setl shiftwidth=4
  autocmd FileType python setl tabstop=4
  autocmd FileType python setl tw=79
  autocmd FileType verilog setl suffixesadd=.v
  autocmd FileType vim setl foldmethod=marker

  autocmd FileType css setl omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setl omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setl omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setl omnifunc=pythoncomplete#Complete
  autocmd FileType xml setl omnifunc=xmlcomplete#CompleteTags
  autocmd FileType java setl omnifunc=javacomplete#Complete
  autocmd FileType java setl completefunc=javacomplete#COmpleteParamsInfo
augroup END


" ----------------------------------------------------------------------------
" vim-plug
"
let g:plug_window='new'

" ----------------------------------------------------------------------------
" unite.vim
"
let g:unite_enable_start_insert=1
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
nnoremap <silent> [unite]g  :<C-u>Unite giti<CR>
nnoremap <silent> [unite]gb :<C-u>Unite giti/branch<CR>
nnoremap <silent> [unite]gc :<C-u>Unite giti/config<CR>
nnoremap <silent> [unite]gl :<C-u>Unite giti/log<CR>
nnoremap <silent> [unite]gr :<C-u>Unite giti/remote<CR>
nnoremap <silent> [unite]gs :<C-u>Unite giti/status<CR>
" All.
nnoremap <silent> [unite]a :<C-u>Unite buffer file_mru bookmark file<CR>

" ----------------------------------------------------------------------------
" vimshell
"
nmap <Space>s :<C-u>VimShell<CR>
nnoremap <silent> <Space>; :<C-u>VimShellPop<CR>

" ----------------------------------------------------------------------------
" vimfiler
"
let g:vimfiler_as_default_explorer = 1
nmap <Space>f :<C-u>VimFiler<CR>

" ----------------------------------------------------------------------------
" incsearch.vim
"
map / <Plug>(incsearch-forward)

" ----------------------------------------------------------------------------
" vim-fugitive
"
nnoremap <silent> <Space>gb :<C-u>Gblame<CR>
nnoremap <silent> <Space>gd :<C-u>Gdiff<CR>
nnoremap <silent> <Space>gs :<C-u>Gstatus<CR>

" ----------------------------------------------------------------------------
" lightline.vim
"
let g:tender_lightline = 1
let g:lightline = {
      \ 'colorscheme': 'tender',
      \ 'mode_map': {'c': 'NORMAL'},
      \ 'active': {
      \   'left': [
      \     ['mode', 'paste'],
      \     ['fugitive', 'readonly', 'filename']
      \   ],
      \   'right': [
      \     ['lineinfo'],
      \     ['percent'],
      \     [ 'syntaxcheck' ],
      \     ['charcode', 'fileformat', 'fileencoding', 'filetype']
      \   ]
      \ },
      \ 'component_function': {
      \   'charcode'     : 'LightLineCharCode',
      \   'fileencoding' : 'LightLineFileencoding',
      \   'fileformat'   : 'LightLineFileformat',
      \   'filename'     : 'LightLineFilename',
      \   'filetype'     : 'LightLineFiletype',
      \   'mode'         : 'LightLineMode',
      \   'modified'     : 'LightLineModified',
      \   'readonly'     : 'LightLineReadonly',
      \   'syntastic'    : 'SyntasticStatuslineFlag',
      \   'fugitive'     : 'LightLineFugitive'
      \ },
      \ 'component_expand': {
      \   'syntaxcheck': 'qfstatusline#Update',
      \ },
      \ 'component_type': {
      \   'syntaxcheck': 'error',
      \ },
      \ }

function! LightLineModified()
  return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
  return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? '⭤' : ''
endfunction

function! LightLineFilename()
  return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
        \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
        \  &ft == 'unite' ? unite#get_status_string() :
        \  &ft == 'vimshell' ? vimshell#get_status_string() :
        \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
        \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
  if &ft !~? 'vimfiler\|gundo' && exists("*fugitive#head")
    let _ = fugitive#head()
    return strlen(_) ? '⭠ '._ : ''
  endif
  return ''
endfunction

function! LightLineFileformat()
  return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
  return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
  return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
  return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

function! LightLineCharCode()
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
"
let g:restart_sessionoptions = "winsize,winpos"
nnoremap <silent> <Space>re  :<C-u>Restart<CR>

" ----------------------------------------------------------------------------
" nerdcommenter
"
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
nmap <Leader>/ <Plug>NERDCommenterToggle
vmap <Leader>/ <Plug>NERDCommenterToggle

" ----------------------------------------------------------------------------
" vim-go
"
let g:go_fmt_command='goimports'
let g:go_fmt_autosave = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:gocomplete#system_function = 'system'

" ----------------------------------------------------------------------------
" neocomplete
"
" <TAB>: completion.
inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<S-TAB>"
" file name completion
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
"
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
"
" 0 以外が設定されていれば :/ or :? 時にそのパータンをハイライトする。
let g:over#command_line#search#enable_incsearch = 1
" 0 以外が設定されていれば :/ or :? 時にそのパータンへカーソルを移動する。
let g:over#command_line#search#enable_move_cursor = 0

cnoreabb <silent><expr>s getcmdtype()==':' && getcmdline()=~'^s' ? 'OverCommandLine<CR><C-u>%s/<C-r>=get([], getchar(0), '')<CR>': 's'

" ----------------------------------------------------------------------------
" vim-qfstatusline
"
let g:Qfstatusline#UpdateCmd = function('lightline#update')

" ----------------------------------------------------------------------------
" matchit.vim
"
runtime macros/matchit.vim

" ----------------------------------------------------------------------------
" rainbow_parentheses.vim
"
let g:rbpt_loadcmd_toggle=1
augroup RainbowParentheses
  autocmd!
  autocmd Syntax * RainbowParenthesesToggleAll
augroup END

" ----------------------------------------------------------------------------
" vim-clang-format
"
let g:clang_format#auto_format=1
augroup ClangFormat
  autocmd!
  autocmd FileType c,cpp,objc nnoremap <buffer><Leader>cf :<C-u>ClangFormat<CR>
  autocmd FileType c,cpp,objc vnoremap <buffer><Leader>cf :ClangFormat<CR>
augroup END

" ----------------------------------------------------------------------------
" rust.vim
"
let g:rustfmt_autosave = 1

" ----------------------------------------------------------------------------
" vim-easy-align
vmap <Enter> <Plug>(EasyAlign)

" ----------------------------------------------------------------------------
" Read local setting.
"
if filereadable(expand('$HOME/.vimrc_local'))
  source $HOME/.vimrc_local
endif

