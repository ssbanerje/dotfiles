local obj = {}

obj._box = nil

-- Show a message in oncscree textbox
function obj:show(message, pos)
  if obj._box ~= nil then
    obj._box:delete()
  end
  if pos == nil then
    local res = hs.window.focusedWindow():screen():frame()
    pos = {
      x = 50,
      y = res.h - 300,
      w = res.w - 100,
      h = 150,
    }
  end
  obj._box = hs.canvas.new(pos)
  obj._box:appendElements({
    type = 'rectangle',
    fillColor = {white = 0.125, alpha = 0.8},
    strokeColor = {white = 0.625, alpha = 0.8},
    strokeWidth = 1,
    roundedRectRadii = {xRadius = 10, yRadius = 10},
  })
  obj._box:appendElements({
    type = 'text',
    text = message,
    textSize = 120,
    textAlignment = 'center',
  })
  obj._box:show()
end

-- Hide textbox
function obj:hide()
  if obj._box ~= nil then
    obj._box:delete()
    obj._box = nil
  end
end

return obj

