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
local gameMap
local mapColliders = {}

local function updateKeybindCache()
    cachedKeybinds = keybinds.getCurrentKeybinds()
end

local function clearMapColliders()
    for _, collider in ipairs(mapColliders) do
        collider:destroy()
    end
    mapColliders = {}
end

function game.load()
    autoscale.load()
    local w, h = love.graphics.getDimensions()
    autoscale.resize(w, h)

    world = wf.newWorld(0, 0, true)
    world:addCollisionClass("RoomSwap")
    world:addCollisionClass("Player", {ignores = {'RoomSwap'}})

    player.collider = world:newBSGRectangleCollider(2528, 1760, 48, 48, 14)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("Player")
    player.collider:setObject(player)
    player.speed = 200

    if musicmanager.getCurrent() == "intro" then
        musicmanager.stop("intro")
    end

    game.loadMap("rooms/ship-main.lua", 2528, 1760)

    cam = camera(player.collider:getX(), player.collider:getY())

    discord.updatePresence({
        details = "Playing",
        state = "Part 1"
    })

    updateKeybindCache()
end

function game.loadMap(mapPath, px, py)
    clearMapColliders()

    gameMap = sti(mapPath)

    local hitboxLayer = gameMap.layers["Hitboxes"]
    if hitboxLayer and hitboxLayer.objects then
        for _, obj in ipairs(hitboxLayer.objects) do
            if obj.shape == "rectangle" then
                local collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                collider:setType("static")
                table.insert(mapColliders, collider)
            end
        end
    end

    local roomSwapLayer = gameMap.layers["RoomSwap"]
    if roomSwapLayer and roomSwapLayer.objects then
        for _, obj in ipairs(roomSwapLayer.objects) do
            if obj.shape == "rectangle" then
                local collider = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
                collider:setCollisionClass("RoomSwap")
                collider:setObject(obj)
                collider:setType("static")
                table.insert(mapColliders, collider)
            end
        end
    end

    if px and py then
        player.collider:setPosition(px, py)
    end
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

    if player.collider:enter('RoomSwap') then
        local collision_data = player.collider:getEnterCollisionData('RoomSwap')
        local other = collision_data.collider
        local userData = other:getObject()
        if userData and userData.properties and userData.properties.RoomFilename then
            local targetMap = userData.properties.RoomFilename
            local targetX = userData.properties.targetX or player.collider:getX()
            local targetY = userData.properties.targetY or player.collider:getY()
            game.loadMap(targetMap, targetX, targetY)
        end
    end

    world:update(dt)

    local px, py = player.collider:getPosition()
    cam:lookAt(px, py)
    
    -- Top
    if cam.x < vw/2 then
        cam.x = vw/2
    end
    -- Left
    if cam.y < vh/2 then
        cam.y = vh/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- Right
    if cam.x > (mapW - vw/2) then
        cam.x = (mapW - vw/2)
    end
    -- Bottom
    if cam.y > (mapH - vh/2) then
        cam.y = (mapH - vh/2)
    end
end

function game.draw()
    autoscale.apply()
    Starfield.draw()
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
