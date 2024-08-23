
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
    if exists('g:ZFAsciiPlayerLog')
        let _start_time = reltime()
        let ret = s:toHLCmds(a:ascii)
        call add(g:ZFAsciiPlayerLog,
                    \   'terminalHL parse used time: '
                    \   . float2nr(reltimefloat(reltime(_start_time, reltime())) * 1000)
                    \   . ', len: ' . len(a:ascii)
                    \ )
        return ret
    else
        return s:toHLCmds(a:ascii)
    endif
endfunction

" lines:
"   ^[[0m^[[48;N;CCCm
"   ^[[NA^[[0m^[[48;N;CCCm
"   ^[[0m^[[48;N;CCCm
" return: [
"   '^[[0m^[[48;N;CCCm',
"   '^[[0m^[[48;N;CCCm',
"   '^[[0m^[[48;N;CCCm',
" ]
function! ZF_AsciiPlayer_terminalHLParsePages(ascii)
    return split(a:ascii, '\C\%x1b\[[0-9]\+A')
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
    for line in split(a:ascii, '[\r\n]\+')
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
"     'bg' : 'NONE or 0~255',
"     'fg' : 'NONE or 0~255',
"   },
" ]
function! ZF_AsciiPlayer_terminalHLParse(line)
    " note:
    "     ^[        => means <esc>, which is 0x1b
    "     N         => text mode ctrl, 0~9
    "     CCC       => color code, 0~255
    "
    " list of things to process
    "     ^[[K              => simply remove
    "     ^[[0m             => reset bg and fg to NONE
    "     ^[[49m            => reset bg to NONE
    "     ^[[39m            => reset fg to NONE
    "     ^[[48;N;CCCm      => set bg to CCC
    "     ^[[38;N;CCCm      => set fg to CCC

    " \C\%x1b\[K
    let line = substitute(a:line, '\C\%x1b\[K', '', 'g')
    let lineInfo = []
    let token = nr2char(27) " 0x1b
    let pStart = 0
    let pL = 0
    let pR = 0
    let pE = strlen(line)
    let bg = 'NONE'
    let fg = 'NONE'

    while pL < pE
        while pL < pE && line[pL] != token
            let pL += 1
        endwhile
        if pL+1 >= pE || line[pL+1] != '[' | break | endif
        if pL > pStart
            call add(lineInfo, {
                        \   'text' : strpart(line, pStart, pL - pStart),
                        \   'bg' : bg,
                        \   'fg' : fg,
                        \ })
        endif

        let pL = pL + 2
        let pR = pL
        while pR < pE
                    \ && line[pR] != 'K'
                    \ && line[pR] != 'm'
            let pR += 1
        endwhile
        if pR >= pE | break | endif

        let patterns = split(strpart(line, pL, pR - pL), ';')
        let pL = pR + 1
        let pStart = pL

        let patternCount = len(patterns)
        if patternCount < 1
            continue
        endif
        if patterns[0] == '0'
            let bg = 'NONE'
            let fg = 'NONE'
        elseif patterns[0] == '49'
            let bg = 'NONE'
        elseif patterns[0] == '39'
            let fg = 'NONE'
        elseif patterns[0] == '48'
            if patternCount >= 3
                let bg = str2nr(patterns[2])
            endif
        elseif patterns[0] == '38'
            if patternCount >= 3
                let fg = str2nr(patterns[2])
            endif
        endif
    endwhile

    return lineInfo
endfunction

