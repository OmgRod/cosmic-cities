local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local Starfield = require("include.background.starfield")
local SpriteFont = require("include.spritefont")
local GameSaveManager = require("include.gamesave")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local loadslot = {}

local saveName
local slotIndex
local saveFile

local save
local destinationState = nil

local stageIndex = 0
local stageTimer = 0
local stageDelay = 0.3
local progress = 0
local currentStageName = "Starting..."
local done = false
local exitTimer = 0

function loadslot.load(param)
    saveName = param or "defaultslot"
    slotIndex = tonumber(saveName:match("slot_(%d+)"))
    if slotIndex then
        saveFile = "save" .. slotIndex .. ".ini"
    elseif saveName:sub(-4) == ".ini" then
        saveFile = saveName
    else
        saveFile = saveName .. ".ini"
    end

    print("[LoadSlot.load] saveName:", saveName)
    print("[LoadSlot.load] slotIndex:", tostring(slotIndex))
    print("[LoadSlot.load] saveFile:", saveFile)

    stageIndex = 0
    stageTimer = 0
    progress = 0
    currentStageName = "Starting..."
    done = false
    exitTimer = 0
    destinationState = nil
end

local stages = {
    {
        name = "Initializing Save...",
        func = function()
            Starfield.update(0)
            print("[Stage 1] Initializing Save")
        end
    },
    {
        name = "Reading Save File...",
        func = function()
            save = GameSaveManager.load(saveFile)

            if not save then
                print("[Stage 2] No save found, initializing new save:", saveFile)
                save = GameSaveManager.create(saveFile)
                save:set("playername", "", "Meta")
                save:save()
            else
                print("[Stage 2] Save file loaded:", saveFile)
            end
        end
    },
    {
        name = "Analyzing Data...",
        func = function()
            local playername = save:get("playername", "Meta") or ""
            print("[Stage 3] playername in save:", tostring(playername))

            if playername ~= "" then
                destinationState = "states/game;" .. saveFile
                print("[Stage 3] Save has initialized data, going to game state")
            else
                destinationState = "states/selectname;" .. saveFile
                print("[Stage 3] Save missing playername, going to selectname state")
            end
        end
    },
    {
        name = "Finalizing...",
        func = function()
            print("[Stage 4] Finalizing stage")
        end
    },
}

function loadslot.update(dt)
    Starfield.update(dt)

    if not done then
        stageTimer = stageTimer + dt
        if stageTimer >= stageDelay then
            stageTimer = 0
            stageIndex = stageIndex + 1
            if stages[stageIndex] then
                currentStageName = stages[stageIndex].name
                progress = stageIndex / #stages
                stages[stageIndex].func()
            else
                done = true
                print("[LoadSlot] All stages done, switching to:", destinationState)
            end
        end
    else
        exitTimer = exitTimer + dt
        if exitTimer >= 0.6 then
            if destinationState then
                state.switch(destinationState)
            else
                print("[LoadSlot] No destinationState set! Staying put.")
            end
        end
    end
end

function loadslot.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local scale = 2
    local x = vw / 2 - bigFont:getWidth(currentStageName, scale) / 2
    local y = vh * 0.45
    bigFont:draw(currentStageName, x, y, scale)

    local barW = vw * 0.5
    local barH = 18
    local barX = (vw - barW) / 2
    local barY = vh * 0.6

    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", barX, barY, barW, barH)

    love.graphics.setColor(0.3, 0.9, 0.3)
    love.graphics.rectangle("fill", barX, barY, barW * progress, barH)
end

return loadslot
