require "hs.wifi"
require "hs.window"
require "hs.pathwatcher"
require "hs.caffeinate"

-- Set window animation off. It's much smoother.
hs.window.animationDuration = 0

-- ------------------------------------------------------
-- Grid settings
-- ------------------------------------------------------

hs.grid.GRIDWIDTH  = 4
hs.grid.GRIDHEIGHT = 4
hs.grid.MARGINX    = 0
hs.grid.MARGINY    = 0

-- Hotkey to activate grid
hs.hotkey.bind("cmd", "G", hs.grid.show)

-- ------------------------------------------------------
-- Hotkeys
-- ------------------------------------------------------

-- Maximize window
hs.hotkey.bind("cmd", "M", hs.grid.maximizeWindow)

-- Setup Sleep Inhibitor
local sleep_menu_icon
local function disable()
  hs.caffeinate.set("displayIdle", false, false)
  hs.caffeinate.set("systemIdle", false, false)
  hs.caffeinate.set("system", false, false)
  sleep_menu_icon:delete()
end
local function enable()
  hs.caffeinate.set("displayIdle", true, true)
  hs.caffeinate.set("systemIdle", true, true)
  hs.caffeinate.set("system", true, true)
  if not menu then
      sleep_menu_icon = hs.menubar.new()
  end
  sleep_menu_icon:returnToMenuBar()
  sleep_menu_icon:setTitle("☕️")
  sleep_menu_icon:setTooltip("Mocha")
  sleep_menu_icon:setClickCallback(function() disable() end)
end
hs.hotkey.bind({"ctrl", "alt", "cmd"}, "S", function()
  if sleep_menu_icon then
    disable()
  else
    enable()
  end
end)

-- Lock Screen
hs.hotkey.bind({"ctrl", "alt"}, "L", hs.caffeinate.lockScreen)

-- Launch iTerm2
hs.hotkey.bind({"ctrl", "alt"}, "T", function ()
  hs.application.launchOrFocus("iTerm")
end)

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
