
" bg/fg:
" * bg
" * fg
" * White/Black/Red/..., :h cterm-colors
" * 0~255
function! ZF_AsciiPlayer_genHighlight(bg, fg)
    let hlGroup = 'ZFAsciiPlayerHL_' . a:bg . '_' . a:fg
    if hlID(hlGroup) != 0
        return hlGroup
    endif

    let colorIndex = (&t_Co == 256 || has('gui') ? 0 : 1)

    if a:bg == '' || a:bg ==? 'bg'
        let guibg = s:defaultBg()
        let ctermbg = guibg
    elseif a:bg ==? 'fg'
        let guibg = s:defaultFg()
        let ctermbg = guibg
    elseif type(a:bg) == type('')
        let guibg = a:bg
        let ctermbg = a:bg
    else
        if a:bg >= 0 && a:bg <= 255
            let guibg = g:ZFAsciiPlayerHLMap[a:bg][colorIndex]
            let ctermbg = a:bg
        else
            let guibg = 'NONE'
            let ctermbg = 'NONE'
        endif
    endif
    if a:fg == '' || a:fg ==? 'fg'
        let guifg = s:defaultFg()
        let ctermfg = guifg
    elseif a:fg ==? 'bg'
        let guifg = s:defaultBg()
        let ctermfg = guifg
    elseif type(a:fg) == type('')
        let guifg = a:fg
        let ctermfg = a:fg
    else
        if a:fg >= 0 && a:fg <= 255
            let guifg = g:ZFAsciiPlayerHLMap[a:fg][colorIndex]
            let ctermfg = a:fg
        else
            let guifg = 'NONE'
            let ctermfg = 'NONE'
        endif
    endif
    execute 'highlight ' . hlGroup
                \ . ' gui=NONE guibg=' . guibg . ' guifg=' . guifg
                \ . ' cterm=NONE ctermbg=' . ctermbg . ' ctermfg=' . ctermfg

    return hlGroup
endfunction

" :h E420
" E420 would occur when change colorschemes,
" even if `Normal` has been set properly
function! s:defaultBg()
    if &background == 'dark'
        return 'Black'
    else
        return 'White'
    endif
endfunction
function! s:defaultFg()
    if &background == 'dark'
        return 'Black'
    else
        return 'White'
    endif
endfunction

" https://jonasjacek.github.io/colors/
if !exists('g:ZFAsciiPlayerHLMap')
    let g:ZFAsciiPlayerHLMap = {
                \   0 :   ['#000000', 'Black'],
                \   1 :   ['#800000', 'DarkRed'],
                \   2 :   ['#008000', 'DarkGreen'],
                \   3 :   ['#808000', 'DarkYellow'],
                \   4 :   ['#000080', 'DarkBlue'],
                \   5 :   ['#800080', 'DarkMagenta'],
                \   6 :   ['#008080', 'DarkCyan'],
                \   7 :   ['#c0c0c0', 'Grey'],
                \   8 :   ['#808080', 'DarkCyan'],
                \   9 :   ['#ff0000', 'Red'],
                \   10 :  ['#00ff00', 'Green'],
                \   11 :  ['#ffff00', 'Yellow'],
                \   12 :  ['#0000ff', 'Blue'],
                \   13 :  ['#ff00ff', 'Magenta'],
                \   14 :  ['#00ffff', 'Cyan'],
                \   15 :  ['#ffffff', 'White'],
                \   16 :  ['#000000', 'Black'],
                \   17 :  ['#00005f', 'DarkBlue'],
                \   18 :  ['#000087', 'DarkBlue'],
                \   19 :  ['#0000af', 'DarkBlue'],
                \   20 :  ['#0000d7', 'Blue'],
                \   21 :  ['#0000ff', 'Blue'],
                \   22 :  ['#005f00', 'DarkGreen'],
                \   23 :  ['#005f5f', 'DarkCyan'],
                \   24 :  ['#005f87', 'DarkCyan'],
                \   25 :  ['#005faf', 'DarkCyan'],
                \   26 :  ['#005fd7', 'DarkCyan'],
                \   27 :  ['#005fff', 'Blue'],
                \   28 :  ['#008700', 'DarkGreen'],
                \   29 :  ['#00875f', 'DarkCyan'],
                \   30 :  ['#008787', 'DarkCyan'],
                \   31 :  ['#0087af', 'DarkCyan'],
                \   32 :  ['#0087d7', 'DarkCyan'],
                \   33 :  ['#0087ff', 'Cyan'],
                \   34 :  ['#00af00', 'DarkGreen'],
                \   35 :  ['#00af5f', 'DarkCyan'],
                \   36 :  ['#00af87', 'DarkCyan'],
                \   37 :  ['#00afaf', 'DarkCyan'],
                \   38 :  ['#00afd7', 'Cyan'],
                \   39 :  ['#00afff', 'Cyan'],
                \   40 :  ['#00d700', 'Green'],
                \   41 :  ['#00d75f', 'DarkCyan'],
                \   42 :  ['#00d787', 'DarkCyan'],
                \   43 :  ['#00d7af', 'Cyan'],
                \   44 :  ['#00d7d7', 'Cyan'],
                \   45 :  ['#00d7ff', 'Cyan'],
                \   46 :  ['#00ff00', 'Green'],
                \   47 :  ['#00ff5f', 'Green'],
                \   48 :  ['#00ff87', 'Cyan'],
                \   49 :  ['#00ffaf', 'Cyan'],
                \   50 :  ['#00ffd7', 'Cyan'],
                \   51 :  ['#00ffff', 'Cyan'],
                \   52 :  ['#5f0000', 'DarkRed'],
                \   53 :  ['#5f005f', 'DarkMagenta'],
                \   54 :  ['#5f0087', 'DarkMagenta'],
                \   55 :  ['#5f00af', 'DarkMagenta'],
                \   56 :  ['#5f00d7', 'DarkMagenta'],
                \   57 :  ['#5f00ff', 'Blue'],
                \   58 :  ['#5f5f00', 'DarkYellow'],
                \   59 :  ['#5f5f5f', 'DarkGrey'],
                \   60 :  ['#5f5f87', 'DarkGrey'],
                \   61 :  ['#5f5faf', 'DarkGrey'],
                \   62 :  ['#5f5fd7', 'DarkGrey'],
                \   63 :  ['#5f5fff', 'Blue'],
                \   64 :  ['#5f8700', 'DarkYellow'],
                \   65 :  ['#5f875f', 'DarkGrey'],
                \   66 :  ['#5f8787', 'DarkCyan'],
                \   67 :  ['#5f87af', 'DarkCyan'],
                \   68 :  ['#5f87d7', 'Grey'],
                \   69 :  ['#5f87ff', 'Cyan'],
                \   70 :  ['#5faf00', 'DarkYellow'],
                \   71 :  ['#5faf5f', 'DarkGrey'],
                \   72 :  ['#5faf87', 'DarkCyan'],
                \   73 :  ['#5fafaf', 'Grey'],
                \   74 :  ['#5fafd7', 'Grey'],
                \   75 :  ['#5fafff', 'Cyan'],
                \   76 :  ['#5fd700', 'DarkYellow'],
                \   77 :  ['#5fd75f', 'DarkGrey'],
                \   78 :  ['#5fd787', 'Grey'],
                \   79 :  ['#5fd7af', 'Grey'],
                \   80 :  ['#5fd7d7', 'Grey'],
                \   81 :  ['#5fd7ff', 'Cyan'],
                \   82 :  ['#5fff00', 'Green'],
                \   83 :  ['#5fff5f', 'Green'],
                \   84 :  ['#5fff87', 'Cyan'],
                \   85 :  ['#5fffaf', 'Cyan'],
                \   86 :  ['#5fffd7', 'Cyan'],
                \   87 :  ['#5fffff', 'Cyan'],
                \   88 :  ['#870000', 'DarkRed'],
                \   89 :  ['#87005f', 'DarkMagenta'],
                \   90 :  ['#870087', 'DarkMagenta'],
                \   91 :  ['#8700af', 'DarkMagenta'],
                \   92 :  ['#8700d7', 'DarkMagenta'],
                \   93 :  ['#8700ff', 'Magenta'],
                \   94 :  ['#875f00', 'DarkYellow'],
                \   95 :  ['#875f5f', 'DarkGrey'],
                \   96 :  ['#875f87', 'DarkMagenta'],
                \   97 :  ['#875faf', 'DarkMagenta'],
                \   98 :  ['#875fd7', 'Grey'],
                \   99 :  ['#875fff', 'Magenta'],
                \   100 : ['#878700', 'DarkYellow'],
                \   101 : ['#87875f', 'DarkYellow'],
                \   102 : ['#878787', 'DarkCyan'],
                \   103 : ['#8787af', 'Grey'],
                \   104 : ['#8787d7', 'Grey'],
                \   105 : ['#8787ff', 'Grey'],
                \   106 : ['#87af00', 'DarkYellow'],
                \   107 : ['#87af5f', 'DarkYellow'],
                \   108 : ['#87af87', 'Grey'],
                \   109 : ['#87afaf', 'Grey'],
                \   110 : ['#87afd7', 'Grey'],
                \   111 : ['#87afff', 'Grey'],
                \   112 : ['#87d700', 'DarkYellow'],
                \   113 : ['#87d75f', 'Grey'],
                \   114 : ['#87d787', 'Grey'],
                \   115 : ['#87d7af', 'Grey'],
                \   116 : ['#87d7d7', 'Grey'],
                \   117 : ['#87d7ff', 'Grey'],
                \   118 : ['#87ff00', 'Yellow'],
                \   119 : ['#87ff5f', 'Yellow'],
                \   120 : ['#87ff87', 'Grey'],
                \   121 : ['#87ffaf', 'Grey'],
                \   122 : ['#87ffd7', 'Grey'],
                \   123 : ['#87ffff', 'White'],
                \   124 : ['#af0000', 'DarkRed'],
                \   125 : ['#af005f', 'DarkMagenta'],
                \   126 : ['#af0087', 'DarkMagenta'],
                \   127 : ['#af00af', 'DarkMagenta'],
                \   128 : ['#af00d7', 'Magenta'],
                \   129 : ['#af00ff', 'Magenta'],
                \   130 : ['#af5f00', 'DarkYellow'],
                \   131 : ['#af5f5f', 'DarkGrey'],
                \   132 : ['#af5f87', 'DarkMagenta'],
                \   133 : ['#af5faf', 'Grey'],
                \   134 : ['#af5fd7', 'Grey'],
                \   135 : ['#af5fff', 'Magenta'],
                \   136 : ['#af8700', 'DarkYellow'],
                \   137 : ['#af875f', 'DarkYellow'],
                \   138 : ['#af8787', 'Grey'],
                \   139 : ['#af87af', 'Grey'],
                \   140 : ['#af87d7', 'Grey'],
                \   141 : ['#af87ff', 'Grey'],
                \   142 : ['#afaf00', 'DarkYellow'],
                \   143 : ['#afaf5f', 'Grey'],
                \   144 : ['#afaf87', 'Grey'],
                \   145 : ['#afafaf', 'Grey'],
                \   146 : ['#afafd7', 'Grey'],
                \   147 : ['#afafff', 'Grey'],
                \   148 : ['#afd700', 'Yellow'],
                \   149 : ['#afd75f', 'Grey'],
                \   150 : ['#afd787', 'Grey'],
                \   151 : ['#afd7af', 'Grey'],
                \   152 : ['#afd7d7', 'Grey'],
                \   153 : ['#afd7ff', 'Grey'],
                \   154 : ['#afff00', 'Yellow'],
                \   155 : ['#afff5f', 'Yellow'],
                \   156 : ['#afff87', 'Grey'],
                \   157 : ['#afffaf', 'Grey'],
                \   158 : ['#afffd7', 'Grey'],
                \   159 : ['#afffff', 'White'],
                \   160 : ['#d70000', 'Red'],
                \   161 : ['#d7005f', 'DarkMagenta'],
                \   162 : ['#d70087', 'DarkMagenta'],
                \   163 : ['#d700af', 'Magenta'],
                \   164 : ['#d700d7', 'Magenta'],
                \   165 : ['#d700ff', 'Magenta'],
                \   166 : ['#d75f00', 'DarkYellow'],
                \   167 : ['#d75f5f', 'DarkGrey'],
                \   168 : ['#d75f87', 'Grey'],
                \   169 : ['#d75faf', 'Grey'],
                \   170 : ['#d75fd7', 'Grey'],
                \   171 : ['#d75fff', 'Magenta'],
                \   172 : ['#d78700', 'DarkYellow'],
                \   173 : ['#d7875f', 'Grey'],
                \   174 : ['#d78787', 'Grey'],
                \   175 : ['#d787af', 'Grey'],
                \   176 : ['#d787d7', 'Grey'],
                \   177 : ['#d787ff', 'Grey'],
                \   178 : ['#d7af00', 'Yellow'],
                \   179 : ['#d7af5f', 'Grey'],
                \   180 : ['#d7af87', 'Grey'],
                \   181 : ['#d7afaf', 'Grey'],
                \   182 : ['#d7afd7', 'Grey'],
                \   183 : ['#d7afff', 'Grey'],
                \   184 : ['#d7d700', 'Yellow'],
                \   185 : ['#d7d75f', 'Grey'],
                \   186 : ['#d7d787', 'Grey'],
                \   187 : ['#d7d7af', 'Grey'],
                \   188 : ['#d7d7d7', 'Grey'],
                \   189 : ['#d7d7ff', 'White'],
                \   190 : ['#d7ff00', 'Yellow'],
                \   191 : ['#d7ff5f', 'Yellow'],
                \   192 : ['#d7ff87', 'Grey'],
                \   193 : ['#d7ffaf', 'Grey'],
                \   194 : ['#d7ffd7', 'White'],
                \   195 : ['#d7ffff', 'White'],
                \   196 : ['#ff0000', 'Red'],
                \   197 : ['#ff005f', 'Red'],
                \   198 : ['#ff0087', 'Magenta'],
                \   199 : ['#ff00af', 'Magenta'],
                \   200 : ['#ff00d7', 'Magenta'],
                \   201 : ['#ff00ff', 'Magenta'],
                \   202 : ['#ff5f00', 'Red'],
                \   203 : ['#ff5f5f', 'Red'],
                \   204 : ['#ff5f87', 'Magenta'],
                \   205 : ['#ff5faf', 'Magenta'],
                \   206 : ['#ff5fd7', 'Magenta'],
                \   207 : ['#ff5fff', 'Magenta'],
                \   208 : ['#ff8700', 'Yellow'],
                \   209 : ['#ff875f', 'Yellow'],
                \   210 : ['#ff8787', 'Grey'],
                \   211 : ['#ff87af', 'Grey'],
                \   212 : ['#ff87d7', 'Grey'],
                \   213 : ['#ff87ff', 'White'],
                \   214 : ['#ffaf00', 'Yellow'],
                \   215 : ['#ffaf5f', 'Yellow'],
                \   216 : ['#ffaf87', 'Grey'],
                \   217 : ['#ffafaf', 'Grey'],
                \   218 : ['#ffafd7', 'Grey'],
                \   219 : ['#ffafff', 'White'],
                \   220 : ['#ffd700', 'Yellow'],
                \   221 : ['#ffd75f', 'Yellow'],
                \   222 : ['#ffd787', 'Grey'],
                \   223 : ['#ffd7af', 'Grey'],
                \   224 : ['#ffd7d7', 'White'],
                \   225 : ['#ffd7ff', 'White'],
                \   226 : ['#ffff00', 'Yellow'],
                \   227 : ['#ffff5f', 'Yellow'],
                \   228 : ['#ffff87', 'White'],
                \   229 : ['#ffffaf', 'White'],
                \   230 : ['#ffffd7', 'White'],
                \   231 : ['#ffffff', 'White'],
                \   232 : ['#080808', 'Black'],
                \   233 : ['#121212', 'Black'],
                \   234 : ['#1c1c1c', 'Black'],
                \   235 : ['#262626', 'DarkGrey'],
                \   236 : ['#303030', 'DarkGrey'],
                \   237 : ['#3a3a3a', 'DarkGrey'],
                \   238 : ['#444444', 'DarkGrey'],
                \   239 : ['#4e4e4e', 'DarkGrey'],
                \   240 : ['#585858', 'DarkGrey'],
                \   241 : ['#626262', 'DarkGrey'],
                \   242 : ['#6c6c6c', 'DarkGrey'],
                \   243 : ['#767676', 'DarkCyan'],
                \   244 : ['#808080', 'DarkCyan'],
                \   245 : ['#8a8a8a', 'DarkCyan'],
                \   246 : ['#949494', 'Grey'],
                \   247 : ['#9e9e9e', 'Grey'],
                \   248 : ['#a8a8a8', 'Grey'],
                \   249 : ['#b2b2b2', 'Grey'],
                \   250 : ['#bcbcbc', 'Grey'],
                \   251 : ['#c6c6c6', 'Grey'],
                \   252 : ['#d0d0d0', 'Grey'],
                \   253 : ['#dadada', 'Grey'],
                \   254 : ['#e4e4e4', 'White'],
                \   255 : ['#eeeeee', 'White'],
                \ }
endif

if 0
    function! s:offset(color0, color1, rgbIndex)
        return abs(str2nr(strpart(a:color0, 1 + a:rgbIndex * 2, 2), 16) - str2nr(strpart(a:color1, 1 + a:rgbIndex * 2, 2), 16))
    endfunction
    function! ZF_AsciiPlayer_initColorMap()
        let color8Map = [
                    \   ['Black',       '#000000'],
                    \   ['DarkBlue',    '#000080'],
                    \   ['DarkGreen',   '#008000'],
                    \   ['DarkCyan',    '#008080'],
                    \   ['DarkRed',     '#800000'],
                    \   ['DarkMagenta', '#800080'],
                    \   ['DarkYellow',  '#808000'],
                    \   ['Grey',        '#c0c0c0'],
                    \   ['DarkGrey',    '#404040'],
                    \   ['Blue',        '#0000ff'],
                    \   ['Green',       '#00ff00'],
                    \   ['Cyan',        '#00ffff'],
                    \   ['Red',         '#ff0000'],
                    \   ['Magenta',     '#ff00ff'],
                    \   ['Yellow',      '#ffff00'],
                    \   ['White',       '#ffffff'],
                    \ ]
        for item in values(g:ZFAsciiPlayerHLMap)
            let minOffset = 60000
            let minIndex = 0
            for i in range(0, len(color8Map) - 1)
                let offset = 0
                            \ + s:offset(color8Map[i][1], item[0], 0)
                            \ + s:offset(color8Map[i][1], item[0], 1)
                            \ + s:offset(color8Map[i][1], item[0], 2)
                if offset < minOffset
                    let minOffset = offset
                    let minIndex = i
                endif
            endfor
            let item[1] = color8Map[minIndex][0]
        endfor
    endfunction
    call ZF_AsciiPlayer_initColorMap()
endif

