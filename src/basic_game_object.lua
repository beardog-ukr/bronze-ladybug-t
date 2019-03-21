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

function BasicGameObject:getAngle()
  return 0
end

-- "cell coordinates" are coordinates of cell occupied by object
-- integer values
-- Should be used to detect conflicts, since there should be only one item in the cell
function BasicGameObject:getCellCoordinates()  
  return self.baseX, self.baseY
end

-- "draw coordinates" are coordinates of the point where object should appear
-- float values, but still "cells", not pixels
-- Should be used to draw object
function BasicGameObject:getDrawCoordinates()  
  return self.baseX, self.baseY
end

-- will be implemented in subclasses
function BasicGameObject:getImageId()
  return nil
end

