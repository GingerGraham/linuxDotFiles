" UI Config
" =========
" Settings here are for configuring the UI

" Turn on line numbering
set nocompatible
set number

" Handle lines and word wrap
set linebreak		" Break lines at word (requires wrap lines)
set showbreak=+++	" Wrap broken line prefix
set textwidth=100	" Line wrap (number of columns)

" Tabs and stops
set autoindent		" Auto indent new lines
set shiftwidth=4	" Number of auto-indent spaces
set smartindent		" Enable smart indent
set smarttab		" Enable smart tabs
set softtabstop=4	" Number of spaces per tab

" Advanced UI
set ruler		" Show row and column information
set backspace=indent,eol,start	" Backspace behaviour

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

" Colour Config
" =============
" Settings here for UI colouration
colorscheme slate
