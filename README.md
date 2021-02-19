
convert files (images for example) and output to vim as colored ascii chars

it's designed extensible, with some hacks,
you may use it as video player, canvas drawer, or even game player

![](https://raw.githubusercontent.com/ZSaberLv0/ZFVimAsciiPlayer/master/preview.png)

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)


# Install

use [vim-plug](https://github.com/junegunn/vim-plug) or any other plugin manager you like to install

```
Plug 'ZSaberLv0/ZFVimAsciiPlayer'
```

this repo only holds basic API,
you must also install extensions to support actual file types:

* `Plug 'ZSaberLv0/ZFVimAsciiPlayer_image'` : image/gif viewer

    * you need `python` and `pip install img2txt.py` to make this extension to work,
        see [ZFVimAsciiPlayer_image](https://github.com/ZSaberLv0/ZFVimAsciiPlayer_image)
        for detail


# Usage

simply open a supported file


# Extensions

see [ZFVimAsciiPlayer_image](https://github.com/ZSaberLv0/ZFVimAsciiPlayer_image) for example

to write extensions:

1. supply impl functions:

    ```
    " params: {
    "   'file' : 'file to open',
    "   'maxWidth' : 'max width (char count)',
    "   'maxHeight' : 'max height (char count)',
    "   'heightScale' : 'height scale to suit terminal char size',
    " }
    " return state: { // return empty for error
    "   'fps' : '-1 to use global g:ZFAsciiPlayer_fps',
    "   'totalFrame' : 'total frame count, -1 for infinite',
    "   ... // extra impl state
    " }
    function! MyExt_converterInit(params)
    endfunction

    " return frame data
    "
    " type=hlCmds: {
    "   'type' : 'hlCmds',
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
    "
    " type=terminalHL: {
    "   'type' : 'terminalHL',
    "   'ascii' : 'terminal ascii with or without highlight',
    " }
    function! MyExt_converterFrame(state, frame)
    endfunction
    ```

1. register the impl functions:

    ```
    if !exists('g:ZFAsciiPlayer_converters')
        let g:ZFAsciiPlayer_converters = {}
    endif
    " register by file extension (must be lowercase)
    let g:ZFAsciiPlayer_converters['my_ext'] = {
            \   'init' : function('MyExt_converterInit'),
            \   'frame' : function('MyExt_converterFrame'),
            \ }
    ```

1. now try to open `*.my_ext` files


