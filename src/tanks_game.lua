local LL = require '../thirdparty/log_lua/log'

local BaseKnife = require '../thirdparty/knife.base'
TimerKnife = require '../thirdparty/knife.timer'

TanksGame = BaseKnife:extend()

require "src/bullet_object"
require "src/player_tank_object"
require "src/wall_object"

local settings_m = require("src/app_defaults")
local appDef = {}
settings_m.setupAppDefaults(appDef)

-- ===========================================================================

local drawSettings = {}
drawSettings.gameAreaX = appDef.largeFrameSize
drawSettings.gameAreaY = appDef.largeFrameSize
drawSettings.cellSize = appDef.cellSize
drawSettings.cellsCount = 13

local mapLegend = {}
mapLegend.wall1 = "v"      -- wall with 1 stength level
mapLegend.wall2 = "w"      -- wall of 2nd strength level
mapLegend.space = " "      -- dirt empty place on the map
mapLegend.playerTank = "P" -- start of player tank (should appear once)
mapLegend.enemyTank = "E" -- start of enemy tank

local keyBindings = {}
keyBindings.up = "up"
keyBindings.down = "down"
keyBindings.left = "left"
keyBindings.right = "right"
keyBindings.fire = "space"

local delays = {} -- tween length in seconds
delays.move = 3 
delays.bullet = delays.move/2

-- ===========================================================================

local function setupOneEnemy(ctx, cx, cy)
  ctx.cellX = cx
  ctx.cellY = cy

  ctx.direction = tankDirections.down
  ctx.moveProgress = 0
  ctx.disabled = false
end

local function setupEnemies(itemsArr, map)
  for i=1, #map do
    for j=1, #map[i] do
      if map[i][j] == mapLegend.enemyTank then
        local newItem = {}
        setupOneEnemy(newItem, j,i)
        itemsArr[#itemsArr+1] = newItem
        map[i][j] = mapLegend.space
      end
    end
  end
end

-- ===========================================================================

local function loadMap(walls)
  local map = {}
  map[ 1] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
  map[ 2] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 3] = {" ","w"," ","w","w"," "," "," "," "," "," "," "," "}
  map[ 4] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 5] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
  map[ 6] = {" ","v"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 7] = {" ","v"," "," "," "," "," "," "," "," "," "," "," "}
  map[ 8] = {" ","v"," "," "," "," "," ","v"," "," "," "," "," "}
  map[ 9] = {" "," ","w","v","v"," "," "," "," "," "," "," "," "}
  map[10] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[11] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[12] = {" ","w"," "," "," "," "," "," "," "," "," "," "," "}
  map[13] = {" "," "," "," "," "," "," "," "," "," "," "," "," "}
   
  for i=1,#map do
    for j=1,#map[i] do
      if (map[i][j] ~= " ") then
        walls[#walls +1] = WallObject(j,i, map[i][j])
      end
    end
  end
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
  
  self.walls = {}
  loadMap(self.walls)

  self.gameFinished = false

  local tankX = 3
  local tankY = 6
  self.playerTank = PlayerTankObject(tankX, tankY)

  -- self.enemies = {}
  -- setupEnemies(self.enemies, self.map)

  self.bullets = {}

  self.images = {}
  self.images[1] = love.graphics.newImage("res/img/wall01.png")
  self.images[2] = love.graphics.newImage("res/img/wall02.png")
  self.images[5] = love.graphics.newImage("res/img/ground01.png")

  self.images[10] = love.graphics.newImage("res/img/tank01.png")

  self.images[20] = love.graphics.newImage("res/img/bullet01.png")

  -- self.images.ground = love.graphics.newImage("res/img/ground01.png")
  -- self.images.tank = love.graphics.newImage("res/img/tank01.png")
  
  -- self.images.wall1 = love.graphics.newImage("res/img/wall01.png")
  -- self.images.wall2 = love.graphics.newImage("res/img/wall02.png")

  self.gameInitialized = true
end

-- ===========================================================================

local function drawBackground(image)
  love.graphics.setColor(1,1,1,1)
  for i=1,drawSettings.cellsCount do
    for j=1,drawSettings.cellsCount do
      local rx = drawSettings.gameAreaX + (i-1)*drawSettings.cellSize
      local ry = drawSettings.gameAreaY + (j-1)*drawSettings.cellSize
      love.graphics.draw( image, rx, ry)
    end
  end
end

local function drawImageInCell(img, cellX, cellY, angle)
  local imgWidth = img:getWidth()
  local imgHeight = img:getHeight()

  local centerX = (cellX-1)*drawSettings.cellSize + drawSettings.cellSize/2
  centerX = centerX + drawSettings.gameAreaX

  local centerY = (cellY-1)*drawSettings.cellSize + drawSettings.cellSize/2
  centerY = centerY + drawSettings.gameAreaY

  love.graphics.draw(img, centerX, centerY, angle, 1,1, imgWidth/2, imgHeight/2)
end

local function drawWalls(images, walls)
  love.graphics.setColor(1,1,1,1)

  for i=1, #walls do
    local wx, wy = walls[i]:getCellCoordinates()
    -- print("Coords: " .. wx .. " : " .. wy)
    local imgId = walls[i]:getImageId()
    if (imgId) and (images[imgId]) then
      drawImageInCell(images[imgId], wx, wy, 0)
    end
  end
end

-- local function drawTank(images, tank)  
--   local angle = tank:getAngle()
--   local tx, ty = tank:getDrawCoordinates()

--   local centerX = drawSettings.gameAreaX
--   centerX = centerX + (tx-1)*drawSettings.cellSize + drawSettings.cellSize/2

--   local centerY = drawSettings.gameAreaY
--   centerY = centerY + (ty-1)*drawSettings.cellSize + drawSettings.cellSize/2

--   local img = images[tank:getImageId()]
--   local imgWidth = img:getWidth()
--   local imgHeight = img:getHeight()

--   love.graphics.draw(img, centerX, centerY, angle, 1,1,
--                      imgWidth/2, imgHeight/2)
-- end

local function drawOneItem(images, item)  
  local angle = item:getAngle()
  local cellX, cellY = item:getDrawCoordinates()

  local centerX = drawSettings.gameAreaX
  centerX = centerX + (cellX-1)*drawSettings.cellSize + drawSettings.cellSize/2

  local centerY = drawSettings.gameAreaY
  centerY = centerY + (cellY-1)*drawSettings.cellSize + drawSettings.cellSize/2

  local img = images[item:getImageId()]
  local imgWidth = img:getWidth()
  local imgHeight = img:getHeight()

  love.graphics.draw(img, centerX, centerY, angle, 1,1,
                     imgWidth/2, imgHeight/2)
end

local function drawBullets(images, bullets)
  for i=1, #bullets do
    if (bullets[i].enabled) then
      drawOneItem(images, bullets[i])
    end
  end
end

local function drawOneEnemy(gameCtx, tankCtx)
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

  love.graphics.draw(gameCtx.images.enemy, centerX, centerY, angle, 1,1,
                     imgWidth/2, imgHeight/2) 
end

local function drawEnemies(gameCtx, enemiesArr)
  for i=1,#enemiesArr do
    if (enemiesArr[i].disabled == false) then
      drawOneEnemy(gameCtx, enemiesArr[i])
    end
  end
end

function TanksGame:drawSelf()
  drawBackground(self.images[5])
  drawWalls(self.images, self.walls)

  drawOneItem(self.images, self.playerTank)
  -- drawEnemies(self, self.enemies)

  drawBullets(self.images,self.bullets)
end

-- ===========================================================================

local function getActualTankCoordinates(itemCtx)
  local resultX = itemCtx.cellX
  local resultY = itemCtx.cellY

  if (itemCtx.moveProgress>=0.5) then
    if (itemCtx.direction == tankDirections.up) then
      resultY = resultY -1
    elseif (itemCtx.direction == tankDirections.down) then
      resultY = resultY +1
    elseif (itemCtx.direction == tankDirections.left) then
      resultX = resultX -1
    elseif (itemCtx.direction == tankDirections.down) then
      resultX = resultX +1
    end
  end

  if (resultX<1) then
    resultX = 1
  end

  if (resultX>13) then
    resultX = 13
  end

  if (resultY<1) then
    resultY = 1
  end

  if (resultY>13) then
    resultY = 13
  end

  return resultX, resultY
end

-- ===========================================================================

--local moveKeysProcessors = {processMoveUp, processMoveDown, processMoveLeft, processMoveRight }
local moveKeys = {keyBindings.up, keyBindings.down, keyBindings.left, keyBindings.right }

function TanksGame:processKeyPressed(key)
  if (key == "escape") then
    love.event.quit(0)
    return;
  end;

  if self.gameFinished then
    LL.debug("Game over, ignoring " .. key)
    return
  end

  for i=1, #moveKeys do
    if (moveKeys[i] == key) then
      -- moveKeysProcessors[i](self.playerTank, self.map)
      self.playerTank:processMoveRequest(key, self.walls)
      return
    end
  end

  if (key == keyBindings.fire) then
    LL.trace("Firing")
    local tx, ty = self.playerTank:getCellCoordinates()
    local dr = self.playerTank:getDirection()
    self.bullets[#self.bullets+1] = BulletObject(tx,ty, dr)
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

-- ===========================================================================

-- removes bullets that reached end of the line
-- TODO: check efficiency
local function cleanupBulletsArray(arr)
  local n=#arr
    
  for i=1,n do
    if (arr[i].moveProgress >0.98) or (arr[i].triggered == true) then
      arr[i]=nil
    end
  end
    
  local j=0
  for i=1,n do
    if arr[i]~=nil then
      j=j+1
      arr[j]=arr[i]
    end
  end
  
  for i=j+1,n do
    arr[i]=nil
  end
end

-- removes bullets that reached end of the line
-- TODO: check efficiency
-- TODO: duplicates cleanupBulletsArray function
local function cleanupEnemiesArray(arr)
  local n=#arr
    
  for i=1,n do
    if (arr[i].disabled == true) then
      arr[i]=nil
    end
  end
    
  local j=0
  for i=1,n do
    if arr[i]~=nil then
      j=j+1
      arr[j]=arr[i]
    end
  end
  
  for i=j+1,n do
    arr[i]=nil
  end
end

local function getActualBulletCoordinates(itemCtx)
  local pm = (itemCtx.finalX - itemCtx.cellX) * itemCtx.moveProgress
  local cx = itemCtx.cellX + pm
  local resultX = math.floor(cx + 0.5)

  pm = (itemCtx.finalY - itemCtx.cellY) * itemCtx.moveProgress
  local cy = itemCtx.cellY + pm
  local resultY = math.floor(cy + 0.5)

  return resultX, resultY
end

local function processConflictsBulletsVsWalls(mapArr, bulletsArr)
  for i=1,#bulletsArr do
    -- check one bullet
    local cx, cy = getActualBulletCoordinates(bulletsArr[i])
    if (cx < 1) or (cx > 13) or (cy < 1) or (cy > 13) then
      LL.error("Bad cx or cy calculated: " .. cx .. " ; " .. cy)
      return
    end

    if (mapArr[cy][cx] ~= mapLegend.space) then
      LL.debug("Conflict detected: " .. cx .. " ; " .. cy)

      bulletsArr[i].triggered = true
      if (mapArr[cy][cx] == mapLegend.wall1) then
        mapArr[cy][cx] = mapLegend.space
      elseif (mapArr[cy][cx] == mapLegend.wall2) then
        mapArr[cy][cx] = mapLegend.wall1
      else
        LL.error("Bad map value detected: " .. mapArr[cy][cx])
      end

    end
  end
end

-- ===========================================================================

-- returns true if conflict detected (game should be over with it)
--         false othervice
local function processConflictsTankVsEnemies(tankCtx, enemiesArr)
  local result = false
  local tx, ty = getActualTankCoordinates(tankCtx)
  for i=1,#enemiesArr do
    local ex, ey = getActualTankCoordinates(enemiesArr[i])
    if (ex == tx) and (ey == ty) then
      result = true
      LL.debug("found conflict at " .. ex .. ":" .. ey)
      break;
    end
  end

  return result
end

local function processConflictsBulletsVsEnemies(bulletsArr, enemiesArr)
  for i=1,#bulletsArr do
    local bx, by = getActualBulletCoordinates(bulletsArr[i])

    for j=1,#enemiesArr do
      local ex,ey = getActualTankCoordinates(enemiesArr[j])

      if (bx == ex) and (by == ey) then
        LL.debug("Killing some: " .. ex .. " ; " .. ey)
        bulletsArr[i].triggered = true
        enemiesArr[j].disabled = true
        break
      end  
    end

  end
end

-- ===========================================================================

-- returns true if one of the byllets hits player tank
--         false othervice
local function processConflictsBulletsVsPlayer(bulletsArr, tankCtx)
  local result = false

  local tx,ty = getActualTankCoordinates(tankCtx)

  for i=1,#bulletsArr do
    local bx, by = getActualBulletCoordinates(bulletsArr[i])

    if (bx == tx) and (by == ty) then
      result = true
      bulletsArr[i].triggered = true
      break
    end
  end

  return result
end

-- ===========================================================================

local function setupEnemyMoveUp(tankCtx, walls)
  if (tankCtx.cellY == 1) then -- TODO: use game ctx const
    LL.debug("Enemy already at max north")
    return
  end

  if (walls[tankCtx.cellY-1][tankCtx.cellX] ~= mapLegend.space) then
    LL.debug("Wall at north from enemy, no way")
    return
  end

  local function postEnemyDownMove()
    LL.debug("Enemy one move to north finished")
    tankCtx.moveProgress=0    
    tankCtx.cellY = tankCtx.cellY -1
  end

  tankCtx.direction = tankDirections.up
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postEnemyDownMove) 
end

local function setupEnemyMoveDown(tankCtx, walls)
  if (tankCtx.cellY == 13) then -- TODO: use game ctx const
    LL.debug("Enemy already at max south")
    return
  end

  if (walls[tankCtx.cellY+1][tankCtx.cellX] ~= mapLegend.space) then
    LL.debug("Wall at south from enemy, no way")
    return
  end

  local function postEnemyDownMove()
    LL.debug("Enemy one move to south finished")
    tankCtx.moveProgress=0    
    tankCtx.cellY = tankCtx.cellY +1
  end

  tankCtx.direction = tankDirections.down
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postEnemyDownMove) 
end

local function setupEnemyMoveLeft(tankCtx, walls)
  if (tankCtx.cellX == 1) then
    LL.debug("Enemy already at max west")
    return
  end

  if (walls[tankCtx.cellY][tankCtx.cellX-1] ~= mapLegend.space) then
    LL.debug("Wall at west from enemy, no way")
    return
  end

  local function postEnemyLeftMove()
    LL.debug("Enemy one move to west finished")
    tankCtx.moveProgress=0    
    tankCtx.cellX = tankCtx.cellX -1
  end

  tankCtx.direction = tankDirections.left
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postEnemyLeftMove) 
end

local function setupEnemyMoveRight(tankCtx, walls)
  if (tankCtx.cellX == 13) then
    LL.debug("Enemy already at max east")
    return
  end

  if (walls[tankCtx.cellY][tankCtx.cellX+1] ~= mapLegend.space) then
    LL.debug("Wall at east from enemy, no way")
    return
  end

  local function postEnemyRightMove()
    LL.debug("Enemy one move to east finished")
    tankCtx.moveProgress=0    
    tankCtx.cellX = tankCtx.cellX +1
  end

  tankCtx.direction = tankDirections.right
  TimerKnife.tween(delays.move, 
                   { [tankCtx] = { moveProgress = 1 } }):finish(postEnemyRightMove) 
end

local function setupEnemyMoves(mapArr, tankCtx, enemiesArr, bulletsArr)
  --
  local moves = {setupEnemyMoveUp, setupEnemyMoveDown,
                 setupEnemyMoveLeft, setupEnemyMoveRight}

  for i=1, #enemiesArr do
    if (enemiesArr[i].moveProgress == 0) then
      local moveIdx = love.math.random( 1, 4 )
      moves[moveIdx](enemiesArr[i], mapArr)
      if (enemiesArr[i].cellX == tankCtx.cellX) or
         (enemiesArr[i].cellY == tankCtx.cellY) then
        performFiring(bulletsArr, enemiesArr[i])
      end
    end
  end
end

-- ===========================================================================

function TanksGame:processUpdate(diffTime)
  if (self.gameInitialized ==nil) then
    return
  end

  if (self.gameFinished == true) then
    return;
  end
  -- else

  -- self.playerTank:processUpdate(diffTime)

  -- BulletObject.processUpdate(diffTime)
  TimerKnife.update(diffTime)

  -- setupEnemyMoves(self.map, self.playerTank, self.enemies, self.bullets)

  -- conflicts processing
  -- self.gameFinished = processConflictsTankVsEnemies(self.playerTank, self.enemies)
  -- if (self.gameFinished) then
  --   LL.debug("hahah, game over")
  --   return
  -- end

  -- self.gameFinished = processConflictsBulletsVsPlayer(self.bullets, self.playerTank)
  -- if (self.gameFinished) then
  --   cleanupBulletsArray(self.bullets)
  --   LL.debug("hahah, game over, player killed")
  --   return
  -- end  

  -- processConflictsBulletsVsEnemies(self.bullets, self.enemies)
  -- cleanupBulletsArray(self.bullets)
  -- cleanupEnemiesArray(self.enemies)

  -- processConflictsBulletsVsWalls(self.map, self.bullets)
  -- cleanupBulletsArray(self.bullets)

end
