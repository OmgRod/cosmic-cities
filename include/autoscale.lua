local autoscale = {}

local vw, vh = 640, 480
local scale, offsetX, offsetY = 1, 0, 0
local canvas

local isApplied = false

function autoscale.load()
    canvas = love.graphics.newCanvas(vw, vh)
    canvas:setFilter("nearest", "nearest")
end

function autoscale.resize(sw, sh)
    local sx = math.floor(sw / vw)
    local sy = math.floor(sh / vh)
    scale = math.max(1, math.min(sx, sy))

    local scaledW = vw * scale
    local scaledH = vh * scale
    offsetX = math.floor((sw - scaledW) / 2)
    offsetY = math.floor((sh - scaledH) / 2)
end

function autoscale.apply()
    if isApplied then return end
    isApplied = true
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 1) -- alpha=1 fix to avoid transparency artifacts
    love.graphics.push()
    love.graphics.origin()
end

function autoscale.reset()
    if not isApplied then return end
    isApplied = false
    love.graphics.pop()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, offsetX, offsetY, 0, scale, scale)
end

function autoscale.getScale()
    return scale
end

function autoscale.getOffset()
    return offsetX, offsetY
end

function autoscale.getVirtualSize()
    return vw, vh
end

return autoscale
