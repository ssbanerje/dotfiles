require "hs.wifi"
require "hs.window"
require "hs.pathwatcher"

-- Grid settings
hs.grid.GRIDWIDTH  = 3
hs.grid.GRIDHEIGHT = 3
hs.grid.MARGINX    = 0
hs.grid.MARGINY    = 0
hs.hotkey.bind("cmd", "G", hs.grid.show)

-- Set window animation off. It's much smoother.
hs.window.animationDuration = 0

-- hot key
hs.hotkey.bind({"cmd", "ctrl"}, "J", function()
  hs.hints.windowHints(hs.window.visibleWindows(), nil, false)
end)

hs.hotkey.bind("cmd", "M", hs.grid.maximizeWindow)

-- Move windows
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Y", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - 10
  f.y = f.y - 10
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "K", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y - 10
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "U", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + 10
  f.y = f.y - 10
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "H", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - 10
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "L", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + 10
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "N", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x - 10
  f.y = f.y + 10
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "J", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.y = f.y + 10
  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  f.x = f.x + 10
  f.y = f.y + 10
  win:setFrame(f)
end)

-- reload config
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
local myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")

-- Home
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "H", function()
  hs.grid.GRIDWIDTH  = 4
  hs.grid.GRIDHEIGHT = 4
  hs.grid.MARGINX    = 0
  hs.grid.MARGINY    = 0
  hs.alert.show("External Monitor Layout")
end)

hs.hotkey.bind({"cmd", "shift", "ctrl"}, "L", function()
  hs.grid.GRIDWIDTH  = 3
  hs.grid.GRIDHEIGHT = 3
  hs.grid.MARGINX    = 0
  hs.grid.MARGINY    = 0
  hs.alert.show("Laptop Monitor Layout")
end)

-- Wifi status watcher
hs.wifi.watcher.new(function ()
  local currentWifi = hs.wifi.currentNetwork()
  -- short-circuit if disconnecting
  if not currentWifi then return end
  hs.alert.show("Wi-Fi connected to " .. currentWifi, 3)
  hs.audiodevice.defaultOutputDevice():setVolume(0)
end):start()
