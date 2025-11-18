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
