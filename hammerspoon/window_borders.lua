local module = {}

local wf = hs.window.filter.defaultCurrentSpace
local active = false

local border = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
border:level(hs.canvas.windowLevels.floating)
border:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.transient)
border:clickActivating(false)
border:canvasMouseEvents(false, false, false, false)
border:appendElements({
  type = "rectangle",
  action = "stroke",
  strokeColor = { red = 1, green = 0.75, blue = 0.25, alpha = 0.8 },
  strokeWidth = 4,
  roundedRectRadii = { xRadius = 8, yRadius = 8 },
})

local events = {
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

function module.redraw()
  if not active then
    return
  end
  local win = hs.window.focusedWindow()
  local app = win and win:application()
  if not win or win:isFullScreen() or (app and app:name() == "Hammerspoon") then
    border:hide()
    return
  end
  border:frame(win:frame())
  border:show()
end

function module.start()
  if active then
    module.redraw()
    return
  end
  active = true
  wf:subscribe(events, module.redraw)
  module.redraw()
end

function module.stop()
  if not active then
    return
  end
  active = false
  wf:unsubscribe(events, module.redraw)
  border:hide()
end

return module
