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
local wf = require("include.windfield")

local keybinds = require("states.optionsmenu.keybinds")

local game = {}

local vw, vh = autoscale.getVirtualSize()

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

Starfield.init(vw, vh)

local cam
local cachedKeybinds = {}
local world
local player = {}

local function updateKeybindCache()
    cachedKeybinds = keybinds.getCurrentKeybinds()
end

function game.load()
    autoscale.load()
    local w, h = love.graphics.getDimensions()
    autoscale.resize(w, h)

    world = wf.newWorld(0, 0, true)

    player.collider = world:newBSGRectangleCollider(1312, 416, 48, 48, 14)
    player.collider:setFixedRotation(true)
    player.speed = 200

    if musicmanager.getCurrent() == "intro" then
        musicmanager.stop("intro")
    end

    gameMap = sti("rooms/ship-cryobeds.lua")

    local hitboxLayer = gameMap.layers["Hitboxes"]
    if hitboxLayer and hitboxLayer.objects then
        for _, obj in ipairs(hitboxLayer.objects) do
            if obj.shape == "rectangle" then
                local collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                collider:setType("static")
            end
        end
    end

    cam = camera(player.collider:getX(), player.collider:getY())

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

    local vx, vy = 0, 0

    if love.keyboard.isDown(cachedKeybinds.walkdown) then vy = vy + 1 end
    if love.keyboard.isDown(cachedKeybinds.walkup) then vy = vy - 1 end
    if love.keyboard.isDown(cachedKeybinds.walkleft) then vx = vx - 1 end
    if love.keyboard.isDown(cachedKeybinds.walkright) then vx = vx + 1 end

    if vx ~= 0 or vy ~= 0 then
        local len = math.sqrt(vx * vx + vy * vy)
        vx, vy = vx / len, vy / len
        player.collider:setLinearVelocity(vx * player.speed, vy * player.speed)
    else
        player.collider:setLinearVelocity(0, 0)
    end

    world:update(dt)

    local px, py = player.collider:getPosition()
    cam:lookAt(px, py)
end

function game.draw()
    autoscale.apply()
    cam:attach()

    if gameMap.layers["Ground"] then
        gameMap:drawLayer(gameMap.layers["Ground"])
    end
    if gameMap.layers["Objects-1"] then
        gameMap:drawLayer(gameMap.layers["Objects-1"])
    end
    if gameMap.layers["Walls"] then
        gameMap:drawLayer(gameMap.layers["Walls"])
    end

    love.graphics.setColor(1, 1, 1)
    local px, py = player.collider:getPosition()
    love.graphics.circle("fill", px, py, 10)

    world:draw()

    cam:detach()
    autoscale.reset()
end

return game
