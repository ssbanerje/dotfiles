-- All modes:
--  > Hyper + ` -> Hammerspoon console
--
-- Normal Mode:
--  * Alt + N -> Navigate
--  * Hyper + K -> Keycaster Mode
--  > Hyper + Enter -> Toggle yabai layout for space
--  > Alt + Enter -> Kitty terminal
--  > Alt + Cmd + Enter -> iTerm
--  > Alt + Shift + Enter -> Safari
--  > Alt + Space -> Toggle Float
--  > Alt + s -> Toggle Split
--  > Alt + m -> Toggle Fullscreen
--  > Alt + Shift + m -> Toggle Native Fullscreen
--
-- Navigate Mode:
--  * Z -> Resize mode
--  * Esc / Enter -> Normal mode
--  > HJKL/Arrows -> Focus window
--  > Shift + HJKL/Arrows -> Warp window
--  > Cmd + Shift + HJKL/Arrows -> Swap window
--  > Cmd + HL/Left/Right -> Send window to prev/next Space & follow
--  > Cmd + JK/Up/Down -> Rotate space (counter)clockwise
--  > | -> Flip on Y axis
--  > - -> Flip on X axis
--  > Hyper + HJKL/Arrows (floating) -> Move window
--  > Alt + HJKL/Arrows -> Stack window
--  > Tab / Shift + Tab -> Cycle stack
--
-- Resize Mode:
--  * Esc -> Normal mode
--  > HJKL/Arrows -> Resize window
--  > + / - -> Increase / decrease gaps
--  > 0 -> Equalize windows
--  > p -> Toggle zoom parent
--  > Cmd + Arrows (floating) -> Half-screen snaps
--  > Cmd + RTFG (floating) -> Quarter-screen snaps
--  > Cmd + QWEV (floating) -> Third-screen snaps
--  > Cmd + ASDZXC (floating) -> Sixth-screen snaps
--
-- Keycaster Mode:
--  * Hyper + K -> Normal mode

---------------------------------------------------------------------------------------------------
-- Defaults
---------------------------------------------------------------------------------------------------
hs.console.clearConsole()
hs.logger.defaultLogLevel = "warning"
hs.window.animationDuration = 0

local hyper = { "cmd", "ctrl", "alt", "shift" }
local home_dir = os.getenv("HOME")

local borders = require("window_borders")
local keycaster = require("keycaster")
local yabai = require("yabai")

local dirs = {
  { keys = { "h", "left" }, compass = "west", label = "Left", dx = -10, dy = 0, resize = { "left:-20:0", "right:-20:0" } },
  { keys = { "j", "down" }, compass = "south", label = "Down", dx = 0, dy = 10, resize = { "bottom:0:20", "top:0:20" } },
  { keys = { "k", "up" }, compass = "north", label = "Up", dx = 0, dy = -10, resize = { "bottom:0:-20", "top:0:-20" } },
  { keys = { "l", "right" }, compass = "east", label = "Right", dx = 10, dy = 0, resize = { "left:20:0", "right:20:0" } },
}

---------------------------------------------------------------------------------------------------
-- Hammerspoon console
---------------------------------------------------------------------------------------------------
hs.hotkey.bind(hyper, "`", "Toggle Hammerspoon Console", hs.toggleConsole)

---------------------------------------------------------------------------------------------------
-- State Machine
---------------------------------------------------------------------------------------------------
local state_machine = require("state_machine"):init()
state_machine:new_state("navigation", "#d53e4f", { on_enter = borders.start, on_exit = borders.stop })
state_machine:new_state("resize", "#e6f598", { on_enter = borders.start, on_exit = borders.stop })
state_machine:new_state("keycaster", "#3288bd", {
  on_enter = function()
    keycaster:start()
  end,
  on_exit = function()
    keycaster:stop()
  end,
})

local function bind_dirs(state, mods, prefix, handler)
  for _, dir in ipairs(dirs) do
    for _, key in ipairs(dir.keys) do
      state_machine:bind(state, { mods, key }, prefix .. " " .. dir.label, function()
        handler(dir)
      end)
    end
  end
end

---------------------------------------------------------------------------------------------------
-- Normal Mode
---------------------------------------------------------------------------------------------------
state_machine:transition("base", "navigation", { "alt", "n" }, "Navigation Mode")
state_machine:transition("base", "keycaster", { hyper, "k" }, "Keycaster Mode")

local yabai_bsp_enabled = true
state_machine:bind("base", { hyper, "return" }, "Toggle Yabai", function()
  local layout = yabai_bsp_enabled and "float" or "bsp"
  yabai_bsp_enabled = not yabai_bsp_enabled
  yabai.ipc({ "space", "--layout", layout })
end)

state_machine:bind("base", { "alt", "return" }, "Open kitty", function()
  local app = hs.application.get("net.kovidgoyal.kitty")
  if app then
    local bin = app:path() .. "/Contents/MacOS/kitty"
    hs.task.new(bin, nil, { "-1", "-d=" .. home_dir }):start()
  else
    hs.application.launchOrFocusByBundleID("net.kovidgoyal.kitty")
  end
end)

state_machine:bind("base", { { "cmd", "alt" }, "return" }, "Open iTerm", function()
  if hs.application.get("com.googlecode.iterm2") then
    hs.osascript.applescript('tell application id "com.googlecode.iterm2" to create window with default profile')
  else
    hs.application.launchOrFocusByBundleID("com.googlecode.iterm2")
  end
end)

state_machine:bind("base", { { "alt", "shift" }, "return" }, "Open Safari", function()
  if hs.application.get("com.apple.Safari") then
    hs.osascript.applescript([[
      tell application id "com.apple.Safari"
        make new document
        activate
      end tell
    ]])
  else
    hs.application.launchOrFocusByBundleID("com.apple.Safari")
  end
end)

for _, cmd in ipairs({
  { { "alt", "space" }, "Toggle Float", { "window", "--toggle", "float" } },
  { { "alt", "m" }, "Fullscreen", { "window", "--toggle", "zoom-fullscreen" } },
  { { { "alt", "shift" }, "m" }, "Native Fullscreen", { "window", "--toggle", "native-fullscreen" } },
  { { "alt", "s" }, "Toggle Split", { "window", "--toggle", "split" } },
}) do
  state_machine:bind("base", cmd[1], cmd[2], function()
    yabai.ipc(cmd[3])
  end)
end

---------------------------------------------------------------------------------------------------
-- Navigation Mode
---------------------------------------------------------------------------------------------------
state_machine:transition("navigation", "base", { "", "escape" }, "Exit")
state_machine:transition("navigation", "base", { "", "return" }, "Exit")
state_machine:transition("navigation", "resize", { "", "Z" }, "Resize State")

bind_dirs("navigation", "", "Focus", function(d)
  yabai.ipc({ "window", "--focus", d.compass })
end)
bind_dirs("navigation", "shift", "Warp", function(d)
  yabai.ipc({ "window", "--warp", d.compass })
end)
bind_dirs("navigation", { "cmd", "shift" }, "Swap", function(d)
  yabai.ipc({ "window", "--swap", d.compass })
end)
bind_dirs("navigation", "alt", "Stack", function(d)
  yabai.ipc({ "window", "--stack", d.compass })
end)
bind_dirs("navigation", hyper, "Move Floating", function(d)
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  yabai.is_floating(win:id(), function()
    win:move({ d.dx, d.dy }, nil, false, 0)
  end)
end)

for _, binding in ipairs({
  { { "cmd", "k" }, "Rotate Clockwise", { "space", "--rotate", "270" } },
  { { "cmd", "up" }, "Rotate Clockwise", { "space", "--rotate", "270" } },
  { { "cmd", "j" }, "Rotate Anticlockwise", { "space", "--rotate", "90" } },
  { { "cmd", "down" }, "Rotate Anticlockwise", { "space", "--rotate", "90" } },
  { { "shift", "\\" }, "Flip on Y", { "space", "--mirror", "y-axis" } },
  { { "", "-" }, "Flip on X", { "space", "--mirror", "x-axis" } },
  { { "cmd", "h" }, "Send Window Prev Space", { "window", "--space", "prev", "--focus" } },
  { { "cmd", "left" }, "Send Window Prev Space", { "window", "--space", "prev", "--focus" } },
  { { "cmd", "l" }, "Send Window Next Space", { "window", "--space", "next", "--focus" } },
  { { "cmd", "right" }, "Send Window Next Space", { "window", "--space", "next", "--focus" } },
}) do
  state_machine:bind("navigation", binding[1], binding[2], function()
    yabai.ipc(binding[3])
  end)
end

state_machine:bind("navigation", { "", "tab" }, "Stack next", function()
  yabai.ipc({ "window", "--focus", "stack.next" }, nil, function(_)
    yabai.ipc({ "window", "--focus", "stack.first" })
  end)
end)
state_machine:bind("navigation", { "shift", "tab" }, "Stack previous", function()
  yabai.ipc({ "window", "--focus", "stack.prev" }, nil, function(_)
    yabai.ipc({ "window", "--focus", "stack.last" })
  end)
end)

---------------------------------------------------------------------------------------------------
-- Resize Mode
---------------------------------------------------------------------------------------------------
state_machine:transition("resize", "base", { "", "escape" }, "Exit")

state_machine:bind("resize", { "", "0" }, "Equalize windows", function()
  yabai.ipc({ "space", "--balance" })
end)
state_machine:bind("resize", { "", "p" }, "Zoom parent", function()
  yabai.ipc({ "window", "--toggle", "zoom-parent" })
end)

local gap = 0
state_machine:bind("resize", { "", "-" }, "Decrease Gap", function()
  gap = math.max(0, gap - 10)
  yabai.ipc({ "space", "--gap", string.format("abs:%d", gap) })
end)
state_machine:bind("resize", { "shift", "=" }, "Increase Gap", function()
  gap = gap + 10
  yabai.ipc({ "space", "--gap", string.format("abs:%d", gap) })
end)

bind_dirs("resize", "", "Resize", function(d)
  yabai.ipc({ "window", "--resize", d.resize[1] })
  yabai.ipc({ "window", "--resize", d.resize[2] })
end)

local unit_positions = {
  left = { { 0, 0, 0.5, 1 }, "Halves - L" },
  up = { { 0, 0, 1, 0.5 }, "Halves - T" },
  right = { { 0.5, 0, 0.5, 1 }, "Halves - R" },
  down = { { 0, 0.5, 1, 0.5 }, "Halves - B" },
  r = { { 0, 0, 0.5, 0.5 }, "Quarters - TL" },
  t = { { 0.5, 0, 0.5, 0.5 }, "Quarters - TR" },
  f = { { 0, 0.5, 0.5, 0.5 }, "Quarters - BL" },
  g = { { 0.5, 0.5, 0.5, 0.5 }, "Quarters - BR" },
  q = { { 0, 0, 1 / 3, 1 }, "Thirds - L" },
  w = { { 1 / 3, 0, 1 / 3, 1 }, "Thirds - M" },
  e = { { 2 / 3, 0, 1 / 3, 1 }, "Thirds - R" },
  v = { { 0, 0, 2 / 3, 1 }, "Two Thirds - L" },
  a = { { 0, 0, 1 / 3, 0.5 }, "Sixths - TL" },
  s = { { 1 / 3, 0, 1 / 3, 0.5 }, "Sixths - TM" },
  d = { { 2 / 3, 0, 1 / 3, 0.5 }, "Sixths - TR" },
  z = { { 0, 0.5, 1 / 3, 0.5 }, "Sixths - BL" },
  x = { { 1 / 3, 0.5, 1 / 3, 0.5 }, "Sixths - BM" },
  c = { { 2 / 3, 0.5, 1 / 3, 0.5 }, "Sixths - BR" },
}
for key, spec in pairs(unit_positions) do
  state_machine:bind("resize", { "cmd", key }, spec[2], function()
    local win = hs.window.focusedWindow()
    if not win then
      return
    end
    yabai.is_floating(win:id(), function()
      win:moveToUnit(spec[1], 0)
    end)
  end)
end

---------------------------------------------------------------------------------------------------
-- Keycaster Mode
---------------------------------------------------------------------------------------------------
state_machine:transition("keycaster", "base", { hyper, "k" }, "Exit")

---------------------------------------------------------------------------------------------------
-- Watchers (retained in globals so Lua GC never collects active watchers)
---------------------------------------------------------------------------------------------------
_G.dotfiles_watchers = {
  config = hs.pathwatcher.new(home_dir .. "/.hammerspoon/", function(files)
    for _, file in ipairs(files) do
      if file:sub(-4) == ".lua" then
        hs.reload()
        return
      end
    end
  end):start(),

  sleep = hs.caffeinate.watcher.new(function(event_type)
    if event_type == hs.caffeinate.watcher.systemDidWake then
      local dev = hs.audiodevice.defaultOutputDevice()
      if dev then
        dev:setOutputMuted(true)
      end
    end
  end):start(),

  wifi = hs.wifi.watcher.new(function()
    local net = hs.wifi.currentNetwork()
    local details = hs.wifi.interfaceDetails()
    local connected = net ~= nil or (details and details.power and details.active)
    local text = net and ("Wi-Fi connected to " .. net)
      or (connected and "Wi-Fi connected" or "Wi-Fi disconnected")
    hs.notify.new({
      title = "Hammerspoon",
      informativeText = text,
      withdrawAfter = 10,
    }):send()
  end):start(),
}

hs.alert.show("Hammerspoon configuration loaded", 1)
