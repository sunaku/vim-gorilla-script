" Language:    GorillaScript
" Maintainer:  "UnCO" Lin
" URL:         http://github.com/unc0/vim-gorilla-script
" License:     WTFPL

" All this is needed to support compiling filenames with spaces, quotes, and
" such. The filename is escaped and embedded into the `makeprg` setting.
"
" Because of this, `makeprg` must be updated on every file rename. And because
" of that, `CompilerSet` can't be used because it doesn't exist when the
" rename autocmd is ran. So, we have to do some checks to see whether `compiler`
" was called locally or globally, and respect that in the rest of the script.

if exists('current_compiler')
  finish
endif

let current_compiler = 'gorilla'
call gorilla#GorillaSetUpVariables()

" Pattern to check if gorilla is the compiler
let s:pat = '^' . current_compiler

" Get a `makeprg` for the current filename.
function! s:GetMakePrg()
  return g:gorilla_compiler
        \. ' -c '
        \. g:gorilla_make_options
        \. ' $* '
        \. fnameescape(expand('%'))
endfunction

" Set `makeprg` and return 1 if gorilla is still the compiler, else return 0.
function! s:SetMakePrg()
  if &l:makeprg =~ s:pat
    let &l:makeprg = s:GetMakePrg()
  elseif &g:makeprg =~ s:pat
    let &g:makeprg = s:GetMakePrg()
  else
    return 0
  endif

  return 1
endfunction

" Set a dummy compiler so we can check whether to set locally or globally.
exec 'CompilerSet makeprg=' . current_compiler
" Then actually set the compiler.
call s:SetMakePrg()
call gorilla#GorillaSetUpErrorFormat()

function! s:GorillaMakeDeprecated(bang, args)
  echoerr 'GorillaMake is deprecated! Please use :make instead, its behavior ' .
  \       'is identical.'
  sleep 5
  exec 'make' . a:bang a:args
endfunction

" Compile the current file.
command! -bang -bar -nargs=* GorillaMake
\        call s:CoffeeMakeDeprecated(<q-bang>, <q-args>)

" Set `makeprg` on rename since we embed the filename in the setting.
augroup GorillaUpdateMakePrg
  autocmd!

  " Update `makeprg` if gorilla is still the compiler, else stop running this
  " function.
  function! s:UpdateMakePrg()
    if !s:SetMakePrg()
      autocmd! GorillaUpdateMakePrg
    endif
  endfunction

  " Set autocmd locally if compiler was set locally.
  if &l:makeprg =~ s:pat
    autocmd BufFilePost,BufWritePost <buffer> call s:UpdateMakePrg()
  else
    autocmd BufFilePost,BufWritePost          call s:UpdateMakePrg()
  endif
augroup END
