state = require("include.stateswitcher")
autoscale = require("include.autoscale")
local fntparser = require("include.fntparser")

function love.load()
    autoscale.load()
    autoscale.resize(love.graphics.getDimensions())
    state.switch("states/mainmenu")
end

function love.update(dt)
    if state.current.update then
        state.current.update(dt)
    end
end

function love.resize(w, h)
    autoscale.resize(w, h)
end

function love.draw()
    autoscale.apply()
    if state.current.draw then
        state.current.draw()
    end
    autoscale.reset()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
    end

    if state.current.keypressed then
        state.current.keypressed(key, scancode, isrepeat)
    end
end
