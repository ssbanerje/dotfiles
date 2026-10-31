local utf8 = require("utf8")

local module = {}

module.keybuffer = ""

local pretty_keys = {
  ["return"] = "⏎",
  ["delete"] = "⌫",
  ["forwarddelete"] = "⌦",
  ["escape"] = "⎋",
  ["space"] = "␣",
  ["tab"] = "⇥",
  ["up"] = "↑",
  ["down"] = "↓",
  ["left"] = "←",
  ["right"] = "→",
  ["home"] = "↖",
  ["end"] = "↘",
  ["pageup"] = "⇞",
  ["pagedown"] = "⇟",
  ["pad"] = "pad",
  ["pad*"] = "*",
  ["pad+"] = "+",
  ["pad/"] = "/",
  ["pad-"] = "-",
  ["pad="] = "=",
  ["padclear"] = "padclear",
  ["padenter"] = "⏎",
  ["help"] = "help",
}
for i = 1, 20 do
  pretty_keys["f" .. i] = "F" .. i
end
for i = 0, 9 do
  pretty_keys["pad" .. i] = tostring(i)
end

local overlay = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
overlay:level(hs.canvas.windowLevels.overlay)
overlay:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.transient)
overlay:clickActivating(false)
overlay:canvasMouseEvents(false, false, false, false)
overlay:appendElements(
  {
    type = "rectangle",
    fillColor = { white = 0.125, alpha = 0.85 },
    strokeColor = { white = 0.625, alpha = 0.8 },
    strokeWidth = 1,
    roundedRectRadii = { xRadius = 10, yRadius = 10 },
  },
  {
    type = "text",
    text = "",
    textSize = 96,
    textAlignment = "center",
  }
)

local function show_message(message)
  local win = hs.window.focusedWindow()
  local screen = (win and win:screen()) or hs.screen.mainScreen()
  if not screen then
    return
  end
  local frame = screen:frame()
  overlay:frame({
    x = frame.x + 50,
    y = frame.y + frame.h - 240,
    w = frame.w - 100,
    h = 140,
  })
  overlay[2].text = message
  overlay:show()
end

local keybuffer_timer = hs.timer.delayed.new(1.5, function()
  module.keybuffer = ""
  overlay:hide()
end)

local function prettify_event(tap_event)
  local flags = tap_event:getFlags()
  local char = hs.keycodes.map[tap_event:getKeyCode()] or ""
  local shift = flags.shift
  if pretty_keys[char] == nil and not (flags.ctrl or flags.cmd or flags.alt or flags.fn) then
    char = tap_event:getCharacters(true) or char
    shift = false
  end

  local prefix = ""
  if flags.cmd then
    prefix = prefix .. "⌘-"
  end
  if flags.ctrl then
    prefix = prefix .. "⌃-"
  end
  if flags.alt then
    prefix = prefix .. "⌥-"
  end
  if shift then
    prefix = prefix .. "⇧-"
  end
  return prefix .. (pretty_keys[char] or char)
end

local key_tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(tap_event)
  local rendered = prettify_event(tap_event)
  local rendered_len = utf8.len(rendered) or #rendered
  local buf_len = utf8.len(module.keybuffer) or #module.keybuffer
  if buf_len + rendered_len > 15 then
    local offset = utf8.offset(module.keybuffer, rendered_len + 1)
    module.keybuffer = offset and module.keybuffer:sub(offset) or ""
  end
  module.keybuffer = module.keybuffer .. rendered

  keybuffer_timer:start()
  show_message(module.keybuffer)
end)

function module:start()
  show_message("Keycaster Mode")
  keybuffer_timer:start()
  key_tap:start()
end

function module:stop()
  overlay:hide()
  module.keybuffer = ""
  keybuffer_timer:stop()
  key_tap:stop()
end

return module
