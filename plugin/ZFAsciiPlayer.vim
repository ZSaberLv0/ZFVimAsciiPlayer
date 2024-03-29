
command! -nargs=* -complete=file ZFAsciiPlayer :call ZFAsciiPlayer(<f-args>)

function! CygpathFix_absPath(path)
    if len(a:path) <= 0|return ''|endif
    if !exists('g:CygpathFix_isCygwin')
        let g:CygpathFix_isCygwin = has('win32unix') && executable('cygpath')
    endif
    let path = fnamemodify(a:path, ':p')
    if g:CygpathFix_isCygwin
        if 0 " cygpath is really slow
            let path = substitute(system('cygpath -m "' . path . '"'), '[\r\n]', '', 'g')
        else
            if match(path, '^/cygdrive/') >= 0
                let path = toupper(strpart(path, len('/cygdrive/'), 1)) . ':' . strpart(path, len('/cygdrive/') + 1)
            else
                if !exists('g:CygpathFix_cygwinPrefix')
                    let g:CygpathFix_cygwinPrefix = substitute(system('cygpath -m /'), '[\r\n]', '', 'g')
                endif
                let path = g:CygpathFix_cygwinPrefix . path
            endif
        endif
    endif
    return substitute(substitute(path, '\\', '/', 'g'), '\%(\/\)\@<!\/\+$', '', '') " (?<!\/)\/+$
endfunction

function! ZF_AsciiPlayer_log(msg)
    echomsg a:msg
    if get(g:, 'ZF_AsciiPlayer_logEnable', 0)
        if !exists('g:ZF_AsciiPlayer_logList')
            let g:ZF_AsciiPlayer_logList = []
        endif
        call add(g:ZF_AsciiPlayer_logList, a:msg)
    endif
endfunction

" params:
"   file
function! ZFAsciiPlayer(...)
    if !exists('b:ZFAsciiPlayer_frameData')
        return ZFAsciiPlayerOn(get(a:, 1, ''))
    else
        call ZFAsciiPlayerOff()
        return 0
    endif
endfunction

function! ZFAsciiPlayerOn(...)
    let file = get(a:, 1, '')
    if empty(file)
        let file = expand('%')
        if empty(file)
            call ZF_AsciiPlayer_log('[ZFAsciiPlayer] no file')
            return 0
        endif
    else
        let file = CygpathFix_absPath(file)
        let file = substitute(file, '\\', '/', 'g')
    endif
    if filereadable(file)
        noautocmd execute 'noautocmd edit! ' . substitute(file, ' ', '\\ ', 'g')
        call ZFFilePostCleanup()
    else
        call ZF_AsciiPlayer_log('[ZFAsciiPlayer] unable to open file: ' . file)
        return 0
    endif

    let maxWidth = winwidth(0)
    if &number
        let maxWidth -= &numberwidth
    endif
    if len(get(g:, 'ZFAsciiPlayer_draw_linePrefix', ' ')) > 0
        let maxWidth -= 1
    endif
    if len(get(g:, 'ZFAsciiPlayer_draw_linePostfix', ' ')) > 0
        let maxWidth -= 1
    endif
    let maxHeight = winheight(0)
    if get(g:, 'ZFAsciiPlayer_draw_headLine', 1)
        let maxHeight -= 1
    endif
    if get(g:, 'ZFAsciiPlayer_draw_tailLine', 1)
        let maxHeight -= 1
    endif
    if maxWidth <= 0 || maxHeight <= 0
        call ZF_AsciiPlayer_log('[ZFAsciiPlayer] window too small: (' . maxWidth . ',' . maxHeight . ')')
        return 0
    endif

    let state = ZF_AsciiPlayer_converterInit({
                \   'file' : file,
                \   'maxWidth' : maxWidth,
                \   'maxHeight' : maxHeight,
                \   'heightScale' : get(g:, 'ZFAsciiPlayer_heightScale', 0.52),
                \ })
    if empty(state) || state['totalFrame'] == 0
        call ZF_AsciiPlayer_log('[ZFAsciiPlayer] unable to parse file: ' . file)
        return 0
    endif

    execute 'augroup ZF_AsciiPlayer_resetDiff_augroup_' . bufnr('%')
        autocmd!
        autocmd DiffUpdated <buffer> diffoff
    execute 'augroup END'

    if state['totalFrame'] == 1 || !has('timers')
        call ZF_AsciiPlayer_draw(ZF_AsciiPlayer_converterFrame(state, 0))
    else
        call s:aniStart(state)
    endif
    return 1
endfunction

function! ZFAsciiPlayerOff()
    call s:aniStop()
    execute 'augroup ZF_AsciiPlayer_resetDiff_augroup_' . bufnr('%')
        autocmd!
    execute 'augroup END'
    call ZF_AsciiPlayer_redraw_cleanup()

    noautocmd edit!
endfunction

function! s:aniStart(state)
    call s:aniStop()

    execute 'augroup ZF_AsciiPlayer_main_augroup_' . bufnr('%') . '_' . ZF_AsciiPlayer_win_getid()
    autocmd!
    autocmd BufEnter,BufWinEnter,WinEnter <buffer> call s:aniNextFrame()
    autocmd BufDelete,BufLeave,BufWinLeave,BufHidden,WinLeave <buffer> call s:aniNextFrameStop()
    execute 'augroup END'

    let fpsDefault = 8
    let fps = get(a:state, 'fps', -1)
    if fps <= 0
        let fps = get(g:, 'ZFAsciiPlayer_fps', fpsDefault)
    endif
    if fps <= 0
        let fps = fpsDefault
    endif
    " frameDataCaches used only for limited totalFrame
    let b:ZFAsciiPlayer_aniTask = {
                \   'bufnr' : bufnr(),
                \   'timerId' : -1,
                \   'state' : a:state,
                \   'frame' : -1,
                \   'frameTime' : float2nr(1000/fps),
                \   'frameDataCaches' : [],
                \ }
    call s:aniNextFrame()
endfunction

function! s:aniStop()
    execute 'augroup ZF_AsciiPlayer_main_augroup_' . bufnr('%') . '_' . ZF_AsciiPlayer_win_getid()
    autocmd!
    execute 'augroup END'

    if !exists('b:ZFAsciiPlayer_aniTask')
        return
    endif
    if b:ZFAsciiPlayer_aniTask['timerId'] != -1
        call s:timer_stop(b:ZFAsciiPlayer_aniTask['timerId'])
        let b:ZFAsciiPlayer_aniTask['timerId'] = -1
    endif
endfunction

function! s:aniTimerCallback(bufnr, timerId)
    if !exists('b:ZFAsciiPlayer_aniTask')
        return
    endif
    let b:ZFAsciiPlayer_aniTask['timerId'] = -1
    if b:ZFAsciiPlayer_aniTask['bufnr'] != a:bufnr
        return
    endif
    call s:aniNextFrame()
endfunction
function! s:aniNextFrame()
    call s:aniNextFrameStop()
    let frame = b:ZFAsciiPlayer_aniTask['frame'] + 1
    let totalFrame = b:ZFAsciiPlayer_aniTask['state']['totalFrame']
    if totalFrame > 0 && frame >= totalFrame
        let frame = 0
    endif
    let b:ZFAsciiPlayer_aniTask['frame'] = frame
    if totalFrame > 0 && totalFrame <= 100
        let frameDataCaches = b:ZFAsciiPlayer_aniTask['frameDataCaches']
        if frame < len(frameDataCaches)
            let frameData = frameDataCaches[frame]
        else
            let frameData = ZF_AsciiPlayer_converterFrame(b:ZFAsciiPlayer_aniTask['state'], frame)
            call add(frameDataCaches, frameData)
        endif
    else
        let frameData = ZF_AsciiPlayer_converterFrame(b:ZFAsciiPlayer_aniTask['state'], frame)
    endif
    call ZF_AsciiPlayer_draw(frameData)

    let frameTime = get(frameData, 'time', b:ZFAsciiPlayer_aniTask['frameTime'])
    if frameTime <= 0
        let frameTime = b:ZFAsciiPlayer_aniTask['frameTime']
    endif
    let b:ZFAsciiPlayer_aniTask['timerId'] = s:timer_start(frameTime, function('s:aniTimerCallback'), [bufnr()])
endfunction

function! s:aniNextFrameStop()
    if exists('b:ZFAsciiPlayer_aniTask') && b:ZFAsciiPlayer_aniTask['timerId'] != -1
        call s:timer_stop(b:ZFAsciiPlayer_aniTask['timerId'])
        let b:ZFAsciiPlayer_aniTask['timerId'] = -1
    endif
endfunction

" ============================================================
" old vim does not support `function(name, arglist)`
if !exists('s:jobTimerMap')
    " <jobTimerId, {callback,params}>
    let s:jobTimerMap = {}
endif
function! s:jobTimerCallback(timerId)
    if !exists('s:jobTimerMap[a:timerId]')
        return
    endif
    let task = remove(s:jobTimerMap, a:timerId)
    let params = copy(task['params'])
    call add(params, a:timerId)
    call call(task['callback'], params)
endfunction
function! s:timer_start(delay, func, params)
    let timerId = timer_start(a:delay, function('s:jobTimerCallback'))
    if timerId == -1
        return -1
    endif
    let s:jobTimerMap[timerId] = {
                \   'callback' : a:func,
                \   'params' : a:params,
                \ }
    return timerId
endfunction
function! s:timer_stop(timerId)
    if !exists('s:jobTimerMap[a:timerId]')
        return
    endif
    call remove(s:jobTimerMap, a:timerId)
    call timer_stop(a:timerId)
endfunction

