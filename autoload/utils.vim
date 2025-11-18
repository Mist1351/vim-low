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

# Функция для поиска файла .editorconfig вверх по директориям
def FindEditorConfig(filepath: string): list<string>
    var configs: list<string> = []
    var dir = fnamemodify(filepath, ':p:h')
    
    while dir != '/' && dir != ''
        var config = dir .. '/.editorconfig'
        if filereadable(config)
            add(configs, config)
            var lines = readfile(config)
            for line in lines
                if line =~ '^\s*root\s*=\s*true'
                    return configs
                endif
            endfor
        endif
        var parent = fnamemodify(dir, ':h')
        if parent == dir
            break
        endif
        dir = parent
    endwhile
    
    return configs
enddef

# Вспомогательная функция для {num1..num2}
def MatchRange(start: string, end: string): string
    var result = '\\('
    for i in range(str2nr(start), str2nr(end))
        if i > str2nr(start)
            result ..= '\\|'
        endif
        result ..= string(i)
    endfor
    result ..= '\\)'
    return result
enddef

# Вспомогательная функция для {opt1,opt2}
def MatchChoices(choices: string): string
    var opts = split(choices, ',')
    var escaped_opts: list<string> = []
    for opt in opts
        add(escaped_opts, substitute(opt, '\.', '\\.', 'g'))
    endfor
    return '\\(' .. join(escaped_opts, '\\|') .. '\\)'
enddef

# Функция для проверки соответствия glob паттерна
def MatchGlob(pattern: string, path: string): bool
    var regex = pattern
   
    # Обработка {num1..num2} ДО экранирования
    while regex =~ '{\d\+\.\.\d\+}'
        regex = substitute(regex, '{\(\d\+\)\.\.\(\d\+\)}', '\=MatchRange(submatch(1), submatch(2))', '')
    endwhile
    
    # Обработка {opt1,opt2,opt3} ДО экранирования
    while regex =~ '{[^}]\+}'
        regex = substitute(regex, '{\([^}]\+\)}', '\=MatchChoices(submatch(1))', '')
    endwhile
    
    # Экранируем специальные символы regex
    regex = substitute(regex, '\.', '\\.', 'g')
    regex = substitute(regex, '+', '\\+', 'g')
    regex = substitute(regex, '\^', '\\^', 'g')
    regex = substitute(regex, '\$', '\\$', 'g')
    regex = substitute(regex, '\[', '\\[', 'g')
    regex = substitute(regex, '\]', '\\]', 'g')

    # Преобразуем glob паттерны в regex
    # Сначала обрабатываем **/ (может пересекать директории)
    regex = substitute(regex, '\*\*/', '\.\{-}/', 'g')
    # Затем оставшиеся ** (в конце или середине пути)
    regex = substitute(regex, '\*\*', '\.\*', 'g')
    # Обычные * (не пересекают /)
    regex = substitute(regex, '\*', '[^/]\*', 'g')
    # ? - один любой символ кроме /
    regex = substitute(regex, '?', '[^/]', 'g')
    
    # Если паттерн не начинается с /, он может совпадать в любой части пути
    if regex[0] != '/'
        regex = '\(^\|/\)' .. regex
    else
        regex = '^' .. regex
    endif
    
    regex = regex .. '$'
    
    return path =~ regex
enddef

# Основная функция для парсинга и применения .editorconfig
export def ApplyEditorConfig()
    var filepath = expand('%:p')
    
    if filepath == '' || !filereadable(filepath)
        return
    endif
    
    var configs = FindEditorConfig(filepath)
    
    if empty(configs)
        return
    endif
    
    var relative_path = fnamemodify(filepath, ':.')
    var properties: dict<string> = {}
    
    # Читаем конфиги от корневого к текущему
    for config in reverse(copy(configs))
        var lines = readfile(config)
        var current_section = ''
        var in_matching_section = false
        
        for line in lines
            var trimmed = trim(line)
            
            # Пропускаем комментарии и пустые строки
            if trimmed == '' || trimmed[0] == '#' || trimmed[0] == ';'
                continue
            endif
            
            # Проверяем секцию [pattern]
            if trimmed =~ '^\[.*\]$'
                current_section = substitute(trimmed, '^\[\(.*\)\]$', '\1', '')
                in_matching_section = MatchGlob(current_section, relative_path)
                continue
            endif
            
            # Если мы в подходящей секции, парсим свойства
            if in_matching_section && trimmed =~ '='
                var parts = split(trimmed, '=')
                if len(parts) >= 2
                    var key = trim(parts[0])
                    var value = trim(join(parts[1 :], '='))
                    properties[key] = value
                endif
            endif
        endfor
    endfor
    
    # Применяем свойства
    if has_key(properties, 'indent_style')
        if properties['indent_style'] == 'tab'
            setlocal noexpandtab
        elseif properties['indent_style'] == 'space'
            setlocal expandtab
        endif
    endif
    
    if has_key(properties, 'indent_size')
        var size = str2nr(properties['indent_size'])
        if size > 0
            execute 'setlocal shiftwidth=' .. size
            execute 'setlocal softtabstop=' .. size
            if properties->get('indent_style', '') == 'space'
                execute 'setlocal tabstop=' .. size
            endif
        endif
    endif
    
    if has_key(properties, 'tab_width')
        var width = str2nr(properties['tab_width'])
        if width > 0
            execute 'setlocal tabstop=' .. width
        endif
    endif
    
    if has_key(properties, 'end_of_line')
        if properties['end_of_line'] == 'lf'
            setlocal fileformat=unix
        elseif properties['end_of_line'] == 'crlf'
            setlocal fileformat=dos
        elseif properties['end_of_line'] == 'cr'
            setlocal fileformat=mac
        endif
    endif
    
    if has_key(properties, 'charset')
        var charset = properties['charset']
        if charset == 'utf-8'
            setlocal fileencoding=utf-8
        elseif charset == 'utf-8-bom'
            setlocal fileencoding=utf-8
            setlocal bomb
        elseif charset == 'latin1'
            setlocal fileencoding=latin1
        endif
    endif
    
    if has_key(properties, 'trim_trailing_whitespace')
        if properties['trim_trailing_whitespace'] == 'true'
            augroup EditorConfigTrimWhitespace
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> :%s/\s\+$//e
            augroup END
        endif
    endif
    
    if has_key(properties, 'insert_final_newline')
        if properties['insert_final_newline'] == 'true'
            setlocal fixendofline
        elseif properties['insert_final_newline'] == 'false'
            setlocal nofixendofline
        endif
    endif
    
    if has_key(properties, 'max_line_length')
        var length = str2nr(properties['max_line_length'])
        if length > 0
            execute 'setlocal textwidth=' .. length
        endif
    endif
enddef
