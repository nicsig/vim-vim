fu vim#refactor#general#main(lnum1,lnum2, bang) abort "{{{1
    let range     = a:lnum1..','..a:lnum2
    let modifiers = 'keepj keepp '
    let view      = winsaveview()

    let substitutions = {
        \ 'au':    {'pat': '^\s*\zsau%[tocmd]',          'rep': 'au'    },
        \ 'C-x':   {'pat': '\C\<\zsC\ze-\a\>',           'rep': 'c'     },
        \ 'com':   {'pat': '^\s*\zscom%[mand]!? ',       'rep': 'com ' },
        \ 'cr':    {'pat': '\C\<CR\>',                   'rep': '<cr>'  },
        \ 'fu':    {'pat': '^\s*\zsfu%[nction]!? ',      'rep': 'fu '  },
        \ 'endfu': {'pat': '^\s*\zsendfu%[nction]\s*$',  'rep': 'endfu' },
        \ 'exe':   {'pat': 'exe%[cute] ',                'rep': 'exe '  },
        \ 'sil':   {'pat': '\<@1<!sil%[ent](!| )',       'rep': ' sil\1'},
        \ 'setl':  {'pat': 'setl%[ocal] ',               'rep': 'setl ' },
        \ 'keepj': {'pat': 'keepj%[umps] ',              'rep': 'keepj '},
        \ 'keepp': {'pat': 'keepp%[atterns] ',           'rep': 'keepp '},
        \ 'nno':   {'pat': '(n|v|x|o|i|c)no%[remap] ',   'rep': '\1no ' },
        \ 'norm':  {'pat': 'normal!',                    'rep': 'norm!' },
        \ 'plug':  {'pat': '\C\<Plug\>',                 'rep': '<plug>'},
        \
        \ 'abort': { 'pat': '^%(.*\)\s*abort)@!\s*fu%[nction]!?.*\)'
        \                 ..'\zs\ze(\s*"\{\{\{\d*)?',
        \            'rep': ' abort' },
        \ }

    sil! exe modifiers..'norm! '..a:lnum1..'G='..a:lnum2..'G'
    for sbs in values(substitutions)
        sil exe modifiers..range..'s/\v'..sbs.pat..'/'..sbs.rep..'/ge'..(a:bang ? '' : 'c')
    endfor

    " format the arguments of a mapping, so that there's no space between them,
    " and they are sorted
    let pat_map = '%(no%[remap]|nn%[oremap]|vn%[oremap]|xn%[oremap]|snor%[emap]|ono%[remap]|no%[remap]!|ino%[remap]|ln%[oremap]|cno%[remap]|tno%[remap]|map|nm%[ap]|vm%[ap]|xm%[ap]|smap|om%[ap]|map!|im%[ap]|lm%[ap]|cm%[ap]|tma%[p])'
    let pat = '\v'..pat_map..'\zs\s+(\<(buffer|expr|nowait|silent|unique)\>\s*)+'
    let Rep = {-> '  '..join(sort(split(submatch(0), '\s\+\|>\zs\ze<')), '')..'  '}
    sil exe '%s/'..pat..'/\=Rep()/ge'

    " make sure all buffer-local mappings use `<nowait>`
    sil exe '%s/\v'..pat_map..'\s+\<buffer\>%(\<expr\>)?\zs%(%(\<expr\>)?\<nowait\>)@!/<nowait>/ge'
    "                             ├────────────────────┘   ├─────────────────────────┘
    "                             │                        └ but not followed by `<nowait>`
    "                             │                          neither by `<expr><nowait>`
    "                             └ look for `<buffer>` may be followed by `<expr>`

    call winrestview(view)
endfu
