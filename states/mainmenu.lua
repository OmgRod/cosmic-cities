local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local Starfield = require("include.background.starfield")
local SpriteFont = require("include.spritefont")
local MenuButtons = require("include.ui.menubuttons")

local bigFont = SpriteFont.new("assets/fonts/rainyhearts.fnt", "assets/fonts/")
local mainmenu = {}
local logo = love.graphics.newImage("assets/sprites/CC_titleLogo_001.png")

local vw, vh = 640, 480
Starfield.init(vw, vh)

local selectedButton = 1
local buttonFontScale = 1.5
local buttonSpacing = 15
local logoY = vh * 0.15
local logoScale = (vw * 0.8) / logo:getWidth()
local logoHeight = logoY + logo:getHeight() * logoScale

local buttons = MenuButtons.create({
    { text = "Start", callback = function() --[[state.switch("states/game")]] end },
    { text = "Options", callback = function() --[[ state.switch("states/options")]] end },
    { text = "Credits", callback = function() state.switch("states/credits") end },
    { text = "Exit", callback = function() love.event.quit() end },
}, bigFont, buttonFontScale, vw, vh, logoHeight, buttonSpacing)

function mainmenu.update(dt)
    Starfield.update(dt)
end

function mainmenu.draw()
    autoscale.apply()
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(logo, 640 * 0.1, logoY, 0, logoScale, logoScale)

    MenuButtons.draw(buttons, selectedButton, bigFont, buttonFontScale, {1, 1, 0}, {1, 1, 1})

    autoscale.reset()
end

function mainmenu.keypressed(key, scancode, isrepeat)
   if key == "down" then
       selectedButton = selectedButton % #buttons + 1
   elseif key == "up" then
       selectedButton = (selectedButton - 2 + #buttons) % #buttons + 1
   elseif key == "return" or key == "z" then
      if love.keyboard.isDown("lalt", "ralt") then return end
      MenuButtons.activate(buttons, selectedButton)
   end
end

return mainmenu
