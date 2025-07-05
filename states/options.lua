local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")

local options = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local vw, vh = 640, 480
Starfield.init(vw, vh)

local buttonScale = 1

local selectedButton = 1

local buttonCount = 5

local buttonHeight = bigFont.lineHeight * buttonScale
local buttonSpacing = 5

local totalButtonsHeight = (buttonHeight * buttonCount) + (buttonSpacing * (buttonCount - 1))
local startY = (vh / 2) - (totalButtonsHeight / 2) - 50

local buttons = MenuButtons.create({
    { text = "Toggle Fullscreen", callback = function() love.window.setFullscreen(not love.window.getFullscreen()) end },
    { text = "Back", callback = function() state.switch("states/mainmenu") end },
}, bigFont, buttonScale, vw, vh, startY, buttonSpacing)

function options.update(dt)
    Starfield.update(dt)
end

function options.draw()
    autoscale.apply()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local title = "Options"
    local scaleBig = 2
    local titleX = math.floor(vw / 2 - bigFont:getWidth(title, scaleBig) / 2)
    local titleY = 50
    bigFont:draw(title, titleX, titleY, scaleBig)

    MenuButtons.draw(buttons, selectedButton, bigFont, buttonScale, {1, 1, 0}, {1, 1, 1})

    autoscale.reset()
end

function options.keypressed(key)
    if key == "down" then
        selectedButton = selectedButton % #buttons + 1
    elseif key == "up" then
        selectedButton = (selectedButton - 2 + #buttons) % #buttons + 1
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        MenuButtons.activate(buttons, selectedButton)
    end
end

return options
