""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" =>Basic
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on
set nu
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set hlsearch
set showcmd
set showmatch
set smartcase
set incsearch
set nohidden
set swapfile
set backup
set undofile
set directory=~/.cache/vim/swap//
set backupdir=~/.cache/vim/backup//
set undodir=~/.cache/vim/undo//
set magic
set autoread
set autowrite
set autowriteall
set backspace=indent,eol,start

"set background=dark
"colorscheme solarized

set encoding=utf8
set ffs=unix

" Set cursor shape and color
if &term =~ "xterm"
    " INSERT mode
    let &t_SI = "\<Esc>[6 q"
    " REPLACE mode
    let &t_SR = "\<Esc>[3 q"
    " NORMAL mode
    let &t_EI = "\<Esc>[1 q"
endif
" 1 -> blinking block  闪烁的方块
" 2 -> solid block  不闪烁的方块
" 3 -> blinking underscore  闪烁的下划线
" 4 -> solid underscore  不闪烁的下划线
" 5 -> blinking vertical bar  闪烁的竖线
" 6 -> solid vertical bar  不闪烁的竖线

"Merge symbols
match ErrorMsg '^\(<\|=\|>\)\{7\}\([^=].\+\)\?$'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key Mapping
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader=" "
nnoremap <leader><space> :tabnew<space>
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
"nnoremap <leader><esc> :q<CR>
nnoremap <leader><CR> :noh<CR>

nnoremap j jzz
nnoremap k kzz
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-up> <c-w>-
nnoremap <c-down> <c-w>+
nnoremap <c-left> <c-w><
nnoremap <c-right> <c-w>>

vnoremap <silent> * :<c-u>call VisualSelection()<CR>/<CR>=@/<CR><CR>
vnoremap <silent> # :<c-u>call VisualSelection()<CR>?<CR>=@/<CR><CR>

"inoremap <tab> <c-n>

inoremap ( ()<esc>i
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap [ []<esc>i
inoremap ] <c-r>=ClosePair(']')<CR>
inoremap { {<CR>}<esc>O

function! ClosePair(char)
  if getline('.')[col('.') - 1] == a:char
    return "\<Right>"
  else
    return a:char
endif
endfunction

function! VisualSelection() range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

map <F3> : UndotreeToggle<CR>
map <F4> : call FilelistToggle()<CR>
map <F5> : call UpdateCtags()<CR>
map <F6> : call QuickFixToggle()<CR>
map <F7> : NERDTreeToggle<CR>
map <F8> : TagbarToggle<CR>
map <F9> : call RefreshAnsiLog()<CR>
" go to xx.h/xx.cpp from xx.cpp/xx.h
map <F12> : AV<CR>

function! UpdateCtags()
  let curdir = expand("%:p:h")
  execute ":cd `git rev-parse --show-toplevel`"
  !ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extras=+q --language-force=C++
  !find $(pwd) -type f -name "*.hpp" -o -name "*.cpp" -o -name "*.h" -o -name "*.c" -o -name "*.hh" -o -name "*.cc" > cscope.files
  !cscope -bR
  execute ":cd " . curdir
endfunction

function! FilelistToggle()
  tabnew `git rev-parse --show-toplevel`/cscope.files
endfunction

function! QuickFixToggle()
  if empty(filter(range(1, winnr('$')), 'getwinvar(v:var, "&buftype") == "quickfix"'))
    copen
  else
    cclose
  endif
endfunction

function! RefreshAnsiLog()
  execute ":AnsiEsc"
  execute ":%s/\r//g"
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ctags & Cscope
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tags=tags;
set autochdir

if has("cscope")
  set csprg=/usr/bin/cscope
  set csto=1
  set cst
  set nocsverb
  if filereadable("cscope.out")
    cs add cscope.out
  endif
  set csverb
  set cscopequickfix=s-,c-,d-,i-,t-,e-
endif

" Find this C symbol
nmap <leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>
" Find this definition
nmap <leader>g :cs find g <C-R>=expand("<cword>")<CR><CR>
" Find functions called by this function
nmap <leader>d :cs find d <C-R>=expand("<cword>")<CR><CR>
" Find functions calling this function
nmap <leader>c :cs find c <C-R>=expand("<cword>")<CR><CR>
" Find this text string
nmap <leader>t :cs find t <C-R>=expand("<cword>")<CR><CR>
" Find this egrep pattern
nmap <leader>e :cs find e <C-R>=expand("<cword>")<CR><CR>
" Find this file
nmap <leader>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
" Find files including this file
nmap <leader>i :cs find i <C-R>=expand("<cfile>")<CR><CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin (vim-plug — autoload/plug.vim ships with this dotfiles vim dir)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible
" Plugins ship as git submodules under ~/.vim/plugins-vendor (no runtime git clone).
call plug#begin('~/.cache/vim/plugged')
Plug '~/.vim/plugins-vendor/nerdtree'
Plug '~/.vim/plugins-vendor/vim-easycomplete'
Plug '~/.vim/plugins-vendor/undotree'
Plug '~/.vim/plugins-vendor/tagbar'
Plug '~/.vim/plugins-vendor/lightline.vim'
Plug '~/.vim/plugins-vendor/vim-fugitive'
Plug '~/.vim/plugins-vendor/vim-systemc'
Plug '~/.vim/plugins-vendor/verilog_systemverilog.vim'
Plug '~/.vim/plugins-vendor/cecutil'
Plug '~/.vim/plugins-vendor/AnsiEsc.vim'
Plug '~/.vim/plugins-vendor/a.vim'
call plug#end()

let g:NERDTreeMinimalUI = 1
let g:NERDTreeHidden = 0
let g:NERDTreeIgnore = ['\.pyc$']
let g:tagbar_compact = 1
let g:tagbar_autofocus = 1
highlight clear TagbarHighlight
highlight link TagbarHighlight NONE
highlight TagbarHighlight cterm=bold gui=bold

" lightline
set laststatus=2
let g:lightline = {
      \ 'colorscheme': 'powerline',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'filename', 'readonly' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ] ],
      \ },
      \ 'component_function': {
      \   'filename': 'LightlineFilename'
      \ },
      \ }

function! LightlineFilename()
  let gitbranch = FugitiveStatusline() !=# '' ? FugitiveStatusline() . ' > ' : ''
  let filename = expand("%:t") !=# '' ? expand("%:t") : ' [No Name] '
  let modified = &modified ? ' [+] ' : ''
  return gitbranch . filename . modified
endfunction

" Highlight the symbol when holding the cursor
let g:easycomplete_cursor_word_hl = 1
" Using nerdfont is highly recommended
let g:easycomplete_nerd_font = 1

" GoTo code navigation
nnoremap gr :EasyCompleteReference<CR>
nnoremap gd :EasyCompleteGotoDefinition<CR>
nnoremap rn :EasyCompleteRename<CR>
nnoremap gb :BackToOriginalBuffer<CR>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => AutoCmd
""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd")
  " cursor stay at last exit when open
  au BufReadPost * if line("'\"") > 1 && line("'\"")<=line("$") | exe "normal! g'\"" | endif
  " remove white-space EOL
  au BufWritePre * %s/\s\+$//e
  " change quickfix window position
  au FileType qf wincmd J
  " set files filetype
  au BufNewFile,BufRead *.fl set filetype=perl
  au BufNewFile,BufRead SConsturct set filetype=python
  au BufNewFile,BufRead SConscript set filetype=python
  au BufNewFile,BufRead SConsopts set filetype=python
endif
