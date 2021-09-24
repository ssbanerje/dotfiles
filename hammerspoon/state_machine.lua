local module = {}
module.__index = module

-- State to track state
module.current_state = nil
module.avail_states = {}
module.base_state_id = "base"

-- State for UI element
module.state_canvas = nil
module.state_colors = {}

-- Logger
module.log = hs.logger.new("state_machine", hs.logger.defaultLogLevel)

-- Initialize the state machine manager
function module:init()
  -- Init supervisor
  module.avail_states[module.base_state_id] = module:new_state(module.base_state_id)
  module.current_state = module.base_state_id

  -- Init UI element
  module.state_canvas = hs.canvas.new({ x = 0, y = 0, w = 0, h = 0 })
  module.state_canvas:level(hs.canvas.windowLevels.tornOffMenu)
  module.state_canvas:appendElements({
    type = "circle",
    action = "fill",
    fillColor = { hex = "#FFFFFF", alpha = 0.7 },
  })
  module.state_canvas:appendElements({
    type = "text",
    text = module.current_state:sub(1, 1):upper(),
    textSize = 45,
    textAlignment = "center",
  })

  return module
end

-- Create a new state machine environmet
function module:new_state(id, color)
  module.log.d("Creating new state " .. id)
  if module.avail_states[id] ~= nil then
    return
  end

  module.avail_states[id] = hs.hotkey.modal.new()
  module.state_colors[id] = color
  return module.avail_states[id]
end

-- Activate the state machine enviroment
function module:activate(id)
  module.log.d("Transitioning from " .. module.current_state .. " to " .. id)

  if module.avail_states[id] == nil then
    return
  end

  -- Deacitivate old state machine
  module:deactivate(module.current_state)

  -- Transition to new state
  module.current_state = id
  if id ~= module.base_state_id then
    local res = hs.screen.mainScreen():fullFrame()
    module.state_canvas:frame({
      x = res.w - math.ceil(res.w / 16),
      y = res.h - math.ceil(res.w / 16),
      w = math.ceil(res.w / 32),
      h = math.ceil(res.w / 32),
    })
    module.state_canvas[1].fillColor = { hex = module.state_colors[id], alpha = 0.8 }
    module.state_canvas[2].text = module.current_state:sub(1, 1):upper()
    module.state_canvas:show()
  end

  -- Activate current state machine
  module.avail_states[id]:enter()
end

-- Deactivate the state machine environment
function module:deactivate(id)
  id = id or module.current_state

  module.log.d("Deactivating " .. id)

  module.avail_states[id]:exit()
  module.state_canvas:hide()
end

-- Define transition from state to state
function module:transition(source, destination, keypress, message, callback)
  if module.avail_states[source] == nil or module.avail_states[destination] == nil then
    return
  end
  module.avail_states[source]:bind(keypress[1], keypress[2], message or "", function()
    -- Do transition
    module:activate(destination)

    -- Run callback
    if callback then
      callback()
    end
  end)
end

-- Run a callback when a keypress occurs in a state
function module:bind(id, keypress, message, callback)
  if module.avail_states[id] == nil then
    return
  end

  module.avail_states[id]:bind(keypress[1], keypress[2], message, callback)
end

return module
