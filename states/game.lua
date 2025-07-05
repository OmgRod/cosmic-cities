local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")

local game = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

function game.update(dt)
    Starfield.update(dt)
end

function game.draw()
    autoscale.apply()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    

    autoscale.reset()
end

function game.keypressed(key)
    if key == "down" then
    
    end
    if key == "up" then

    end
    if key == "left" then

    end
    if key == "right" then

    end
end

return game
