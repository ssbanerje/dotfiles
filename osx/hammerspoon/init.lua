----------------------------------------------------------------------------------------------------
-- Setup keyboard shortcuts.
----------------------------------------------------------------------------------------------------
local hyper = {'ctrl','alt'}
hshelp_keys = {hyper, 'h'}
hs.loadSpoon('ModalMgr')
local textbox = require('textbox')

----------------------------------------------------------------------------------------------------
-- Setup default parameters.
----------------------------------------------------------------------------------------------------
hs.logger.defaultLogLevel='info'
hs.window.animationDuration = 0
hs.grid.setGrid('6x4')
hs.grid.setMargins('0x0')


----------------------------------------------------------------------------------------------------
-- Setup watchers.
----------------------------------------------------------------------------------------------------
-- Watch for configuration changes
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

spoon.ModalMgr.supervisor:bind(hyper, 'r', 'Reload Configuration', function()
  hs.reload()
  hs.notify.new({title='Hammerspoon', informativeText='Hammerspoon configuration reloaded'}):send()
end)

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


----------------------------------------------------------------------------------------------------
-- Register Window Switcher.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind('alt', 'tab', 'Show Window Hints', function()
	spoon.ModalMgr:deactivateAll()
	hs.hints.windowHints()
end)


----------------------------------------------------------------------------------------------------
-- Register Hammerspoon console.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, 'c', 'Toggle Hammerspoon Console', function()
	spoon.ModalMgr:deactivateAll()
	hs.toggleConsole()
end)


----------------------------------------------------------------------------------------------------
-- Register lock screen.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, 'l', 'Lock Screen', function()
	spoon.ModalMgr:deactivateAll()
	hs.caffeinate.lockScreen()
end)

----------------------------------------------------------------------------------------------------
-- Register window tiling.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr:new('window')
local window_modal = spoon.ModalMgr.modal_list['window']
local space_watcher = hs.spaces.watcher.new(function()
	spoon.ModalMgr:deactivate({'window'})
end)

----------------------------------------------------------------------------------------------------
-- Maximize window.
----------------------------------------------------------------------------------------------------
window_modal:bind('', 'm', 'Maximize', function()
  hs.grid.maximizeWindow()
end)

spoon.ModalMgr.supervisor:bind(hyper, 'm', 'Maximize window', function()
	hs.grid.maximizeWindow()
end)

----------------------------------------------------------------------------------------------------
-- Screen positons.
----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
-- Grid.
----------------------------------------------------------------------------------------------------
window_modal:bind('', '\\', 'Toggle grid', function()
	hs.grid.show()
end)

spoon.ModalMgr.supervisor:bind(hyper, '\\', 'Toggle grid', function()
	hs.grid.show()
end)

window_modal:bind('', ';', 'Snap window to grid', function()
  hs.grid.snap(hs.window.focusedWindow())
end)

window_modal:bind('', '\'', 'Snap all windows to grid', function()
  hs.fnutils.map(hs.window.visibleWindows(), hs.grid.snap)
end)

----------------------------------------------------------------------------------------------------
-- Cascade windows.
----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
-- Move windows
----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
-- Shrink windows.
----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
-- Grow windows
----------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------
-- Toggle help.
----------------------------------------------------------------------------------------------------
window_modal:bind('', '/', 'Toggle cheatsheet', function()
	spoon.ModalMgr:toggleCheatsheet()
end)

----------------------------------------------------------------------------------------------------
-- Enter window modal.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, 'w', 'Enter Window Tiling Mode', function()
	spoon.ModalMgr:deactivateAll()
  textbox.show('Tiling Mode')
  space_watcher:start()
	spoon.ModalMgr:activate({'window'}, '#FFBD2E')
end)

----------------------------------------------------------------------------------------------------
-- Exit window modal.
----------------------------------------------------------------------------------------------------
window_modal:bind('', 'escape', 'Exit', function()
	spoon.ModalMgr:deactivate({'window'})
end)

window_modal.exited = function()
  textbox:hide()
  space_watcher:stop()
end


----------------------------------------------------------------------------------------------------
-- Setup keycaster modal.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr:new('keycaster')
local keycaster_modal = spoon.ModalMgr.modal_list['keycaster']
local keybuffer = ''
local keybuffer_timer = hs.timer.delayed.new(1.5, function()
  keybuffer = ''
  textbox.hide()
end)

-- Convert key press into displayable string
function prettify_event_type(tap_event)
  local result = ''
  local pretty_keys = {
    ['return'] = '⏎', ['delete'] = '⌫', ['forwarddelete'] = '⌦', ['escape'] = '⎋', ['space'] =
    '␣', ['tab'] = '⇥', ['up'] = '↑', ['down'] = '↓', ['left'] = '←', ['right'] = '→', ['home'] =
    '↖', ['end'] = '↘', ['pageup'] = '⇞', ['pagedown'] = '⇟', ['f1'] = 'f1', ['f2'] = 'f2', ['f3'] =
    'f3', ['f4'] = 'f4', ['f5'] = 'f5', ['f6'] = 'f6', ['f7'] = 'f7', ['f8'] = 'f8', ['f9'] = 'f9',
    ['f10'] = 'f10', ['f11'] = 'f11', ['f12'] = 'f12', ['f13'] = 'f13', ['f14'] = 'f14', ['f15'] =
    'f15', ['f16'] = 'f16', ['f17'] = 'f17', ['f18'] = 'f18', ['f19'] = 'f19', ['f20'] = 'f20',
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

----------------------------------------------------------------------------------------------------
-- Show a keypress.
----------------------------------------------------------------------------------------------------
local key_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(tap_event)
  local char = prettify_event_type(tap_event)
  if utf8.len(keybuffer) + utf8.len(char) > 5 then
    local off = utf8.len(char) + 1
    keybuffer = keybuffer:sub(utf8.offset(keybuffer, off), -1)
  end
  keybuffer = keybuffer .. prettify_event_type(tap_event)

  keybuffer_timer:start()
  textbox.show(keybuffer)
end)

----------------------------------------------------------------------------------------------------
-- Enter keycaster modal.
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:bind(hyper, 'k', 'Enter Keycaster Mode', function()
	spoon.ModalMgr:deactivateAll()
	spoon.ModalMgr:activate({'keycaster'}, '#C23B22')
  key_tap:start()
end)

----------------------------------------------------------------------------------------------------
-- Exit keycaster.
----------------------------------------------------------------------------------------------------
keycaster_modal:bind(hyper, 'k', 'Exit', function()
	spoon.ModalMgr:deactivate({'keycaster'})
end)

keycaster_modal.exited = function()
  keybuffer = ''
  textbox.hide()
  keybuffer_timer:stop()
  key_tap:stop()
end

----------------------------------------------------------------------------------------------------
-- Initialize the modal supervisor
----------------------------------------------------------------------------------------------------
spoon.ModalMgr.supervisor:enter()

