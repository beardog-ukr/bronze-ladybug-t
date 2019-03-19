local BaseKnife = require '../thirdparty/knife.base'

TanksGame = BaseKnife:extend()

-- ===========================================================================

local mapLegend = {}
mapLegend.wall1 = "v"      -- wall with 1 stength level
mapLegend.wall2 = "w"      -- wall of 2nd strength level
mapLegend.tankPlayer = "T" -- player tank (TODO will be 
                            --  replaced by "spawning point"?) 
mapLegend.space = " "      -- dirt empty place on the map

-- ===========================================================================

function setupPlayerTank(ctx)
  ctx.cellX =3
  ctx.cellY =6
  ctx.moveProgress = 0.5
end
-- ===========================================================================

local function loadMap(ctx)
  local map = {}
  map[ 1] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
  map[ 2] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 3] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 4] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 5] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
  map[ 6] = {" ","v"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 7] = {" ","v"," ","T"," "," "," "," "," "," "," "," "," "}
  map[ 8] = {" ","v"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 9] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
  map[10] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[11] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[12] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[13] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
   
  ctx.map = map
end

local function setGameArea(ctx, offsetX, offsetY, areaWidth, areaHeight)
  ctx.gameAreaX = offsetX
  ctx.gameAreaY = offsetY
  ctx.gameAreaWidth = areaWidth
  ctx.gameAreaWidth = areaHeight

  ctx.cellWidth = math.floor(areaWidth/ctx.cellsCount)
  ctx.cellHeight = math.floor(areaHeight/ctx.cellsCount)
  ctx.cellSize = ctx.cellHeight -- TODO

  print("cw = " .. ctx.cellWidth)
  print("ch = " .. ctx.cellHeight)
end

function TanksGame:constructor(offsetX, offsetY, areaWidth, areaHeight)
  self.cellsCount = 13

  setGameArea(self, offsetX, offsetY, areaWidth, areaHeight)
  
  loadMap(self)

  self.gameFinished = false

  self.playerTank = {}
  setupPlayerTank(self.playerTank)  

  self.images = {}
  self.images.ground = love.graphics.newImage( "res/img/ground01.png" )
  self.images.tank = love.graphics.newImage( "res/img/tank01.png" )
  self.images.wall1 = love.graphics.newImage( "res/img/wall01.png" )
  self.images.wall2 = love.graphics.newImage( "res/img/wall02.png" )
end

-- ===========================================================================

local function drawBackground(ctx)
  love.graphics.setColor(1,1,1,1)
  for i=1,#ctx.map do
    for j=1, #ctx.map[i] do
      local rx = ctx.gameAreaX + (i-1)*ctx.cellSize
      local ry = ctx.gameAreaY + (j-1)*ctx.cellSize
      love.graphics.draw( ctx.images.ground, rx, ry)
    end
  end
end

local function drawImageInCell(img, cellX, cellY, angle, 
                               baseX, baseY, cellSize)
  local imgWidth = img:getWidth()
  local imgHeight = img:getHeight()

  local centerX = baseX + (cellX-1)*cellSize + cellSize/2
  local centerY = baseY + (cellY-1)*cellSize + cellSize/2

  love.graphics.draw(img, centerX, centerY, angle, 1,1, imgWidth/2, imgHeight/2)
end

local function drawWalls(ctx)
  love.graphics.setColor(1,1,1,1)

  for i=1,#ctx.map do
    for j=1, #ctx.map[i] do
      if (ctx.map[i][j] ~= mapLegend.space) then
        local wallImg = nil;
        if (ctx.map[i][j] == mapLegend.wall1) then
          wallImg = ctx.images.wall1
        elseif (ctx.map[i][j] == mapLegend.wall2) then
          wallImg = ctx.images.wall2
        end

        if (wallImg) then
          drawImageInCell(wallImg, j,i, 0,
                          ctx.gameAreaX, ctx.gameAreaX, ctx.cellSize)
        end
      end
      
    end
  end
end

local function drawTank(gameCtx, tankCtx)  
  local angle = math.pi/2

  local centerX = gameCtx.gameAreaX
  centerX = centerX + (tankCtx.cellX-1)*gameCtx.cellSize + gameCtx.cellSize/2
  centerX = centerX - (tankCtx.moveProgress*gameCtx.cellSize)

  local centerY = gameCtx.gameAreaY
  centerY = centerY + (tankCtx.cellY-1)*gameCtx.cellSize + gameCtx.cellSize/2
  -- centerY = centerY - (tankCtx.moveProgress*gameCtx.cellSize)

  local imgWidth = gameCtx.images.tank:getWidth()
  local imgHeight = gameCtx.images.tank:getHeight()

  love.graphics.draw(gameCtx.images.tank, centerX, centerY, angle, 1,1,
                     imgWidth/2, imgHeight/2) 
                    --  gameCtx.cellSize/2, gameCtx.cellSize/2)

  -- love.graphics.setColor(1,1,1,1)

  -- for i=1,#ctx.map do
  --   for j=1, #ctx.map[i] do
  --     if (ctx.map[i][j] ~= mapLegend.space) then
  --       local wallImg = nil;
  --       if (ctx.map[i][j] == mapLegend.wall1) then
  --         wallImg = ctx.images.wall1
  --       elseif (ctx.map[i][j] == mapLegend.wall2) then
  --         wallImg = ctx.images.wall2
  --       end

  --       if (wallImg) then
  --         drawImageInCell(wallImg, j,i, 0,
  --                         ctx.gameAreaX, ctx.gameAreaX, ctx.cellSize)
  --       end
  --     end
      
  --   end
  -- end
end

function TanksGame:drawSelf()
  drawBackground(self)
  drawWalls(self)

  drawTank(self, self.playerTank)
  -- drawImageInCell(self.images.tank, 2,5, math.pi,
  --                 self.gameAreaX, self.gameAreaX, self.cellSize)

  -- drawImageInCell(self.images.tank, 2,6, math.pi/2,
  --                 self.gameAreaX, self.gameAreaX, self.cellSize)

  -- drawImageInCell(self.images.tank, 2,13, 0,
  --                 self.gameAreaX, self.gameAreaX, self.cellSize)
end

-- ===========================================================================

function TanksGame:processKeyPressed(key)
  if (key == "escape") then
    love.event.quit(0)
    return;
  end;

  if (key=="left") then
    
  end
end

-- ===========================================================================

function TanksGame:processUpdate(diffTime)
  if (self.gameFinished == true) then
    return;
  end

end
