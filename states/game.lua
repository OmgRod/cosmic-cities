local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")
local musicmanager = require("include.musicmanager")
local camera = require("include.hump.camera")
local discord = require("include.discordRPC")
local anim8 = require("include.anim8")
local sti = require("include.sti")

local keybinds = require("states.optionsmenu.keybinds")

local game = {}

local vw, vh = autoscale.getVirtualSize()

local player = {
    x = 790,
    y = 420,
    speed = 200
}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

Starfield.init(vw, vh)

local cam

local cachedKeybinds = {}

local function updateKeybindCache()
    cachedKeybinds = keybinds.getCurrentKeybinds()
end

function game.load()
    autoscale.load()
    local w, h = love.graphics.getDimensions()
    autoscale.resize(w, h)

    if musicmanager.getCurrent() == "intro" then
        musicmanager.stop("intro")
    end

    gameMap = sti("rooms/ship-cryobeds.lua")

    cam = camera(player.x, player.y)

    discord.updatePresence({
        details = "Playing",
        state = "Part 1"
    })

    updateKeybindCache()
end

function game.resize(w, h)
    autoscale.resize(w, h)
end

function game.refreshKeybinds()
    updateKeybindCache()
end

function game.update(dt)
    Starfield.update(dt)

    if love.keyboard.isDown(cachedKeybinds.walkdown) then
        player.y = player.y + player.speed * dt
    end
    if love.keyboard.isDown(cachedKeybinds.walkup) then
        player.y = player.y - player.speed * dt
    end
    if love.keyboard.isDown(cachedKeybinds.walkleft) then
        player.x = player.x - player.speed * dt
    end
    if love.keyboard.isDown(cachedKeybinds.walkright) then
        player.x = player.x + player.speed * dt
    end

    cam:lookAt(player.x, player.y)
end

function game.draw()
    autoscale.apply()

    cam:attach()
    gameMap:drawLayer(gameMap.layers["Ground"])
    gameMap:drawLayer(gameMap.layers["Objects-1"])
    gameMap:drawLayer(gameMap.layers["BackWall"])
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", player.x, player.y, 10)
    gameMap:drawLayer(gameMap.layers["FrontWall"])
    cam:detach()

    autoscale.reset()
end

return game
