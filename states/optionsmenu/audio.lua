local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")
local GameSaveManager = require("include.gamesave")
local Monthlies = require("include.ui.monthlies")
local musicmanager = require("include.musicmanager")

local audio = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local buttonScale = 1
local selectedButton = 1

local buttonCount = 2
local buttonHeight = bigFont.lineHeight * buttonScale
local buttonSpacing = 5
local totalButtonsHeight = (buttonHeight * buttonCount) + (buttonSpacing * (buttonCount - 1))
local startY = (vh / 2) - (totalButtonsHeight / 2) - 50

local save = GameSaveManager.load("options.ini")

local buttons

local function createButtons()
    return MenuButtons.create({
        { 
            text = "Old Menu Theme: " .. ((save:get("oldmenutheme", "Audio") and "On") or "Off"), 
            callback = function()
                save:setAndSave("oldmenutheme", not save:get("oldmenutheme", "Audio"), "Audio")
                if save:get("oldmenutheme", "Audio") then
                    musicmanager.stop(musicmanager.getCurrent())
                    musicmanager.play("music.intro.old", true)
                else
                    musicmanager.stop(musicmanager.getCurrent())
                    musicmanager.play("music.intro", true)
                end
                buttons = createButtons()
                selectedButton = 1
            end
        },
        { text = "Back", callback = function() state.switch("states/options") end },
    }, bigFont, buttonScale, vw, vh, startY, buttonSpacing)
end

buttons = createButtons()

function audio.update(dt)
    Starfield.update(dt)
end

function audio.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local title = "Audio Settings"
    local scaleBig = 2
    local titleX = math.floor(vw / 2 - bigFont:getWidth(title, scaleBig) / 2)
    local titleY = 50
    bigFont:draw(title, titleX, titleY, scaleBig)

    MenuButtons.draw(buttons, selectedButton, bigFont, buttonScale, {1, 1, 0}, {1, 1, 1})

    Monthlies.draw()
end

function audio.keypressed(key)
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

function audio.enter()
    selectedButton = 1
    buttons = createButtons()
end

return audio
