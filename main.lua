state = require("include.stateswitcher")
autoscale = require("include.autoscale")
local fntparser = require("include.fntparser")
local SpriteFont = require("include.spritefont")
local flux = require("include.flux")
local GameSaveManager = require("include.gamesave")
local musicmanager = require("include.musicmanager")

local escapeHoldTime = 0
local escapeHeld = false

local deltatime

local quitFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local quitDotCount = 0
quitFade = 0
local quitDotTimer = 0
local quitting = false

local vw, vh = autoscale.getVirtualSize()

local save

local notificationSprite = nil
local notificationX = vw
local notificationY = -100
local notificationTimer = 0
local notificationActive = false

function notifySprite(sprite)
    notificationSprite = sprite
    notificationX = vw
    notificationY = -100
    notificationTimer = 0
    notificationActive = true

    flux.to(_G, 0.5, { notificationX = vw - sprite:getWidth() - 10, notificationY = 10 }):ease("quadout")
    flux.after(_G, 3, {}):oncomplete(function()
        flux.to(_G, 0.5, { notificationY = -100 }):ease("quadin"):oncomplete(function()
            notificationActive = false
            notificationSprite = nil
        end)
    end)
end

function generateTextSprite(text)
    local font = love.graphics.newFont(16)
    local w = font:getWidth(text)
    local h = font:getHeight()
    local canvas = love.graphics.newCanvas(w + 20, h + 20)

    love.graphics.setCanvas(canvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setFont(font)
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", 0, 0, canvas:getWidth(), canvas:getHeight(), 8, 8)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, 10, 10)
    love.graphics.setCanvas()

    return love.graphics.newImage(canvas:newImageData())
end

function love.joystickadded(joystick)
    if joystick:isGamepad() then
        local name = joystick:getName()
        local message = "Gamepad connected: " .. name
        local textSprite = generateTextSprite(message)
        notifySprite(textSprite)
    end
end

function love.load()
    autoscale.load()
    autoscale.resize(love.graphics.getDimensions())

    save = GameSaveManager.load("options.ini")
    musicmanager.load("intro", "assets/sounds/music.intro.wav", "stream")

    state.switch("states/mainmenu")
end

function love.update(dt)
    flux.update(dt)
    deltatime = dt

    if escapeHeld then
        escapeHoldTime = escapeHoldTime + dt

        quitDotTimer = quitDotTimer + dt
        if quitDotCount < 4 and quitDotTimer >= 0.5 then
            quitDotTimer = quitDotTimer - 0.5
            quitDotCount = quitDotCount + 1
        end

        if quitDotCount == 4 then
            love.event.quit()
        end
    end

    if state.current.update then
        state.current.update(dt)
    end
end

function love.resize(w, h)
    autoscale.resize(w, h)
    vw, vh = autoscale.getVirtualSize()
    if state.current.resize then
        state.current.resize(w, h)
    end
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    autoscale.apply()
    if state.current.draw then
        state.current.draw()
    end
    autoscale.reset()

    if quitting then
        local dots = string.rep(".", quitDotCount)
        local text = "Quitting" .. dots
        local scale = 1.5
        local x = 5
        local y = (GameSaveManager.load("options.ini"):get("fps", "Miscellaneous") == true or GameSaveManager.load("options.ini"):get("fps", "Miscellaneous") == "true") and 45 or 5

        love.graphics.setColor(1, 1, 1, quitFade)
        quitFont:draw(text, x, y, scale)
    end

    local rawFps = GameSaveManager.load("options.ini"):get("fps", "Miscellaneous")
    local showFps = rawFps == true or rawFps == "true"

    if showFps then
        if not love.fpsDisplayTimer then love.fpsDisplayTimer = 0 end
        if not love.fpsDisplayValue then love.fpsDisplayValue = 0 end

        love.fpsDisplayTimer = love.fpsDisplayTimer + deltatime
        if love.fpsDisplayTimer >= 0.2 then
            love.fpsDisplayValue = math.floor(1 / deltatime + 0.5)
            love.fpsDisplayTimer = 0
        end

        local text = "FPS: " .. love.fpsDisplayValue
        local scale = 1.5
        local x, y = 5, 5

        love.graphics.setColor(1, 1, 1)
        quitFont:draw(text, x, y, scale)
    end

    if notificationActive and notificationSprite then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(notificationSprite, notificationX, notificationY)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    end

    if key == "escape" and not escapeHeld then
        escapeHeld = true
        escapeHoldTime = 0
        quitting = true
        quitDotCount = 0
        quitDotTimer = 0
        quitFade = 0
        flux.remove(_G, "quitFade")
        flux.to(_G, 1, { quitFade = 1 }):ease("quadout")
    end

    if state.current.keypressed then
        state.current.keypressed(key, scancode, isrepeat)
    end
end

function love.keyreleased(key)
    if key == "escape" then
        escapeHeld = false
        escapeHoldTime = 0
        quitting = false
        quitDotCount = 0
        quitDotTimer = 0
        quitFade = 0
        flux.remove(_G, "quitFade")
    end
end
