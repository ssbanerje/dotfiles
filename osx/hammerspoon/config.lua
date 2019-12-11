require "hs.hotkey"
require "hs.notify"
require "hs.pathwatcher"

-- Perform reload
function reload()
  hs.reload()
  hs.notify.new({title="Hammerspoon", informativeText="Hammerspoon configuration reloaded"}):send()
end

-- Reload by hotkey
hs.hotkey.bind(hyper, 'r', reload)

-- Watch for configuration changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function (files)
  local doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    reload()
  end
end):start()

