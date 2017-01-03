syntax on

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', {'dir': '~/.fzf', 'do': './install --all'}
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'ap/vim-buftabline'
Plug 'jpalardy/vim-slime'
Plug 'christoomey/vim-tmux-navigator'
Plug 'mattn/emmet-vim', {'for': ['html', 'css', 'htmldjango', 'htmljinja']}
Plug 'mbbill/undotree', {'on': 'UndotreeToggle'}
Plug 'moll/vim-bbye'
Plug 'robertmeta/nofrils'
Plug 'editorconfig/editorconfig-vim'
Plug 'neomake/neomake'

" indenting help
Plug '2072/PHP-Indenting-for-VIm', {'for': 'php'}
Plug 'hynek/vim-python-pep8-indent', {'for': 'python'}
Plug 'Kareeeeem/python-docstring-comments', {'for': 'python'}
Plug 'pangloss/vim-javascript', {'for': ['javascript.jsx', 'javascript']}
" Plug 'mxw/vim-jsx', {'for': ['javascript.jsx', 'javascript']}

call plug#end()

filetype plugin indent on

set autoindent
set background=dark
set backspace=2
set colorcolumn=80
set dir=~/.vim/tmp
set encoding=utf-8
set expandtab
set formatoptions=jcroq
set hidden
set hlsearch
set ignorecase
set incsearch
set nofoldenable
set nowrap
set number
set scrolloff=3
set shiftwidth=4
set smartcase
set softtabstop=4
set tags=./tags,.git/tags
set undodir=~/.vim/undodir/
set undofile

" statusline
set laststatus=2
set statusline=%n\ %.20F\ %y
set statusline+=\ %h%m%r
set statusline+=%= " right alignment from this point
set statusline+=%-14.(%l,%c%V%)\ %P
set statusline+=\ %-4#Error#%{neomake#statusline#LoclistStatus('ll\ ')}%*

if executable("ag")
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
endif

" Expand `%%` to current directory.
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" Because backslash is in a awkward place.
let mapleader = "\<Space>"

" I almost never want to go to the ABSOLUTE beginning of a line
nnoremap 0 ^

" break lines on a comma
nnoremap <leader>, f,cw,<CR><ESC>

nnoremap <Leader><Leader> :up<cr>

" Break line
nnoremap K i<cr><esc>kg$

" Toggle search highlighting
nnoremap <leader>h :set hlsearch!<CR>

" Toggle paste
nnoremap <leader>p :set paste!<CR>

" j and k on columns rather than lines
nnoremap j gj
nnoremap k gk

" Y yanks till eol to be consistent with C and D
nnoremap Y y$

" Highlight last inserted text
nnoremap gV `[v`]

" keep the visual selection after changing indentation
xnoremap < <gv
xnoremap > >gv

nnoremap <leader>q :Bdelete<cr>

nnoremap <leader>gq gqip

nnoremap <left> :bp<cr>
nnoremap <right> :bn<cr>

" fzf
nnoremap <C-p> :Files<CR>
nnoremap <leader>t :Tags<CR>
nnoremap <leader>m :History<CR>
nnoremap <leader>b :Buffers<cr>

" Slime
let g:slime_target = 'tmux'
let g:slime_python_ipython = 1
let g:slime_no_mappings = 1
xnoremap <leader>s <Plug>SlimeRegionSend
nnoremap <leader>s <Plug>SlimeParagraphSend
nnoremap <leader>v <Plug>SlimeConfig

" Neomake
let g:neomake_error_sign = {'text': 'E>', 'texthl': 'ErrorMsg'}
let g:neomake_warning_sign = {'text': 'W>', 'texthl': 'WarningMsg'}
let g:neomake_message_sign = {'text': 'M>', 'texthl': 'StatusLine'}
let g:neomake_info_sign = {'text': 'I>', 'texthl': 'StatusLine'}
let g:neomake_remove_invalid_entries = 1

let g:neomake_javascript_enabled_makers = ['eslint_d']

let g:neomake_c_enabled_makers = ['clang']
let g:neomake_c_clang_args = ['-fsyntax-only', '-std=c99', '-Weverything']

let g:neomake_python_enabled_makers = ['flake8']
let g:neomake_python_flake8_args = ['--max-line-length=100']

augroup neo_make
    au!
    au BufWritePost * Neomake
augroup END

" Emmet
let g:user_emmet_install_global = 0

" vim-jsx
" let g:jsx_ext_required = 0

" Undotree
nnoremap <F5> :UndotreeToggle<CR>
if !exists('g:undotree_SplitWidth')
    let g:undotree_SplitWidth = 30
endif

" buftabline
let g:buftabline_numbers=1
let g:buftabline_indicators=1
let g:buftabline_numbers=1

" This keeps the sign column visible at all times. Can't stand the
" twitching when linting for errors.
augroup signcolumn
    au!
    au FileType python,c,javascript set signcolumn=yes
augroup END

" Only register these autocommands if the necessary executables are present
if executable('ctags') && executable('ctags')
    augroup tags
        au BufWritePost *.py,*.c call system('git-tags')
        au BufWritePost *.js call system("git-tags && clean_js_tags")
    augroup END
endif

augroup write_file
    au!
    let blacklist = ['markdown', 'text']
    " strip all trailing whitespace in all files except of type in blacklist
    au BufWritePre * if index(blacklist, &ft) < 0 | call Preserve('%s/\s\+$//ge')
augroup END

augroup go
    au!
    " au BufWritePre *.go call Preserve('%!gofmt 2> /dev/null')
    au FileType go setlocal formatprg=gofmt noexpandtab tabstop=4
augroup END

augroup md
    au!
    au FileType *markdown* setlocal formatoptions+=t
    au FileType *markdown* setlocal formatprg=par\ -72
    au FileType *markdown* setlocal textwidth=72
    au FileType *markdown* setlocal textwidth=72
    au FileType *markdown* nnoremap <leader>snl :set spell spelllang=nl<cr>
    au FileType *markdown* nnoremap <leader>ss :set nospell<cr>
augroup END

augroup txt
    au!
    au FileType text setlocal wrap linebreak nolist
augroup END

augroup shell
    au!
    au FileType sh setlocal tabstop=4 noexpandtab
augroup END

augroup c
    au!
    autocmd BufRead,BufNewFile *.h,*.c set filetype=c
    au FileType c setlocal commentstring=//\ %s
    " Don't indent case inside switch statements
    au FileType c setlocal cinoptions+=:0
augroup END

augroup frontend
    au!
    " au FileType css,html,htmljinja,htmldjango setlocal shiftwidth=2 softtabstop=2
    au FileType htmljinja setlocal commentstring={#\ %s\ #}
    au FileType mako,html,css,htmldjango,htmljinja EmmetInstall
augroup END

augroup qf
    au!
    au FileType qf set nobuflisted
augroup END

" colorscheme
augroup colors
    au!
    hi link NeomakeError SpellBad
    hi link NeomakeWarning SpellCap
augroup END
colorscheme nofrils-dark

" http://stackoverflow.com/a/7086709
" call a command and restore view. Also resets the registers.
function! Preserve(command)
    let w = winsaveview()
    execute a:command
    call winrestview(w)
endfunction
