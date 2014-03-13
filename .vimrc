" Intialzie pathogen, a plugin management system that lets plugins live in
" their own directories

call pathogen#infect()

" First setup variable for other variables
"let g:useNinjaTagList=1

syntax on

if ( filereadable($HOME . "/.vimrc.site") )
  source $HOME/.vimrc.site
endif

""""""""""""""" Global Setup """"""""""""""""""""
"First source the environment location
source $HOME/.eihooks/dotfiles/vimrc

""""""""""""""" Global Options """"""""""""""""""""

set fo+=qr                     " q: gq foramts with comments, see :help fo-table, r: auto insert comments on new lines
set foldcolumn=0               " turn off the foldcolumn
set history=200                " Remember 100 lines of history, for commands and searches
set hls                        " highlight serach terms
set list                       " Show tabs differently
set listchars=tab:>-           " Use >--- for tabs
set nolinebreak                " don't wrap at words, messes up copying
set smartcase                  " if any capitol in search, turns search case sensitive
set shiftwidth=2               " use 2 space idnetning
set softtabstop=2              " use 4 space indenting
set ts=2                       " Default to 4 spaces for tabs
"set tags=~/.commontags,./tags " Setup the standard tags files
set textwidth=0                " turn wrapping off
set visualbell                 " Use a flash instead of a sound for bells
set wildmode=longest:full      " Matches only to longest filename, displays to menu possible matches
set complete=.,w,b,u           " complete from current file, and current buffers default: .,w,b,u,t,i  trying to keep down completion time
set directory=$HOME/.vim/tmp   " set directory for tmp files to be in .vim, so that .swp files are not littered
set clipboard=unnamed          " Use the * register when a register is not specified - unifies with system clipboard!

"set foldmethod=indent   " use indent unless overridden
"set foldlevel=0         " show contents of all folds
"set foldcolumn=2        " set a column incase we need it
set foldlevelstart=9999


filetype plugin on          "turns on filetype plugin, lets matchit work well

"set background=dark
"colorscheme solarized
colorscheme zellner         "changes color scheme to something that looks decent on the mac

" Set the vim info options
" In order: local marks for N files are saved, global marks are saved,
" a maximum of 500 lines for each register is saved,
" command history number, search history number,
" restore the buffer list and restore global variables

"if so that older versions of vim won't barf on standard systems
if (v:version >= 603)
  set viminfo='1000,f1,<500,:100,/100,%,!
endif

" Open a the quickfix window after any grep-style event
autocmd QuickFixCmdPost *grep* cwindow

""""""""""""""" Status Line """"""""""""""""""""

" Set the status line
set statusline=%f\ %y%{GetStatusEx()}[b:%n]\ %{fugitive#statusline()}\ %m%r%=(%l/%L,%c%V)\ %P

" Function for getting the file format and the encoding for the status line.
function! GetStatusEx()
  let str = ' [' . &fileformat
  if has('multi_byte') && &fileencoding != ''
    let str = str . ':' . &fileencoding
  endif
  let str = str . '] '
  return str
endfunction


" Setup the status line to display the tagname, if the taglist plugin has been
" loaded
autocmd VimEnter * try
autocmd VimEnter *   call Tlist_Get_Tagname_By_Line()
autocmd VimEnter *   set statusline=%f\ %y%{GetStatusEx()}[b:%n]\ [t:%{Tlist_Get_Tagname_By_Line()}]\ %m%r%=(%l/%L,%c%V)\ %P
autocmd VimEnter *   map <silent> <Leader>tap :TlistAddFilesRecursive . *pm<CR>
autocmd VimEnter * catch
autocmd VimEnter * endt

""""""""""""""" Filetype Settings """"""""""""""""

" explicitly map file extension .t to perl syntax instead of tads
" which is auto detected by file type plug-in on
" This line should always be after file type plug-in
autocmd BufNewFile,BufRead *.t set syntax=perl

"Set an autocommand to turn off cindenting for mail types
au FileType mail set nocindent

" Turn off cursor line in mail
au Filetype mail  highlight! CursorLine cterm=NONE ctermbg=NONE

" Fold the headers out of view
" au FileType mail 1,/^\s*$/fold

" Correct indenting behavior for # in non C++ code (it used to force it to the
" beginning, since # starts a preprocessor line in C++, but in perl we want to
" to be at the indent level of the code)
set cinkeys-=0#
au FileType c,cpp set cinkeys+=0#

""""""""""""""" Plugin Settings """"""""""""""""

" vim todo settings
  autocmd BufNewFile,BufRead *.todo set foldlevelstart=0 "todo files have a fold level..
  autocmd BufNewFile,BufRead *.todo set filetype=todo " .todo files to filetype todo

  " Force folds to display
  autocmd BufNewFile,BufRead *.todo normal zX

  " map \dg to insearch daily goals todo at the end of the list
  autocmd BufNewFile,BufRead *.todo map <Leader>dg GoTODO ds {ds} Send daily goal email<ESC>

  " map tds in insert mode
  autocmd BufNewFile,BufRead *.todo iab tds <C-R>=strftime("%Y-%m-%d", localtime()+86400)<CR>
  autocmd BufNewFile,BufRead *.todo iab {tds} {<C-R>=strftime("%Y-%m-%d", localtime()+86400)<CR>}

  let g:todo_done_file = ".todo_done_log.todo" " Set file to put done tasks in
  let g:todo_browser = "open" " what browser to use to open incidents

" calendar settings
" PrePad taken from stackoverflow:
" http://stackoverflow.com/questions/4964772/string-formatting-padding-in-vim
  function! PrePad(s,amt,...)
      if a:0 > 0
          let char = a:1
      else
          let char = ' '
      endif
      return repeat(char,a:amt - len(a:s)) . a:s
  endfunction

  function InsertCalendarDueDate(day,month,year,week,dir)
    " day   : day you actioned
    " month : month you actioned
    " year  : year you actioned
    " week  : day of week (Mo=1 ... Su=7)
    " dir   : direction of calendar
    exe 'q'
    exe 'normal A {' . a:year . '-' . PrePad(a:month, 2, '0') . '-' . PrePad(a:day, 2, '0') . '}'
  endfunction
  let calendar_action = 'InsertCalendarDueDate'

  let g:calendar_no_mappings=0 " turn off default mappings
  nmap <unique> <Leader>cal <Plug>CalendarH
  nmap <unique> <Leader>caL <Plug>CalendarV


"rcsvers.vim settings
  let g:rvSaveDirectoryType = 1 "Use single directory for all files
  let g:rvSaveDirectoryName = "$HOME/.vim/RCSFiles/" "Place to save RCS files

  "Setup exlcude expressions for rcs
  "1. Mutt mail files
  "2. p4 submit descriptions
  "3. tmp files from perforce form commands
  let g:rvExcludeExpression = 'muttng-bernard-\d\+\|p4submitdesc\.txt\|\/tmp\.\d\+\.\d\+'

  let g:rvRlogOptions = '-zLT' "Display log in local timezone

"YankRing settings...
  "Don't remap <C-N> and <C-P>
  let g:yankring_replace_n_pkey = '<F3>'
  let g:yankring_replace_n_nkey = '<F2>'

"AddressComplete Settings
  "automatically address complete on exit
  let g:addressCompleteOnExit = 1

  " setup <++> in empty header fields, redefine tab to move between them
  let g:useMailFieldTabbing = 1

"Buff explorer settings
  let g:bufExplorerSplitOutPathName=-1 " Don't split the path and file name.

" Large file settings in MB
  let g:LargeFile = 4

" EasyMotion settings
  " Use - as the leader for EasyMotion
  let g:EasyMotion_leader_key = '-'

" Session settings
  "When opened with a session, save the changes
  let g:session_autosave = 'yes'

  "When opened, use the latest session
  "let g:session_default_to_last = 'yes'

  "Auto open the last session
  let g:session_autoload = 'no'

"Ctrlp settings
  "Default to using regexes
  let g:ctrlp_regexp = 1

  " Use Ctrl-, rather than Ctrl-p
  let g:ctrlp_map = '<leader>aa'

  " Keep the cache file across restarts for faster startup
  let g:ctrlp_clear_cache_on_exit = 0

  " Setup alternate command maps TODO: why don't they display?
  nn <silent> <Leader>ab :CtrlPBuffer<CR>
  nn <silent> <Leader>aq :CtrlPQuickfix<CR>

"Syntastic Settings
  " Automatically open the location list when there are errors
  let g:syntastic_auto_loc_list = 1

  " Use my jshintrc file rather than default
  let g:syntastic_javascript_jshint_args="-c ~/.jshintrc"

  " Map <leader>st to SyntasticToggleMode
  map <Leader>st :SyntasticReset<CR>

  " Setup javascript as the only active syntax
  let g:syntastic_mode_map = { 'mode': 'passive',
                             \ 'active_filetypes': ['javascript'],
                             \ 'passive_filetypes': [] }

""""""""""""""" Command mappings """"""""""""""""

"Map statements
  "map comma to yank to mark a
  map , y'a

  "map the buff explorer open key
  map <F8> \be

  "Map for YRShow
  map <F4> :YRShow<CR>
  map <Leader>yr :YRShow<CR>

  " Make enter and Sift-Enter insert lines without going to insert mode
  " Next Line Doesn't work, why not?
  "noremap <Shift-Enter> O<ESC>j
  "nmap <Enter> o<ESC>k

  "Use EnhancedCommentify for commenting
  noremap <silent> - :call EnhancedCommentify('no', 'comment')<CR>j
  noremap <silent> _ :call EnhancedCommentify('no', 'decomment')<CR>j

  " Make Y work as expected
  nnoremap Y y$

  " Resize windows with the arrow keys
  nnoremap <up>    <C-W>+
  nnoremap <down>  <C-W>-
  nnoremap <left>  3<C-W>>
  nnoremap <right> 3<C-W><

"Normal Mode Maps
  "map control arrow to move between buffers
  nmap <C-n> :bn<CR>
  nmap <C-p> :bp<CR>

  "map F1 to paste in the selection buffer (*)
  nmap <F1> "*p

  " Make "." go back to the starting point on the line
  nmap . .`[

  " Make \tp toggle paste mode
  nmap \tp :set paste!<CR>

  " Map \r to grab the last paragraph, copy it, select the new copy, and pipe
  " it through a recs command
  :nmap <leader>r GV{yGpGV{j!recs-

" Maybe if I had a real X buffer, this would be cool.  Too bad.
"  " X buffer cut/paste
"  nmap <Leader>xp "*p
"  nmap <Leader>xy :set opfunc=XBufferYank<CR>g@
"
"  function! XBufferYank(type, ...)
"    '[,']yank "*
"  endfunction

  " map \uo to open the first url on the line
  map <Leader>ou :call OpenUrl()<CR>

"Visual Mode Maps
  "Visual mode comment adding
  "vmap <Leader>c :s/^/#/g<enter>:nohl<enter> " leader-c comments block
  "vmap <Leader>x :s/^#//g<enter>:nohl<enter> " leader-x uncomments block
  vmap <C-A> :Align =<enter>                 " Align =  in block
  vmap <Leader>h :Align =><enter>            " Align => in block

"Insert Mode Maps
  "map ctrl-a and ctrl-e to act like emacs
  imap <C-A> <C-O>^
  imap <C-E> <C-O>$

"Commands for perforce, from Scott Windsor
  " Perforce commands
  " Works, but commented out for now, want these commands elsewhere
  "command -nargs=0 Diff :!p4 diff %
  "command -nargs=0 Changes :!p4 changes %
  "command -nargs=1 Describe :!p4 describe <args> | more
  "command -nargs=0 Edit :!p4 edit %
  "command -nargs=0 Revert :!p4 revert %

" Unite
  " Much of this is is borrowed from: https://github.com/terryma/dotfiles/blob/master/.vimrc
  let g:unite_source_history_yank_enable = 1
  call unite#filters#matcher_default#use(['matcher_fuzzy'])

  " Unite mappers, the final word is the type of thing that will be serached, otherwise is fairly self-explanatory

  " Search all files from current dir
  nnoremap <leader>ut :<C-u>Unite -buffer-name=files   -start-insert file_rec/async:!<cr>

  " Search files in current dir
  "nnoremap <leader>uf :<C-u>Unite -buffer-name=files   -start-insert file<cr>

  " Search files in mru order
  nnoremap <leader>um :<C-u>Unite -buffer-name=mru     -start-insert file_mru<cr>

  " Search buffer names
  nnoremap <leader>ub :<C-u>Unite -buffer-name=buffer  buffer<cr>

  " Start unite with a grep
  nnoremap <leader>ug :Unite -buffer-name=grep grep:.<cr>

  " Unite grep the word under the cursor
  nnoremap <leader>ul :UniteWithCursorWord -buffer-name=grep grep:.<cr>

  " Search yank history
  nnoremap <leader>uy :<C-u>Unite -buffer-name=yank    history/yank<cr>

  " Search Help docs !! (yay!)
  nnoremap <leader>uh :<C-u>Unite -start-insert -buffer-name=help help<CR>

  " search command history
  nnoremap <leader>uc :<C-u>Unite -buffer-name=commands history/command<CR>

  " Search registers
  nnoremap <leader>ur :<C-u>Unite -start-insert -buffer-name=register register<CR>

  " Search outline, think taglist
  nnoremap <leader>uo :<C-u>Unite -buffer-name=outline -start-insert outline<CR>

  " For some reason <C-a> was getting mapped away, using autocmd to bypass
  " that
  " Search files with Ctrl-a
  nnoremap <C-a> :<C-u>Unite -buffer-name=files   -start-insert file_rec/async:!<cr>
  autocmd VimEnter * nnoremap <C-a> :<C-u>Unite -buffer-name=files   -start-insert file_rec/async:!<cr>

  " Start in insert mode
  let g:unite_enable_start_insert = 1

  " Setup a data directory
  let g:unite_data_directory = "~/.unite"

  " Enable history yank source
  let g:unite_source_history_yank_enable = 1

  " Also save clipboard values
  let g:unite_source_history_yank_save_clipboard = 1

  " Keep more yank history
  let g:unite_source_history_yank_limit = 10000

  " Open in bottom right
  let g:unite_split_rule = "botright"

  " Shorten the default update date of 500ms
  let g:unite_update_time = 200

  " Unite MRU settings
  let g:unite_source_file_mru_limit = 1000
  let g:unite_cursor_line_highlight = 'TabLineSel'
  " let g:unite_abbr_highlight = 'TabLine'

  " Custom mappings for the unite buffer
  autocmd FileType unite call s:unite_settings()
  function! s:unite_settings()
    " Play nice with supertab
    let b:SuperTabDisabled=1
    " Enable navigation with control-j and control-k in insert mode
    imap <buffer> <C-j>   <Plug>(unite_select_next_line)
    imap <buffer> <C-k>   <Plug>(unite_select_previous_line)
    nmap <buffer> <ESC> <Plug>(unite_exit)
    imap <buffer> <ESC> <Plug>(unite_exit)
    nmap <buffer> <c-j> <Plug>(unite_loop_cursor_down)
    nmap <buffer> <c-k> <Plug>(unite_loop_cursor_up)
    imap <buffer> <c-a> <Plug>(unite_choose_action)
    imap <buffer> <Tab> <Plug>(unite_exit_insert)
    imap <buffer> jj <Plug>(unite_insert_leave)
    imap <buffer> <C-w> <Plug>(unite_delete_backward_word)
    imap <buffer> <C-u> <Plug>(unite_delete_backward_path)
    imap <buffer> '     <Plug>(unite_quick_match_default_action)
    nmap <buffer> '     <Plug>(unite_quick_match_default_action)
    nmap <buffer> <C-r> <Plug>(unite_redraw)
    imap <buffer> <C-r> <Plug>(unite_redraw)
    inoremap <silent><buffer><expr> <C-s> unite#do_action('split')
    nnoremap <silent><buffer><expr> <C-s> unite#do_action('split')
    inoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
    nnoremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
  endfunction

  " Use ag for search
  if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
  endif

  " Airline status bar settings
  "Enable tab line when just one tab open
  let g:airline#extensions#tabline#enabled = 1

""""""""""""""" Typos """"""""""""""""""""
" A list of iabbrev to correct common typos

iabbrev colleicton collection
iabbrev Colleicton Collection
iabbrev restaurnt restaurant
iabbrev restauarnt restaurant

""""""""""""""" Syntax """"""""""""""""""""

" turn on syntax coloring
syntax on

" Add support for spitfire comments
function EnhCommentifyCallback(ft)
  if a:ft == 'htmlspitfire'
    let b:ECcommentOpen = '##'
    let b:ECcommentClose = ''
  endif
endfunction
let g:EnhCommentifyCallbackExists = 'Yes'

""""""""""""""" Version 7 Settings """"""""""""""""""""

if ( v:version >= 700 )
  " Vim 7.0c+ options
  "set cursorline " Get a highlight of the line the cursor is on

  " Change cursor line to highlight the line
  highlight! CursorLine cterm=NONE ctermbg=0

  " Change spelling colors to not suck, green and brown respectively
  highlight! SpellCap ctermbg=3
  highlight! SpellBad ctermbg=2
endif


if ( v:version >= 703 )
  set undofile                   " Keep undo history around, across vim reboots
  set undodir=$HOME/.vim/tmp     " set directory for undo files
endif

""""""""""""""" Version 7 Settings """"""""""""""""""""

" The highlight changes at least have to be at the end here... not sure why
" Highlight trailing whitespace in red so I can prevent that.
" Must be below any colorscheme setting
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
augroup WhiteSpaceMatching
  autocmd BufWinEnter * if &modifiable && &ft!='unite' | match ExtraWhitespace /\s\+$/ | endif
  autocmd InsertEnter * if &modifiable && &ft!='unite' | match ExtraWhitespace /\s\+\%#\@<!$/ | endif
  autocmd InsertLeave * if &modifiable && &ft!='unite' | match ExtraWhitespace /\s\+$/ | endif
  autocmd BufWinLeave * if &modifiable && &ft!='unite' | call clearmatches() | endif
augroup END
