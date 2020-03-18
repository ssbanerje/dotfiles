-- Watch for configuration changes
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function (files)
  local doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
    hs.notify.new({title="Hammerspoon", informativeText="Hammerspoon configuration reloaded"}):send()
  end
end):start()
