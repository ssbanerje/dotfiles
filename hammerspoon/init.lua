-- All modes:
--  > Hyper + ` -> Hammerspoon console
--
-- Normal Mode:
--  * Alt + N -> Navigate
--  * Hyper + K -> Keycaster Mode
--  > Alt + Enter -> iTerm2
--  > Alt + Cmd + Enter -> Safari
--  > Alt + Space -> Toggle Float
--  > Alt + s -> Toggle last split
--  > Alt + m -> Toggle Fullscreen
--  > Alt + Shift + m -> Toggle Native Fullscreen
--
-- Navigate Mode:
--  * Z -> Resize mode
--  * Esc -> Normal mode
--  > HJKL/Arrows -> Navigate
--  > Cmd HJKL/Arrows -> Swap windows
--  > Shift + HL/Arrows -> Move Space
--  > Shift + JK/Arrows -> Rotate (counter)clockwise
--  > | -> Flip on Y
--  > - -> Flip on X
--  > Hyper + HJKL (on floating) -> Move window
--
-- Resize Mode:
--   * Esc -> Normal Mode
--   > HJKL + Arrows -> Resize
--   > +- -> Increase decrease gaps
--   > 0 -> Equalize windows
--   > Arrows (on floating window) -> Half screen windows
--   > RTFG (on floating window) -> Quarter screen windows
--   > QWE (on floating window) -> Third screen windows
--   > ASDZXC (on floating window) -> Sixth screen windows
--
-- Keycaster Mode:
--   * Hyper + K -> Normal Mode


---------------------------------------------------------------------------------------------------
-- Default
---------------------------------------------------------------------------------------------------
hs.console.clearConsole()
hs.logger.defaultLogLevel='info'
hs.window.animationDuration = 0

local hyper = {'cmd', 'ctrl', 'alt', 'shift'}


---------------------------------------------------------------------------------------------------
-- Hammerspoon console
---------------------------------------------------------------------------------------------------
hs.hotkey.bind(hyper, '`', 'Toggle Hammerspoon Console', hs.toggleConsole)


---------------------------------------------------------------------------------------------------
-- State Machine
---------------------------------------------------------------------------------------------------
local state_machine = require('state_machine'):init()
state_machine:new_state('navigation', '#d53e4f')
state_machine:new_state('resize', '#e6f598')
state_machine:new_state('keycaster', '#3288bd')


---------------------------------------------------------------------------------------------------
-- Normal Mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: Navigation
local borders = require('window_borders')
state_machine:transition(state_machine.base_state_id, 'navigation', {'alt', 'n'}, 'Navigation Mode', function()
  borders:start()
end)

-- STATE TRANSITION: Keycaster
local keycaster = require('keycaster')
state_machine:transition(state_machine.base_state_id, 'keycaster', {hyper, 'k'}, 'Keycaster Mode', function()
  keycaster:start()
end)

-- BINDING: Open a iTerm2 window
state_machine:bind('base', {'alt', 'return'}, 'Open iTerm', function()
  if hs.application.find("iTerm") then
    hs.applescript.applescript([[
			tell application "iTerm"
				create window with default profile
			end tell
		]])
  else
    hs.application.open("iTerm")
  end
end)

-- BINDING: Open a Safari window
state_machine:bind('base', {{'alt', 'cmd'}, 'return'}, 'Open Safari', function()
  if hs.application.find("Safari") then
    hs.applescript.applescript([[
			tell application "Safari"
				make new document
        activate
			end tell
		]])
  else
    hs.application.open("Safari")
  end
end)

-- BINDING: Load Yabai commands for Normal mode
local yabai_commands = {
  {{'alt', 'space'}, 'Toggle Float', {'window', '--toggle', 'float'}},
  {{'alt', 'm'}, 'Fullscreen', {'window', '--toggle', 'zoom-fullscreen'}},
  {{{'alt', 'shift'}, 'm'}, 'Fullscreen', {'window', '--toggle', 'native-fullscreen'}},
  {{'alt', 's'}, 'Toggle Split', {'window', '--toggle', 'split'}},
}
local yabai = require('yabai')
for _, c in pairs(yabai_commands) do
  state_machine:bind(state_machine.base_state_id, c[1], c[2], function() yabai:ipc(c[3]) end)
end


---------------------------------------------------------------------------------------------------
-- Navigation Mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: Exit navigation state
state_machine:transition('navigation', state_machine.base_state_id, {'', 'escape'}, 'Exit', function()
  borders:stop()
end)
state_machine:transition('navigation', state_machine.base_state_id, {'', 'return'}, 'Exit', function()
  borders:stop()
end)

-- STATE TRANSITION: Resize state
state_machine:transition('navigation', 'resize', {'', 'Z'}, 'Resize State')

-- BINDINGS: Yabai movement keys Window movement keys
local yabai_keys = {
  {{'', 'h'}, 'Focus Left', {'window', '--focus', 'west'}},
  {{'', 'j'}, 'Focus Down', {'window', '--focus', 'south'}},
  {{'', 'k'}, 'Focus Up', {'window', '--focus', 'north'}},
  {{'', 'l'}, 'Focus Right', {'window', '--focus', 'east'}},
  {{'', 'left'}, 'Focus Left', {'window', '--focus', 'west'}},
  {{'', 'down'}, 'Focus Down', {'window', '--focus', 'south'}},
  {{'', 'up'}, 'Focus Up', {'window', '--focus', 'north'}},
  {{'', 'right'}, 'Focus Right', {'window', '--focus', 'east'}},

  {{'cmd', 'h'}, 'Swap left', {'window', '--swap', 'west'}},
  {{'cmd', 'j'}, 'Swap down', {'window', '--swap', 'south'}},
  {{'cmd', 'k'}, 'Swap up', {'window', '--swap', 'north'}},
  {{'cmd', 'l'}, 'Swap right', {'window', '--swap', 'east'}},
  {{'cmd', 'left'}, 'Swap left', {'window', '--swap', 'west'}},
  {{'cmd', 'up'}, 'Swap up', {'window', '--swap', 'north'}},
  {{'cmd', 'down'}, 'Swap down', {'window', '--swap', 'south'}},
  {{'cmd', 'right'}, 'Swap right', {'window', '--swap', 'east'}},

  {{'shift', 'k'}, 'Rotate Clockwise', {'space', '--rotate', '270'}},
  {{'shift', 'j'}, 'Rotate Anticlockwise', {'space', '--rotate', '90'}},
  {{'shift', 'up'}, 'Rotate Clockwise', {'space', '--rotate', '270'}},
  {{'shift', 'down'}, 'Rotate Anticlockwise', {'space', '--rotate', '90'}},

  {{'shift', '\\'}, 'Flip on Y', {'space', '--mirror', 'y-axis'}},
  {{'', '-'}, 'Flip on X', {'space', '--mirror', 'x-axis'}},
}
for k, c in pairs(yabai_keys) do
  state_machine:bind('navigation', c[1], c[2], function() yabai:ipc(c[3]) end)
end

-- BIDNING: Move window to space
local function move_window(yk, kk)
  return function()
    yabai:ipc({'window', '--space', yk})
    hs.timer.doAfter(.2, function()
      hs.eventtap.event.newKeyEvent('ctrl', true):post()
      hs.eventtap.event.newKeyEvent(kk, true):post()
      hs.eventtap.event.newKeyEvent(kk, false):post()
      hs.eventtap.event.newKeyEvent('ctrl', false):post()
    end)
  end
end
state_machine:bind('navigation', {'shift', 'h'}, 'Move Window', move_window('prev', 'left'))
state_machine:bind('navigation', {'shift', 'left'}, 'Move Window', move_window('prev', 'left'))
state_machine:bind('navigation', {'shift', 'l'}, 'Move Window', move_window('next', 'right'))
state_machine:bind('navigation', {'shift', 'right'}, 'Move Window', move_window('next', 'right'))

-- BINDING: Move floating window
local move_commands = {
  h = function(f) f.x = f.x - 10; return f end,
  l = function(f) f.x = f.x + 10; return f end,
  j = function(f) f.y = f.y + 10; return f end,
  k = function(f) f.y = f.y - 10; return f end,
}
for k, v in pairs(move_commands) do
  state_machine:bind('navigation', {hyper, k}, 'Move Window', function()
    local win = hs.window.focusedWindow()
    if not win then return end
    yabai:is_floating(win:id(), function()
      local update = v(win:frame())
      win:setFrame(update)
    end)
  end)
end


---------------------------------------------------------------------------------------------------
-- Resize mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: Exit resize state
state_machine:transition('resize', state_machine.base_state_id, {'', 'escape'}, 'Exit', function()
  borders:stop()
end)
state_machine:transition('resize', state_machine.base_state_id, {'', 'return'}, 'Exit', function()
  borders:stop()
end)

-- BINDINGS: Yabai resize keys Window movement keys
local yabai_keys = {
  {{'', '0'}, 'Equalize windows', {'space', '--balance'}},
}
for k, c in pairs(yabai_keys) do
  state_machine:bind('resize', c[1], c[2], function() yabai:ipc(c[3]) end)
end

-- BINDINGS: Increase and decrease window gaps
local gap = 0
state_machine:bind('resize', {'', '-'}, 'Decrease Gap', function()
  gap = gap - 10
  if (gap < 0) then
      gap = 0;
  end
  yabai:ipc({'space', '--gap', string.format('abs:%d', gap)})
end)
state_machine:bind('resize', {'shift', '='}, 'Increase Gap', function()
  gap = gap + 10
  yabai:ipc({'space', '--gap', string.format('abs:%d', gap)})
end)

-- BINDINGS: Window resize keys
state_machine:bind('resize', {'', 'h'}, 'Resize Window', function()
  yabai:ipc({'window', '--resize', 'left:-50:0'})
  yabai:ipc({'window', '--resize', 'right:-50:0'})
end)
state_machine:bind('resize', {'', 'j'}, 'Resize Window', function()
  yabai:ipc({'window', '--resize', 'bottom:0:50'})
  yabai:ipc({'window', '--resize', 'top:0:50'})
end)
state_machine:bind('resize', {'', 'k'}, 'Resize Window', function()
  yabai:ipc({'window', '--resize', 'bottom:0:-50'})
  yabai:ipc({'window', '--resize', 'top:0:-50'})
end)
state_machine:bind('resize', {'', 'l'}, 'Resize Window', function()
  yabai:ipc({'window', '--resize', 'left:50:0'})
  yabai:ipc({'window', '--resize', 'right:50:0'})
end)

-- BINDING: Screen positons
local positions = {
  left = {{0, 0, 0.5, 1}, 'Halves - L'},
  up = {{0, 0, 1, 0.5}, 'Halves - T'},
  right = {{0.5, 0, 0.5, 1}, 'Halves - R'},
  down = {{0, 0.5, 1, 0.5}, 'Halves - L'},
  r = {{0, 0, 0.5, 0.5}, 'Quarters - TR'},
  t = {{0.5, 0, 0.5, 0.5}, 'Quarters - TL'},
  g = {{0.5, 0.5, 0.5, 0.5}, 'Quarters - BR'},
  f = {{0, 0.5, 0.5, 0.5}, 'Quarters - BL'},
  q = {{0, 0, 0.33333, 1}, 'Thirds - L'},
  w = {{0.33333, 0, 0.33333, 1}, 'Thirds - M'},
  e = {{0.66666, 0, 0.33333, 1}, 'Thirds - R'},
  v = {{0, 0, 0.66666, 1}, 'Two Thirds - L'},
  a = {{0, 0, 0.33333, 0.5}, 'Sixths - TL'},
  s = {{0.33333, 0, 0.33333, 0.5}, 'Sixths - TM'},
  d = {{0.66666, 0, 0.33333, 0.5}, 'Sixths - TR'},
  z = {{0, 0.5, 0.33333, 0.5}, 'Sixths - BL'},
  x = {{0.33333, 0.5, 0.33333, 0.5}, 'Sixths - BM'},
  c = {{0.66666, 0.5, 0.33333, 0.5}, 'Sixths - BR'},
}
for k,v in pairs(positions) do
  state_machine:bind('resize', {{'cmd'}, k}, v[2], function()
    local window = hs.window.focusedWindow()
    if not window then
      return
    end
    yabai:is_floating(window:id(), function()
      window:move(v[1])
    end)
  end)
end

---------------------------------------------------------------------------------------------------
-- Keycaster Mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: To normal mode
state_machine:transition('keycaster', state_machine.base_state_id, {hyper, 'k'}, 'Exit', function()
  keycaster:stop()
end)


---------------------------------------------------------------------------------------------------
-- Initialize the modal supervisor
---------------------------------------------------------------------------------------------------
state_machine:activate('base')


---------------------------------------------------------------------------------------------------
-- Setup watchers
---------------------------------------------------------------------------------------------------
-- Watch for configuration change
local config_watcher = hs.pathwatcher.new(os.getenv('HOME') .. '/.hammerspoon/', function(files)
  local doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == '.lua' then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
    hs.notify.new({
      title='Hammerspoon',
      informativeText='Hammerspoon configuration reloaded',
      withdrawAfter=10,
    }):send()
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
  local net = hs.wifi.currentNetwork()
  if net == nil then
    hs.notify.new({
      title='Hammerspoon',
      informativeText= 'Wi-Fi disconnected',
      withdrawAfter=10,
    }):send()
  else
    hs.notify.new({
      title='Hammerspoon',
      informativeText='Wi-Fi connected to ' .. net,
      withdrawAfter=10,
    }):send()
  end
end)
wifi_watcher:start()
