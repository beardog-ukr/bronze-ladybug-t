local settings_m = require("src/app_defaults")
local appDef = {}
settings_m.setupAppDefaults(appDef)

local LL = require '../thirdparty/log_lua/log'

require "src/tanks_game"
local tanksGame = nil

-- ===========================================================================

function love.keypressed(key)
  tanksGame:processKeyPressed(key)
end

-- ===========================================================================

function love.load(arg)
  local success = love.window.setMode(appDef.windowWidth, appDef.windowHeight,
                                      {resizable=false})
  if (not success) then
    log_m.error("Failed to set window mode")
  end

  love.window.setTitle( "A kind of Tanks game" )

  tanksGame = TanksGame(appDef.largeFrameSize, appDef.largeFrameSize,
                        appDef.gameAreaWidth, appDef.gameAreaHeight)
end

-- ===========================================================================

local function drawLargeBorders()
  -- draw (restore) large borders
  love.graphics.setColor(appDef.palette.emptyScreen)
  love.graphics.rectangle("fill", 0, 0, 
                          appDef.largeFrameSize, appDef.windowHeight)
  love.graphics.rectangle("fill", appDef.largeFrameSize + appDef.gameAreaWidth, 0,
                          appDef.largeFrameSize, appDef.windowHeight)
  love.graphics.rectangle("fill", appDef.largeFrameSize, 0,
                          appDef.gameAreaWidth, appDef.largeFrameSize)
  love.graphics.rectangle("fill", 
                          appDef.largeFrameSize, appDef.largeFrameSize + appDef.gameAreaHeight,
                          appDef.gameAreaWidth, appDef.largeFrameSize)
end

local function drawSmallBorders()
  --draw smaller borders
  love.graphics.setColor(appDef.palette.gameAreaBorder)

  love.graphics.rectangle("fill",
                          appDef.largeFrameSize - appDef.smallFrameSize, 
                          appDef.largeFrameSize - appDef.smallFrameSize,
                          appDef.gameAreaWidth + appDef.smallFrameSize*2, 
                          appDef.smallFrameSize)
  love.graphics.rectangle("fill",
                          appDef.largeFrameSize - appDef.smallFrameSize, 
                          appDef.largeFrameSize + appDef.gameAreaHeight,
                          appDef.gameAreaWidth + appDef.smallFrameSize*2, appDef.smallFrameSize)
  love.graphics.rectangle("fill",
                          appDef.largeFrameSize - appDef.smallFrameSize, appDef.largeFrameSize,
                          appDef.smallFrameSize, appDef.gameAreaHeight)
  love.graphics.rectangle("fill",
                          appDef.largeFrameSize + appDef.gameAreaWidth, appDef.largeFrameSize,
                          appDef.smallFrameSize, appDef.gameAreaHeight)
  --
end

function love.draw()
  love.graphics.clear()

  drawLargeBorders()
  drawSmallBorders()    

  tanksGame:drawSelf()
end

-- ===========================================================================

function love.update(diffTime)
  tanksGame:processUpdate(diffTime)
end
