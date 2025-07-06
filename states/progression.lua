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

function progression.draw()
    autoscale.apply()
    love.graphics.clear(245 / 255, 81 / 255, 81 / 255, 1)

    local planetShadow = love.graphics.newImage("assets/sprites/CC_planetShadow_001.png")
    local planetX = vw / 2 - planetShadow:getWidth() / 2
    local planetY = vh / 2 - planetShadow:getHeight() / 2
    love.graphics.setColor(128 / 255, 42 / 255, 42 / 255, 1)
    love.graphics.draw(planetShadow, planetX, planetY)

    MenuButtons.draw(buttons, selectedButton, bigFont, backButtonScale, {1, 1, 0}, {1, 1, 1})

    autoscale.reset()
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
