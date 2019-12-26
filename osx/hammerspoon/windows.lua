require 'hs.window'
require 'hs.hotkey'
require 'hs.caffeinate'

-- Disable animation
hs.window.animationDuration = 0

-- Lock Screen
hs.hotkey.bind(hyper, 'l', hs.caffeinate.lockScreen)

-- Show grid
hs.grid.setGrid('6x4')
hs.grid.setMargins('0x0')
hs.hotkey.bind(hyper, 'g', hs.grid.show)
hs.hotkey.bind('cmd', 'g', hs.grid.show)

-- Maximize window
hs.hotkey.bind(hyper, 'm', hs.grid.maximizeWindow)
hs.hotkey.bind('cmd', 'm', hs.grid.maximizeWindow)

-- Screen positions
local positions = {
  left = {0, 0, 0.5, 1},
  up = {0, 0, 1, 0.5},
  right = {0.5, 0, 0.5, 1},
  down = {0, 0.5, 1, 0.5},
  u = {0, 0, 0.5, 0.5},
  i = {0.5, 0, 0.5, 0.5},
  k = {0.5, 0.5, 0.5, 0.5},
  j = {0, 0.5, 0.5, 0.5},
  d = {0, 0, 0.33333, 1},
  f = {0.33333, 0, 0.33333, 1},
  g = {0.66666, 0, 0.33333, 1},
  e = {0, 0, 0.66666, 1}
}

-- Set keybindings
for k,v in pairs(positions) do
  hs.hotkey.bind(hyper, k, function()
    local window = hs.window.focusedWindow()
    if not window then return end
    window:move(v)
  end)
end

-- Cycle through all potions
local cycle = coroutine.create(function()
  local keys = {'left', 'up', 'right', 'down', 'u', 'i', 'k', 'j', 'd', 'f', 'g'}
  while true do
    for i = 1, #keys do
      coroutine.yield(positions[keys[i]])
    end
  end
end)
hs.hotkey.bind(hyper, 'c', function()
  local _, pos = coroutine.resume(cycle)
  local window  = hs.window.focusedWindow()
  if not window then return end
  window:move(pos)
end)

