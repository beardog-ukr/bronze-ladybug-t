local LL = require '../thirdparty/log_lua/log'

require "src/basic_game_object"

WallObject = BasicGameObject:extend()

function WallObject:constructor(x,y, symbol)
  BasicGameObject.constructor(self, x,y)
  -- print("Wall obj constructor: " .. self.baseX .. ";" .. self.baseY .. " s:" .. symbol)
  
  self.strength = 1
  if (symbol == "w") then
    self.strength = 2
  end


end

function WallObject:getImageId()  
  if (self.strength==1) then
    return 1
  elseif (self.strength ==2) then
    return 2
  else
--  Note: following causes flood in case of error    
--    LL.error("Bad strength value " .. self.strength)
  end
end

