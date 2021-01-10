
function! ZF_AsciiPlayer_draw(frameData)
    let b:ZFAsciiPlayer_frameData = a:frameData
    if exists('w:ZFAsciiPlayer_frameDataCur')
        unlet w:ZFAsciiPlayer_frameDataCur
    endif
    call ZF_AsciiPlayer_redraw()
endfunction

function! ZF_AsciiPlayer_clear()
    call clearmatches()
    if exists('w:ZFAsciiPlayer_frameDataCur')
        unlet w:ZFAsciiPlayer_frameDataCur
    endif
    let &l:cursorline = &g:cursorline
endfunction

function! ZF_AsciiPlayer_redraw()
    if exists('w:ZFAsciiPlayer_frameDataCur')
                \ || !exists('b:ZFAsciiPlayer_frameData')
        return
    endif
    let w:ZFAsciiPlayer_frameDataCur = b:ZFAsciiPlayer_frameData

    let oldPos = getpos('.')
    let oldUndo = &undolevels
    set undolevels=-1
    setlocal modifiable

    if empty(w:ZFAsciiPlayer_frameDataCur['lines'])
        silent! normal! gg"_dG
    else
        execute 'silent! normal! gg' . len(w:ZFAsciiPlayer_frameDataCur['lines']) . 'j"_dG'
    endif

    call setline(1, w:ZFAsciiPlayer_frameDataCur['lines'])
    call clearmatches()
    for hlCmd in w:ZFAsciiPlayer_frameDataCur['hlCmds']
        call matchadd(hlCmd['group'], ''
                    \   . '\%' . hlCmd['iLine'] . 'l'
                    \   . '\%>' . hlCmd['pos'] . 'c'
                    \   . '\%<' . (hlCmd['pos'] + hlCmd['len'] + 1) . 'c'
                    \ )
    endfor

    " for performance
    setlocal nocursorline

    setlocal nomodified
    setlocal nomodifiable
    let &undolevels = oldUndo
    try
        call setpos('.', oldPos)
    catch
    endtry
    redraw

    " auto redraw since matchadd() affects to windows only
    execute 'augroup ZF_AsciiPlayer_draw_augroup_' . bufnr('%') . '_' . ZF_AsciiPlayer_win_getid()
    autocmd!
    autocmd BufDelete <buffer> call s:cleanup()
    autocmd BufEnter,BufWinEnter,WinEnter <buffer> call ZF_AsciiPlayer_redraw()
    autocmd BufLeave,BufWinLeave,BufHidden <buffer> call ZF_AsciiPlayer_clear()
    execute 'augroup END'
endfunction

if exists('*win_getid')
    function! ZF_AsciiPlayer_win_getid()
        return win_getid()
    endfunction
else
    function! ZF_AsciiPlayer_win_getid()
        if exists('w:ZFAsciiPlayer_winid')
            return w:ZFAsciiPlayer_winid
        endif
        let s:ZFAsciiPlayer_winid = get(s:, 'ZFAsciiPlayer_winid', 0) + 1
        let w:ZFAsciiPlayer_winid = s:ZFAsciiPlayer_winid
        return w:ZFAsciiPlayer_winid
    endfunction
endif

function! s:cleanup()
    call clearmatches()
    execute 'augroup ZF_AsciiPlayer_draw_augroup_' . bufnr('%') . '_' . ZF_AsciiPlayer_win_getid()
    autocmd!
    execute 'augroup END'
endfunction

