require "hs.caffeinate"
require "hs.audiodevice"

-- Set volume to zero
hs.caffeinate.watcher.new(function(eventType)
  if (eventType == hs.caffeinate.watcher.systemDidWake) then
    hs.audiodevice.defaultOutputDevice():setMuted(true)
  end
end):start()
