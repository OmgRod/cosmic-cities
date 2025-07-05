local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")

local credits = {}

local bigFont = SpriteFont.new("assets/fonts/rainyhearts.fnt", "assets/fonts/")
local smallFont = SpriteFont.new("assets/fonts/rainyhearts.fnt", "assets/fonts/")

local vw, vh = 640, 480

Starfield.init(vw, vh)

function credits.update(dt)
    Starfield.update(dt)
end

function credits.draw()
    autoscale.apply()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1, 1)
    local title = "Credits"
    local scaleBig = 2
    local titleX = math.floor(320 - (bigFont:getWidth(title, scaleBig) / 2))
    local titleY = math.floor(50)
    bigFont:draw(title, titleX, titleY, scaleBig)

    local text = "Lead Developer - OmgRod\nCharacter Art - Caz Wolf"
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local startY = math.floor(240)
    local scaleSmall = 1
    for i, line in ipairs(lines) do
        local lineWidth = smallFont:getWidth(line, scaleSmall)
        local x = math.floor(320 - (lineWidth / 2))
        local y = math.floor(startY + (i - 1) * smallFont.lineHeight * scaleSmall)
        smallFont:draw(line, x, y, scaleSmall)
    end

    autoscale.reset()
end

function credits.keypressed(key)
    if key == "x" then
        state.switch("states/mainmenu")
    end
end

return credits
