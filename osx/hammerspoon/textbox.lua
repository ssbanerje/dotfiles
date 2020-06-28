local window = require('hs.window')
local canvas = require('hs.canvas')

local module = {}
module.box = nil

module.show = function(message)
  canvas.enableScreenUpdates()
  if module.box ~= nil then
    module.box[2]['text'] = message
  else
    local res = window.focusedWindow():screen():frame()
    module.box = canvas.new({
      x = (res.w - 650)/2,
      y = (res.h - 160)/2,
      w = 650,
      h = 160,
    })
    module.box[1] = {
      type = "rectangle",
      fillColor = {white = 0.125, alpha = 0.8},
      strokeColor = {white = 0.625, alpha = 0.8},
      strokeWidth = 1,
    }
    module.box[2] = {
      type = "text",
      text = message,
      textSize = 120,
      textAlignment = "center",
    }
    module.box:show()
  end
end

module.hide = function()
  if module.box ~= nil then
    module.box:delete()
    module.box = nil
  end
end

return module

