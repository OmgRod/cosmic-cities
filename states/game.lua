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
local GameSaveManager = require("include.gamesave")
local keybinds = require("states.optionsmenu.keybinds")

local save

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

local isPaused = false
local pauseButtons = {}
local selectedPauseButton = 1
local pausedFontScale = 1.5
local pausedSpacing = 15
local pausedLogoHeight = vh * 0.2
local hasSavedInPause = false

local currentRoom = "rooms/ship-main.lua"

local autosaveTimer = 0
local autosaveInterval = 900

local totalPlayTime = 0
local playTimeThisSession = 0

function game.saveGame()
    save:set("playerX", player.collider:getX(), "Position")
    save:set("playerY", player.collider:getY(), "Position")
    save:set("currentRoom", currentRoom, "Position")
    save:set("time", totalPlayTime + playTimeThisSession, "Meta")
    save:save()
end

function game.loadGame()
    local savedata = {
        playerX = save:get("playerX", "Position"),
        playerY = save:get("playerY", "Position"),
        currentRoom = save:get("currentRoom", "Position"),
        time = save:get("time", "Meta") or 0,
    }
    totalPlayTime = savedata.time
    playTimeThisSession = 0
    return savedata
end

local function initPauseButtons()
    pauseButtons = MenuButtons.create({
        {
            text = "Continue",
            callback = function()
                isPaused = false
            end
        },
        {
            text = "Save Game",
            callback = function()
                game.saveGame()
                hasSavedInPause = true
            end
        },
        {
            text = "Exit",
            callback = function()
                if not hasSavedInPause then
                    print("Warning: You haven't saved the game.")
                else
                    state.switch("states/mainmenu")
                end
            end
        }
    }, bigFont, pausedFontScale, vw, vh, pausedLogoHeight, pausedSpacing)
    selectedPauseButton = 1
    hasSavedInPause = false
    MenuButtons.updateScroll(pauseButtons, selectedPauseButton)
end

local function updateKeybindCache()
    cachedKeybinds = keybinds.getCurrentKeybinds()
end

local function clearMapColliders()
    for _, collider in ipairs(mapColliders) do
        collider:destroy()
    end
    mapColliders = {}
end

function game.load(savename)
    autoscale.load()
    local w, h = love.graphics.getDimensions()
    autoscale.resize(w, h)

    save = GameSaveManager.load(savename)

    world = wf.newWorld(0, 0, true)
    world:addCollisionClass("RoomSwap")
    world:addCollisionClass("Player", {ignores = {'RoomSwap'}})

    savedata = game.loadGame()

    player.collider = world:newBSGRectangleCollider(savedata.playerX or 2528, savedata.playerY or 1760, 48, 48, 14)
    player.collider:setFixedRotation(true)
    player.collider:setCollisionClass("Player")
    player.collider:setObject(player)
    player.speed = 200

    if musicmanager.getCurrent() == "intro" then
        musicmanager.stop("intro")
    end

    game.loadMap(true, savedata.currentRoom or currentRoom, savedata.playerX or 2528, savedata.playerY or 1760)

    cam = camera(player.collider:getX(), player.collider:getY())

    discord.updatePresence({
        details = "Playing",
        state = "Part 1"
    })

    updateKeybindCache()
end

function game.loadMap(isFirstLoad, mapPath, px, py)
    clearMapColliders()

    gameMap = sti(mapPath)

    currentRoom = mapPath

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

    local autosaveEnabled = GameSaveManager.load("options.ini"):get("autosave", "Miscellaneous")
    if not isFirstLoad and (autosaveEnabled == true or autosaveEnabled == "true") then
        game.saveGame()
        print("game autosaved by room switch")
    end
end

function game.resize(w, h)
    autoscale.resize(w, h)
end

function game.refreshKeybinds()
    updateKeybindCache()
end

function game.update(dt)
    if love.keyboard.isDown(cachedKeybinds.pause) then
        if not game._pausePressed then
            isPaused = not isPaused
            if isPaused then
                initPauseButtons()
            end
            game._pausePressed = true
        end
    else
        game._pausePressed = false
    end

    if isPaused then
        return
    end

    playTimeThisSession = playTimeThisSession + dt

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
            game.loadMap(false, targetMap, targetX, targetY)
        end
    end

    local autosaveEnabled = GameSaveManager.load("options.ini"):get("autosave", "Miscellaneous")
    autosaveTimer = autosaveTimer + dt
    if autosaveTimer >= autosaveInterval and (autosaveEnabled == true or autosaveEnabled == "true") then
        game.saveGame()
        autosaveTimer = 0
        print("game autosaved by timer")
    end

    world:update(dt)

    local px, py = player.collider:getPosition()
    cam:lookAt(px, py)

    if cam.x < vw/2 then cam.x = vw/2 end
    if cam.y < vh/2 then cam.y = vh/2 end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    if cam.x > (mapW - vw/2) then cam.x = (mapW - vw/2) end
    if cam.y > (mapH - vh/2) then cam.y = (mapH - vh/2) end
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

    cam:detach()

    if isPaused then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, vw, vh)

        local title = "Game Paused"
        local titleW = bigFont:getWidth(title, 2)
        local titleX = (vw - titleW) / 2
        local titleY = vh * 0.1
        love.graphics.setColor(1, 1, 1)
        bigFont:draw(title, titleX, titleY, 2)

        MenuButtons.draw(pauseButtons, selectedPauseButton, bigFont, pausedFontScale, {1, 1, 0}, {1, 1, 1})
    end

    autoscale.reset()
end

function game.keypressed(key)
    if isPaused then
        if key == "down" then
            selectedPauseButton = selectedPauseButton % #pauseButtons + 1
            MenuButtons.updateScroll(pauseButtons, selectedPauseButton)
        elseif key == "up" then
            selectedPauseButton = (selectedPauseButton - 2 + #pauseButtons) % #pauseButtons + 1
            MenuButtons.updateScroll(pauseButtons, selectedPauseButton)
        elseif key == "return" or key == "z" then
            if love.keyboard.isDown("lalt", "ralt") then return end
            MenuButtons.activate(pauseButtons, selectedPauseButton)
        end
    end
end

return game
