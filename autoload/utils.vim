vim9script

# Автоматически определять корень проекта по маркерам
export def FindProjectRoot(): string
    var markers = ['.git', '.hg', '.svn', 'package.json', 'Cargo.toml', 'go.mod']
    var dir = expand('%:p:h')

    for marker in markers
        var found = finddir(marker, dir .. ';')
        if !empty(found)
            return fnamemodify(found, ':h')
        endif
        found = findfile(marker, dir .. ';')
        if !empty(found)
            return fnamemodify(found, ':h')
        endif
    endfor

    return getcwd()
enddef

# Color
def ContrastColor(bg: string): string
    var r = str2nr(bg[1] .. bg[2], 16)
    var g = str2nr(bg[3] .. bg[4], 16)
    var b = str2nr(bg[5] .. bg[6], 16)
    var luminance = 0.299 * r + 0.587 * g + 0.114 * b
    return luminance > 186 ? '#000000' : '#FFFFFF'
enddef

def CollectColors(): dict<bool>
    var lines = getline(1, '$')
    var matches = {}
    for line in lines
        var start = 0
        while true
            var [m, s, e] = matchstrpos(line, '#\x\{6}', start)
            if empty(m)
                break
            endif
            matches[m] = true
            start = e
        endwhile
    endfor
    return matches
enddef

export def ColorizeHex(): void
    silent! syntax clear ColorHexDynamic
    var matches = CollectColors()
    for color in keys(matches)
        var group = 'ColorHex_' .. substitute(color, '#', '', '')
        execute 'highlight ' .. group .. ' guibg=' .. color .. ' guifg=' .. ContrastColor(color)
        execute 'syntax match ' .. group .. ' "' .. color .. '" containedIn=ALL'
    endfor
enddef

# omnifunc
export def GDScriptOmni(findstart: number, base: string): any
    if findstart
        var line = getline('.')
        var colnum = col('.') - 1
        # Ищем начало текущего слова
        while colnum > 0 && line[colnum - 1] =~ '\k'
            colnum -= 1
        endwhile
        return colnum
    else
        var res = []

        # Собираем локальные символы
        var lines = getline(1, '$')
        for l in lines
            for pat in ['^\s*func\s\+\zs\k\+', '^\s*var\s\+\zs\k\+', '^\s*const\s\+\zs\k\+']
                if l =~ pat
                    var name = matchstr(l, pat)
                    # Фильтруем по base
                    if base == '' || name =~ '^' .. base
                        if index(res, name) == -1
                            add(res, name)
                        endif
                    endif
                endif
            endfor
        endfor

        # Добавляем теги из ctags
        try
            # Используем regex вместо glob
            var tag_pattern = base == '' ? '.*' : '^' .. base
            for t in taglist(tag_pattern)
                var name = t.name
                # Дополнительная фильтрация (taglist может вернуть лишнее)
                if base == '' || name =~ '^' .. base
                    if index(res, name) == -1
                        add(res, name)
                    endif
                endif
            endfor
        catch /E/
            # Логируем ошибку для отладки
            echohl ErrorMsg
            echom 'Ошибка taglist: ' .. v:exception
            echohl None
        endtry

        return res
    endif
enddef
