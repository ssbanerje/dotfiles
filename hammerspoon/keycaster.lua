local module = {}

-- Textbox in which the keypresses are displayed
module.textbox = require('textbox')

-- Keypress string displayed on screen
module.keybuffer = ''

-- Pretty keys
module.pretty_keys = {
  ['return'] = '⏎',
  ['delete'] = '⌫',
  ['forwarddelete'] = '⌦',
  ['escape'] = '⎋',
  ['space'] = '␣',
  ['tab'] = '⇥',
  ['up'] = '↑',
  ['down'] = '↓',
  ['left'] = '←',
  ['right'] = '→',
  ['home'] = '↖',
  ['end'] = '↘',
  ['pageup'] = '⇞',
  ['pagedown'] = '⇟',
  ['f1'] = 'F1',
  ['f2'] = 'F2',
  ['f3'] = 'F3',
  ['f4'] = 'F4',
  ['f5'] = 'F5',
  ['f6'] = 'F6',
  ['f7'] = 'F7',
  ['f8'] = 'F8',
  ['f9'] = 'F9',
  ['f10'] = 'F10',
  ['f11'] = 'F11',
  ['f12'] = 'F12',
  ['f13'] = 'F13',
  ['f14'] = 'F14',
  ['f15'] = 'F15',
  ['f16'] = 'F16',
  ['f17'] = 'F17',
  ['f18'] = 'F18',
  ['f19'] = 'F19',
  ['f20'] = 'F20',
  ['pad'] = 'pad',
  ['pad*'] = '*',
  ['pad+'] = '+',
  ['pad/'] = '/',
  ['pad-'] = '-',
  ['pad='] = '=',
  ['pad0'] = '0',
  ['pad1'] = '1',
  ['pad2'] = '2',
  ['pad3'] = '3',
  ['pad4'] = '4',
  ['pad5'] = '5',
  ['pad6'] = '6',
  ['pad7'] = '7',
  ['pad8'] = '8',
  ['pad9'] = '9',
  ['padclear'] = 'padclear',
  ['padenter'] = '⏎',
  ['help'] = 'help',
}


-- Timer to clear the `keybuffer`
module.keybuffer_timer = hs.timer.delayed.new(1.5, function()
  module.keybuffer = ''
  module.textbox:hide()
end)

-- Convert key press into displayable string
function module:_prettify_event_type(tap_event)
  local result = ''
  local flags = tap_event:getFlags()
  local char = hs.keycodes.map[tap_event:getKeyCode()]
  if (module.pretty_keys[char] == nil) and not (flags.ctrl or flags.cmd or flags.alt or flags.fn) then
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

  return result .. (module.pretty_keys[char] or char)
end

-- Show a keypress
module.key_tap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(tap_event)
  local char = module:_prettify_event_type(tap_event)
  if utf8.len(module.keybuffer) + utf8.len(char) > 15 then
    local off = utf8.len(char) + 1
    module.keybuffer = module.keybuffer:sub(utf8.offset(module.keybuffer, off), -1)
  end
  module.keybuffer = module.keybuffer .. module:_prettify_event_type(tap_event)

  module.keybuffer_timer:start()
  module.textbox:show(module.keybuffer)
end)

-- Initialize keycaster
function module:start()
  module.textbox:show('Keycaster Mode')
  module.key_tap:start()
end

-- Exit keycaster
function module:stop()
  module.textbox:hide()
  module.keybuffer = ''
  module.keybuffer_timer:stop()
  module.key_tap:stop()
end

return module
