local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")

local game = {}
local player = {
    x = 0,
    y = 0,
    speed = 200
}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

function game.load()
    camera = require("include.hump.camera")
    cam = camera()
end

function game.update(dt)
    Starfield.update(dt)

    if love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end

    cam:lookAt(player.x, player.y)
end

function game.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    cam:attach()
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", player.x, player.y, 10)
    cam:detach()
end

return game
