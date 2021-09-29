-- All modes:
--  > Hyper + ` -> Hammerspoon console
--
-- Normal Mode:
--  * Alt + N -> Navigate
--  * Hyper + K -> Keycaster Mode
--  > Hyper + Enter -> Toggle yabai for space
--  > Alt + Enter -> Terminal
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
--  > Shfit HJKL/Arrows -> Warp windows
--  > Cmd + Shift + HJKL/Arrows -> Swap windows
--  > Cmd + HL/Arrows -> Move Space
--  > Cmd + JK/Arrows -> Rotate (counter)clockwise
--  > | -> Flip on Y
--  > - -> Flip on X
--  > Hyper + HJKL/Arrows (on floating) -> Move window
--  > Alt + HJKL -> Stack window
--  > Tab -> Move through stack
--  > Shift + Tab -> Move through stack
--
-- Resize Mode:
--  * Esc -> Normal Mode
--  > HJKL + Arrows -> Resize
--  > +- -> Increase decrease gaps
--  > 0 -> Equalize windows
--  > p -> Toggle zoom parent (occupy parent space as well)
--  > Arrows (on floating window) -> Half screen windows
--  > RTFG (on floating window) -> Quarter screen windows
--  > QWE (on floating window) -> Third screen windows
--  > ASDZXC (on floating window) -> Sixth screen windows
--
-- Keycaster Mode:
--   * Hyper + K -> Normal Mode

---------------------------------------------------------------------------------------------------
-- Default
---------------------------------------------------------------------------------------------------
hs.console.clearConsole()
hs.logger.defaultLogLevel = "warning"
hs.window.animationDuration = 0

local hyper = { "cmd", "ctrl", "alt", "shift" }

---------------------------------------------------------------------------------------------------
-- Hammerspoon console
---------------------------------------------------------------------------------------------------
hs.hotkey.bind(hyper, "`", "Toggle Hammerspoon Console", hs.toggleConsole)

---------------------------------------------------------------------------------------------------
-- State Machine
---------------------------------------------------------------------------------------------------
local state_machine = require("state_machine"):init()
state_machine:new_state("navigation", "#d53e4f")
state_machine:new_state("resize", "#e6f598")
state_machine:new_state("keycaster", "#3288bd")

---------------------------------------------------------------------------------------------------
-- Normal Mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: Navigation
local borders = require("window_borders")
state_machine:transition(state_machine.base_state_id, "navigation", { "alt", "n" }, "Navigation Mode", function()
  borders.start()
end)

-- STATE TRANSITION: Keycaster
local keycaster = require("keycaster")
state_machine:transition(state_machine.base_state_id, "keycaster", { hyper, "k" }, "Keycaster Mode", function()
  keycaster:start()
end)

-- BINDING: Turn on/off BSP splitting
local yabai = require("yabai")
local yabai_toggle = true
state_machine:bind("base", { hyper, "return" }, "Toggle Yabai", function()
  local layout
  if yabai_toggle then
    layout = "float"
  else
    layout = "bsp"
  end
  yabai_toggle = not yabai_toggle
  yabai.ipc({ "space", "--layout", layout })
end)

-- BINDING: Open a terminal window
state_machine:bind("base", { "alt", "return" }, "Open kitty", function()
  if hs.application.find("kitty") then
    local nop = function(_) end
    hs.task.new("/usr/local/bin/kitty", nop, nop, { "-1", "-d=" .. os.getenv("HOME") }):start()
  else
    hs.application.open("kitty")
  end
end)

state_machine:bind("base", { { "cmd", "alt" }, "return" }, "Open iTerm", function()
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
state_machine:bind("base", { { "alt", "shift" }, "return" }, "Open Safari", function()
  if hs.application.find("Safari") then
    hs.applescript.applescript([[
    tell application "Safari"
      make new document
      activate
    end tell]])
  else
    hs.application.open("Safari")
  end
end)

-- BINDING: Load Yabai commands for Normal mode
local yabai_commands = {
  { { "alt", "space" }, "Toggle Float", { "window", "--toggle", "float" } },
  { { "alt", "m" }, "Fullscreen", { "window", "--toggle", "zoom-fullscreen" } },
  { { { "alt", "shift" }, "m" }, "Fullscreen", { "window", "--toggle", "native-fullscreen" } },
  { { "alt", "s" }, "Toggle Split", { "window", "--toggle", "split" } },
}
for _, c in pairs(yabai_commands) do
  state_machine:bind(state_machine.base_state_id, c[1], c[2], function()
    yabai.ipc(c[3])
  end)
end

---------------------------------------------------------------------------------------------------
-- Navigation Mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: Exit navigation state
state_machine:transition("navigation", state_machine.base_state_id, { "", "escape" }, "Exit", function()
  borders.stop()
end)
state_machine:transition("navigation", state_machine.base_state_id, { "", "return" }, "Exit", function()
  borders.stop()
end)

-- STATE TRANSITION: Resize state
state_machine:transition("navigation", "resize", { "", "Z" }, "Resize State")

-- BINDINGS: Yabai movement keys Window movement keys
local yabai_keys = {
  { { "", "h" }, "Focus Left", { "window", "--focus", "west" } },
  { { "", "j" }, "Focus Down", { "window", "--focus", "south" } },
  { { "", "k" }, "Focus Up", { "window", "--focus", "north" } },
  { { "", "l" }, "Focus Right", { "window", "--focus", "east" } },
  { { "", "left" }, "Focus Left", { "window", "--focus", "west" } },
  { { "", "down" }, "Focus Down", { "window", "--focus", "south" } },
  { { "", "up" }, "Focus Up", { "window", "--focus", "north" } },
  { { "", "right" }, "Focus Right", { "window", "--focus", "east" } },

  { { "shift", "h" }, "Warp left", { "window", "--warp", "west" } },
  { { "shift", "j" }, "Warp down", { "window", "--warp", "south" } },
  { { "shift", "k" }, "Warp up", { "window", "--warp", "north" } },
  { { "shift", "l" }, "Warp right", { "window", "--warp", "east" } },
  { { "shift", "left" }, "Warp left", { "window", "--warp", "west" } },
  { { "shift", "up" }, "Warp up", { "window", "--warp", "north" } },
  { { "shift", "down" }, "Warp down", { "window", "--warp", "south" } },
  { { "shift", "right" }, "Warp right", { "window", "--warp", "east" } },
  { { { "cmd", "shift" }, "h" }, "Swap left", { "window", "--swap", "west" } },
  { { { "cmd", "shift" }, "j" }, "Swap down", { "window", "--swap", "south" } },
  { { { "cmd", "shift" }, "k" }, "Swap up", { "window", "--swap", "north" } },
  { { { "cmd", "shift" }, "l" }, "Swap right", { "window", "--swap", "east" } },
  { { { "cmd", "shift" }, "left" }, "Swap left", { "window", "--swap", "west" } },
  { { { "cmd", "shift" }, "up" }, "Swap up", { "window", "--swap", "north" } },
  { { { "cmd", "shift" }, "down" }, "Swap down", { "window", "--swap", "south" } },
  { { { "cmd", "shift" }, "right" }, "Swap right", { "window", "--swap", "east" } },

  { { "cmd", "k" }, "Rotate Clockwise", { "space", "--rotate", "270" } },
  { { "cmd", "j" }, "Rotate Anticlockwise", { "space", "--rotate", "90" } },
  { { "cmd", "up" }, "Rotate Clockwise", { "space", "--rotate", "270" } },
  { { "cmd", "down" }, "Rotate Anticlockwise", { "space", "--rotate", "90" } },

  { { "shift", "\\" }, "Flip on Y", { "space", "--mirror", "y-axis" } },
  { { "", "-" }, "Flip on X", { "space", "--mirror", "x-axis" } },

  { { "alt", "h" }, "Stack left", { "window", "--stack", "west" } },
  { { "alt", "j" }, "Stack down", { "window", "--stack", "south" } },
  { { "alt", "k" }, "Stack up", { "window", "--stack", "north" } },
  { { "alt", "l" }, "Stack right", { "window", "--stack", "east" } },
  { { "alt", "left" }, "Stack left", { "window", "--stack", "west" } },
  { { "alt", "down" }, "Stack down", { "window", "--stack", "south" } },
  { { "alt", "up" }, "Stack up", { "window", "--stack", "north" } },
  { { "alt", "right" }, "Stack right", { "window", "--stack", "east" } },
}
for _, c in pairs(yabai_keys) do
  state_machine:bind("navigation", c[1], c[2], function()
    yabai.ipc(c[3])
  end)
end

-- BIDNING: Move window to space
local function move_window(yk, kk)
  return function()
    yabai.ipc({ "window", "--space", yk })
    hs.timer.doAfter(0.2, function()
      hs.eventtap.event.newKeyEvent("ctrl", true):post()
      hs.eventtap.event.newKeyEvent(kk, true):post()
      hs.eventtap.event.newKeyEvent(kk, false):post()
      hs.eventtap.event.newKeyEvent("ctrl", false):post()
    end)
  end
end
state_machine:bind("navigation", { "cmd", "h" }, "Move Window", move_window("prev", "left"))
state_machine:bind("navigation", { "cmd", "left" }, "Move Window", move_window("prev", "left"))
state_machine:bind("navigation", { "cmd", "l" }, "Move Window", move_window("next", "right"))
state_machine:bind("navigation", { "cmd", "right" }, "Move Window", move_window("next", "right"))

-- BINDING: Move floating window
local move_commands = {
  h = function(f)
    f.x = f.x - 10
    return f
  end,
  l = function(f)
    f.x = f.x + 10
    return f
  end,
  j = function(f)
    f.y = f.y + 10
    return f
  end,
  k = function(f)
    f.y = f.y - 10
    return f
  end,
  left = function(f)
    f.x = f.x - 10
    return f
  end,
  right = function(f)
    f.x = f.x + 10
    return f
  end,
  down = function(f)
    f.y = f.y + 10
    return f
  end,
  up = function(f)
    f.y = f.y - 10
    return f
  end,
}
for k, v in pairs(move_commands) do
  state_machine:bind("navigation", { hyper, k }, "Move Window", function()
    local win = hs.window.focusedWindow()
    if not win then
      return
    end
    yabai.is_floating(win:id(), function()
      local update = v(win:frame())
      win:setFrame(update)
    end)
  end)
end

-- BINDING: Move in stack
state_machine:bind("navigation", { "", "tab" }, "Stack move forward", function()
  yabai.ipc({ "window", "--focus", "stack.next" }, nil, function(_)
    yabai.ipc({ "window", "--focus", "stack.first" })
  end)
end)

state_machine:bind("navigation", { "shift", "tab" }, "Stack move backward", function()
  yabai.ipc({ "window", "--focus", "stack.prev" }, nil, function(_)
    yabai.ipc({ "window", "--focus", "stack.last" })
  end)
end)

---------------------------------------------------------------------------------------------------
-- Resize mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: Exit resize state
state_machine:transition("resize", state_machine.base_state_id, { "", "escape" }, "Exit", function()
  borders:stop()
end)

-- BINDINGS: Yabai resize keys Window movement keys
yabai_keys = {
  { { "", "0" }, "Equalize windows", { "space", "--balance" } },
  { { "", "p" }, "Zoom parent", { "window", "--toggle", "zoom-parent" } },
}
for _, c in pairs(yabai_keys) do
  state_machine:bind("resize", c[1], c[2], function()
    yabai.ipc(c[3])
  end)
end

-- BINDINGS: Increase and decrease window gaps
local gap = 0
state_machine:bind("resize", { "", "-" }, "Decrease Gap", function()
  gap = gap - 10
  if gap < 0 then
    gap = 0
  end
  yabai.ipc({ "space", "--gap", string.format("abs:%d", gap) })
end)
state_machine:bind("resize", { "shift", "=" }, "Increase Gap", function()
  gap = gap + 10
  yabai.ipc({ "space", "--gap", string.format("abs:%d", gap) })
end)

-- BINDINGS: Window resize keys
yabai_keys = {
  h = { "left:-20:0", "right:-20:0" },
  j = { "bottom:0:20", "top:0:20" },
  k = { "bottom:0:-20", "top:0:-20" },
  l = { "left:20:0", "right:20:0" },
  left = { "left:-20:0", "right:-20:0" },
  down = { "bottom:0:20", "top:0:20" },
  up = { "bottom:0:-20", "top:0:-20" },
  right = { "left:20:0", "right:20:0" },
}
for k, c in pairs(yabai_keys) do
  state_machine:bind("resize", { "", k }, "Resize Window", function()
    yabai.ipc({ "window", "--resize", c[1] })
    yabai.ipc({ "window", "--resize", c[2] })
  end)
end

-- BINDING: Screen positons
local positions = {
  left = { { 0, 0, 0.5, 1 }, "Halves - L" },
  up = { { 0, 0, 1, 0.5 }, "Halves - T" },
  right = { { 0.5, 0, 0.5, 1 }, "Halves - R" },
  down = { { 0, 0.5, 1, 0.5 }, "Halves - L" },
  r = { { 0, 0, 0.5, 0.5 }, "Quarters - TR" },
  t = { { 0.5, 0, 0.5, 0.5 }, "Quarters - TL" },
  g = { { 0.5, 0.5, 0.5, 0.5 }, "Quarters - BR" },
  f = { { 0, 0.5, 0.5, 0.5 }, "Quarters - BL" },
  q = { { 0, 0, 0.33333, 1 }, "Thirds - L" },
  w = { { 0.33333, 0, 0.33333, 1 }, "Thirds - M" },
  e = { { 0.66666, 0, 0.33333, 1 }, "Thirds - R" },
  v = { { 0, 0, 0.66666, 1 }, "Two Thirds - L" },
  a = { { 0, 0, 0.33333, 0.5 }, "Sixths - TL" },
  s = { { 0.33333, 0, 0.33333, 0.5 }, "Sixths - TM" },
  d = { { 0.66666, 0, 0.33333, 0.5 }, "Sixths - TR" },
  z = { { 0, 0.5, 0.33333, 0.5 }, "Sixths - BL" },
  x = { { 0.33333, 0.5, 0.33333, 0.5 }, "Sixths - BM" },
  c = { { 0.66666, 0.5, 0.33333, 0.5 }, "Sixths - BR" },
}
for k, v in pairs(positions) do
  state_machine:bind("resize", { { "cmd" }, k }, v[2], function()
    local window = hs.window.focusedWindow()
    if not window then
      return
    end
    yabai.is_floating(window:id(), function()
      window:move(v[1])
    end)
  end)
end

---------------------------------------------------------------------------------------------------
-- Keycaster Mode
---------------------------------------------------------------------------------------------------
-- STATE TRANSITION: To normal mode
state_machine:transition("keycaster", state_machine.base_state_id, { hyper, "k" }, "Exit", function()
  keycaster:stop()
end)

---------------------------------------------------------------------------------------------------
-- Initialize the modal supervisor
---------------------------------------------------------------------------------------------------
state_machine:activate("base")

---------------------------------------------------------------------------------------------------
-- Setup watchers
---------------------------------------------------------------------------------------------------
-- Watch for configuration change
local config_watcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
    hs.notify.new({
      title = "Hammerspoon",
      informativeText = "Hammerspoon configuration reloaded",
      withdrawAfter = 10,
    }):send()
  end
end)
config_watcher:start()

-- Set volume to zero after sleep
local sleep_watcher = hs.caffeinate.watcher.new(function(eventType)
  if eventType == hs.caffeinate.watcher.systemDidWake then
    hs.audiodevice.defaultOutputDevice():setMuted(true)
  end
end)
sleep_watcher:start()

-- Wifi status watcher
local wifi_watcher = hs.wifi.watcher.new(function()
  local net = hs.wifi.currentNetwork()
  if net == nil then
    hs.notify.new({
      title = "Hammerspoon",
      informativeText = "Wi-Fi disconnected",
      withdrawAfter = 10,
    }):send()
  else
    hs.notify.new({
      title = "Hammerspoon",
      informativeText = "Wi-Fi connected to " .. net,
      withdrawAfter = 10,
    }):send()
  end
end)
wifi_watcher:start()
