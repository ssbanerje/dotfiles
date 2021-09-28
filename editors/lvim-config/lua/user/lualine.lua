local components = require("core.lualine.components")

-- Helper functions {{{

-- Setup colors for lualine sections
local function lualine_color(section)
	return function(mode)
		return function(color)
			-- Set mode
			if type(mode) == "string" then
				if mode == "all" then
					mode = { "normal", "command", "replace", "visual" }
				else
					mode = { mode }
				end
			end

			-- Set color
			for _, m in pairs(mode) do
				lvim.builtin.lualine.options.theme[m][section] = color
			end
		end
	end
end

-- Setup contents of lualine sections
local function lualine(section)
	return function(config)
		local cfg = {}
		local cfg_in = {}
		for _, v in pairs(config) do
			-- Clean components
			if type(v[1]) == "string" and v[1]:find("components.", 1, true) == 1 then
				local a = v.active
				local i = v.inactive
				v = vim.deepcopy(components[string.sub(v[1], #"components." + 1)])
				v["active"] = a
				v["inactive"] = i
			end

			-- Load active
			if v.active == nil or v.active then
				table.insert(cfg, v)
			end

			-- Load inactive
			if v.inactive then
				table.insert(cfg_in, v)
			end
		end
		lvim.builtin.lualine.sections["lualine_" .. section] = cfg
		lvim.builtin.lualine.inactive_sections["lualine_" .. section] = cfg_in
	end
end

-- }}}

components.location.icon = ""

lvim.builtin.lualine.options.section_separators = { left = "", right = "" }
lvim.builtin.lualine.options.component_separators = { left = "", right = "" }

lvim.builtin.lualine.options.theme = require("lualine.themes.onedarker")

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

lualine_color "a" "normal" { fg = colors.black, bg = colors.blue, gui = "bold" }
lualine_color "a" "insert" { fg = colors.black, bg = colors.green, gui = "bold" }
lualine_color "a" "visual" { fg = colors.black, bg = colors.orange, gui = "bold" }
lualine_color "a" "replace" { fg = colors.black, bg = colors.magenta, gui = "bold" }
lualine_color "a" "command" { fg = colors.black, bg = colors.red, gui = "bold" }
lualine_color "b" "all" { bg = colors.gray }
lualine_color "a" "inactive" { fg = colors.black, bg = colors.violet, gui = "bold" }
lualine_color "b" "inactive" { fg = colors.violet, bg = colors.black }
lualine_color "c" "inactive" { fg = colors.violet, bg = colors.black }

lualine "a" {
	"mode",
	{
		function()
			return vim.fn.winnr()
		end,
		inactive = true,
	},
}
lualine "b" {
  { "components.filename", inactive = true },
  { "components.branch", inactive = true },
}
lualine "c" {}
components.treesitter.cond = require("core.lualine.conditions").hide_in_width
components.lsp.cond = require("core.lualine.conditions").hide_in_width
lualine "x" {
  components.diff,
  components.diagnostics,
  -- components.lsp
}
lualine "y" {
	components.filetype,
  components.treesitter,
	"fileformat",
	components.encoding,
	{ "components.location", active = false, inactive = true },
	{ "progress", active = false, inactive = true },
}
lualine "z" { components.location, "progress" }

-- vim:set fdm=marker:
