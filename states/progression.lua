local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")

local progression = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local backButtonScale = 1
local backPadding = 25 * backButtonScale
local backButtonHeight = bigFont.lineHeight * backButtonScale
local backButtonY = vh - backButtonHeight - backPadding
local selectedButton = 1

local buttons = MenuButtons.create({
    { text = "Back", callback = function() state.switch("states/mainmenu") end },
}, bigFont, backButtonScale, vw, vh, backButtonY, 0)

local planetImage = love.graphics.newImage("assets/sprites/CC_planetShadow_001.png")
local asteroidImage = love.graphics.newImage("assets/sprites/CC_asteroidShadow_001.png")
local planetX, planetY = 100, 100
local asteroidX, asteroidY = 300, 300

local dots = {}

local function getClosestEdgePoints(imageA, x1, y1, imageB, x2, y2)
    local w1, h1 = imageA:getWidth(), imageA:getHeight()
    local w2, h2 = imageB:getWidth(), imageB:getHeight()

    local dx = x2 - x1
    local dy = y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len == 0 then
        return x1, y1, x2, y2
    end

    local ux, uy = dx / len, dy / len

    local edgeA_x = x1 + (w1 / 2) * ux
    local edgeA_y = y1 + (h1 / 2) * uy

    local edgeB_x = x2 - (w2 / 2) * ux
    local edgeB_y = y2 - (h2 / 2) * uy

    return edgeA_x, edgeA_y, edgeB_x, edgeB_y
end

local function generateWaddleDots()
    local startX, startY, endX, endY = getClosestEdgePoints(planetImage, planetX, planetY, asteroidImage, asteroidX, asteroidY)
    dots = {}
    for i = 1, 5 do
        local t = i / 6
        local x = startX + (endX - startX) * t
        local y = startY + (endY - startY) * t
        x = x + love.math.random(-3, 3)
        y = y + love.math.random(-3, 3)
        table.insert(dots, { x = x, y = y })
    end
end

generateWaddleDots()

function progression.draw()
    love.graphics.clear(245 / 255, 81 / 255, 81 / 255, 1)

    love.graphics.setColor(128 / 255, 42 / 255, 42 / 255, 1)
    love.graphics.draw(planetImage, planetX, planetY)
    love.graphics.draw(asteroidImage, asteroidX, asteroidY)

    love.graphics.setColor(1, 1, 1)
    for _, dot in ipairs(dots) do
        love.graphics.circle("fill", dot.x, dot.y, 3)
    end

    MenuButtons.draw(buttons, selectedButton, bigFont, backButtonScale, {1, 1, 0}, {1, 1, 1})
end

function progression.keypressed(key)
    if key == "down" then
        selectedButton = selectedButton % #buttons + 1
    elseif key == "up" then
        selectedButton = (selectedButton - 2 + #buttons) % #buttons + 1
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        MenuButtons.activate(buttons, selectedButton)
    end
end

return progression
