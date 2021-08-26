local module = {}

module.sock_file = string.format("/tmp/yabai_%s.socket", os.getenv("USER"))
module.sock_timeout = 5
module.socket = hs.socket

module.ipc = function(args, callback)
  callback = callback or function(x) return x end

  local msg = ""
  for k, c in pairs(args) do
    msg = msg .. tostring(c) .. string.char(0)
  end
  msg = msg .. string.char(0)

  local sock = module.socket.new()
  local res = ""
  sock:setTimeout(module.sock_timeout or -1)
  sock:connect(module.sock_file, function()
    sock:write(msg, function(_)
      sock:setCallback(function(data, _)
        res = res .. data
        if sock:connected() then
          sock:read('\n')
        else
          callback(res)
        end
      end)
      sock:read('\n')
    end)
  end)
end

return module
