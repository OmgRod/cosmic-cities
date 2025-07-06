state = require("include.stateswitcher")
autoscale = require("include.autoscale")
local fntparser = require("include.fntparser")
local SpriteFont = require("include.spritefont")
local flux = require("include.flux")
local GameSave = require("include.gamesave")

local escapeHoldTime = 0
local escapeHeld = false

local deltatime;

local quitFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local quitDotCount = 0
quitFade = 0
local quitDotTimer = 0
local quitting = false

local vw, vh = autoscale.getVirtualSize()

GameSave.load()

function love.load()
    autoscale.load()
    autoscale.resize(love.graphics.getDimensions())
    state.switch("states/mainmenu")
end

function love.update(dt)
    flux.update(dt)

    deltatime = dt

    if escapeHeld then
        escapeHoldTime = escapeHoldTime + dt
        if escapeHoldTime >= 2 and not quitting then
            quitting = true
            quitDotCount = 0
            quitDotTimer = 0

            flux.to(_G, 1/3, { quitFade = 1 }):ease("quadout")
        end
    end

    if quitting then
        quitDotTimer = quitDotTimer + dt
        if quitDotTimer >= 1 then
            quitDotTimer = quitDotTimer - 1
            quitDotCount = (quitDotCount % 3) + 1
        end
    end

    if quitting and escapeHoldTime >= 5 then
        love.event.quit()
    end

    if state.current.update then
        state.current.update(dt)
    end
end

function love.resize(w, h)
    autoscale.resize(w, h)
end

function love.draw()
    love.graphics.clear()

    if state.current.draw then
        state.current.draw()
    end

    autoscale.apply()

    if quitting then
        local dots = string.rep(".", quitDotCount)
        local text = "Quitting" .. dots
        local scale = 1.5

        local x = 5
        local y = 35

        love.graphics.setColor(1, 1, 1, quitFade)
        quitFont:draw(text, x, y, scale)
        love.graphics.setColor(1, 1, 1, 1)
    end

    if GameSave.get("fps", "Options") then
        if not love.fpsDisplayTimer then love.fpsDisplayTimer = 0 end
        if not love.fpsDisplayValue then love.fpsDisplayValue = 0 end

        love.fpsDisplayTimer = love.fpsDisplayTimer + deltatime
        if love.fpsDisplayTimer >= 0.2 then
            love.fpsDisplayValue = math.floor(1 / deltatime + 0.5)
            love.fpsDisplayTimer = 0
        end

        local text = "FPS: " .. love.fpsDisplayValue
        local scale = 1.5

        local x = 5
        local y = 5

        love.graphics.setColor(1, 1, 1)
        quitFont:draw(text, x, y, scale)
        love.graphics.setColor(1, 1, 1, 1)
    end

    autoscale.reset()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    end

    if key == "escape" then
        escapeHeld = true
        escapeHoldTime = 0
        quitting = false
        quitDotCount = 0
        quitDotTimer = 0
        quitFade = 0
        flux.remove(_G, "quitFade")
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
