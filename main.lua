state = require("include.stateswitcher")
autoscale = require("include.autoscale")
local fntparser = require("include.fntparser")
local SpriteFont = require("include.spritefont")

local escapeHoldTime = 0
local escapeHeld = false

local quitFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local quitMessage = "Quitting"
local quitDotCount = 0
local quitFade = 0
local quitDotTimer = 0
local quitting = false

local vw, vh = autoscale.getVirtualSize()

local function lerp(a, b, t)
    return a + (b - a) * t
end

function love.load()
    autoscale.load()
    autoscale.resize(love.graphics.getDimensions())
    state.switch("states/mainmenu")
end

function love.update(dt)
    if escapeHeld then
        escapeHoldTime = escapeHoldTime + dt
        if escapeHoldTime >= 2 and not quitting then
            quitting = true
            quitDotCount = 0
            quitDotTimer = 0
        end
    end

    if quitting then
        quitDotTimer = quitDotTimer + dt
        if quitDotTimer >= 1 then
            quitDotTimer = quitDotTimer - 1
            quitDotCount = (quitDotCount % 3) + 1
        end

        quitFade = lerp(quitFade, 1, math.min(1, 3 * dt))
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
        local text = quitMessage .. dots
        local scale = 1.5

        local x = 5
        local y = 5

        love.graphics.setColor(1, 1, 1, quitFade)
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
    end
end
