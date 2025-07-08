local autoscale = require("include.autoscale")

local monthlies = {}

local vw, vh = autoscale.getVirtualSize()

function monthlies.draw()
    local save = require("include.gamesave").load("options.ini")
    if not save:get("monthlies", "EasterEggs") then
        return
    end

    local month = tonumber(os.date("%m"))
    local sprite

    if month == 1 then
        local t = love.timer.getTime()
        local frame = math.floor(t * 2) % 2 + 1
        sprite = love.graphics.newImage(string.format("assets/sprites/CC_januaryIcon_00%d.png", frame))
    elseif month == 2 then
        sprite = love.graphics.newImage("assets/sprites/CC_februaryIcon_001.png")
    elseif month == 3 then
        sprite = love.graphics.newImage("assets/sprites/CC_marchIcon_001.png")
    elseif month == 4 then
        sprite = love.graphics.newImage("assets/sprites/CC_aprilIcon_001.png")
    elseif month == 5 then
        sprite = love.graphics.newImage("assets/sprites/CC_mayIcon_001.png")
    elseif month == 6 then
        sprite = love.graphics.newImage("assets/sprites/CC_juneIcon_001.png")
    elseif month == 7 then
        sprite = love.graphics.newImage("assets/sprites/CC_julyIcon_001.png")
    elseif month == 8 then
        sprite = love.graphics.newImage("assets/sprites/CC_augustIcon_001.png")
    elseif month == 9 then
        sprite = love.graphics.newImage("assets/sprites/CC_septemberIcon_001.png")
    elseif month == 10 then
        sprite = love.graphics.newImage("assets/sprites/CC_octoberIcon_001.png")
    elseif month == 11 then
        sprite = love.graphics.newImage("assets/sprites/CC_novemberIcon_001.png")
    elseif month == 12 then
        sprite = love.graphics.newImage("assets/sprites/CC_decemberIcon_001.png")
    end

    if sprite then
        local padding = 10
        local spriteW, spriteH = sprite:getWidth(), sprite:getHeight()
        local x = vw - spriteW - padding
        local y = vh - spriteH - padding
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(sprite, x, y, 0)
    end
end

return monthlies
