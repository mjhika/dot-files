let mapleader = " "
let maplocalleader = " m"

" [[ Setting options ]]
"
"

" Make line numbers default
set number
set relativenumber

" Enable mouse mode
set mouse=a

" Don't show the mode, since it's already in the status line
set noshowmode

" Sync clipboard between OS and Vim.
" Uncomment if you want your OS clipboard to remain independent.
" set clipboard=unnamedplus

" Enable break indent
set breakindent

" Save undo history
set undodir=~/.vim/undodir
set undofile

" Case-insensitive searching UNLESS \C or capital letters in search term
set ignorecase
set smartcase

" Keep signcolumn on by default
set signcolumn=yes

" Decrease update time
set updatetime=250

" Decrease mapped sequence wait time
set timeoutlen=300

" Configure how new splits should be opened
set splitright
set splitbelow

" Sets how vim will display certain whitespace characters
set list
" Note: Spaces must be escaped with a backslash in Vimscript listchars
set listchars=tab:⇥\ ,trail:·,nbsp:␣,eol:⏎

" Show which line your cursor is on
set cursorline

" Show a column for 80 and 120
set colorcolumn=80,120

" Minimal number of screen lines to keep above and below the cursor
set scrolloff=10

" Raise a dialog asking if you wish to save the current file(s)
set confirm

" Disable line wrapping
set nowrap

" [[ Basic Keymaps ]]
"
"

" Clear highlights on search when pressing <Esc> in normal mode
nnoremap <Esc> :nohlsearch<CR>

" Recenter the page while scrolling
" Move up half page
nnoremap <C-u> <C-u>zz
" Move down half page
nnoremap <C-d> <C-d>zz

" Easily switch between next and previous buffers
nnoremap <silent> <C-j> :bnext<CR>
nnoremap <silent> <C-k> :bprev<CR>

" Easily close and force close buffers
nnoremap <silent> <leader>c :bdelete<CR>
nnoremap <silent> <leader>C :bdelete!<CR>

" Move lines that are selected in visual mode
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Allow j and k to work even with word wrap
" This uses an expression map (<expr>)
nnoremap <expr> <silent> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> <silent> k v:count == 0 ? 'gk' : 'k'

" [[ Custom Functions ]]
"
"

" Toggle line wrapping
" Vimscript allows toggling booleans with `!`
nnoremap <leader>tw :set wrap!<CR>
