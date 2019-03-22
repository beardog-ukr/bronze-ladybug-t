local LL = require '../thirdparty/log_lua/log'

require "src/basic_game_object"
BulletObject = BasicGameObject:extend()

-- ===========================================================================

local directions = {}
directions.up =1
directions.down =2
directions.left =3
directions.right =4

directions.angle = {math.pi,
                    0,
                    math.pi/2,
                    -math.pi/2} -- for up, down, left,right
directions.xModifier = {0,0,-1,1}
directions.yModifier = {-1,1,0,0}

-- ===========================================================================

function BulletObject:constructor(x,y, direction)
  BasicGameObject.constructor(self, x,y)

  self.baseX = x + directions.xModifier[direction]
  self.baseY = y + directions.yModifier[direction]


  self.direction = direction
  self.moveProgress = 0

  local flightLength = 0
  local finalX = self.baseX
  local finalY = self.baseY
  if (self.direction == directions.left) then
    finalX = 1
    flightLength = self.baseX - finalX
  elseif (self.direction == directions.right) then
    finalX = 13
    flightLength = finalX - self.baseX
  elseif (self.direction == directions.up) then
    finalY = 1
    flightLength = self.baseY - finalY
  elseif (self.direction == directions.down) then
    finalY = 13
    flightLength = finalY - self.baseY
  end

  local flightSpeed = 1 -- cell per second
  local flightTime = flightLength*flightSpeed

  local function postBulletMove()
    LL.debug("Bullet move finished ")
    self.moveProgress=0
    self.tween = nil
    self.enabled = false
  end

  self.flightLength = flightLength
  LL.debug("Flight length will be " .. self.flightLength)
  self.tween = TimerKnife.tween(flightTime,
                   { [self] = { moveProgress = 1 } }):finish(postBulletMove)
end

function BulletObject:getAngle()
  return directions.angle[self.direction]
end

function BulletObject:getDrawCoordinates()
  local resultX = directions.xModifier[self.direction]
  resultX = resultX*self.flightLength*self.moveProgress
  resultX = resultX + self.baseX
  
  local resultY = directions.yModifier[self.direction]
  resultY = resultY*self.flightLength*self.moveProgress
  resultY = resultY + self.baseY

  return resultX, resultY
end

function BulletObject:getImageId()
  return 20
end

-- ===========================================================================
