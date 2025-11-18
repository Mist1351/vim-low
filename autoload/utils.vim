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

