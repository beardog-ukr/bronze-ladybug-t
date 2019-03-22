local LL = require '../thirdparty/log_lua/log'

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

-- ===========================================================================

function PlayerTankObject:constructor(x,y, symbol)
  BasicGameObject.constructor(self, x,y)

  self.direction = tankDirections.down
  self.moveProgress = 0
  self.nextMove = nil
end

function PlayerTankObject:getAngle()
  return tankDirectionAngles[self.direction]
end

function PlayerTankObject:getDirection()
  return self.direction
end

function PlayerTankObject:getCellCoordinates()  
  local resultX, resultY = self:getDrawCoordinates()
  resultX = math.floor(resultX + 0.5)
  resultY = math.floor(resultY + 0.5)
  return resultX, resultY
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

function PlayerTankObject:processMoveRequest(key, walls)
  if (self.moveProgress > 0.05) then
    LL.warn("Still moving: " .. self.moveProgress)
    self.nextMove = key
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
    newBaseX = newBaseX +1
    newDirection = tankDirections.right
  end

  if (newBaseX<1) or (newBaseX>13) or (newBaseY<1) or (newBaseY>13) then
    LL.warn("Limit line, no move")
    return
  end

  for i=1,#walls do
    local wx, wy = walls[i]:getCellCoordinates()
    if (wx == newBaseX) and (wy == newBaseY) and (walls[i].enabled == true) then
      LL.warn("Found wall at " .. wx .. ":" .. wy .. ", no move")
      return
    end
  end

  local function postTankMove()
    LL.debug("one move to " .. key .. " finished")
    self.moveProgress=0
    self.baseX = newBaseX
    self.baseY = newBaseY
    if (self.nextMove) then
      LL.debug("initiate next move to " .. self.nextMove)
      self:processMoveRequest(self.nextMove, walls)
      self.nextMove = nil
    end
  end

  self.direction = newDirection
  TimerKnife.tween(2,
                   { [self] = { moveProgress = 1 } }):finish(postTankMove)

end

function PlayerTankObject:processConflict()
  LL.debug("Something hits player tank #" .. self.gameId)
  self.enabled = false
end

