local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")
local camera = require("include.hump.camera")

local game = {}

local vw, vh = autoscale.getVirtualSize()

local player = {
    x = vw / 2,
    y = vh / 2,
    speed = 200
}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

Starfield.init(vw, vh)

local cam

function game.load()
    autoscale.load()
    local w, h = love.graphics.getDimensions()
    autoscale.resize(w, h)

    cam = camera(player.x, player.y)
end

function game.resize(w, h)
    autoscale.resize(w, h)
end

function game.update(dt)
    Starfield.update(dt)

    if love.keyboard.isDown("down") then
        player.y = math.min(player.y + player.speed * dt, vh)
    end
    if love.keyboard.isDown("up") then
        player.y = math.max(player.y - player.speed * dt, 0)
    end
    if love.keyboard.isDown("left") then
        player.x = math.max(player.x - player.speed * dt, 0)
    end
    if love.keyboard.isDown("right") then
        player.x = math.min(player.x + player.speed * dt, vw)
    end

    cam:lookAt(player.x, player.y)
end

function game.draw()
    autoscale.apply()

    cam:attach()
    Starfield.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", player.x, player.y, 10)
    cam:detach()

    autoscale.reset()
end

return game
