require "hs.wifi"
require "hs.caffeinate"

-- Set grid size.
hs.grid.GRIDWIDTH  = 2
hs.grid.GRIDHEIGHT = 2
hs.grid.MARGINX    = 0
hs.grid.MARGINY    = 0
-- Set window animation off. It's much smoother.
hs.window.animationDuration = 0

-- hot key
hs.hotkey.bind("cmd", "J", function()
                 hs.hints.windowHints(hs.window.visibleWindows(),
                                      nil,
                                      false
                 )
                 end
)

hs.hotkey.bind("cmd", "G", hs.grid.show)
hs.hotkey.bind("cmd", ";", hs.grid.maximizeWindow)


-- reload config
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "R", function()
      hs.reload()
      hs.alert.show("Config reloaded!")
end)

-- Home
hs.hotkey.bind({"cmd", "shift", "ctrl"}, "H", function()
      local laptopScreen = "Color LCD"
      local thunderboltDisplay = "Thunderbolt Display"
      local hpDisplay = "HP Z23i"
      local windowLayout = {
         {"Google Chrome",  nil,          thunderboltDisplay, hs.layout.left50,    nil, nil},
         {"Terminal",    nil,          hpDisplay, hs.layout.maximized,   nil, nil},
         {"Spotify",    nil,          laptopScreen, hs.layout.maximized,   nil, nil},
      }
      hs.layout.apply(windowLayout)
      hs.alert.show("Layout home loaded")
end)


-- hs.hotkey.bind({"cmd", "shift", "ctrl"}, "M", function()
--       local laptopScreen = "Color LCD"
--       local thunderboltDisplay = "Thunderbolt Display"
--       local hpDisplay = "HP Z23i"
--       local windowLayout = {
--          {"Google Chrome",  nil,          hpdisplay, hs.layout.maximized,    nil, nil},
--          {"Preview",  nil,          thunderboltDisplay, hs.layout.right50,    nil, nil},
--          {"nvALT",    nil,          thunderboltDisplay, geometry.rect(0.5, 0.5, 0.5, 0.5),   nil, nil},
--          {"Mail",    nil,          thunderboltDisplay, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"Microsoft Outlook",    nil,          thunderboltDisplay, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"Messages",    nil,          thunderboltDisplay, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"Terminal",    nil,          thunderboltDisplay, hs.layout.maximized,   nil, nil},
--          {"Spotify",    nil,          laptopScreen, hs.layout.maximized,   nil, nil},
--          {"Safari",    nil,          laptopScreen, hs.layout.maximized,   nil, nil},
--       }
--       hs.layout.apply(windowLayout)
--       hs.alert.show("Layout loaded")
-- end)


-- hs.hotkey.bind({"cmd", "shift", "ctrl"}, "T", function()
--       local laptopScreen = "Color LCD"
--       local thunderboltDisplay = "Thunderbolt Display"
--       local hpDisplay = "HP Z23i"
--       local windowLayout = {
--          {"Google Chrome",  nil,          laptopScreen, hs.layout.maximized,    nil, nil},
--          {"Terminal",    nil,          hpDisplay, hs.layout.maximized,   nil, nil},
--          {"Spotify",    nil,          laptopScreen, hs.layout.maximized,   nil, nil},
--          {"Preview",  nil,          thunderboltDisplay, hs.layout.right50,    nil, nil},
--          {"Microsoft Outlook",    nil,          thunderboltDisplay, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"Mail",    nil,          thunderboltDisplay, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"nvALT",    nil,          thunderboltDisplay, geometry.rect(0.5, 0.5, 0.5, 0.5),   nil, nil},
--       }
--       hs.layout.apply(windowLayout)
--       hs.alert.show("Layout loaded")
-- end)


-- -- work
-- hs.hotkey.bind({"cmd", "shift", "ctrl"}, "W", function()
--       local laptopScreen = "Color LCD"
--       local Display = "Display"
--       local hpDisplay = "HP LP2065"
--       local windowLayout = {
--          {"Google Chrome",  nil,          hpDisplay, hs.layout.maximized,    nil, nil},
--          {"Emacs",    nil,          Display, geometry.rect(0.5, 0.5, 0.5, 0.5),   nil, nil},
--          {"Preview",  nil,          hpDisplay, hs.layout.maximized,    nil, nil},
--          {"nvALT",    nil,          Display, geometry.rect(0.5, 0.5, 0.5, 0.5),   nil, nil},
--          {"Mail",    nil,          Display, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"Microsoft Outlook",    nil,          Display, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"Messages",    nil,          Display, geometry.rect(0.5, 0, 0.5, 0.5),   nil, nil},
--          {"Terminal",    nil,          Display, hs.layout.maximized,   nil, nil},
--          {"Spotify",    nil,          laptopScreen, hs.layout.maximized,   nil, nil},
--          {"Safari",    nil,          laptopScreen, hs.layout.maximized,   nil, nil},
--       }
--       hs.layout.apply(windowLayout)
--       hs.alert.show("Layout loaded")
-- end)

hs.hotkey.bind({"cmd", "shift", "ctrl"}, "P", function()
      local laptopScreen = "Color LCD"
      local windowLayout = {
         {"Chrome",  nil,          laptopScreen, geometry.rect(0, 0.5, 0.5, 0.5),    nil, nil},
         {"Terminal",    nil,          laptopScreen, geometry.rect(0.0, 0.0, 0.5, 0.5),   nil, nil},
      }
      hs.layout.apply(windowLayout)
      hs.alert.show("Layout loaded")
end)

------------------
-- wifi watcher --
------------------
hs.wifi.watcher.new(function ()
    local currentWifi = hs.wifi.currentNetwork()
    -- short-circuit if disconnecting
    if not currentWifi then return end
    hs.alert.show("Wi-Fi connected to " .. currentWifi, 3)
    hs.audiodevice.defaultOutputDevice():setVolume(0)
end):start()