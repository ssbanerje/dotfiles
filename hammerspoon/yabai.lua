local module = {}

module.sock_file = string.format("/tmp/yabai_%s.socket", os.getenv("USER"))
module.sock_timeout = 5

-- Interact with the Yabai instance with a UNIX domain socket
function module.ipc(command, callback_success, callback_failure)
  callback_success = callback_success or function(x)
    return x
  end
  callback_failure = callback_failure or function(x)
    return x
  end

  local msg = ""
  for _, c in ipairs(command) do
    msg = msg .. tostring(c) .. string.char(0)
  end
  msg = msg .. string.char(0)

  local sock = hs.socket.new()
  local res = ""
  sock:setTimeout(module.sock_timeout or -1)
  sock:connect(module.sock_file, function()
    sock:write(msg, function(_)
      sock:setCallback(function(data, _)
        res = res .. data
        if sock:connected() then
          sock:read("\n")
        else
          if res:sub(1, 1) ~= "\x07" then
            callback_success(res)
          else
            callback_failure(res)
          end
        end
      end)
      sock:read("\n")
    end)
  end)
end

-- Interact with the Yabai instance over the CLI
function module.exec(command, callback)
  callback = callback or function(x)
    return x
  end

  hs.task.new("/usr/local/bin/yabai", callback, function(_, ...)
    print("Yabai Output =>", hs.inspect(table.pack(...)))
    return true
  end, {
    "-m",
    table.unpack(command),
  }):start()
end

-- Check if a window is floating and run call back if it is
function module.is_floating(window_id, callback)
  module:ipc({ "query", "--windows", "--window", tostring(window_id) }, function(x)
    local meta = hs.json.decode(x)
    if meta.floating == 1 then
      callback()
    end
  end)
end

return module
