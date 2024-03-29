if exists('g:autoloaded_vim#refactor#method#call')
    finish
endif
let g:autoloaded_vim#refactor#method#call = v:true

const s:FUNCTION_NAMES = getcompletion('[a-z]', 'function')
    \ ->filter({_, v -> v =~# '^[a-z][^#]*\%((\|()\)$'})

" Interface {{{1
fu vim#refactor#method#call#main(...) abort "{{{2
    if !a:0
        let &opfunc = 'vim#refactor#method#call#main'
        return 'g@l'
    endif
    let view = winsaveview()

    call vim#util#search('\%' .. col('.') .. 'c\%' .. line('.') .. 'l\S*\zs(')
    let funcname = getline('.')->matchstr('\S*\%' .. col('.') .. 'c')
    if match(s:FUNCTION_NAMES, '^\V' .. funcname .. '\m\%((\|()\)') == -1
        echohl ErrorMsg
        echo 'no builtin function under the cursor'
        echohl NONE
        call winrestview(view)
    endif
    norm! v
    " TODO: Do we need to write a `vim#util#jump_to_closing_bracket()` function?{{{
    "
    " If so, here's the code:
    "
    "     let opening_bracket = getline('.')->strpart(col('.') - 1)[0]
    "     if index(['<', '(', '[', '{'], opening_bracket) == -1
    "         return
    "     endif
    "     let closing_bracket = {'<': '>', '(': ')', '[': ']', '{': '}'}[opening_bracket]
    "     call searchpair(opening_bracket, '', closing_bracket,
    "         \ 'W', 'synID(".", col("."), 1)->synIDattr("name") =~? "comment\\|string"')
    "
    " But I'm not sure we need it.
    " Maybe `vim#util#search(')')` is enough...
    "}}}
    call vim#util#jump_to_closing_bracket()
    sil norm! y
    "     let s2 = s:search_closing_quote() | let [lnum2, col2] = getcurpos()[1 : 2] | norm! v
    "     let s1 = s:search_opening_quote() | let [lnum1, col1] = getcurpos()[1 : 2] | norm! y

    let bang = typename(a:1) == 'number' ? a:1 : v:true
    "     if !vim#util#weCanRefactor(
    "         \ [s1, s2],
    "         \ lnum1, col1,
    "         \ lnum2, col2,
    "         \ bang,
    "         \ view,
    "         \ 'map/filter {expr2}', 'lambda',
    "         \ )
    "         return
    "     endif

    "     if @" =~# '\Cv:key'
    "         let new_expr = '{i, v -> ' .. s:get_expr(@") .. '}'
    "     else
    "         let new_expr = '{_, v -> ' .. s:get_expr(@") .. '}'
    "     endif

    "     call vim#util#put(
    "         \ new_expr,
    "         \ lnum1, col1,
    "         \ lnum2, col2,
    "         \ )
endfu
"}}}1
