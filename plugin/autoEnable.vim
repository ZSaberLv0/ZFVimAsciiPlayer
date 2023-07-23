
augroup ZFFilePost_augroup
    autocmd!
    autocmd BufReadPost,FileReadPost * :call ZFFilePostAction()
    function! ZFFilePostRegister(moduleName, params)
        if !exists('g:ZFFilePost')
            let g:ZFFilePost = {}
        endif
        let g:ZFFilePost[a:moduleName] = a:params
    endfunction
    function! ZFFilePostAction()
        let file = expand('<afile>')
        if !filereadable(file) || empty(get(g:, 'ZFFilePost', {}))
                    \ || get(b:, 'ZFFilePostDisable', 0)
                    \ || get(b:, 'ZFFilePostProcessing', 0)
            return
        endif
        let b:ZFFilePostFile = file
        let b:ZFFilePostProcessing = 1
        let priorityHighest = -1
        let itemHighest = {}
        for item in values(g:ZFFilePost)
            let priority = item['checker'](file)
            if priority > priorityHighest
                let priorityHighest = priority
                let itemHighest = item
            endif
        endfor
        if !empty(itemHighest)
            if exists('b:ZFFilePostRunning')
                if !empty(get(b:ZFFilePostRunning, 'cleanup', ''))
                    call b:ZFFilePostRunning['cleanup'](file)
                endif
            endif
            let b:ZFFilePostRunning = itemHighest
            call itemHighest['action'](file)
        endif
        unlet b:ZFFilePostProcessing
    endfunction
    function! ZFFilePostDisable()
        let b:ZFFilePostDisable = 1
        call ZFFilePostCleanup()
    endfunction
    function! ZFFilePostCleanup()
        if !exists('b:ZFFilePostFile')
            return
        endif
        if exists('b:ZFFilePostRunning')
            unlet b:ZFFilePostRunning
        endif
        for item in values(g:ZFFilePost)
            if !empty(get(item, 'cleanup', ''))
                call item['cleanup'](b:ZFFilePostFile)
            endif
        endfor
    endfunction
augroup END

function! s:autoEnable_checker(file)
    let ext = tolower(fnamemodify(a:file, ':e'))
    if !empty(ext) && exists('g:ZFAsciiPlayer_converters[ext]')
        return 9
    endif
    return -1
endfunction
function! s:autoEnable_action(file)
    call ZFAsciiPlayerOn()
endfunction
function! s:autoEnable_cleanup(file)
    call ZFAsciiPlayerOff()
endfunction
call ZFFilePostRegister('ZFAsciiPlayer', {
            \   'checker' : function('s:autoEnable_checker'),
            \   'action' : function('s:autoEnable_action'),
            \   'cleanup' : function('s:autoEnable_cleanup'),
            \ })

