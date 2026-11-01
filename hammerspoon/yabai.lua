local module = {}

module.sock_file = string.format("/tmp/yabai_%s.socket", os.getenv("USER"))
module.sock_timeout = 5

-- Interact with Yabai over its UNIX domain socket
function module.ipc(command, callback_success, callback_failure)
  local parts = {}
  for i, arg in ipairs(command) do
    parts[i] = tostring(arg)
  end
  local msg = table.concat(parts, "\0") .. "\0\0"

  local sock = hs.socket.new()
  local chunks = {}
  sock:setTimeout(module.sock_timeout or -1)
  sock:connect(module.sock_file, function()
    sock:write(msg, function(_)
      sock:setCallback(function(data, _)
        if data then
          chunks[#chunks + 1] = data
        end
        if sock:connected() then
          sock:read("\n")
        else
          local res = table.concat(chunks)
          if res:sub(1, 1) ~= "\x07" then
            if callback_success then
              callback_success(res)
            end
          elseif callback_failure then
            callback_failure(res)
          end
        end
      end)
      sock:read("\n")
    end)
  end)
end

-- Invoke `callback` only when `window_id` is currently floating in Yabai
function module.is_floating(window_id, callback)
  module.ipc({ "query", "--windows", "--window", tostring(window_id) }, function(payload)
    local ok, meta = pcall(hs.json.decode, payload)
    if ok and type(meta) == "table" and (meta["is-floating"] == true or meta.floating == 1) then
      callback()
    end
  end)
end

return module
