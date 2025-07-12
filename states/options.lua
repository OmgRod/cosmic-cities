local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")
local GameSaveManager = require("include.gamesave")
local Monthlies = require("include.ui.monthlies")
local discord = require("include.discordRPC")

local options = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local buttonScale = 1

local selectedButton = 1

local buttonCount = 5

local buttonHeight = bigFont.lineHeight * buttonScale
local buttonSpacing = 5

local totalButtonsHeight = (buttonHeight * buttonCount) + (buttonSpacing * (buttonCount - 1))
local startY = (vh / 2) - (totalButtonsHeight / 2) - 50

function options.loadSave(filename)
    save = GameSaveManager.load(filename or "options.ini")
end

options.loadSave()

function options.load()
    discord.updatePresence({
        details = "Browsing Menus",
        state = "Options"
    })
end

local function createButtons()
    return MenuButtons.create({
        { text = "Fullscreen: " .. (love.window.getFullscreen() and "On" or "Off"), callback = function() 
            love.window.setFullscreen(not love.window.getFullscreen()) 
            buttons = createButtons()
        end },
        {
            text = "Show FPS: " .. ((save:get("fps", "Miscellaneous") and "On") or "Off"), 
            callback = function()
                save:setAndSave("fps", not save:get("fps", "Miscellaneous"), "Miscellaneous")
                buttons = createButtons()
            end
        },
        {
            text = "Autosave: " .. ((save:get("autosave", "Miscellaneous") and "On") or "Off"), 
            callback = function()
                save:setAndSave("autosave", not save:get("autosave", "Miscellaneous"), "Miscellaneous")
                buttons = createButtons()
            end
        },
        { text = "Keybinds", callback = function() state.switch("states/optionsmenu/keybinds") end },
        { text = "Easter Eggs", callback = function() state.switch("states/optionsmenu/eastereggs") end },
        { text = "Back", callback = function() state.switch("states/mainmenu") end },
    }, bigFont, buttonScale, vw, vh, startY, buttonSpacing)
end

buttons = createButtons()

function options.update(dt)
    Starfield.update(dt)

    local currentFullscreen = love.window.getFullscreen()
    if currentFullscreen ~= prevFullscreen then
        prevFullscreen = currentFullscreen
        buttons = createButtons()
    end
end

function options.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local title = "Options"
    local scaleBig = 2
    local titleX = math.floor(vw / 2 - bigFont:getWidth(title, scaleBig) / 2)
    local titleY = 50
    bigFont:draw(title, titleX, titleY, scaleBig)

    MenuButtons.draw(buttons, selectedButton, bigFont, buttonScale, {1, 1, 0}, {1, 1, 1})

    Monthlies.draw()
end

function options.keypressed(key)
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

return options
