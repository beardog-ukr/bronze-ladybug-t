local LL = require '../thirdparty/log_lua/log'

local BaseKnife = require '../thirdparty/knife.base'
local TimerKnife = require '../thirdparty/knife.timer'

TanksGame = BaseKnife:extend()

-- ===========================================================================

local mapLegend = {}
mapLegend.wall1 = "v"      -- wall with 1 stength level
mapLegend.wall2 = "w"      -- wall of 2nd strength level
mapLegend.tankPlayer = "T" -- player tank (TODO will be 
                            --  replaced by "spawning point"?) 
mapLegend.space = " "      -- dirt empty place on the map

local keyBindings = {}
keyBindings.up = "up"
keyBindings.down = "down"
keyBindings.left = "left"
keyBindings.right = "right"

local tankDirections = {}
tankDirections.up =1
tankDirections.down =2
tankDirections.left =3
tankDirections.right =4

local tankDirectionAngles = {math.pi, 
                             0, 
                             math.pi/2, 
                             -math.pi/2} -- for up, down, left,right

local delays = {}
delays.move = 3

-- ===========================================================================

function setupPlayerTank(ctx)
  ctx.cellX =3
  ctx.cellY =6
  ctx.direction = tankDirections.down

  ctx.moveProgress = 0
end
-- ===========================================================================

local function loadMap(ctx)
  local map = {}
  map[ 1] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
  map[ 2] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 3] = {" ","w"," ","w","w"," "," "," "," "," "," "," "," "}
  map[ 4] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 5] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
  map[ 6] = {" ","v"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 7] = {" ","v"," ","T"," "," "," "," "," "," "," "," "," "}
  map[ 8] = {" ","v"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 9] = {" "," "," ","v","v"," "," "," "," "," "," "," "," "}
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

  self.gameInitialized = true
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
  local angle = tankDirectionAngles[tankCtx.direction]

  local centerX = gameCtx.gameAreaX
  centerX = centerX + (tankCtx.cellX-1)*gameCtx.cellSize + gameCtx.cellSize/2

  local centerY = gameCtx.gameAreaY
  centerY = centerY + (tankCtx.cellY-1)*gameCtx.cellSize + gameCtx.cellSize/2

  local moveProgressModifier = (tankCtx.moveProgress*gameCtx.cellSize)
  if (tankCtx.direction == tankDirections.left) then
    centerX = centerX - moveProgressModifier
  elseif (tankCtx.direction == tankDirections.right) then
    centerX = centerX + moveProgressModifier
  elseif (tankCtx.direction == tankDirections.up) then
    centerY = centerY - moveProgressModifier
  elseif (tankCtx.direction == tankDirections.down) then
    centerY = centerY + moveProgressModifier
  end

  local imgWidth = gameCtx.images.tank:getWidth()
  local imgHeight = gameCtx.images.tank:getHeight()

  love.graphics.draw(gameCtx.images.tank, centerX, centerY, angle, 1,1,
                     imgWidth/2, imgHeight/2) 
end

function TanksGame:drawSelf()
  drawBackground(self)
  drawWalls(self)

  drawTank(self, self.playerTank)
end

-- ===========================================================================

local function processMoveUp(tankCtx, walls)
  LL.debug("Like moving up (north)")

  if (tankCtx.moveProgress > 0.05) then
    LL.warn("Move in progress, skip moving up (north)")
    return
  end

  if (tankCtx.cellY == 1) then
    LL.debug("Already at max north")
    return
  end

  if (walls[tankCtx.cellY-1][tankCtx.cellX] ~= mapLegend.space) then
    LL.debug("Wall at north, no way")
    return
  end

  local function postUpMove()
    LL.debug("One move to north finished")
    tankCtx.moveProgress=0    
    tankCtx.cellY = tankCtx.cellY -1
  end

  tankCtx.direction = tankDirections.up
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postUpMove) 
end

local function processMoveDown(tankCtx, walls)
  LL.debug("Like moving down")

  if (tankCtx.moveProgress > 0.05) then
    LL.warn("Move in progress, skip moving down (south)")
    return
  end

  if (tankCtx.cellY == 13) then -- TODO: use game ctx const
    LL.debug("Already at max south")
    return
  end

  if (walls[tankCtx.cellY+1][tankCtx.cellX] ~= mapLegend.space) then
    LL.debug("Wall at south, no way")
    return
  end

  local function postDownMove()
    LL.debug("One move to south finished")
    tankCtx.moveProgress=0    
    tankCtx.cellY = tankCtx.cellY +1
  end

  tankCtx.direction = tankDirections.down
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postDownMove) 
end

local function processMoveLeft(tankCtx, walls)
  LL.debug("Like moving left (west)")

  if (tankCtx.moveProgress > 0.05) then
    LL.warn("Move in progress, skip moving left")
    return
  end

  if (tankCtx.cellX == 1) then
    LL.debug("Already at max west")
    return
  end

  if (walls[tankCtx.cellY][tankCtx.cellX-1] ~= mapLegend.space) then
    LL.debug("Wall at west, no way left")
    return
  end

  local function postLeftMove()
    LL.debug("One move to north finished")
    tankCtx.moveProgress=0    
    tankCtx.cellX = tankCtx.cellX -1
  end

  tankCtx.direction = tankDirections.left
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postLeftMove) 

end

local function processMoveRight(tankCtx, walls)
  LL.debug("Like moving right (east)")

  if (tankCtx.moveProgress > 0.05) then
    LL.warn("Move in progress, skip moving right")
    return
  end

  if (tankCtx.cellX == 13) then
    LL.debug("Already at max east")
    return
  end

  if (walls[tankCtx.cellY][tankCtx.cellX+1] ~= mapLegend.space) then
    LL.debug("Wall at east, no way to right")
    return
  end

  local function postRightMove()
    LL.debug("One move to east finished")
    tankCtx.moveProgress=0    
    tankCtx.cellX = tankCtx.cellX +1
  end

  tankCtx.direction = tankDirections.right
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postRightMove) 
end

local moveKeysProcessors = {processMoveUp, processMoveDown, processMoveLeft, processMoveRight }
local moveKeys = {keyBindings.up, keyBindings.down, keyBindings.left, keyBindings.right }

function TanksGame:processKeyPressed(key)
  if (key == "escape") then
    love.event.quit(0)
    return;
  end;

  for i=1, #moveKeys do
    if (moveKeys[i] == key) then
      moveKeysProcessors[i](self.playerTank, self.map)
      return
    end
  end

end

-- ===========================================================================

local function progressFinished(value)
  if (value > 0.95) and (value <= 1.05) then
    return true
  else 
    return false 
  end 
end

function TanksGame:processUpdate(diffTime)
  if (self.gameInitialized ==nil) then
    return
  end

  if (self.gameFinished == true) then
    return;
  end
  -- else

  TimerKnife.update(diffTime)

end
