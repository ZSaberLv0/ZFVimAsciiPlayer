
" return: {
"   'lines' : [],
"   'hlCmds' : [
"     {
"       'group' : '',
"       'iLine' : 'start from 1',
"       'pos' : '',
"       'len' : '',
"     },
"     ...
"   ],
" }
function! ZF_AsciiPlayer_terminalHLToHLCmd(ascii)
    return s:toHLCmds(a:ascii)
endfunction

function! s:toHLCmds(ascii)
    let hlCmds = []
    let lines = []
    let iLine = 1

    " add a dummy line to tail for convenient
    if get(g:, 'ZFAsciiPlayer_draw_headLine', 1)
        call add(lines, '')
        let iLine += 1
    endif

    " each lines
    for line in split(a:ascii, '[\r\n]')
        let lineInfo = ZF_AsciiPlayer_terminalHLParse(line)
        call s:toHLCmds_line(iLine, lineInfo, lines, hlCmds)
        let iLine += 1
    endfor

    " add a dummy line to tail for convenient
    if get(g:, 'ZFAsciiPlayer_draw_tailLine', 1)
        call add(lines, '')
    endif

    return {
                \   'lines' : lines,
                \   'hlCmds' : hlCmds,
                \ }
endfunction

function! s:toHLCmds_line(iLine, lineInfo, lines, hlCmds)
    let line = ''

    " add head token
    let linePrefix = get(g:, 'ZFAsciiPlayer_draw_linePrefix', ' ')
    if len(linePrefix) > 0
        call add(a:hlCmds, {
                    \   'group' : ZF_AsciiPlayer_genHighlight('NONE', 'bg'),
                    \   'iLine' : a:iLine,
                    \   'pos' : len(line),
                    \   'len' : len(linePrefix),
                    \ })
        let line .= linePrefix
    endif

    for item in a:lineInfo
        call add(a:hlCmds, {
                    \   'group' : ZF_AsciiPlayer_genHighlight(item['bg'], item['fg']),
                    \   'iLine' : a:iLine,
                    \   'pos' : len(line),
                    \   'len' : len(item['text']),
                    \ })
        let line .= item['text']
    endfor

    " add tail token to bypass tail white space plugins
    let linePostfix = get(g:, 'ZFAsciiPlayer_draw_linePostfix', '_')
    if len(linePostfix) > 0
        call add(a:hlCmds, {
                    \   'group' : ZF_AsciiPlayer_genHighlight('NONE', 'bg'),
                    \   'iLine' : a:iLine,
                    \   'pos' : len(line),
                    \   'len' : len(linePostfix),
                    \ })
        let line .= linePostfix
    endif

    call add(a:lines, line)
endfunction

" return: [
"   {
"     'text' : '',
"     'bg' : 'NONE, 0~255',
"     'fg' : 'NONE, 0~255',
"   },
" ]
function! ZF_AsciiPlayer_terminalHLParse(line)
    " \C\%x1b\[K
    let line = substitute(a:line, '\C\%x1b\[K', '', 'g')

    let lineInfo = []
    let bg = -1
    let fg = -1
    while 1
        let pos = match(line, '\%x1b')
        if pos < 0
            if len(line) > 0
                call add(lineInfo, {
                            \   'text' : line,
                            \   'bg' : bg,
                            \   'fg' : fg,
                            \ })
            endif
            break
        elseif pos > 0
            call add(lineInfo, {
                        \   'text' : strpart(line, 0, pos),
                        \   'bg' : bg,
                        \   'fg' : fg,
                        \ })
            let line = strpart(line, pos)
        endif

        " \C\%x1b\[[0-9a-zA-Z;]+[mC]
        let pattern = matchstr(line, '\C\%x1b\[[0-9a-zA-Z;]\+[mC]')
        if len(pattern) == 0
            let line = substitute(line, '\%x1b', '', '')
            continue
        endif

        if match(pattern, '\C^\%x1b\[\([0-9]\+\)C') == 0
            " \C^\%x1b\[([0-9]+)C
            call add(lineInfo, {
                        \   'text' : repeat(' ', str2nr(substitute(pattern, '\C^\%x1b\[\([0-9]\+\)C', '\1', ''))),
                        \   'bg' : 'NONE',
                        \   'fg' : 'NONE',
                        \ })
            let line = strpart(line, len(pattern))
        elseif match(pattern, '\C^\%x1b\[0m$') == 0
            let bg = -1
            let fg = -1
            let line = strpart(line, len(pattern))
        elseif match(pattern, '\C^\%x1b\[49m$') == 0
            let bg = -1
            let line = strpart(line, len(pattern))
        elseif match(pattern, '\C^\%x1b\[39m$') == 0
            let fg = -1
            let line = strpart(line, len(pattern))
        elseif match(pattern, '\C^\%x1b\[48;5;\([0-9]\+\)m$') == 0
            " \C^\%x1b\[48;5;([0-9]+)m$
            let bg = str2nr(substitute(pattern, '\C^\%x1b\[48;5;\([0-9]\+\)m$', '\1', ''))
            let line = strpart(line, len(pattern))
        elseif match(pattern, '\C^\%x1b\[38;5;\([0-9]\+\)m$') == 0
            " \C^\%x1b\[38;5;([0-9]+)m$
            let fg = str2nr(substitute(pattern, '\C^\%x1b\[38;5;\([0-9]\+\)m$', '\1', ''))
            let line = strpart(line, len(pattern))
        else
            let line = substitute(line, '\%x1b', '', '')
            continue
        endif
    endwhile
    return lineInfo
endfunction

