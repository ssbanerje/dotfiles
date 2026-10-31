local module = {}
module.__index = module

module.base_state_id = "base"
module.current_state = module.base_state_id
module.modals = {}
module.log = hs.logger.new("state_machine", hs.logger.defaultLogLevel)

local badge = nil

local function show_badge(label, color)
  local screen = hs.screen.mainScreen()
  if not badge or not screen then
    return
  end
  local res = screen:fullFrame()
  local size = math.ceil(res.w / 32)
  local margin = math.ceil(res.w / 16)
  badge:frame({
    x = res.x + res.w - margin,
    y = res.y + res.h - margin,
    w = size,
    h = size,
  })
  badge[1].fillColor = { hex = color or "#FFFFFF", alpha = 0.8 }
  badge[2].text = label
  badge:show()
end

function module:init()
  badge = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
  badge:level(hs.canvas.windowLevels.tornOffMenu)
  badge:behavior(hs.canvas.windowBehaviors.canJoinAllSpaces + hs.canvas.windowBehaviors.transient)
  badge:clickActivating(false)
  badge:canvasMouseEvents(false, false, false, false)
  badge:appendElements(
    {
      type = "circle",
      action = "fill",
      fillColor = { hex = "#FFFFFF", alpha = 0.7 },
    },
    {
      type = "text",
      text = "",
      textSize = 45,
      textAlignment = "center",
    }
  )
  return self
end

-- Register a modal state with native :entered() / :exited() hooks
function module:new_state(id, color, hooks)
  if id == self.base_state_id or self.modals[id] then
    return self.modals[id]
  end
  hooks = hooks or {}
  local modal = hs.hotkey.modal.new()
  local label = id:sub(1, 1):upper()

  function modal:entered()
    module.current_state = id
    show_badge(label, color)
    if hooks.on_enter then
      hooks.on_enter()
    end
  end

  function modal:exited()
    if hooks.on_exit then
      hooks.on_exit()
    end
    if badge then
      badge:hide()
    end
    module.current_state = module.base_state_id
  end

  self.modals[id] = modal
  return modal
end

function module:activate(id)
  if self.current_state ~= self.base_state_id and self.modals[self.current_state] then
    self.modals[self.current_state]:exit()
  end
  if id ~= self.base_state_id and self.modals[id] then
    self.modals[id]:enter()
  end
end

function module:bind(id, keypress, message, callback)
  local mods, key = keypress[1], keypress[2]
  if id == self.base_state_id then
    hs.hotkey.bind(mods, key, message, callback)
  elseif self.modals[id] then
    self.modals[id]:bind(mods, key, message, callback)
  end
end

function module:transition(source, destination, keypress, message, callback)
  self:bind(source, keypress, message or "", function()
    self:activate(destination)
    if callback then
      callback()
    end
  end)
end

return module
