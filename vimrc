behave xterm

set hidden "keep undo history when changing between buffers
set confirm " ask confirmation if modified buffers exist
set wildmenu " nicer filename autocomplete - like CTRL+P
set wildmode=longest:full,full
set nocompatible
set modeline    " read mode line
set expandtab
set shiftwidth=4	" insert 4 spaces when pressing [TAB]
set softtabstop=4	" insert 4 spaces when pressing [TAB]
set tabstop=8	        " view \t as 8 space wide, for viewing code with tabs (evil)
set ruler
set number
set textwidth=0 "this sets it for plain text files.  It is reset by filetype below
set showmatch
set smartindent
set visualbell
set incsearch
set hlsearch
set wildmenu
set wildmode=list:longest,full
set undolevels=1000 "explicitly state default, just in case...

set showcmd             " display incomplete commands
set backspace=indent,eol,start
set ignorecase          " ignore case in search patterns ...
set smartcase           " ... unless pattern contains uppercase

set scrolloff=3
set incsearch           " do incremental searching
set listchars=tab:^-,trail:@
set completeopt=longest,menuone,preview

set bg=dark

" c indent: 
" (0 -- line up the next line within open parentheses with the first
"       non-whitespace character.
" l1 -- line up with 'case' statement labels correctly
set cino=(0,l1

" fix for putty keyboard issues
if ($TERM =~? "putty")
    map <Esc>OA <C-Up>
    map <Esc>OB <C-Down>
    map <Esc>OC <C-Right>
    map <Esc>OD <C-Left>
    map <Esc><Esc>[A <A-Up>
    map <Esc><Esc>[B <A-Down>
    map <Esc><Esc>[C <A-Right>
    map <Esc><Esc>[D <A-Left>
    map <Esc>[[A <F1>
    map <Esc>[[B <F2>
    map <Esc>[[C <F3>
    map <Esc>[[D <F4>
    map <Esc>[[E <F5>
    map! <Esc>OA <C-Up>
    map! <Esc>OB <C-Down>
    map! <Esc>OC <C-Right>
    map! <Esc>OD <C-Left>
    map! <Esc><Esc>[A <A-Up>
    map! <Esc><Esc>[B <A-Down>
    map! <Esc><Esc>[C <A-Right>
    map! <Esc><Esc>[D <A-Left>
    map! <Esc>[[A <F1>
    map! <Esc>[[B <F2>
    map! <Esc>[[C <F3>
    map! <Esc>[[D <F4>
    map! <Esc>[[E <F5>
endif

" read manpages more convenients with :Man
runtime! ftplugin/man.vim

" customize directory explorer (:Sex/:Vex/:Ex commands) settings
let g:netrw_liststyle = 3               " default to tree style
" let g:newrw_list_hide = '.*\.swp$'
nnoremap <silent> ,h :Rexplore<CR>

" highlight ack searches (doesn't work everywhere?)
let g:ackhighlight = 1
" ack search for word under cursor
nnoremap ,a :Ack <C-R><C-W><CR>:set hlsearch<CR>
" ack search for word under cursor, appending to current quickfix list
nnoremap ,A :AckAdd <C-R><C-W><CR>:set hlsearch<CR>

" keymappings
map <F5> :vert diffsplit

" indent/unindent visual blocks keeping highlight (unlike the defaults)
vnoremap > >gv
vnoremap < <gv

" cycle through buffers
set wildcharm=<C-Z>
nnoremap ,, :b <C-Z>
nnoremap <C-h> :bp<CR>
nnoremap <C-l> :bn<CR>

" navigate windows
noremap <C-Right> <C-w>l
noremap <C-Up> <C-w>k
noremap <C-Down> <C-w>j
noremap <C-Left> <C-w>h
noremap! <C-Right> <C-o><C-w>l
noremap! <C-Up> <C-o><C-w>k
noremap! <C-Down> <C-o><C-w>j
noremap! <C-Left> <C-o><C-w>h

map Q :nohlsearch<CR>

"Only do this part when compiled with support for autocommands.
if has("autocmd")
  " Remove all cprog autocommands
  au!
  filetype plugin indent on

  " Turn off line wrap for common files
  au BufNewFile,BufRead db.*	setlocal nowrap
  au BufNewFile,BufRead /etc/*	setlocal nowrap

  au BufNewFile,BufRead,StdinReadPost *
    \ let s:l1 = getline(1) |
    \ if s:l1 =~ '^Return-Path: ' |
    \   setf mail |
    \ endif

  " Restore cursor to the last position in file
  au BufReadPost *
      \ if line("'\"") > 0 && line("'\"") <= line("$") |
      \   exe "normal g`\"" |
      \ endif

  " When starting to edit a file:
  "   For C and C++ files set formatting of comments and set C-indenting on.
  "   For other files switch it off.
  "   Don't change the order, it's important that the line with * comes first.
  augroup Text
    autocmd FileType *      setlocal formatoptions=tcq comments&
    autocmd FileType crontab setlocal tw=0
    autocmd FileType c,cpp  setlocal tw=79 formatoptions=croq cindent comments=sr:/*,mb:*,el:*/,://
    au FileType c setlocal cino=:0,g0,t0,(0,w1,W4
    au FileType c setlocal expandtab
    autocmd FileType vim  setlocal tw=80 comments=:\"
    autocmd FileType make setlocal formatoptions=tcq tw=0 ts=4 noet comments=:#

    autocmd FileType perl setlocal formatoptions=croq comments=:# tw=80
    autocmd FileType perl setlocal errorformat=%f:%l:%m 
    autocmd FileType perl setlocal autowrite 
    autocmd FileType perl map ,c :"%"!perltidy -q -pt=2 -sak="if elsif" <CR>
    
    autocmd FileType xml setlocal sts=2 sw=2 et tw=0
    
    autocmd FileType awk  setlocal formatoptions=croq autoindent comments=:# 
    autocmd FileType sh  setlocal formatoptions=croq autoindent comments=:# 
    
    au FileType html setlocal tw=0
    au FileType php setlocal tw=0
    au FileType js setlocal tw=0
    
    au FileType p4 setlocal tw=0
    au FileType p4 setlocal wrap
    au FileType p4 setlocal ai      
    au FileType p4 setlocal noet 

    " unless we hear otherwise, *.t is perl
    autocmd BufNewFile,BufRead *.t setf perl

    syntax on
    autocmd FileType c,cpp syn sync fromstart
  augroup END

  " After entering a buffer, the working directory is changed to the directory
  " where the file in the current buffer comes from.  Can be confusing til you get
  " used to it  :)
  if $vim_cd
      autocmd BufEnter * :lcd %:p:h
  endif

  augroup GPGASCII
     au!
     au BufReadPost *.asc  :"%"!gpg -q -d
     au BufReadPost *.asc  |redraw
     au BufWritePre *.asc  :"%"!gpg -q -e -a
     au BufWritePost *.asc u
     au VimLeave *.asc :!clear
  augroup END 

  autocmd QuickFixCmdPost [^l]* nested cwindow
  autocmd QuickFixCmdPost    l* nested lwindow
  autocmd FileType qf call AdjustWindowHeight(3, 10)

endif " has("autocmd")

function! MyStatusLine()
    let sl = '{%n/%{bufnr("$")}}%t%m%r%h%w%y %<%F%%= %l/%L,%c%V (%3b=0x%02B) %P'
    return sl
endfunction

function! AdjustWindowHeight(minheight, maxheight)
      exe max([min([line("$")+1, a:maxheight]), a:minheight]) . "wincmd _"
endfunction

" mode options

" If comparing files side-by-side, then ...
if &diff
    " double the width up to a reasonable maximum
    let &columns = ((&columns*2 > 172)? 172: &columns*2)

	" add bottom scrollbar
	set guioptions=agimrb
endif 

syntax enable

" fold options
syn sync fromstart
let perl_include_pod=1
let perl_extended_vars=1

" apparently we need to re-run this after the folding config prep
syntax on
highlight User1 term=bold ctermfg=0 ctermbg=3 guifg=wheat guibg=peru
