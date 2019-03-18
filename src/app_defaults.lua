local cellSize = 32
local rowsCount = 13
local columnsCount = 13

local function hexColorToLove2D(r,g,b)
  local rr = r/256
  local rg = g/256
  local rb = b/256
  return {rr, rg, rb, 1}
end


local function setupAppDefaults(ctx)
  ctx.largeFrameSize = 40
  ctx.smallFrameSize = 5

  ctx.gameAreaWidth = cellSize*columnsCount
  ctx.gameAreaHeight = cellSize * rowsCount

  ctx.windowWidth = ctx.largeFrameSize*2 + ctx.gameAreaWidth
  ctx.windowHeight = ctx.largeFrameSize*2 + ctx.gameAreaHeight

  ctx.cellSize = cellSize
  ctx.rowsCount = rowsCount
  ctx.columnsCount = columnsCount

  ctx.palette = {}
  -- ctx.palette.emptyScreen = {0.05, 0.05, 0.4, 1} --
  ctx.palette.emptyScreen = hexColorToLove2D(0xff, 0x63, 0x47 )
  ctx.palette.gameAreaBorder = {0.7, 0.03, 0.7, 1}
end

-- ===========================================================================

return {
  setupAppDefaults = setupAppDefaults,
}
