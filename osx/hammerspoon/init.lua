require "hs.wifi"
require "hs.window"
require "hs.pathwatcher"
require "hs.caffeinate"

-- ------------------------------------------------------
-- Variables 
-- ------------------------------------------------------
hyper = {"cmd","ctrl"}
hyper_alt = {"cmd", "ctrl", "alt"}
hs.window.animationDuration = 0
hs.grid.GRIDWIDTH  = 4
hs.grid.GRIDHEIGHT = 4
hs.grid.MARGINX    = 0
hs.grid.MARGINY    = 0

-- ------------------------------------------------------
-- Hotkeys
-- ------------------------------------------------------

-- Show grid
hs.hotkey.bind(hyper, 'g', hs.grid.show)
hs.hotkey.bind("cmd", 'g', hs.grid.show)

-- Maximize window
hs.hotkey.bind(hyper, 'm', hs.grid.maximizeWindow)
hs.hotkey.bind("cmd", 'm', hs.grid.maximizeWindow)

-- Screen halves
hs.hotkey.bind(hyper, "Left", function () 
  hs.window.focusedWindow():move(hs.layout.left50)
end)
hs.hotkey.bind(hyper, "Right", function () 
  hs.window.focusedWindow():move(hs.layout.right50)
end)
hs.hotkey.bind(hyper, "Up", function () 
  hs.window.focusedWindow():move({0, 0, 1, 0.5})
end)
hs.hotkey.bind(hyper, "Down", function () 
  hs.window.focusedWindow():move({0, 0.5, 1, 0.5})
end)

-- Lock Screen
hs.hotkey.bind(hyper, 'l', hs.caffeinate.lockScreen)

-- Toggle console
hs.hotkey.bind(hyper, 'y', hs.toggleConsole)

-- Reload configuration
hs.hotkey.bind(hyper, 'r', hs.reload)

-- ------------------------------------------------------
-- Watchers
-- ------------------------------------------------------

-- Hammerspoon configuration watcher
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function (files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end):start()
hs.alert.show("Hammerspoon Configuration Loaded")

-- Wifi status watcher
hs.wifi.watcher.new(function ()
  local currentWifi = hs.wifi.currentNetwork()
  if not currentWifi then return end
  hs.alert.show("Wi-Fi connected to " .. currentWifi, 3)
  hs.audiodevice.defaultOutputDevice():setVolume(0)
end):start()
