-- Colorscheme built from the active theme in ~/.cache/theme/nvim.lua.
-- The background stays transparent so the terminal's bg shows through.
local ok, c = pcall(dofile, vim.fn.expand("~/.cache/theme/nvim.lua"))
if not ok or type(c) ~= "table" then
    vim.cmd("colorscheme gruvbox")
    return
end

vim.cmd("highlight clear")
vim.g.colors_name = "theme"
vim.o.termguicolors = true

local function hl(group, spec) vim.api.nvim_set_hl(0, group, spec) end

local groups = {
    -- editor
    Normal = { fg = c.fg },
    NormalNC = { fg = c.fg },
    NormalFloat = { fg = c.fg, bg = c.bg1 },
    FloatBorder = { fg = c.line, bg = c.bg1 },
    FloatTitle = { fg = c.accent, bg = c.bg1, bold = true },
    Cursor = { fg = c.bg, bg = c.cursor },
    CursorLine = { bg = c.bg1 },
    CursorColumn = { bg = c.bg1 },
    ColorColumn = { bg = c.bg1 },
    LineNr = { fg = c.fg3 },
    CursorLineNr = { fg = c.accent, bold = true },
    SignColumn = {},
    FoldColumn = { fg = c.fg3 },
    Folded = { fg = c.fg2, bg = c.bg1 },
    VertSplit = { fg = c.line },
    WinSeparator = { fg = c.line },
    StatusLine = { fg = c.fg1, bg = c.bg1 },
    StatusLineNC = { fg = c.fg2, bg = c.bg },
    TabLine = { fg = c.fg2, bg = c.bg1 },
    TabLineFill = { bg = c.bg },
    TabLineSel = { fg = c.fg, bg = c.bg3, bold = true },
    Visual = { bg = c.bg3 },
    Search = { fg = c.bg, bg = c.accent },
    IncSearch = { fg = c.bg, bg = c.accent_light1 },
    CurSearch = { fg = c.bg, bg = c.accent_light1 },
    MatchParen = { fg = c.accent, bold = true },
    NonText = { fg = c.line },
    Whitespace = { fg = c.line },
    EndOfBuffer = { fg = c.bg },
    Pmenu = { fg = c.fg, bg = c.bg1 },
    PmenuSel = { fg = c.bg, bg = c.accent },
    PmenuSbar = { bg = c.bg2 },
    PmenuThumb = { bg = c.line },
    WildMenu = { fg = c.bg, bg = c.accent },
    Title = { fg = c.accent, bold = true },
    Directory = { fg = c.blue },
    ErrorMsg = { fg = c.red },
    WarningMsg = { fg = c.color3 },
    MoreMsg = { fg = c.green },
    ModeMsg = { fg = c.fg1 },
    Question = { fg = c.green },
    SpellBad = { sp = c.red, undercurl = true },
    SpellCap = { sp = c.color3, undercurl = true },

    -- syntax
    Comment = { fg = c.fg2, italic = true },
    Constant = { fg = c.color5 },
    String = { fg = c.color2 },
    Character = { fg = c.color2 },
    Number = { fg = c.color5 },
    Boolean = { fg = c.color5 },
    Float = { fg = c.color5 },
    Identifier = { fg = c.fg },
    Function = { fg = c.color4 },
    Statement = { fg = c.color1 },
    Keyword = { fg = c.color1 },
    Conditional = { fg = c.color1 },
    Repeat = { fg = c.color1 },
    Label = { fg = c.color1 },
    Exception = { fg = c.color1 },
    Operator = { fg = c.fg1 },
    PreProc = { fg = c.color6 },
    Include = { fg = c.color6 },
    Define = { fg = c.color6 },
    Macro = { fg = c.color6 },
    Type = { fg = c.color3 },
    StorageClass = { fg = c.color3 },
    Structure = { fg = c.color3 },
    Typedef = { fg = c.color3 },
    Special = { fg = c.accent },
    Delimiter = { fg = c.fg1 },
    Todo = { fg = c.bg, bg = c.accent, bold = true },
    Error = { fg = c.red },
    Underlined = { underline = true },

    -- treesitter
    ["@comment"] = { link = "Comment" },
    ["@string"] = { link = "String" },
    ["@number"] = { link = "Number" },
    ["@boolean"] = { link = "Boolean" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Constant" },
    ["@function"] = { link = "Function" },
    ["@function.call"] = { link = "Function" },
    ["@function.builtin"] = { link = "Function" },
    ["@method"] = { link = "Function" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.return"] = { link = "Keyword" },
    ["@conditional"] = { link = "Conditional" },
    ["@repeat"] = { link = "Repeat" },
    ["@operator"] = { link = "Operator" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@variable"] = { fg = c.fg },
    ["@variable.builtin"] = { fg = c.color5 },
    ["@property"] = { fg = c.fg },
    ["@field"] = { fg = c.fg },
    ["@parameter"] = { fg = c.fg },
    ["@punctuation"] = { link = "Delimiter" },
    ["@tag"] = { fg = c.color1 },
    ["@tag.attribute"] = { fg = c.color3 },
    ["@markup.heading"] = { link = "Title" },

    -- diagnostics
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.color3 },
    DiagnosticInfo = { fg = c.blue },
    DiagnosticHint = { fg = c.color6 },
    DiagnosticUnderlineError = { sp = c.red, undercurl = true },
    DiagnosticUnderlineWarn = { sp = c.color3, undercurl = true },
    DiagnosticUnderlineInfo = { sp = c.blue, undercurl = true },
    DiagnosticUnderlineHint = { sp = c.color6, undercurl = true },

    -- git
    DiffAdd = { fg = c.green },
    DiffChange = { fg = c.color3 },
    DiffDelete = { fg = c.red },
    DiffText = { fg = c.bg, bg = c.color3 },
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.color3 },
    GitSignsDelete = { fg = c.red },

    -- snacks
    SnacksNormal = { link = "NormalFloat" },
    SnacksPicker = { link = "NormalFloat" },
    SnacksPickerBorder = { link = "FloatBorder" },
    SnacksPickerMatch = { fg = c.accent, bold = true },
    SnacksPickerDir = { fg = c.fg2 },
}

for group, spec in pairs(groups) do hl(group, spec) end

for i = 0, 15 do vim.g["terminal_color_" .. i] = c["color" .. i] end
