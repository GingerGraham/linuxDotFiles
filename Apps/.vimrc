" Plugin Config
" =============
filetype off		" Helps force plugins to load correctly when it is turned back on below
filetype plugin indent on " For plugins to load correctly

" Encoding & Language Config
" ==========================
set encoding=utf-8

" UI Config
" =========
" Settings here are for configuring the UI

" Turn on line numbering
set nocompatible
set number
set relativenumber

" Handle lines and word wrap
set linebreak		" Break lines at word (requires wrap lines)
set showbreak=+++	" Wrap broken line prefix
set textwidth=100	" Line wrap (number of columns)

" Tabs and stops
set autoindent		" Auto indent new lines
set tabstop=4		" Setting tab stop value
set shiftwidth=4	" Number of auto-indent spaces
set smartindent		" Enable smart indent
set smarttab		" Enable smart tabs
set softtabstop=4	" Number of spaces per tab

" Advanced UI
set ruler		" Show row and column information
set backspace=indent,eol,start	" Backspace behaviour
syntax on		" Turn on syntax highlighting
set showmode
set showcmd
set matchpairs+=<:>

" Search Settings
" ===============
set showmatch		" Highlight matching braces (was actually working already???)
set hlsearch		" Highlight all search results
set smartcase		" Enable smart case searches
set ignorecase		" Always case insensitve search (is this needed???)
set incsearch		" Search for strings incremental
set wildmenu		" Display command line's tab complete options as a menu

" Control Settings
" ================
" A collection of control settings
set mouse=a
set title
set undolevels=1000	" Number of undo levels
set foldmethod=indent	" Fold based on indentation
set foldnestmax=5	" Fold up to defined number of levels
set autowrite		" Automatically save before commands like :next and :make
set scrolloff=5		" Display 5 lines above/below cursor when scrolling with a mouse
set ttyfast		" Speed up scrolling

" Colour Config
" =============
" Settings here for UI colouration
colorscheme industry

" Read in plugins
" ===============
"if filereadable(expand("~/vimrc.plug"))
"	source ~/.vimrc.plug
"endif
