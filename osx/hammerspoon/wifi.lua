require "hs.wifi"
require "hs.audiodevice"

-- Wifi status watcher
hs.wifi.watcher.new(function ()
  local currentWifi = hs.wifi.currentNetwork()
  if not currentWifi then return end
  hs.notify.new({title="Hammerspoon", informativeText="Wi-Fi connected to " .. currentWifi}):send()
end):start()
