local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local MenuButtons = require("include.ui.menubuttons")
local discord = require("include.discordRPC")

local credits = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local smallFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local backButtonScale = 1
local backPadding = 25 * backButtonScale

local backButtonHeight = bigFont.lineHeight * backButtonScale
local backButtonY = vh - backButtonHeight - backPadding

local selectedButton = 1

local buttons = MenuButtons.create({
    { text = "Back", callback = function() state.switch("states/mainmenu") end },
}, bigFont, backButtonScale, vw, vh, backButtonY, 0)

function credits.load()
    discord.updatePresence({
        details = "Browsing Menus",
        state = "Credits"
    })
end

function credits.update(dt)
    Starfield.update(dt)
end

function credits.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    Starfield.draw()

    love.graphics.setColor(1, 1, 1)
    local title = "Credits"
    local scaleBig = 2
    local titleX = math.floor(320 - (bigFont:getWidth(title, scaleBig) / 2))
    local titleY = 80
    bigFont:draw(title, titleX, titleY, scaleBig)

    local text = "Lead Developer - OmgRod\nPixel Art - OmgRod\nMusic - PumpkinSmarty\nSFX - Bfxr"
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    local startY = math.floor(titleY + bigFont.lineHeight * scaleBig + 20)
    local scaleSmall = 1
    local lineSpacing = 6
    for i, line in ipairs(lines) do
        local lineWidth = smallFont:getWidth(line, scaleSmall)
        local x = math.floor(320 - (lineWidth / 2))
        local y = math.floor(startY + (i - 1) * (smallFont.lineHeight * scaleSmall + lineSpacing))
        smallFont:draw(line, x, y, scaleSmall)
    end

    MenuButtons.draw(buttons, selectedButton, bigFont, backButtonScale, {1, 1, 0}, {1, 1, 1})
end

function credits.keypressed(key)
    if key == "down" then
       selectedButton = selectedButton % #buttons + 1
    elseif key == "up" then
       selectedButton = (selectedButton - 2 + #buttons) % #buttons + 1
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        MenuButtons.activate(buttons, selectedButton)
    end
end

return credits
