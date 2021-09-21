-- Remaping Keys {{{

-- Replicate the vim nnoremap command
local function nnoremap(key)
	return function(mapping)
		lvim.keys.normal_mode[key] = mapping
	end
end

-- Replicate the vim vnoremap data
local function vnoremap(key)
	return function(mapping)
		lvim.keys.visual_mode[key] = mapping
	end
end

-- Internal function set or update which_key mappings
local function _which_key(key, ty)
	if type(key) ~= "string" then
		key = tostring(key)
	end
	return function(mapping)
		if lvim.builtin.which_key[ty][key] == nil then
			lvim.builtin.which_key[ty][key] = mapping
		else
			for k, v in pairs(mapping) do
				lvim.builtin.which_key[ty][key][k] = v
			end
		end
	end
end

-- Install or update which_key normal mode mappings
local function which_key(key)
	return _which_key(key, "mappings")
end

-- Install or update which_key visual mode mappings
local function which_vkey(key)
	return _which_key(key, "vmappings")
end

-- }}}

-- Lualine {{{

local components = require("core.lualine.components")

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
				v = components[string.sub(v[1], #"components." + 1)]
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

return {
	key = {
		nnoremap = nnoremap,
		vnoremap = vnoremap,
		which_key = which_key,
		which_vkey = which_vkey,
	},
	statusline = {
		lualine = lualine,
		lualine_color = lualine_color,
	},
}

-- vim:set fdm=marker:
