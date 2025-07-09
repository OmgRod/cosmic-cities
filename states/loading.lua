local autoscale = require("include.autoscale")
local Starfield = require("include.background.starfield")
local SpriteFont = require("include.spritefont")
local flux = require("include.flux")
local GameSaveManager = require("include.gamesave")
local musicmanager = require("include.musicmanager")
local discord = require("include.discordRPC")
local steam = require("include.steamwrapper")
local state = require("include.stateswitcher")
local ProgressBar = require("include.ui.progressbar")

local loadingFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local loading = {
    fade = 0,
    stageIndex = 0,
    stageTimer = 0,
    stageDelay = 0.4,
    currentStageName = "Initializing...",
    progress = 0,
    done = false,
    exitTimer = 0
}

flux.to(loading, 1, { fade = 1 }):ease("quadout")

local stages = {
    {
        name = "Example loading state",
        func = function()
            print("Hello, world!")
        end
    }
}

function loading.update(dt)
    Starfield.update(dt)
    flux.update(dt)

    if not loading.done then
        loading.stageTimer = loading.stageTimer + dt
        if loading.stageTimer >= loading.stageDelay then
            loading.stageTimer = 0
            loading.stageIndex = loading.stageIndex + 1
            local stage = stages[loading.stageIndex]
            if stage then
                loading.currentStageName = stage.name
                loading.progress = loading.stageIndex / #stages
                stage.func()
            else
                loading.done = true
            end
        end
    else
        loading.exitTimer = loading.exitTimer + dt
        if loading.exitTimer >= 0.6 then
            state.switch("states/mainmenu")
        end
    end
end

function loading.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()
    Starfield.draw()

    love.graphics.setColor(1, 1, 1, loading.fade)
    local textScale = 2
    local text = loading.currentStageName
    local x = vw / 2 - loadingFont:getWidth(text, textScale) / 2
    local y = vh * 0.45
    loadingFont:draw(text, x, y, textScale)

    ProgressBar.draw(vw * 0.25, vh * 0.6, vw * 0.5, 18, loading.progress, loading.fade)
    love.graphics.setColor(1, 1, 1, 1)
end

return loading
