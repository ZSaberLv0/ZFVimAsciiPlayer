
" {
"   'file extension' : {
"     'init' : function('converterInit'),
"     'frame' : function('converterFrame'),
"   },
" }
if !exists('g:ZFAsciiPlayer_converters')
    let g:ZFAsciiPlayer_converters = {}
endif

" params: {
"   'file' : 'file to open',
"   'maxWidth' : 'max width (char count)',
"   'maxHeight' : 'max height (char count)',
"   'heightScale' : 'height scale to suit terminal char size',
" }
" return state: { // return empty for error
"   'fps' : '-1 to use global',
"   'totalFrame' : 'total frame count, -1 for infinite',
"   ... // extra impl state
" }
function! ZF_AsciiPlayer_converterInit(params)
    let ext = tolower(fnamemodify(a:params['file'], ':e'))
    if empty(ext)
        return {}
    endif
    let impl = get(g:ZFAsciiPlayer_converters, ext, {})
    if empty(impl)
        return {}
    endif
    let state = impl['init'](a:params)
    if empty(state)
        return state
    endif
    let state['_impl_frame'] = impl['frame']
    return state
endfunction

" return frame data: {
"   'time' : 'frame time, 0 to use global fps',
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
function! ZF_AsciiPlayer_converterFrame(state, frame)
    return a:state['_impl_frame'](a:state, a:frame)
endfunction

