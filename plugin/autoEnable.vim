
augroup ZFFilePost_augroup
    autocmd!
    autocmd BufReadPost,FileReadPost * :call ZFFilePostAction()
    function! ZFFilePostRegister(moduleName, checker, action)
        if !exists('g:ZFFilePost')
            let g:ZFFilePost = {}
        endif
        let g:ZFFilePost[a:moduleName] = {
                    \   'checker' : a:checker,
                    \   'action' : a:action,
                    \ }
    endfunction
    function! ZFFilePostAction()
        let file = expand('<afile>')
        if !filereadable(file) || empty(get(g:, 'ZFFilePost', {}))
            return
        endif
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
            call itemHighest['action'](file)
        endif
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
    call ZFAsciiPlayer()
endfunction
call ZFFilePostRegister('ZFAsciiPlayer', function('s:autoEnable_checker'), function('s:autoEnable_action'))

