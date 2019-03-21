local LL = require '../thirdparty/log_lua/log'

local TimerKnife = require '../thirdparty/knife.timer'

require "src/basic_game_object"
PlayerTankObject = BasicGameObject:extend()

-- ===========================================================================

local tankDirections = {}
tankDirections.up =1
tankDirections.down =2
tankDirections.left =3
tankDirections.right =4

local tankDirectionAngles = {math.pi, 
                             0, 
                             math.pi/2, 
                             -math.pi/2} -- for up, down, left,right

local keyBindings = {}
keyBindings.up = "up"
keyBindings.down = "down"
keyBindings.left = "left"
keyBindings.right = "right"
keyBindings.fire = "space"

-- ===========================================================================

function PlayerTankObject:constructor(x,y, symbol)
  BasicGameObject.constructor(self, x,y)
  
  self.direction = tankDirections.down
  self.moveProgress = 0

end

function PlayerTankObject:getAngle()
  return tankDirectionAngles[self.direction]
end

function PlayerTankObject:getDrawCoordinates()  
  local resultX = self.baseX
  local resultY = self.baseY

  if (self.direction == tankDirections.left) then
    resultX = resultX - self.moveProgress
  elseif (self.direction == tankDirections.right) then
    resultX = resultX + self.moveProgress
  elseif (self.direction == tankDirections.up) then
    resultY = resultY - self.moveProgress
  elseif (self.direction == tankDirections.down) then
    resultY = resultY + self.moveProgress
  end

  return resultX, resultY
end

function PlayerTankObject:getImageId()
  return 10  
end

-- ===========================================================================

-- local function performMove(tankCtx, maxLim, walls)
--   if (tankCtx.cellY == 13) then
--     LL.debug("Enemy already at max south")
--     return
--   end

--   if (walls[tankCtx.cellY+1][tankCtx.cellX] ~= mapLegend.space) then
--     LL.debug("Wall at south from enemy, no way")
--     return
--   end

--   local function postEnemyDownMove()
--     LL.debug("Enemy one move to south finished")
--     tankCtx.moveProgress=0    
--     tankCtx.cellY = tankCtx.cellY +1
--   end

--   tankCtx.direction = tankDirections.down
--   TimerKnife.tween(delays.move, 
--                    { [tankCtx] = { moveProgress = 1 } }):finish(postEnemyDownMove) 
-- end

-- local moveKeys = {keyBindings.up, keyBindings.down, keyBindings.left, keyBindings.right }
-- local moveMaxLim = {1, 13, 1, 13 }

function PlayerTankObject:processMoveRequest(key, walls)
  if (self.moveProgress > 0.05) then
    LL.warn("Still moving: " .. self.moveProgress)
    return
  end

  local newBaseX = self.baseX
  local newBaseY = self.baseY
  local newDirection = self.direction

  if (key == keyBindings.up) then
    newBaseY = newBaseY -1
    newDirection = tankDirections.up
  elseif (key == keyBindings.down) then
    newBaseY = newBaseY +1
    newDirection = tankDirections.down
  elseif (key == keyBindings.left) then
    newBaseX = newBaseX -1
    newDirection = tankDirections.left
  elseif (key == keyBindings.right) then
    newBaseX = newBaseY +1
    newDirection = tankDirections.right
  end

  if (newBaseX<1) or (newBaseX>13) or (newBaseY<1) or (newBaseY>13) then
    LL.warn("Limit line, no move")
    return
  end

  for i=1,#walls do
    local wx, wy = walls[i]:getCellCoordinates()
    if (wx == newBaseX) and (wy == newBaseY) then
      LL.warn("Found wall at " .. wx .. ":" .. wy .. ", no move")
      return
    end
  end

  local function postTankMove()
    LL.debug("one move to " .. key .. " finished")
    self.moveProgress=0    
    self.baseX = newBaseX
    self.baseY = newBaseY
  end

  self.direction = newDirection
  TimerKnife.tween(5, 
                   { [self] = { moveProgress = 1 } }):finish(postTankMove)

end

function PlayerTankObject:processUpdate(diffTime)
  TimerKnife.update(diffTime)
end