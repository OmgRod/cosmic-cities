local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local Starfield = require("include.background.starfield")
local SpriteFont = require("include.spritefont")
local GameSaveManager = require("include.gamesave")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local loadslot = {}

local loadingProgress = 0
local loadingSpeed = 1.2
local done = false
local timer = 0
local saveName = passvar[1] or "defaultslot"
local saveFile = saveName .. ".ini"

function loadslot.update(dt)
    Starfield.update(dt)

    if not done then
        loadingProgress = loadingProgress + dt * loadingSpeed
        if loadingProgress >= 1 then
            done = true
        end
    else
        timer = timer + dt
        if timer >= 0.6 then
            state.switch("states/game;" .. saveFile)
        end
    end
end

function loadslot.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local text = done and "Loading..." or "Preparing Save..."
    local scale = 2
    local x = vw / 2 - bigFont:getWidth(text, scale) / 2
    local y = vh * 0.45
    bigFont:draw(text, x, y, scale)

    local barW = vw * 0.5
    local barH = 18
    local barX = (vw - barW) / 2
    local barY = vh * 0.6

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, barW, barH)

    love.graphics.setColor(0.3, 0.9, 0.3)
    love.graphics.rectangle("fill", barX, barY, barW * math.min(loadingProgress, 1), barH)
end

return loadslot
