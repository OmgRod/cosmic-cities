local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuSaveSlots = require("include.ui.menusaveslots")
local GameSaveManager = require("include.gamesave")

local selectsave = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local selectedSlot = 1
local slotScale = 0.85
local slotSpacing = 8
local slotWidth = 360
local slotHeight = 85
local startY = 110

local saveSlots

local backButton = {
    text = "Back",
    callback = function()
        state.switch("states/mainmenu")
    end
}

local function formatTime(seconds)
    seconds = tonumber(seconds or 0)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function createSlots()
    local slots = {}

    for i = 1, 3 do
        local filename = "save" .. i .. ".ini"
        local s = GameSaveManager.load(filename)

        if s and s.data and next(s.data) then
            local playername = (s.get and (s:get("playername", "Meta") or s:get("playername"))) or "Unknown"
            local timePlayedRaw = (s.get and (s:get("time", "Meta") or s:get("time"))) or "0"
            local timePlayed = tonumber(timePlayedRaw) or 0

            slots[i] = {
                slotName = "Slot " .. i,
                playtime = formatTime(timePlayed),
                playername = playername,
                callback = function()
                    state.switch("states/loadslot;slot_" .. i)
                end,
                isEmpty = false
            }
        else
            slots[i] = {
                slotName = "Slot " .. i,
                playtime = "",
                playername = "Create New Save",
                callback = function()
                    state.switch("states/loadslot;slot_" .. i)
                end,
                isEmpty = true
            }
        end
    end

    return slots
end

saveSlots = MenuSaveSlots.create(createSlots(), bigFont, slotScale, vw, vh, startY, slotSpacing, slotWidth, slotHeight)

local totalItems = #saveSlots + 1

function selectsave.update(dt)
    Starfield.update(dt)
end

function selectsave.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local title = "Select a save"
    local scaleBig = 1.8
    local titleX = math.floor(vw / 2 - bigFont:getWidth(title, scaleBig) / 2)
    local titleY = 40
    bigFont:draw(title, titleX, titleY, scaleBig)

    MenuSaveSlots.draw(saveSlots, selectedSlot <= #saveSlots and selectedSlot or nil, bigFont, slotScale, {1, 1, 0}, {1, 1, 1})

    local backY = 130 + (#saveSlots * (slotHeight + slotSpacing)) + 18
    local backX = math.floor(vw / 2 - bigFont:getWidth(backButton.text, slotScale * 1.8) / 2)

    if selectedSlot == totalItems then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(1, 1, 1)
    end

    bigFont:draw(backButton.text, backX, backY, slotScale * 1.8)
end

function selectsave.keypressed(key)
    local sound = love.audio.newSource("assets/sounds/sfx.select.1.wav", "static")

    if key == "down" then
        selectedSlot = selectedSlot % totalItems + 1
        sound:play()
    elseif key == "up" then
        selectedSlot = (selectedSlot - 2 + totalItems) % totalItems + 1
        sound:play()
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        if selectedSlot == totalItems then
            backButton.callback()
        else
            MenuSaveSlots.activate(saveSlots, selectedSlot)
        end
    end
end

return selectsave
