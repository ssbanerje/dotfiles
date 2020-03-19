----------------------------------------------------------------------------------------------------
-- Setup default parameters.
----------------------------------------------------------------------------------------------------
hs.logger.defaultLogLevel="info"
hs.window.animationDuration = 0
hs.grid.setGrid('6x4')
hs.grid.setMargins('0x0')


----------------------------------------------------------------------------------------------------
-- Setup watchers.
----------------------------------------------------------------------------------------------------
-- Watch for configuration changes
local config_watcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
  local doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
    hs.notify.new({title="Hammerspoon", informativeText="Hammerspoon configuration reloaded"}):send()
  end
end)
config_watcher:start()

-- Set volume to zero after sleep
local sleep_watcher = hs.caffeinate.watcher.new(function(eventType)
  if (eventType == hs.caffeinate.watcher.systemDidWake) then
    hs.audiodevice.defaultOutputDevice():setMuted(true)
  end
end)
sleep_watcher:start()

-- Wifi status watcher
local wifi_watcher = hs.wifi.watcher.new(function ()
  local currentWifi = hs.wifi.currentNetwork()
  if not currentWifi then return end
  hs.notify.new({title="Hammerspoon", informativeText="Wi-Fi connected to " .. currentWifi}):send()
end)
wifi_watcher:start()


----------------------------------------------------------------------------------------------------
-- Setup keyboard shortcuts.
----------------------------------------------------------------------------------------------------
hyper = {"ctrl","alt"}
hshelp_keys = {hyper, '/'}
hs.loadSpoon("ModalMgr")


----------------------------------------------------------------------------------------------------
-- Register Window Switcher.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind("alt", "tab", 'Show Window Hints', function()
	spoon.ModalMgr:deactivateAll()
	hs.hints.windowHints()
end)


----------------------------------------------------------------------------------------------------
-- Register Hammerspoon console.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, "c", "Toggle Hammerspoon Console", function()
	spoon.ModalMgr:deactivateAll()
	hs.toggleConsole()
end)


----------------------------------------------------------------------------------------------------
-- Register lock screen.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, "l", "Lock Screen", function()
	spoon.ModalMgr:deactivateAll()
	hs.caffeinate.lockScreen()
end)

----------------------------------------------------------------------------------------------------
-- Register window tiling.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr:new("window")
local window_modal = spoon.ModalMgr.modal_list["window"]
local box = nil
local text = nil
local rect = nil
local space_watcher = hs.spaces.watcher.new(function()
	spoon.ModalMgr:deactivate({"window"})
end)

-- Maximize window.
window_modal:bind('', 'm', 'Maximize', function()
  hs.grid.maximizeWindow()
end)

spoon.ModalMgr.supervisor:bind(hyper, 'm', 'Maximize window', function()
	hs.grid.maximizeWindow()
end)

-- Screen positons.
local positions = {
  left = {{0, 0, 0.5, 1}, "Halves - L"},
  up = {{0, 0, 1, 0.5}, "Halves - T"},
  right = {{0.5, 0, 0.5, 1}, "Halves - R"},
  down = {{0, 0.5, 1, 0.5}, "Halves - L"},
  r = {{0, 0, 0.5, 0.5}, "Quarters - TR"},
  t = {{0.5, 0, 0.5, 0.5}, "Quarters - TL"},
  g = {{0.5, 0.5, 0.5, 0.5}, "Quarters - BR"},
  f = {{0, 0.5, 0.5, 0.5}, "Quarters - BL"},
  q = {{0, 0, 0.33333, 1}, "Thirds - L"},
  w = {{0.33333, 0, 0.33333, 1}, "Thirds - M"},
  e = {{0.66666, 0, 0.33333, 1}, "Thirds - R"},
  v = {{0, 0, 0.66666, 1}, "Two Thirds - L"},
  a = {{0, 0, 0.33333, 0.5}, "Sixths - TL"},
  s = {{0.33333, 0, 0.33333, 0.5}, "Sixths - TM"},
  d = {{0.66666, 0, 0.33333, 0.5}, "Sixths - TR"},
  z = {{0, 0.5, 0.33333, 0.5}, "Sixths - BL"},
  x = {{0.33333, 0.5, 0.33333, 0.5}, "Sixths - BM"},
  c = {{0.66666, 0.5, 0.33333, 0.5}, "Sixths - BR"},
}

for k,v in pairs(positions) do
  window_modal:bind({}, k, v[2], function()
    local window = hs.window.focusedWindow()
    if not window then return end
    window:move(v[1])
  end)
end

-- Grid.
window_modal:bind('', '\\', 'Toggle grid', function()
	hs.grid.show()
end)

-- Cascade windows.
window_modal:bind('', ',', 'Cascade windows', function()
  local cascadeSpacing = 40
  local windows = hs.window.orderedWindows()
  local screen = windows[1]:screen():frame()
  local nOfSpaces = #windows - 1
  local xMargin = screen.w / 10
  local yMargin = 20
  for i, win in ipairs(windows) do
    local offset = (i - 1) * cascadeSpacing
    local rect = {
      x = xMargin + offset,
      y = screen.y + yMargin + offset,
      w = screen.w - (2 * xMargin) - (nOfSpaces * cascadeSpacing),
      h = screen.h - (2 * yMargin) - (nOfSpaces * cascadeSpacing),
    }
    win:setFrame(rect)
  end
end)

-- Move windows
window_modal:bind('', 'h', 'Move window left', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - 10
  win:setFrame(f)
end)

window_modal:bind('', 'j', 'Move window down', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y + 10
  win:setFrame(f)
end)

window_modal:bind('', 'k', 'Move window up', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y - 10
  win:setFrame(f)
end)

window_modal:bind('', 'l', 'Move window right', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + 10
  win:setFrame(f)
end)

-- Shrink windows.
window_modal:bind('ctrl', 'h', 'Shrink window left', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + 10
  f.w = f.w - 10
  win:setFrame(f)
end)

window_modal:bind('ctrl', 'j', 'Shrink window down', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.h = f.h - 10
  win:setFrame(f)
end)

window_modal:bind('ctrl', 'k', 'Shrink window up', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y + 10
  f.h = f.h - 10
  win:setFrame(f)
end)

window_modal:bind('ctrl', 'l', 'Shrink window right', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.w = f.w - 10
  win:setFrame(f)
end)

-- Grow windows
window_modal:bind('shift', 'h', 'Grow window left', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - 10
  f.w = f.w + 10
  win:setFrame(f)
end)

window_modal:bind('shift', 'j', 'Grow window down', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.h = f.h + 10
  win:setFrame(f)
end)

window_modal:bind('shift', 'k', 'Grow window up', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y - 10
  f.h = f.h + 10
  win:setFrame(f)
end)

window_modal:bind('shift', 'l', 'Grow window right', function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.w = f.w + 10
  win:setFrame(f)
end)

-- Toggle help.
window_modal:bind('', '/', 'Toggle cheatsheet', function()
	spoon.ModalMgr:toggleCheatsheet()
end)

-- Enter window modal.
spoon.ModalMgr.supervisor:bind(hyper, 'w', 'Enter Window Tiling Mode', function()
	spoon.ModalMgr:deactivateAll()
  local res = hs.window.focusedWindow():screen():frame()
  box = hs.geometry.rect((res.w-600)/2, (res.h-160)/2, 600, 160)
  rect = hs.drawing.rectangle(box)
  text = hs.drawing.text(box, "Tiling Mode")
  rect:setLevel("overlay")
  rect:setFillColor({white = 0.125, alpha = 0.8})
  rect:setFill(true)
  rect:setStrokeColor({white = 0.625, alpha = 0.8})
  rect:setStrokeWidth(1)
  rect:setStroke(true)
  rect:setRoundedRectRadii(4, 4)
  text:setLevel("overlay")
  text:setTextSize(120)
  text:setTextStyle({alignment = "center"})
  rect:show()
  text:show()
  space_watcher:start()
	spoon.ModalMgr:activate({"window"}, "#FFBD2E")
end)

-- Exit window modal.
window_modal:bind('', 'escape', 'Exit', function()
	spoon.ModalMgr:deactivate({"window"})
end)

window_modal.exited = function()
    text:delete()
    rect:delete()
    space_watcher:stop()
end


----------------------------------------------------------------------------------------------------
-- Initialize the modal supervisor
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:enter()
