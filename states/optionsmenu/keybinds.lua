local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")
local GameSaveManager = require("include.gamesave")
local Monthlies = require("include.ui.monthlies")

local keybinds = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local buttonScale = 1
local selectedButton = 1

local awaitingKey = false
local awaitingKeyAction = nil

local save = GameSaveManager.load("options.ini")

local keyActions = {
    { "walkup",   "Walk Up",    "up" },
    { "walkdown", "Walk Down",  "down" },
    { "walkleft", "Walk Left",  "left" },
    { "walkright","Walk Right", "right" },
    { "quit", "Quit Game", "escape" },
    { "pause", "Pause Game", "x" },
}

local function getCurrentKeybinds()
    local binds = {}
    for _, triple in ipairs(keyActions) do
        local key = triple[1]
        binds[key] = save:get(key, "Keybinds") or triple[3]
    end
    return binds
end

local function getKeybind(key, defaultKey)
    return save:get(key, "Keybinds") or defaultKey or "None"
end

local buttonSpacing = 5

local updateButtonsText

local function createButtons()
    local entries = {}

    for _, triple in ipairs(keyActions) do
        local key, label, defaultKey = triple[1], triple[2], triple[3]
        local value = getKeybind(key, defaultKey)
        table.insert(entries, {
            text = label .. ": " .. value,
            callback = function()
                awaitingKey = true
                awaitingKeyAction = key
            end
        })
    end

    table.insert(entries, {
        text = "Reset All",
        callback = function()
            for _, triple in ipairs(keyActions) do
                local key, _, defaultKey = triple[1], triple[2], triple[3]
                save:set(key, defaultKey, "Keybinds")
            end
            save:save("options.ini")
            awaitingKey = false
            awaitingKeyAction = nil
            updateButtonsText()
        end
    })

    table.insert(entries, {
        text = "Back",
        callback = function()
            awaitingKey = false
            awaitingKeyAction = nil
            state.switch("states/options")
        end
    })

    local buttonCount = #entries
    local buttonHeight = bigFont.lineHeight * buttonScale
    local totalButtonsHeight = (buttonHeight * buttonCount) + (buttonSpacing * (buttonCount - 1))
    local startY = (vh / 2) - (totalButtonsHeight / 2) - 50

    return MenuButtons.create(entries, bigFont, buttonScale, vw, vh, startY, buttonSpacing)
end

local buttons = createButtons()

function updateButtonsText()
    for i, btn in ipairs(buttons) do
        for _, triple in ipairs(keyActions) do
            local key, label, defaultKey = triple[1], triple[2], triple[3]
            if btn.text:sub(1, #label) == label then
                local value = getKeybind(key, defaultKey)
                local newText = label .. ": " .. value
                btn.text = newText
                btn.width = bigFont:getWidth(newText, buttonScale)
                btn.x = (vw / 2) - (btn.width / 2)
            end
        end
    end
end

function keybinds.update(dt)
    Starfield.update(dt)
end

function keybinds.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local title = awaitingKey and ("Press a key for " .. (function()
        for _, triple in ipairs(keyActions) do
            if triple[1] == awaitingKeyAction then
                return triple[2]
            end
        end
        return ""
    end)()) or "Keybinds"
    local scaleBig = 2
    local titleX = math.floor(vw / 2 - bigFont:getWidth(title, scaleBig) / 2)
    local titleY = 50
    bigFont:draw(title, titleX, titleY, scaleBig)

    if not awaitingKey then
        MenuButtons.draw(buttons, selectedButton, bigFont, buttonScale, {1, 1, 0}, {1, 1, 1})
    end

    Monthlies.draw()
end

function keybinds.keypressed(key)
    if awaitingKey then
        save:set(awaitingKeyAction, key, "Keybinds")
        save:save("options.ini")
        awaitingKey = false
        awaitingKeyAction = nil
        updateButtonsText()
        return
    end

    local sound = love.audio.newSource("assets/sounds/sfx.select.1.wav", "static")
    if key == "down" then
        selectedButton = selectedButton % #buttons + 1
        sound:play()
    elseif key == "up" then
        selectedButton = (selectedButton - 2 + #buttons) % #buttons + 1
        sound:play()
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        MenuButtons.activate(buttons, selectedButton)
    end
end

function keybinds.enter()
    awaitingKey = false
    awaitingKeyAction = nil
    buttons = createButtons()
end

keybinds.getCurrentKeybinds = getCurrentKeybinds
return keybinds
