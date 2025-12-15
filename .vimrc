set nocompatible           " Use Vim defaults

function PackInit() abort

    if empty(glob('~/.vim/pack/minpac/opt/minpac'))
        silent !git clone --quiet https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
    endif

    packadd minpac
    call minpac#init()
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    call minpac#add('tpope/vim-sensible')             " use sensible defaults
    call minpac#add('tpope/vim-sleuth')               " automatically adjust 'shiftwidth' and 'expandtab'
    call minpac#add('spf13/vim-autoclose')            " close opened parantheses and '\"
    call minpac#add('andymass/vim-matchup')           " match language specfic words with %
    call minpac#add('tpope/vim-repeat')               " make repetition work well with plugins
    call minpac#add('chrisbra/matchit')               " advanced matching
    call minpac#add('tpope/vim-surround')             " handle surroundings
    call minpac#add('tpope/vim-speeddating')          " use <c-a>/<c-x> on dates
    call minpac#add('junegunn/fzf.vim')               " use fzf for file management
    call minpac#add('catppuccin/vim')                 " catppuccin colorscheme
    call minpac#add('vimpostor/vim-lumen')            " automatic background color.
    call minpac#add('vim-airline/vim-airline-themes') " missing themes?
    if executable('ctags')                            " use tagbar if ctags is available
        call minpac#add('majutsushi/tagbar')
    endif

endfunction

command! PackUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PackClean  source $MYVIMRC | call PackInit() | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()


set vb t_vb=                   " turn the bell off.
set matchpairs+=<:>            " Add pointy brackets to matchpairs
set nostartofline              " don't jump cursor around. Stay in one column

set nobackup                   " Keep no backup file, use version control
set modelines=2                " Enable modelines in files
set viminfo='20,\"50,h         " Read/write a .viminfo file, don't store more
                               " Than 50 lines of registers
set viminfofile=~/.vim/viminfo " Store info under ~/.vim
set title                      " set Terminals Title.
set autowrite                  " Save before :make :suspend, etc
set encoding=utf-8             " use utf-8 as default encoding.
set updatetime=100             " default updatetime 4000ms is not good
                               " for async update
" Persistent Undo
if !isdirectory(glob('~/.vim/undodir'))
    call mkdir($HOME."/.vim/undodir","p")
endif
set undodir=~/.vim/undodir     " Store undo history in this directory
set undofile                   " Enable persistent undo

" Whitespace
set wrap                       " Enable line Wrapping
set autoindent                 " take indent for new line from previous line
set linebreak                  " Wrap at word
set tabstop=4                  " Tabwidth
set shiftwidth=4               " Indention
set softtabstop=4              " Make sure all tabs are 4 spaces
set expandtab                  " Expand tabs to spaces

" Searching
set ignorecase                 " Searches are case insensitive
set smartcase                  " Unless they contain at least one capital letter
set hlsearch                   " highlight search

" Line numbering
set number                     " Show current line number
set relativenumber             " Relative line numbers on
"NERDTree
nnoremap <leader>d :NERDTreeToggle<CR>

" Make tags placed in .git/tags file available in all levels of a repository
let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
if gitroot != ''
    let &tags = &tags . ',' . gitroot . '/.git/tags'
endif

" Tagbar and switch to that window.
nnoremap <silent> <leader>tt :TagbarToggle<CR><C-w><C-w>

" User Interface
set cursorline            " Highlight the line the cursor's in
set showcmd               " Show (partial) commands in status line.
set showmatch             " Show matching brackets
set noshowmode            " Get rid of default mode indicator

set termguicolors
if has('gui_running')
    set linespace=1
endif

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='catppuccin_mocha'
let g:airline_left_sep = '' 
let g:airline_right_sep = ''
if !exists('g:airline_symbols')
      let g:airline_symbols = {}
endif
let g:lumen_light_colorscheme='catppuccin_latte'
let g:lumen_dark_colorscheme='catppuccin_frappe'

" Basic latex setup
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_CompileRule_pdf='latexmk -pdf $*'


" Window management
" split window vertically with <leader> v
nmap <leader>v :vsplit<CR> <C-w><C-w>
" split window horizontally with <leader> s
nmap <leader>s :split<CR> <C-w><C-w>
" Switch between windows with <leader> w
nmap <leader>w <C-w><C-w>_

if has("autocmd")
    " Makefiles have real Tabs
    au FileType make set noexpandtab
    " In text files, always limit the width of text to 78 characters
    au BufNewFile,BufRead *.txt,*markdown,*md,*asciidoc,*adoc set tw=78
    " Yaml uses tabsize of two
    au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
    au BufNewFile,BufRead *.go set ft=go
endif " has("autocmd")

" My mappings
map <F5> :set number<CR>     " Turn on linenumbers.
map <F6> :set nonumber<CR>   " Turn off linenumbers.
nnoremap <leader>p :GFiles<CR>
