hs.console.clearConsole()

---------------------------------------------------------------------------------------------------
-- Setup default
---------------------------------------------------------------------------------------------------
local hyper = {'cmd', 'ctrl', 'alt', 'shift'}
local textbox = require('textbox')
hs.loadSpoon('ModalMgr')

hs.logger.defaultLogLevel='info'
hs.window.animationDuration = 0
hs.grid.setGrid('6x4')
hs.grid.setMargins('0x0')


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
    hs.notify.new({title='Hammerspoon', informativeText='Hammerspoon configuration reloaded'}):send()
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
    hs.notify.show('Hammerspoon', 'Wi-Fi disconnected', '')
  else
    hs.notify.show('Hammerspoon', 'Wi-Fi connected to ' .. net, '')
  end
end)
wifi_watcher:start()


---------------------------------------------------------------------------------------------------
-- iTerm
---------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind('alt', 'return', 'Open iTerm', function()
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


---------------------------------------------------------------------------------------------------
-- Yabai keys
---------------------------------------------------------------------------------------------------
-- Function to interact with the Yabai instance
local yabai = require('yabai')
-- local function yabai(command, callback)
--   callback = callback or function(x) return x end
--   hs.task.new(
--     "/usr/local/bin/yabai",
--     callback,
--     function(ud, ...)
--       print("Yabai Output =>", hs.inspect(table.pack(...)))
--       return true
--     end,
--     command):start()
-- end

-- Window movement keys
local yabai_keys = {
  {'alt', 'space', 'Toggle Float', {'window', '--toggle', 'float'}},
  {'alt', 'v', 'Toggle Split', {'window', '--toggle', 'split'}},
  {'alt', 'm', 'Fullscreen', {'window', '--toggle', 'zoom-fullscreen'}},
  {{'alt', 'shift'}, 'm', 'Fullscreen', {'window', '--toggle', 'native-fullscreen'}},

  {'alt', 'h', 'Focus Left', {'window', '--focus', 'west'}},
  {'alt', 'j', 'Focus Down', {'window', '--focus', 'south'}},
  {'alt', 'k', 'Focus Up', {'window', '--focus', 'north'}},
  {'alt', 'l', 'Focus Right', {'window', '--focus', 'east'}},

  {'alt', 'left', 'swap left', {'window', '--swap', 'west'}},
  {'alt', 'up', 'swap up', {'window', '--swap', 'north'}},
  {'alt', 'down', 'swap down', {'window', '--swap', 'south'}},
  {'alt', 'right', 'swap right', {'window', '--swap', 'east'}},

  {hyper, 'e', 'Equalize windows', {'space', '--balance'}},

  {hyper, 'left', 'Rotate Clockwise', {'space', '--rotate', '270'}},
  {hyper, 'right', 'Rotate Anticlockwise', {'space', '--rotate', '90'}},
  {hyper, 'up', 'Flip on X', {'space', '--mirror', 'x-axis'}},
  {hyper, 'down', 'Flip on Y', {'space', '--mirror', 'y-axis'}},
}
for k, c in pairs(yabai_keys) do
  spoon.ModalMgr.supervisor:bind(c[1], c[2], c[3], function() yabai.ipc(c[4]) end)
end

-- Window resize keys
spoon.ModalMgr.supervisor:bind({'alt', 'shift'}, 'h', "Resize Window", function()
  yabai.ipc({'window', '--resize', 'left:-50:0'})
  yabai.ipc({'window', '--resize', 'right:-50:0'})
end)
spoon.ModalMgr.supervisor:bind({'alt', 'shift'}, 'j', "Resize Window", function()
  yabai.ipc({'window', '--resize', 'bottom:0:50'})
  yabai.ipc({'window', '--resize', 'top:0:50'})
end)
spoon.ModalMgr.supervisor:bind({'alt', 'shift'}, 'k', "Resize Window", function()
  yabai.ipc({'window', '--resize', 'bottom:0:-50'})
  yabai.ipc({'window', '--resize', 'top:0:-50'})
end)
spoon.ModalMgr.supervisor:bind({'alt', 'shift'}, 'l', "Resize Window", function()
  yabai.ipc({'window', '--resize', 'left:50:0'})
  yabai.ipc({'window', '--resize', 'right:50:0'})
end)

-- Move window to space
spoon.ModalMgr.supervisor:bind({'alt', 'shift'}, 'left', "Move Window", function()
  yabai.ipc({'window', '--space', 'prev'})
  hs.timer.doAfter(.2, function()
    hs.eventtap.event.newKeyEvent('ctrl', true):post()
    hs.eventtap.event.newKeyEvent('left', true):post()
    hs.eventtap.event.newKeyEvent('left', false):post()
    hs.eventtap.event.newKeyEvent('ctrl', false):post()
  end)
end)
spoon.ModalMgr.supervisor:bind({'alt', 'shift'}, 'right', "Move Window", function()
  yabai.ipc({'window', '--space', 'next'})
  hs.timer.doAfter(.2, function()
    hs.eventtap.event.newKeyEvent('ctrl', true):post()
    hs.eventtap.event.newKeyEvent('right', true):post()
    hs.eventtap.event.newKeyEvent('right', false):post()
    hs.eventtap.event.newKeyEvent('ctrl', false):post()
  end)
end)

-- Increase and decrease window gaps
local gap = 0
spoon.ModalMgr.supervisor:bind('alt', '-', 'Decrease Gap', function()
  gap = gap - 10
  if (gap < 0) then
      gap = 0;
  end
  yabai.ipc({'space', '--gap', string.format('abs:%d', gap)})
end)
spoon.ModalMgr.supervisor:bind('alt', '=', 'Increase Gap', function()
  gap = gap + 10
  yabai.ipc({'space', '--gap', string.format('abs:%d', gap)})
end)

-- Draw borders around window
local global_border = nil

local function redrawBorder()
  if global_border ~= nil then
    global_border:delete()
    global_border = nil
  end
  win = hs.window.focusedWindow()
  if win == nil or win:isFullScreen() or win:application():name() == "Hammerspoon" then
    return
  end
  top_left = win:topLeft()
  size = win:size()
  global_border = hs.drawing.rectangle(hs.geometry.rect(top_left['x'], top_left['y'], size['w'], size['h']))
  global_border:setStrokeColor({["red"]=1,["blue"]=0.25,["green"]=0.75,["alpha"]=0.8})
  global_border:setFill(false)
  global_border:setStrokeWidth(4)
  global_border:show()
end

local allwindows = hs.window.filter.new(nil)
for i, e in pairs({hs.window.filter.windowCreated, hs.window.filter.windowDestroyed, hs.window.filter.windowFocused, hs.window.filter.windowFullscreened, hs.window.filter.windowHidden, hs.window.filter.windowMinimized, hs.window.filter.windowMoved, hs.window.filter.windowUnfocused, hs.window.filter.windowUnfullscreened, hs.window.filter.windowUnhidden, hs.window.filter.windowUnminimized}) do
  allwindows:subscribe(e, redrawBorder)
end
redrawBorder()

---------------------------------------------------------------------------------------------------
-- Window Switcher
---------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, 'tab', 'Show Window Hints', hs.hints.windowHints)


---------------------------------------------------------------------------------------------------
-- Hammerspoon console
---------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, '`', 'Toggle Hammerspoon Console', hs.toggleConsole)


---------------------------------------------------------------------------------------------------
-- Window Modal
---------------------------------------------------------------------------------------------------
spoon.ModalMgr:new('window')
local window_modal = spoon.ModalMgr.modal_list['window']
local space_watcher = hs.spaces.watcher.new(function()
	spoon.ModalMgr:deactivate({'window'})
end)

-- Maximize window
window_modal:bind('', 'm', 'Maximize', hs.grid.maximizeWindow)

-- Screen positons
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
  window_modal:bind({}, k, v[2], function()
    local window = hs.window.focusedWindow()
    if not window then return end
    window:move(v[1])
  end)
end

-- Grid
window_modal:bind('', '\\', 'Toggle grid', hs.grid.show)

spoon.ModalMgr.supervisor:bind(hyper, '\\', 'Toggle grid', hs.grid.show)

window_modal:bind('', ';', 'Snap window to grid', function()
  hs.grid.snap(hs.window.focusedWindow())
end)

window_modal:bind('', '\'', 'Snap all windows to grid', function()
  hs.fnutils.map(hs.window.visibleWindows(), hs.grid.snap)
end)

-- Cascade windows
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

-- Move window
local move_commands = {
  ['h'] = function(f) f.x = f.x - 10; return f end,
  ['l'] = function(f) f.x = f.x + 10; return f end,
  ['j'] = function(f) f.y = f.y + 10; return f end,
  ['k'] = function(f) f.y = f.y - 10; return f end,
}

for k, v in pairs(move_commands) do
  local move = function()
    local win = hs.window.focusedWindow()
    local update = v(win:frame())
    win:setFrame(update)
  end
  window_modal:bind('', k, 'Move Window', move, nil, move)
end

-- Shrink windows
local shrink_commands = {
  ['h'] = function(f) f.x = f.x + 10; f.w = f.w - 10; return f end,
  ['l'] = function(f) f.w = f.w - 10; return f end,
  ['j'] = function(f) f.h = f.h - 10; return f end,
  ['k'] = function(f) f.y = f.y + 10; f.h = f.h - 10; return f end,
}

for k, v in pairs(shrink_commands) do
  local shrink = function()
    local win = hs.window.focusedWindow()
    local update = v(win:frame())
    win:setFrame(update)
  end
  window_modal:bind('ctrl', k, 'Shrink Window', shrink, nil, shrink)
end

-- Grow window
local grow_commands = {
  ['h'] = function(f) f.x = f.x - 10; f.w = f.w + 10; return f end,
  ['l'] = function(f) f.w = f.w + 10; return f end,
  ['j'] = function(f) f.h = f.h + 10; return f end,
  ['k'] = function(f) f.y = f.y - 10; f.h = f.h + 10; return f end,
}

for k, v in pairs(grow_commands) do
  local grow = function()
    local win = hs.window.focusedWindow()
    local update = v(win:frame())
    win:setFrame(update)
  end
  window_modal:bind('shift', k, 'Grow Window', grow, nil, grow)
end

-- Enter window modal
spoon.ModalMgr.supervisor:bind(hyper, 'w', 'Enter Window Tiling Mode', function()
	spoon.ModalMgr:deactivateAll()
  space_watcher:start()
	spoon.ModalMgr:activate({'window'}, '#FFBD2E')
  textbox:show('Tiling Mode')
end)

-- Toggle cheat sheet
window_modal:bind('shift', '/', 'Toggle Cheat Sheet', function()
	spoon.ModalMgr:toggleCheatsheet()
end)

-- Exit window modal
window_modal:bind('', 'escape', 'Exit', function()
	spoon.ModalMgr:deactivate({'window'})
end)

window_modal.exited = function()
  textbox:hide()
  space_watcher:stop()
end


---------------------------------------------------------------------------------------------------
-- Keycaster modal
---------------------------------------------------------------------------------------------------
spoon.ModalMgr:new('keycaster')
local keycaster_modal = spoon.ModalMgr.modal_list['keycaster']
local keybuffer = ''
local keybuffer_timer = hs.timer.delayed.new(1.5, function()
  keybuffer = ''
  textbox:hide()
end)

-- Convert key press into displayable string
function prettify_event_type(tap_event)
  local result = ''
  local pretty_keys = {
    ['return'] = '⏎', ['delete'] = '⌫', ['forwarddelete'] = '⌦', ['escape'] = '⎋', ['space'] =
    '␣', ['tab'] = '⇥', ['up'] = '↑', ['down'] = '↓', ['left'] = '←', ['right'] = '→', ['home'] =
    '↖', ['end'] = '↘', ['pageup'] = '⇞', ['pagedown'] = '⇟', ['f1'] = 'F1', ['f2'] = 'F2', ['f3'] =
    'F3', ['f4'] = 'F4', ['f5'] = 'F5', ['f6'] = 'F6', ['f7'] = 'F7', ['f8'] = 'F8', ['f9'] = 'F9',
    ['f10'] = 'F10', ['f11'] = 'F11', ['f12'] = 'F12', ['f13'] = 'F13', ['f14'] = 'F14', ['f15'] =
    'F15', ['f16'] = 'F16', ['f17'] = 'F17', ['f18'] = 'F18', ['f19'] = 'F19', ['f20'] = 'F20',
    ['pad'] = 'pad', ['pad*'] = '*', ['pad+'] = '+', ['pad/'] = '/', ['pad-'] = '-', ['pad='] = '=',
    ['pad0'] = '0', ['pad1'] = '1', ['pad2'] = '2', ['pad3'] = '3', ['pad4'] = '4', ['pad5'] = '5',
    ['pad6'] = '6', ['pad7'] = '7', ['pad8'] = '8', ['pad9'] = '9', ['padclear'] = 'padclear',
    ['padenter'] = '⏎', ['help'] = 'help',
  }

  local flags = tap_event:getFlags()
  local char = hs.keycodes.map[tap_event:getKeyCode()]
  if (pretty_keys[char] == nil) and not (flags.ctrl or flags.cmd or flags.alt or flags.fn) then
    char = tap_event:getCharacters(true)
    flags.shift = false
  end

  if flags.shift then
    result = '⇧-' .. result
  end
  if flags.alt then
    result = '⌥-' .. result
  end
  if flags.ctrl then
    result = '⌃-' .. result
  end
  if flags.cmd then
    result = '⌘-' .. result
  end

  return result .. (pretty_keys[char] ~= nil and pretty_keys[char] or char)
end

-- Show a keypress
local key_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(tap_event)
  local char = prettify_event_type(tap_event)
  if utf8.len(keybuffer) + utf8.len(char) > 15 then
    local off = utf8.len(char) + 1
    keybuffer = keybuffer:sub(utf8.offset(keybuffer, off), -1)
  end
  keybuffer = keybuffer .. prettify_event_type(tap_event)

  keybuffer_timer:start()
  textbox:show(keybuffer)
end)

-- Enter keycaster modal
spoon.ModalMgr.supervisor:bind(hyper, 'k', 'Enter Keycaster Mode', function()
	spoon.ModalMgr:deactivateAll()
	spoon.ModalMgr:activate({'keycaster'}, '#C23B22')
  textbox:show('Keycaster Mode')
  key_tap:start()
end)

-- Exit keycaster
keycaster_modal:bind(hyper, 'k', 'Exit', function()
	spoon.ModalMgr:deactivate({'keycaster'})
end)

keycaster_modal.exited = function()
  keybuffer = ''
  textbox:hide()
  keybuffer_timer:stop()
  key_tap:stop()
end

---------------------------------------------------------------------------------------------------
-- Initialize the modal supervisor
---------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:enter()
