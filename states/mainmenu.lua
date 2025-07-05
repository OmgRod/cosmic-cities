local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local Starfield = require("include.background.starfield")

local mainmenu = {}
local logo = love.graphics.newImage("assets/sprites/CC_titleLogo_001.png")

local vw, vh = 640, 480

Starfield.init(vw, vh)

function mainmenu.update(dt)
    Starfield.update(dt)
end

function mainmenu.draw()
    autoscale.apply()

    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local scale = (640 * 0.8) / logo:getWidth()
    local x = 640 * 0.1
    local y = 480 * 0.15

    love.graphics.draw(logo, x, y, 0, scale, scale)

    autoscale.reset()
end

function mainmenu.keypressed(key)
   if key == "x" then
      state.switch("states/credits")
   end
end

return mainmenu
