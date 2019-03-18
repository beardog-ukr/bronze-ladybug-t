local BaseKnife = require '../thirdparty/knife.base'

TanksGame = BaseKnife:extend()

local function setGameArea(ctx, offsetX, offsetY, areaWidth, areaHeight)
  ctx.gameAreaX = offsetX
  ctx.gameAreaY = offsetY
  ctx.gameAreaWidth = areaWidth
  ctx.gameAreaWidth = areaHeight
end

function TanksGame:constructor(offsetX, offsetY, areaWidth, areaHeight)
  setGameArea(self, offsetX, offsetY, areaWidth, areaHeight)

  self.gameFinished = false

  self.groundImage = love.graphics.newImage( "res/img/ground01.png" )
  self.tankImage = love.graphics.newImage( "res/img/tank01.png" )
  self.wallImage = love.graphics.newImage( "res/img/wall02.png" )
end

function TanksGame:drawSelf()
  love.graphics.draw( self.groundImage, 100, 100)
  love.graphics.draw( self.wallImage, 100, 100)
  love.graphics.draw( self.groundImage, 132, 100)
  love.graphics.draw( self.wallImage, 132, 100)

  love.graphics.draw( self.groundImage, 100, 132)
  love.graphics.draw( self.wallImage, 100, 132)
  love.graphics.draw( self.groundImage, 132, 132)
  love.graphics.draw( self.wallImage, 132, 132)

  love.graphics.draw( self.groundImage, 164, 100)
  love.graphics.draw( self.tankImage, 164, 100, math.rad(90))
end

function TanksGame:processKeyPressed(key)
  if (key == "escape") then
    love.event.quit(0)
    return;
  end;
end

function TanksGame:processUpdate(diffTime)
  if (self.gameFinished == true) then
    return;
  end

end
