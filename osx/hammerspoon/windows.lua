-- Disable animation
hs.window.animationDuration = 0

-- Lock Screen
hs.hotkey.bind(hyper, 'l', hs.caffeinate.lockScreen)

-- Setup grid
hs.grid.setGrid('6x4')
hs.grid.setMargins('0x0')

-- Modals
local binding = hs.hotkey.modal.new({"shift"}, "escape", "Starting tiling mode...")
local spaceWatcher = hs.spaces.watcher.new(function()
  binding:exit()
  spaceWatcher:stop()
end)

-- Entry into state machine
binding.entered = function()
  if hs.window.focusedWindow():isFullScreen() then
    binding:exit()
    return
  end
  spaceWatcher:start()
end

-- Grid functions
binding:bind({}, "t", "Show grid", function()
  hs.grid.show()
end)

-- Maximize window
hs.hotkey.bind('cmd', 'm', hs.grid.maximizeWindow)

binding:bind({}, "m", "Maximize", function()
  hs.grid.maximizeWindow()
end)

-- Screen positions
local positions = {
  left = {{0, 0, 0.5, 1}, "Halves - L"},
  up = {{0, 0, 1, 0.5}, "Halves - T"},
  right = {{0.5, 0, 0.5, 1}, "Halves - R"},
  down = {{0, 0.5, 1, 0.5}, "Halves - L"},
  u = {{0, 0, 0.5, 0.5}, "Quarters - TR"},
  i = {{0.5, 0, 0.5, 0.5}, "Quarters - TL"},
  k = {{0.5, 0.5, 0.5, 0.5}, "Quarters - BR"},
  j = {{0, 0.5, 0.5, 0.5}, "Quarters - BL"},
  q = {{0, 0, 0.33333, 1}, "Thirds - L"},
  w = {{0.33333, 0, 0.33333, 1}, "Thirds - M"},
  e = {{0.66666, 0, 0.33333, 1}, "Thirds - R"},
  a = {{0, 0, 0.66666, 1}, "Two Thirds - L"},
  d = {{0, 0, 0.33333, 0.5}, "Sixths - TL"},
  f = {{0.33333, 0, 0.33333, 0.5}, "Sixths - TM"},
  g = {{0.66666, 0, 0.33333, 0.5}, "Sixths - TR"},
  c = {{0, 0.5, 0.33333, 0.5}, "Sixths - BL"},
  v = {{0.33333, 0.5, 0.33333, 0.5}, "Sixths - BM"},
  b = {{0.66666, 0.5, 0.33333, 0.5}, "Sixths - BR"},
}

-- Set keybindings
for k,v in pairs(positions) do
  binding:bind({}, k, v[2], function()
    local window = hs.window.focusedWindow()
    if not window then return end
    window:move(v[1])
  end)
end

local cycle = coroutine.create(function()
  local keys = {}
  local n = 0
  for k, _ in pairs(positions) do
    n = n + 1
    keys[n] = k
  end
  while true do
    for i = 1, #keys do
      coroutine.yield(positions[keys[i]][1])
    end
  end
end)

binding:bind({}, 'space', "Cycle configurations", function()
  local _, pos = coroutine.resume(cycle)
  local window  = hs.window.focusedWindow()
  if not window then return end
  window:move(pos)
end)

-- Exit criteria
binding:bind({}, "escape", nil, function()
  binding:exit()
end)

binding.exited = function()
  hs.alert.show("Exiting tiling mode")
  spaceWatcher:stop()
end
