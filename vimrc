vim9script

const HOME_DIR: string = fnamemodify(expand('$MYVIMRC'), ':p:h')

set nopaste
set nocompatible
filetype plugin on

g:mapleader = ' '

syntax on

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,latin1
set termencoding=utf-8

set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set expandtab
set tabstop=4

set rnu
set nu
set ttymouse=sgr
set hlsearch
set cc=80,100
set foldcolumn=1
set showtabline=2
set conceallevel=2
set concealcursor=nvc
set listchars=eol:$,tab:>.,space:.
set nolist

set laststatus=2
set statusline=%{toupper(mode())}\ %f%=%y\ [%{&ff}]\ [%{&fenc}]\ %l/%L\ %c\ [%{strftime("%H:%M")}]

#colorscheme morning
#colorscheme powershell
colorscheme acme
set background=light
set termguicolors

if "" == &clipboard
    set clipboard=unnamed
endif
set clipboard+=unnamedplus

const swap_tmp_dir: string = expand(HOME_DIR .. "/tmp/")
if "" == finddir(swap_tmp_dir)
	mkdir(swap_tmp_dir, 'p', 0o700)
endif
const BACKUP_DIR: string = expand(HOME_DIR .. '/.backup')
if !isdirectory(BACKUP_DIR)
	mkdir(BACKUP_DIR, 'p', 0o700)
endif
const SWP_DIR: string = expand(HOME_DIR .. '/.swp')
if !isdirectory(SWP_DIR)
	mkdir(SWP_DIR, 'p', 0o700)
endif

if has('persistent_undo')
	const UNDO_DIR: string = expand(HOME_DIR .. '/.undo')
	if !isdirectory(UNDO_DIR)
		mkdir(UNDO_DIR, 'p', 0o700)
	endif
	execute 'set undodir=' .. expand(UNDO_DIR)
	set undofile
	set undolevels=1000
	set undoreload=10000
endif
execute 'set backupdir=' .. expand(BACKUP_DIR)
execute 'set directory=' .. expand(SWP_DIR)

# Save cursor position
autocmd BufReadPost *
	\ if line("'\"") > 0 && line("'\"") <= line("$") |
	\   exe "normal! g`\"" |
	\ endif

# Leader
nnoremap <silent> <leader> <Nop>
# Clear
nnoremap <silent> <esc> :noh<CR>
# Config
nnoremap <silent> <leader>C <Nop>
nnoremap <silent> <leader>Cr :so $MYVIMRC<CR>
nnoremap <silent> <leader>Co :e $MYVIMRC<CR>
# Quickfix
nnoremap <silent> <leader>c <Nop>
nnoremap <silent> <leader>cc :cc<CR>
nnoremap <silent> <leader>cn :cn<CR>
nnoremap <silent> <leader>cN :cN<CR>
nnoremap <silent> <leader>cp :cp<CR>
nnoremap <silent> <leader>cP :cP<CR>
# Buffer
nnoremap <silent> <leader>b <Nop>
nnoremap <silent> <leader>bd :bd<CR>
nnoremap <silent> <leader>bn :bn<CR>
nnoremap <silent> <leader>bp :bp<CR>
# Tab
nnoremap <silent> <leader>t <Nop>
nnoremap <silent> <leader>td :tabc<CR>
nnoremap <silent> <leader>tn :tabn<CR>
nnoremap <silent> <leader>tp :tabp<CR>
# File
nnoremap <silent> <leader>e :Explore<CR>
nnoremap <silent> <leader>f <Nop>
nnoremap <silent> <leader>fe :Explore<CR>
# Search
nnoremap <silent> <leader>s <Nop>
nnoremap <silent> <leader>sr :registers<CR>
nnoremap <silent> <leader>sb :buffers<CR>
nnoremap <silent> <leader>sm :marks<CR>
# Window
nnoremap <silent> <leader>w <Nop>
nnoremap <silent> <leader>wd <C-w>c
# X
nnoremap <silent> <leader>x <Nop>
nnoremap <silent> <leader>xc :ColorizeHex<CR>
nnoremap <silent> <leader>xy :ClipboardYank<CR>
nnoremap <silent> <leader>xp :ClipboardPaste<CR>
nnoremap <silent> <leader>xq :set <C-r>=&tgc ? "notgc" : "tgc"<cr><cr>
# Alias
vnoremap <silent> j gj
vnoremap <silent> k gk
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> <C-s> :w<CR>
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-j> <C-w>j
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-l> <C-w>l
# Tags
nnoremap <silent> <leader>] :silent! tn<CR>
nnoremap <silent> <leader>[ :silent! tp<CR>

nnoremap <silent> <S-k> <Nop>

set directory^=$HOME_DIR/tmp/

set tags=./tags;,tags
map <F8> :!ctags -R .<CR>

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

augroup AutoComplete
    autocmd!
    autocmd FileType c,cpp setlocal omnifunc=ccomplete#Complete
    autocmd FileType c,cpp setlocal complete=.,w,b,u,t,i
    autocmd FileType vim setlocal omnifunc=syntaxcomplete#Complete
    autocmd FileType vim setlocal complete=.,w,b,u,t,i
augroup END
set completeopt=longest,menuone
set completepopup=height:10,width:10,highlight:InfoPopup
set wildmenu

# Color
def ContrastColor(bg: string): string
    var r = str2nr(bg[1] .. bg[2], 16)
    var g = str2nr(bg[3] .. bg[4], 16)
    var b = str2nr(bg[5] .. bg[6], 16)
    var luminance = 0.299 * r + 0.587 * g + 0.114 * b
    return luminance > 186 ? '#000000' : '#FFFFFF'
enddef

def CollectColors(): dict<bool>
    var lines = getline(1, '$')
    var matches = {}
    for line in lines
        var start = 0
        while true
            var [m, s, e] = matchstrpos(line, '#\x\{6}', start)
            if empty(m)
                break
            endif
            matches[m] = true
            start = e
        endwhile
    endfor
    return matches
enddef

def ColorizeHex(): void
    silent! syntax clear ColorHexDynamic
    var matches = CollectColors()
    for color in keys(matches)
        var group = 'ColorHex_' .. substitute(color, '#', '', '')
        execute 'highlight ' .. group .. ' guibg=' .. color .. ' guifg=' .. ContrastColor(color)
        execute 'syntax match ' .. group .. ' "' .. color .. '" containedIn=ALL'
    endfor
enddef
if !exists('g:loaded_colorize')
    g:loaded_colorize = 1
    command! ColorizeHex call <SID>ColorizeHex()
endif

if !exists('g:loaded_clip')
    g:loaded_clip = 1
    if executable('clip.exe')
        augroup WSLYank
            autocmd!
            autocmd TextYankPost * if v:event.operator ==# 'y' && v:event.regname ==# '"' | call system('clip.exe', @0) | endif
        augroup END
    endif
endif
