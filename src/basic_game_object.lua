local LL = require '../thirdparty/log_lua/log'

local BaseKnife = require '../thirdparty/knife.base'

BasicGameObject = BaseKnife:extend()

-- ===========================================================================

function BasicGameObject:constructor(x,y)
  -- print("Basic obj constructor: " .. x .. ":" .. y)
  self.baseX = x
  self.baseY = y
  self.enabled = true
end

function BasicGameObject:getCellCoordinates()  
  return self.baseX, self.baseY
end

-- will be implemented in subclasses
function BasicGameObject:getImageId()
  return nil
end