---@class Chadracula
---@field config ChadraculaConfig
---@field palette ChadraculaPalette
local Chadracula = {}

---@alias Contrast "hard" | "soft" | ""

---@class ItalicConfig
---@field strings boolean
---@field comments boolean
---@field operators boolean
---@field folds boolean
---@field emphasis boolean

---@class HighlightDefinition
---@field fg string?
---@field bg string?
---@field sp string?
---@field blend integer?
---@field bold boolean?
---@field standout boolean?
---@field underline boolean?
---@field undercurl boolean?
---@field underdouble boolean?
---@field underdotted boolean?
---@field strikethrough boolean?
---@field italic boolean?
---@field reverse boolean?
---@field nocombine boolean?

---@class ChadraculaConfig
---@field terminal_colors boolean?
---@field undercurl boolean?
---@field underline boolean?
---@field bold boolean?
---@field italic ItalicConfig?
---@field strikethrough boolean?
---@field contrast Contrast?
---@field invert_selection boolean?
---@field invert_signs boolean?
---@field invert_tabline boolean?
---@field invert_intend_guides boolean?
---@field inverse boolean?
---@field overrides table<string, HighlightDefinition>?
---@field palette_overrides table<string, string>?
Chadracula.config = {
  terminal_colors = true,
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true,
  contrast = "",
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
}

-- Define the color palette
---@class ChadraculaPalette
Chadracula.palette = {
  white = "#F8F8F2",
  darker_black = "#19192c",
  black = "#141423",
  black2 = "#1c1c31",
  one_bg = "#23233d",
  one_bg2 = "#2b2b4c",
  one_bg3 = "#373760",
  grey = "#414171",
  grey_fg = "#4b4b83",
  grey_fg2 = "#555594",
  light_grey = "#6060a4",
  red = "#FF5555",
  baby_pink = "#FF6E6E",
  pink = "#FF6BCB",
  line = "#2D2D4E",
  green = "#50FA7B",
  vibrant_green = "#20E3B2",
  nord_blue = "#05C3FF",
  blue = "#2CCCFF",
  yellow = "#F1FA8C",
  sun = "#F2FA95",
  purple = "#BD93F9",
  dark_purple = "#a166f6",
  teal = "#92A2D4",
  orange = "#FFB86C",
  cyan = "#2CCCFF",
  statusline_bg = "#19192c",
  lightbg = "#2b2b4c",
  pmenu_bg = "#9A86FD",
  folder_bg = "#9A86FD",
  violet = "#9A86FD",
  darkgreen = "#1B312E",
  brownred = "#5D2932",
}

-- Function to get colors based on config
local function get_colors()
  local p = Chadracula.palette
  local config = Chadracula.config

  for color, hex in pairs(config.palette_overrides) do
    p[color] = hex
  end

  local bg = vim.o.background
  local contrast = config.contrast

  local color_groups = {
    dark = {
      bg0 = p.black,
      bg1 = p.one_bg,
      bg2 = p.one_bg2,
      bg3 = p.one_bg3,
      bg4 = p.grey,
      fg0 = p.white,
      fg1 = p.white,
      fg2 = p.grey_fg,
      fg3 = p.grey_fg2,
      fg4 = p.light_grey,
      red = p.red,
      green = p.green,
      yellow = p.yellow,
      blue = p.blue,
      purple = p.purple,
      aqua = p.teal,
      orange = p.orange,
      gray = p.grey,
    },
  }

  if contrast ~= nil and contrast ~= "" then
    color_groups[bg].bg0 = p[bg .. "0_" .. contrast]
  end

  return color_groups[bg]
end

-- Define highlight groups
local function get_groups()
  local colors = get_colors()
  local config = Chadracula.config

  -- Terminal colors setup
  if config.terminal_colors then
    local term_colors = {
      colors.bg0,
      colors.red,
      colors.green,
      colors.yellow,
      colors.blue,
      colors.purple,
      colors.aqua,
      colors.fg4,
      colors.gray,
      colors.red,
      colors.green,
      colors.yellow,
      colors.blue,
      colors.purple,
      colors.aqua,
      colors.fg1,
    }
    for index, value in ipairs(term_colors) do
      vim.g["terminal_color_" .. index - 1] = value
    end
  end

  local groups = {
    Normal = config.transparent_mode and { fg = colors.fg1, bg = nil } or { fg = colors.fg1, bg = colors.bg0 },
    Comment = { fg = colors.grey, italic = config.italic.comments },
    Constant = { fg = colors.purple },
    String = { fg = colors.orange, italic = config.italic.strings },
    Character = { fg = colors.purple },
    Number = { fg = colors.purple },
    Boolean = { fg = colors.purple },
    Float = { fg = colors.purple },
    Identifier = { fg = colors.white },
    Function = { fg = colors.vibrant_green },
    Statement = { fg = colors.pink },
    Conditional = { fg = colors.pink },
    Repeat = { fg = colors.pink },
    Label = { fg = colors.pink },
    Operator = { fg = colors.orange, italic = config.italic.operators },
    Keyword = { fg = colors.pink },
    Exception = { fg = colors.pink },
    PreProc = { fg = colors.teal },
    Include = { fg = colors.teal },
    Define = { fg = colors.teal },
    Macro = { fg = colors.teal },
    PreCondit = { fg = colors.teal },
    Type = { fg = colors.blue },
    StorageClass = { fg = colors.orange },
    Structure = { fg = colors.teal },
    Typedef = { fg = colors.blue },
    Special = { fg = colors.pink },
    Underlined = { fg = colors.blue, underline = config.underline },
    Error = { fg = colors.red, bold = config.bold },
    Todo = { fg = colors.bg0, bg = colors.yellow, bold = config.bold, italic = config.italic.comments },
    -- Add more highlight groups as needed
  }

  -- Apply user overrides
  for group, hl in pairs(config.overrides) do
    if groups[group] then
      groups[group].link = nil
    end
    groups[group] = vim.tbl_extend("force", groups[group] or {}, hl)
  end

  return groups
end

---@param config ChadraculaConfig?
Chadracula.setup = function(config)
  Chadracula.config = vim.tbl_deep_extend("force", Chadracula.config, config or {})
end

--- Load the theme
Chadracula.load = function()
  if vim.version().minor < 8 then
    vim.notify_once("chadracula.nvim: you must use neovim 0.8 or higher")
    return
  end

  -- Reset colors
  if vim.g.colors_name then
    vim.cmd.hi("clear")
  end
  vim.g.colors_name = "chadracula"
  vim.o.termguicolors = true

  local groups = get_groups()

  -- Add highlights
  for group, settings in pairs(groups) do
    vim.api.nvim_set_hl(0, group, settings)
  end
end

return Chadracula
