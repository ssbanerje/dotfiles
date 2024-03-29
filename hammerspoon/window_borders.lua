local module = {}
module.__index = module

-- Graphics object for drawing borders
module.border = nil

-- Colors used for stroking windows
module.stroke_color_src = { red = 1, blue = 0.25, green = 0.75, alpha = 0.8 }
module.stroke_color_tgt = { red = 1, blue = 0.25, green = 0.75, alpha = 0.8 }

-- Handlers listening for window events
module.handler = nil
module.events = {
  hs.window.filter.windowCreated,
  hs.window.filter.windowDestroyed,
  hs.window.filter.windowFocused,
  hs.window.filter.windowHidden,
  hs.window.filter.windowMinimized,
  hs.window.filter.windowMoved,
  hs.window.filter.windowUnfocused,
  hs.window.filter.windowUnhidden,
  hs.window.filter.windowUnminimized,
}

-- Start drawing borders
function module.start()
  module.handler = hs.window.filter.new()
  module.handler.setLogLevel(hs.logger.defaultLogLevel)
  module.handler:setDefaultFilter({})
  module.handler:setSortOrder(hs.window.filter.sortByFocusedLast)
  for _, e in ipairs(module.events) do
    module.handler:subscribe(e, module.redraw)
  end
  module.redraw()
end

-- Stop drawing borders
function module.stop()
  if module.handler then
    for _, e in ipairs(module.events) do
      module.handler:unsubscribe(e)
    end
    module.handler = nil
  end
  if module.border then
    module.border:hide()
    module.border = nil
  end
end

-- Draw borders around window
function module.redraw()
  if module.border ~= nil then
    module.border:delete()
    module.border = nil
  end
  local win = hs.window.focusedWindow()
  if win == nil or win:isFullScreen() or win:application():name() == "Hammerspoon" then
    return
  end
  local winframe = win:frame()
  local max = win:screen():frame()
  module.border = hs.canvas.new({ x = max.x, y = max.y, w = max.w, h = max.h })
  module.border
    :appendElements({
      type = "rectangle",
      action = "stroke",
      strokeColor = { red = 1, blue = 0.25, green = 0.75, alpha = 0.8 },
      strokeWidth = 4,
      frame = { x = winframe.x, y = winframe.y - max.y, w = winframe.w, h = winframe.h },
    })
    :show()
end

return module
