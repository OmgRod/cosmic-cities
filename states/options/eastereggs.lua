local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")
local GameSave = require("include.gamesave")

local eastereggs = {}

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

GameSave.load()

local function createButtons()
    return MenuButtons.create({
        { text = "Options Icons: " .. tostring(GameSave.get("monthlies", "EasterEggs") or false), callback = function()
            GameSave.set("monthlies", not GameSave.get("monthlies", "EasterEggs"), "EasterEggs")
            buttons = createButtons()
        end },
        { text = "Back", callback = function() state.switch("states/options") end },
    }, bigFont, buttonScale, vw, vh, startY, buttonSpacing)
end

buttons = createButtons()

function eastereggs.update(dt)
    Starfield.update(dt)
end

function eastereggs.draw()
    autoscale.apply()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local title = "Easter Eggs"
    local scaleBig = 2
    local titleX = math.floor(vw / 2 - bigFont:getWidth(title, scaleBig) / 2)
    local titleY = 50
    bigFont:draw(title, titleX, titleY, scaleBig)

    MenuButtons.draw(buttons, selectedButton, bigFont, buttonScale, {1, 1, 0}, {1, 1, 1})

    if GameSave.get("monthlies", "EasterEggs") then
        local month = tonumber(os.date("%m"))

        local sprite

        if month == 1 then
            local t = love.timer.getTime()
            local frame = math.floor(t * 2) % 2 + 1
            local spritePath = string.format("assets/sprites/CC_januaryIcon_00%d.png", frame)
            sprite = love.graphics.newImage(spritePath)
        elseif month == 2 then
            sprite = love.graphics.newImage("assets/sprites/CC_februaryIcon_001.png")
        elseif month == 3 then
            sprite = love.graphics.newImage("assets/sprites/CC_marchIcon_001.png")
        elseif month == 4 then
            sprite = love.graphics.newImage("assets/sprites/CC_aprilIcon_001.png")
        elseif month == 5 then
            -- sprite = love.graphics.newImage("assets/sprites/CC_mayIcon_001.png")
        elseif month == 6 then
            -- sprite = love.graphics.newImage("assets/sprites/CC_juneIcon_001.png")
        elseif month == 7 then
            -- sprite = love.graphics.newImage("assets/sprites/CC_julyIcon_001.png")
        elseif month == 8 then
            -- sprite = love.graphics.newImage("assets/sprites/CC_augustIcon_001.png")
        elseif month == 9 then
            -- sprite = love.graphics.newImage("assets/sprites/CC_septemberIcon_001.png")
        elseif month == 10 then
            sprite = love.graphics.newImage("assets/sprites/CC_octoberIcon_001.png")
        elseif month == 11 then
            -- sprite = love.graphics.newImage("assets/sprites/CC_novemberIcon_001.png")
        elseif month == 12 then
            sprite = love.graphics.newImage("assets/sprites/CC_decemberIcon_001.png")
        end

        if sprite then
            local padding = 10
            local spriteW, spriteH = sprite:getWidth(), sprite:getHeight()
            local x = vw - spriteW - padding
            local y = vh - spriteH - padding
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(sprite, x, y, 0)
        end
    end

    autoscale.reset()
end

function eastereggs.keypressed(key)
    if key == "down" then
        selectedButton = selectedButton % #buttons + 1
    elseif key == "up" then
        selectedButton = (selectedButton - 2 + #buttons) % #buttons + 1
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        MenuButtons.activate(buttons, selectedButton)
    end
end

return eastereggs
