" Language:    GorillaScript
" Maintainer:  "UnCO" Lin
" URL:         http://github.com/unc0/vim-gorilla-script
" License:     WTFPL

autocmd BufNewFile,BufRead *.gs set filetype=gorilla

function! s:DetectGorilla()
    if getline(1) =~ '^#!.*\<gorilla\>'
        setfiletype gorilla
    endif
endfunction

autocmd BufRead * call s:DetectGorilla()
