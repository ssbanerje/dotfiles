lvim.builtin.dashboard.active = true

-- Setup customs sections in the dashboard plugin.
-- TODO FIXME `bin_len` and `padding` needs to be made UTF8 safe
local function custom_section(key)
  return function(desc)
    return function(cmd)
      -- Calculate padding
      local bin_len = #lvim.builtin.dashboard.custom_section.a.description[1]
      local padding = bin_len - #desc

      -- Change descriptions
      if padding > 0 then
        desc = desc .. string.rep(" ", padding)
      elseif padding < 0 then
        padding = padding * -1
        for _, v in pairs(lvim.dashboard.custom_section) do
          v.description = v.description .. string.rep(" ", padding)
        end
      end

      -- Add command
      lvim.builtin.dashboard.custom_section[key] = {
        description = { desc },
        command = cmd,
      }
    end
  end
end

custom_section "d1" "  Marks" "Telescope marks"
