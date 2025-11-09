vim9script

set background=light

hi clear
const colors_name = 'acme'

const c_none: dict<string> = {gui: 'NONE', cterm: 'NONE'}
const c_cursor: dict<string> = {gui: '#EEEEEE', cterm: '255'}
const c_fg: dict<string> = {gui: '#0E0E0D', cterm: '16'}
const c_fg_l: dict<string> = {gui: '#8E8E84', cterm: '102'}
const c_fg_d: dict<string> = {gui: '#7F7F77', cterm: '102'}
const c_bg: dict<string> = {gui: '#FFFFEA', cterm: '230'}
const c_bg_l: dict<string> = {gui: '#EEEE9E', cterm: '11'}
const c_bg_d: dict<string> = {gui: '#99994C', cterm: '100'}
const c_norm: dict<string> = {gui: '#EAFFFF', cterm: '195'}
const c_norm_l: dict<string> = {gui: '#CCCCBF', cterm: '252'}
const c_norm_d: dict<string> = {gui: '#8888CC', cterm: '104'}
const c_error: dict<string> = {gui: '#E54747', cterm: '196'}
const c_diff_add: dict<string> = {gui: '#2E8B57', cterm: '28'}
const c_diff_change: dict<string> = {gui: '#1E90FF', cterm: '32'}
const c_diff_delete: dict<string> = {gui: '#FF0000', cterm: '196'}
const c_diff_text: dict<string> = {gui: '#E2BB1B', cterm: '214'}
const c_special: dict<string> = {gui: '#D8D8C7', cterm: '188'}

const a_bold = 'bold'
const a_underline = 'underline'
const a_undercurl = 'undercurl'
const a_underdouble = 'underdouble'
const a_underdotted = 'underdotted'
const a_underdashed = 'underdashed'
const a_strikethrough = 'strikethrough'
const a_reverse = 'reverse'
const a_inverse = 'inverse'
const a_italic = 'italic'
const a_standout = 'standout'
const a_nocombine = 'nocombine'

def H(groupName: string, fg: dict<string>, bg: dict<string> = c_none, attrs: list<string> = []): void
    var attrs_value = len(attrs) > 0 ? join(attrs, ',') : 'NONE'
    execute 'highlight ' groupName
        \ 'guifg=' .. fg.gui
        \ 'guibg=' .. bg.gui
        \ 'ctermfg=' .. fg.cterm
        \ 'ctermbg=' .. bg.cterm
        \ 'gui=' .. attrs_value
        \ 'cterm=' .. attrs_value
enddef

hi! link Boolean Constant
hi! link Character Constant
hi! link Conditional Statement
hi! link CurSearch IncSearch
hi! link CursorLineFold FoldColumn
hi! link CursorLineSign SignColumn
hi! link Debug Special
hi! link Define PreProc
hi! link Delimiter Special
hi! link Exception Statement
hi! link Float Constant
hi! link Function Identifier
hi! link Include PreProc
hi! link Keyword Statement
hi! link Label Statement
hi! link Macro PreProc
hi! link MessageWindow WarningMsg
hi! link Number Constant
hi! link Operator Statement
hi! link PmenuKind Pmenu
hi! link PmenuKindSel PmenuSel
hi! link PmenuExtra Pmenu
hi! link PmenuExtraSel PmenuSel
hi! link PopupNotification WarningMsg
hi! link PopupSelected PmenuSel
hi! link PreCondit PreProc
hi! link QuickFixLine Search
hi! link Repeat Statement
hi! link SpecialChar Special
hi! link SpecialComment Special
hi! link StatusLineTerm StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link StorageClass Type
hi! link String Constant
hi! link Structure Type
hi! link Tag Special
hi! link Typedef Type
hi! link debugBreakpoint SignColumn
hi! link debugPC SignColumn

H('Normal', c_fg, c_bg)
H('ColorColumn', c_fg, c_bg_l)
H('Conceal', c_fg, c_none, [a_bold])
H('Cursor', c_fg, c_cursor)
H('lCursor', c_fg, c_cursor)
H('CursorIM', c_fg, c_cursor)
H('CursorColumn', c_fg, c_bg_l)
H('CursorLine', c_fg, c_bg_l)
H('Directory', c_norm_d, c_none)
H('DiffAdd', c_diff_add, c_bg, [a_bold, a_reverse])
H('DiffChange', c_diff_change, c_bg, [a_bold, a_reverse])
H('DiffDelete', c_diff_delete, c_bg, [a_bold, a_reverse])
H('DiffText', c_diff_text, c_fg, [a_bold, a_reverse])
H('EndOfBuffer', c_fg, c_bg, [a_bold])
H('ErrorMsg', c_bg, c_error)
H('VertSplit', c_fg, c_norm)
H('Folded', c_fg, c_norm, [a_italic])
H('FoldColumn', c_fg, c_norm_l)
H('SignColumn', c_fg, c_norm_l)
H('IncSearch', c_fg, c_norm)
H('LineNr', c_fg, c_bg)
H('LineNrBelow', c_fg, c_bg)
H('LineNrAbove', c_fg, c_bg)
H('CursorLineNr', c_fg, c_bg_l, [a_bold])
H('CursorLineFold', c_fg, c_bg_l, [a_bold])
H('CursorLineSign', c_fg, c_bg_l, [a_bold])
H('MatchParen', c_fg, c_norm_d, [a_bold])
H('MessageWindow', c_fg, c_norm)
H('ModeMsg', c_fg, c_bg)
H('MoreMsg', c_fg, c_bg)
H('NonText', c_fg, c_bg)
H('Pmenu', c_fg, c_bg_l)
H('PmenuSel', c_fg, c_bg_d, [a_bold])
H('PmenuSbar', c_fg, c_norm_d)
H('PmenuThumb', c_fg, c_norm)
H('Question', c_fg, c_bg, [a_bold])
H('QuickFixLine', c_fg, c_bg, [a_bold])
H('Search', c_fg, c_norm_l)
H('SpecialKey', c_special, c_none, [a_bold])
#H('SpellBad', c_yellow, c_bright_yellow)
#H('SpellCap', c_blue, c_bright_blue)
#H('SpellLocal', c_cyan, c_bright_cyan)
#H('SpellRare', c_black, c_bright_red)
H('StatusLine', c_fg, c_norm, [a_bold, a_underline])
H('StatusLineNC', c_fg, c_norm, [a_strikethrough, a_underline])
H('TabLine', c_bg, c_norm_d, [a_italic, a_underline])
H('TabLineFill', c_fg, c_norm, [a_underline])
H('TabLineSel', c_fg, c_bg, [a_bold, a_underline])
H('Terminal', c_fg, c_bg)
H('Title', c_fg, c_bg, [a_bold])
H('Visual', c_none, c_norm_l)
H('VisualNOS', c_none, c_norm_l)
H('WarningMsg', c_error, c_none)
H('WildMenu', c_bg, c_norm_d, [a_underline])
H('Comment', c_fg_l, c_bg, [a_italic])
H('Constant', c_fg, c_bg)
H('Identifier', c_fg, c_bg)
H('Statement', c_fg_d, c_bg, [a_bold])
H('PreProc', c_fg, c_bg)
H('Type', c_fg_d, c_bg, [a_bold])
H('Special', c_fg, c_bg)
H('Underlined', c_fg, c_bg, [a_underline])
H('Ignore', c_fg, c_none)
H('Error', c_fg, c_error)
H('Todo', c_fg, c_bg_l)
H('Added', c_diff_add, c_bg)
H('Changed', c_diff_change, c_bg)
H('Removed', c_diff_delete, c_bg)
H('ToolbarLine', c_fg, c_bg)
H('ToolbarButton', c_fg, c_bg)
