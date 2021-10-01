lvim.builtin.lualine.options.section_separators = { left = "", right = "" }

lvim.builtin.lualine.options.component_separators = { left = "", right = "" }

-- Setup Colors {{{

lvim.builtin.lualine.options.theme = require("lualine.themes.onedarker")

-- Set colorscheme for a lualine section
local function lualine_color(section)
  return function(config)
    for mode, cfg in pairs(config) do
      for _, m in pairs(mode == "all" and { "normal", "command", "replace", "visual" } or { mode }) do
        lvim.builtin.lualine.options.theme[m][section] = cfg
      end
    end
  end
end

local colors = {
  black = "#000000",
  white = "#FFFFFF",
  gray = "#3d3d3d",
  blue = "#51AFEF",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#98BE65",
  magenta = "#C678DD",
  orange = "#FF8800",
  red = "#EC5F67",
  violet = "#A9A1E1",
  yellow = "#ECBE7B",
}

-- Lualine colors

lualine_color "a" {
  normal = { fg = colors.black, bg = colors.blue, gui = "bold" },
  insert = { fg = colors.black, bg = colors.green, gui = "bold" },
  visual = { fg = colors.black, bg = colors.orange, gui = "bold" },
  replace = { fg = colors.black, bg = colors.magenta, gui = "bold" },
  command = { fg = colors.black, bg = colors.red, gui = "bold" },
  inactive = { fg = colors.black, bg = colors.violet, gui = "bold" },
}

lualine_color "b" {
  all = { bg = colors.gray },
  inactive = { fg = colors.violet, bg = colors.black },
}

lualine_color "c" {
  inactive = { fg = colors.violet, bg = colors.black }
}

-- }}}

-- Setup Sections {{{

-- Setup contents of lualine sections
local function lualine(section)
  return function(config)
    local cfg_active = {}
    local cfg_inactive = {}
    for _, v in pairs(config) do
      if v.active == nil or v.active then
        table.insert(cfg_active, v)
      end
      if v.inactive then
        table.insert(cfg_inactive, v)
      end
    end
    lvim.builtin.lualine.sections["lualine_" .. section] = cfg_active
    lvim.builtin.lualine.inactive_sections["lualine_" .. section] = cfg_inactive
  end
end

local function resize_condition(size)
  return function()
    return vim.fn.winwidth(0) > size
  end
end

-- Setup components
local components = require("core.lualine.components")
components.diagnostics.cond = nil
components.diff.cond = nil
components.lsp.cond = resize_condition(120)
components.spaces.cond = resize_condition(120)
components.treesitter.cond = resize_condition(120)

-- Section A
lualine "a" {
  { "mode", icon = "" },
  { function() return vim.fn.winnr() end, icon = "", inactive = true },
}

-- Section B
lualine "b" {
  { "filename", color = {}, inactive = true },
  { "b:gitsigns_head", icon = "", color = {}, cond = resize_condition(80), inactive = true },
}

-- Section C
lualine "c" {
  components.diff,
}

-- Section X
lualine "x" {
  components.diagnostics,
  components.treesitter,
  components.lsp
}

-- Section Y
lualine "y" {
  { "filetype", color = {}, cond = resize_condition(80) },
  { "fileformat", color = { gui = "bold" }, cond = resize_condition(120) },
  { "o:encoding", fmt = string.upper, color = {}, cond = resize_condition(120) },
  components.spaces,

  -- Inactive sections
  { "location", icon = "", color = {}, active = false, inactive = true },
  { "progress", icon = "𥳐" , color = {}, active = false, inactive = true },
}

-- Section Z
lualine "z" {
  { "location", icon = "", color = {} },
  { "progress", icon = "𥳐" , color = {}, cond = resize_condition(80) },
}

lvim.builtin.lualine.extensions = {
  -- Quickfix
  {
    sections = {
      lualine_a = {
        { function() return vim.fn.winnr() end, icon = "", inactive = true },
      },
      lualine_b = {
        function()
          return vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0 and
            vim.fn.getloclist(0, { title = 0 }).title or
            vim.fn.getqflist({ title = 0 }).title
        end,
      },
      lualine_y = {
        {
          function()
            return " " .. (vim.fn.getloclist(0, { filewinid = 1 }).filewinid ~= 0 and "Loc List" or "QF List")
          end,
          color = { gui = "bold" },
        }
      }
    },
    filetypes = { "qf" },
    init = function() vim.g.qf_disable_statusline = true end
  },
}

-- }}}

-- vim:set fdm=marker:
