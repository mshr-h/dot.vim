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

" In Windows/Linux, take in a difference of ".vim" and "$VIM/vimfiles".
let $DOTVIM = expand('~/.vim')

" enable matchit.vim
source $VIMRUNTIME/macros/matchit.vim

"golint
set runtimepath+=globpath($GOPATH, "src/github.com/golang/lint/misc/vim")

" NeoBundle: "{{{
let s:neobundle_dir = expand('~/.bundle')

if has('vim_starting') "{{{
  " Set runtimepath. "{{{
  if s:is_windows
    let runtimepath = join([
          \ expand('~/.vim'),
          \ expand('$VIM/runtime'),
          \ expand('~/.vim/after')], ',')
  endif "}}}

  " Load neobundle. "{{{
  if isdirectory('neobundle.vim')
    set runtimepath+=neobundle.vim
  elseif finddir('neobundle.vim', '.;') != ''
    execute 'set runtimepath+=' . finddir('neobundle.vim', '.;')
  elseif &runtimepath !~ '/neobundle.vim'
    if !isdirectory(s:neobundle_dir.'/neobundle.vim')
      execute printf('!git clone %s://github.com/Shougo/neobundle.vim.git',
            \ (exists('$http_proxy') ? 'https' : 'git'))
            \ s:neobundle_dir.'/neobundle.vim'
    endif
    execute 'set runtimepath+=' . s:neobundle_dir.'/neobundle.vim'
  endif "}}}

  if filereadable('vimrc_local.vim') ||
        \ findfile('vimrc_local.vim', '.;') != ''
    " Load develop version.
    call neobundle#local(fnamemodify(
          \ findfile('vimrc_local.vim', '.;'), ':h'), { 'resettable' : 0 })
  endif
endif "}}}

call neobundle#begin(s:neobundle_dir)

let g:neobundle#enable_tail_path = 1
let g:neobundle#default_options = {
      \ 'default' : { 'overwrite' : 0 },
      \ }

NeoBundleFetch 'Shougo/neobundle.vim', '', 'default'
if !s:is_windows
  NeoBundle 'Shougo/vimproc.vim'
endif
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neomru.vim', {'depends' : ['unite.vim']}
NeoBundle 'Shougo/vimshell', {'depends' : ['unite.vim']}
NeoBundle 'Shougo/vimfiler', {'depends' : ['unite.vim']}
NeoBundle 'vim-scripts/Align'
NeoBundle 'tyru/restart.vim'
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'thinca/vim-quickrun'
NeoBundle 'tpope/vim-surround'
NeoBundle 'Yggdroot/indentLine'
NeoBundle "gcmt/wildfire.vim"
NeoBundle 'kmnk/vim-unite-giti', {'depends' : ['unite.vim']}
NeoBundle 'osyo-manga/vim-over'
NeoBundle 'haya14busa/incsearch.vim'
NeoBundle 'fatih/vim-go', {"autoload": {"filetypes": ['go']}}
NeoBundle 'scrooloose/syntastic'
NeoBundle 'tyru/eskk.vim'
if(has('lua'))
  NeoBundle 'Shougo/neocomplete'
  NeoBundle 'Shougo/neosnippet', {'depends' : ['neocomplete']}
  NeoBundle 'Shougo/neosnippet-snippets', {'depends' : ['Shougo/neosnippet']}
endif

NeoBundleLocal ~/.vim/bundle
" Installation check.
NeoBundleCheck

call neobundle#end()

filetype plugin indent on

" Enable syntax color.
syntax enable
"}}}

" Encoding: "{{{
set encoding=utf-8
" Setting of terminal encoding.
if !has('gui_running')
  if &term ==# 'win32' &&
        \ (v:version < 703 || (v:version == 703 && has('patch814')))
    " Setting when use the non-GUI Japanese console.

    " Garbled unless set this.
    set termencoding=cp932
    " Japanese input changes itself unless set this.  Be careful because the
    " automatic recognition of the character code is not possible!
    set encoding=japan
  else
    if $ENV_ACCESS ==# 'linux'
      set termencoding=euc-jp
    elseif $ENV_ACCESS ==# 'colinux'
      set termencoding=utf-8
    else  " fallback
      set termencoding=  " same as 'encoding'
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
  if iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
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
  else  " cp932
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
command! -bang -bar -complete=file -nargs=? Jis  Iso2022jp<bang> <args>
command! -bang -bar -complete=file -nargs=? Sjis  Cp932<bang> <args>
command! -bang -bar -complete=file -nargs=? Unicode Utf16<bang> <args>

" Tried to make a file note version.
" Don't save it because dangerous.
command! WUtf8 setl fenc=utf-8
command! WIso2022jp setl fenc=iso-2022-jp
command! WCp932 setl fenc=cp932
command! WEuc setl fenc=euc-jp
command! WUtf16 setl fenc=ucs-2le
command! WUtf16be setl fenc=ucs-2
" Aliases.
command! WJis  WIso2022jp
command! WSjis  WCp932
command! WUnicode WUtf16

if has('multi_byte_ime')
  set iminsert=0 imsearch=0
endif
"}}}

" Editor: "{{{
" Don't create backup.
set nowritebackup
set nobackup
set backupdir-=.
" Don't create swap file.
set noswapfile
" Don't create undo file.
set noundofile
" Highlight matches
set hlsearch
set matchpairs+=<:>
" Show line number.
set number
" Wrap conditions.
set whichwrap+=h,l,<,>,[,],b,s,~
"Show some special characters.
set list
if s:is_windows
  set listchars=tab:>-,trail:-
else
  set listchars=tab:▸\ ,trail:-
endif
" 全角スペース・行末のスペース・タブの可視化
if has("syntax")
  syntax on
  " PODバグ対策
  syn sync fromstart
  function! ActivateInvisibleIndicator()
    " 下の行の"　"は全角スペース
    syntax match InvisibleJISX0208Space "　" display containedin=ALL
    highlight InvisibleJISX0208Space term=underline ctermbg=Blue guibg=darkgray gui=underline
  endfunction
  augroup invisible
    autocmd! invisible
    autocmd BufNew,BufRead * call ActivateInvisibleIndicator()
  augroup END
endif
" Do not wrap long line.
set wrap
" Disable bell.
set t_vb=
set novisualbell
" Increase history amount.
set history=500
" Always display statusline.
set laststatus=2
" Height of command line.
set cmdheight=2
" Show command on statusline.
set showcmd
" Show title.
set title
" Title length.
set titlelen=95
" Smart insert tab setting.
set smarttab
" Exchange tab to spaces.
set expandtab
" Use auto indent.
set autoindent
" Use smart indent.
set smartindent
" Autoindent width.
set shiftwidth=2
" Substitute <Tab> with blanks.
set tabstop=2
" Spaces instead <Tab>.
set softtabstop=2
" Enable backspace delete indent and newline.
set backspace=indent,eol,start
" Share clipboard.
set clipboard=unnamed,autoselect
" Use incremental search.
set incsearch
" 検索時に大文字を含んでいたら大/小を区別
set smartcase
" 大文字と小文字を区別しない
set ignorecase
" Enable modeline.
set modeline
" Display another buffer when current buffer isn't saved.
set hidden
" 256 colors in terminal
set t_Co=256
" Ctrl-a increment fix
set nf="hex"
"}}}

" Syntax: "{{{
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

" Shift + F で自動修正
autocmd FileType python nnoremap <S-f> :call Autopep8()<CR>

" Java
let g:java_highlight_functions = 'style'
let g:java_highlight_all=1
let g:java_highlight_debug=1
let g:java_allow_cpp_keywords=1
let g:java_space_errors=1
let g:java_highlight_functions=1

" Go
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
    \ 'ctagsargs' : '-sort -silent'
\ }
"}}}

" Autocommands "{{{
augroup MyAutoCmd
  autocmd!

  autocmd BufWritePost *.vim,.vimrc source $MYVIMRC
  autocmd BufRead,BufNewFile *.vim,.vimrc setl foldmethod=marker
  autocmd BufRead,BufNewFile *.v setl suffixesadd=.v
  autocmd BufRead,BufNewFile *.py setl shiftwidth=4 cin tw=79
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
  autocmd! BufRead,BufNewFile *.smv
  autocmd  BufRead,BufNewFile *.smv so ~/.vim/smv.vim

  autocmd FileType vimfiler call s:vimfiler_my_settings()
  autocmd FileType unite call s:unite_settings()

  autocmd FileType css setl omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setl omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setl omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setl omnifunc=pythoncomplete#Complete
  autocmd FileType xml setl omnifunc=xmlcomplete#CompleteTags
augroup END
"}}}

" Plugin: "{{{

" VimFiler "{{{
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
else
  " Like Textmate icons.
  let g:vimfiler_tree_leaf_icon = ' '
  let g:vimfiler_tree_opened_icon = '▾'
  let g:vimfiler_tree_closed_icon = '▸'
  let g:vimfiler_file_icon = ' '
  let g:vimfiler_readonly_file_icon = '✗'
  let g:vimfiler_marked_file_icon = '✓'
endif

function! s:vimfiler_my_settings() "{{{
  call vimfiler#set_execute_file('vim', ['vim', 'notepad'])
  call vimfiler#set_execute_file('txt', 'vim')

  " Overwrite settings.
  nnoremap <silent><buffer> J
        \ <C-u>:Unite -buffer-name=files -default-action=lcd directory_mru<CR>

  nmap <buffer> O <Plug>(vimfiler_sync_with_another_vimfiler)
  nnoremap <silent><buffer><expr> gy vimfiler#do_action('tabopen')
  nmap <buffer> <Tab> <Plug>(vimfiler_switch_to_other_window)

  " Migemo search.
  if !empty(unite#get_filters('matcher_migemo'))
    nnoremap <silent><buffer><expr> /  line('$') > 10000 ?  'g/' :
          \ ":\<C-u>Unite -buffer-name=search -start-insert line_migemo\<CR>"
  endif
endfunction
"}}}

"}}}

" VimShell "{{{
nmap <Space>s  :<C-u>VimShell<CR>
nnoremap <silent> <Space>;  :<C-u>VimShellPop<CR>
"}}}

" wildfire.vim "{{{
let g:wildfire_fuel_map = "<CR>"
let g:wildfire_water_map = "<C-CR>t"
let g:wildfire_objects = ["i'", 'i"', "i)", "i]", "i}", "ip", "it"]
"}}}

" Unite.vim "{{{
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
"}}}

" neocomplete "{{{
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
      \ 'vimshell' : $HOME.'.vimshell/command-history'
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
"}}}

" neosnippet "{{{
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
"}}}

" lightline: "{{{
let g:lightline = {
        \ 'mode_map': {'c': 'NORMAL'},
        \ 'active': {
        \   'left': [
        \     ['mode', 'paste'],
        \     ['filename']
        \   ],
        \   'right': [
        \     ['lineinfo', 'syntastic'],
        \     ['percent'],
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
        \ }
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
  " "<F>  70" => char: 'F', nr: '70'
  let [str, char, nr; rest] = matchlist(ascii, '\v\<(.{-1,})\>\s*([0-9]+)')

  " Format the numeric value
  let nr = printf(nrformat, nr)

  return "'". char ."' ". nr
endfunction
"}}}

" Restart.vim "{{{
let g:restart_save_window_values=0
nnoremap <silent> <Space>re  :<C-u>Restart<CR>
"}}}

" indentLine "{{{
let g:indentLine_faster = 1
let g:indentLine_color_term = 111
let g:indentLine_color_gui = '#708090'
let g:indentLine_char = '|'
let g:indentLine_fileTypeExclude = ['help', 'vimfiler', 'unite']
"}}}

" nerdcommenter "{{{
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
nmap <Leader>/ <Plug>NERDCommenterToggle
vmap <Leader>/ <Plug>NERDCommenterToggle
"}}}

" vimproc.vim "{{{
if has('win32')
  let g:vimproc_dll_path = $DOTVIM . '/vimproc_win32.dll'
endif
"}}}

" over.vim "{{{
" 0 以外が設定されていれば :/ or :? 時にそのパータンをハイライトする。
let g:over#command_line#search#enable_incsearch = 1
" 0 以外が設定されていれば :/ or :? 時にそのパータンへカーソルを移動する。
let g:over#command_line#search#enable_move_cursor = 0

cnoreabb <silent><expr>s getcmdtype()==':' && getcmdline()=~'^s' ? 'OverCommandLine<CR><C-u>%s/<C-r>=get([], getchar(0), '')<CR>' : 's'
"}}}

" incsearch.vim "{{{
map / <Plug>(incsearch-forward)
map ? <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
"}}}

" vim-go "{{{
let g:go_fmt_command='goimports'
let g:go_fmt_autosave = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
"}}}

" syntastic "{{{
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_go_checkers = ['golint']
let g:syntastic_c_checkers = []
let g:syntastic_python_checkers = []
"}}}

" eskk.vim "{{{
let g:eskk#enable_completion = 1
let g:eskk#directory = '~/.config/skk'
let g:eskk#dictionary = {
      \ 'path': "~/.config/skk/skk-jisyo",
      \ 'sorted': 1,
      \ 'encoding': 'utf-8',
      \}
let g:eskk#large_dictionary = {
      \ 'path': "~/.config/skk/SKK-JISYO.LL",
      \ 'sorted': 1,
      \ 'encoding': 'euc-jp',
      \}

"}}}

"}}}

" Keymapping: "{{{
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
"}}}

"}}}

" Read local setting.
if filereadable(expand('$HOME/.vimrc_local'))
  source $HOME/.vimrc_local
endif
