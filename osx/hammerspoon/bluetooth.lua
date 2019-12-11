require "string"
require "hs.caffeinate"

function bluetooth(power)
  print("Setting bluetooth to " .. power)
  hs.task.new("/usr/local/bin/blueutil", function (rc, stderr, stdout)
    if rc ~= 0 then
        print(string.format("Unexpected result executing `blueutil`: rc=%d stderr=%s stdout=%s", rc, stderr, stdout))
    end
  end, {"--power", power}):start()
end

hs.caffeinate.watcher.new(function (event)
  if event == hs.caffeinate.watcher.systemWillSleep then
    bluetooth("off")
  elseif event == hs.caffeinate.watcher.screensDidWake then
     bluetooth("on")
   end
end):start()
