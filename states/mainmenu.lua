local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local Starfield = require("include.background.starfield")
local SpriteFont = require("include.spritefont")
local MenuButtons = require("include.ui.menubuttons")
local musicmanager = require("include.musicmanager")
local discord = require("include.discordRPC")
local splashtext = require("include.ui.splashtext")
local TextboxModule = require("include.ui.textbox")
local SelectionBox = require("include.ui.textbox.selectionbox")
local dialogwrapper = require("include.dialogwrapper")
local gamesave = require("include.gamesave")

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local mainmenu = {}
local logo = love.graphics.newImage("assets/sprites/CC_titleLogo_001.png")

local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local selectedButton = 1
local buttonFontScale = 1.5
local buttonSpacing = 15
local logoY = vh * 0.15
local logoScale = (vw * 0.8) / logo:getWidth()
local logoHeight = logoY + logo:getHeight() * logoScale

local buttons = MenuButtons.create({
    { text = "Start", callback = function() state.switch("states/selectsave") end },
    { text = "Options", callback = function() state.switch("states/options") end },
    { text = "Credits", callback = function() state.switch("states/credits") end },
    {
        text = "Test",
        callback = function()
            local dialog = dialogwrapper.get("newgame")
            if not dialog or mainmenu.textboxGroup then return end

            local texts = {}
            local current = dialog
            while current do
                table.insert(texts, current.text)
                current = current.nextDialog
            end

            mainmenu.textboxGroup = TextboxModule.TextboxGroup.new(texts, bigFont, function() end)
            local w = mainmenu.textboxGroup.width or vw
            local h = mainmenu.textboxGroup.height or vh
            mainmenu.textboxGroup:setPosition((vw - w) / 2, (vh - h) / 2)

            mainmenu.selectionBox = nil
        end
    },
    { text = "Exit", callback = function() love.event.quit() end },
}, bigFont, buttonFontScale, vw, vh, logoHeight, buttonSpacing)

MenuButtons.updateScroll(buttons, selectedButton, vh)

local selectSound = love.audio.newSource("assets/sounds/sfx.select.1.wav", "static")

function mainmenu.load()
    splashtext.init()
    if gamesave.load("options.ini"):get("oldmenutheme", "Audio") then
        if musicmanager.getCurrent() ~= "music.intro.old" then
            musicmanager.stop(musicmanager.getCurrent())
            musicmanager.play("music.intro.old", true)
        end
    else
        if musicmanager.getCurrent() ~= "music.intro" then
            musicmanager.stop(musicmanager.getCurrent())
            musicmanager.play("music.intro", true)
        end
    end

    discord.updatePresence({
        details = "Browsing Menus",
        state = "Main Menu",
        largeImageKey = "logo",
        largeImageText = "Cosmic Cities"
    })
end

function mainmenu.update(dt)
    Starfield.update(dt)
    splashtext.update(dt)

    if mainmenu.textboxGroup and mainmenu.textboxGroup:isActive() then
        mainmenu.textboxGroup:update(dt)
    else
        mainmenu.textboxGroup = nil
    end

    if mainmenu.selectionBox then
        mainmenu.selectionBox:update(dt)
    end
end

function mainmenu.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()
    Starfield.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(logo, vw * 0.1, logoY, 0, logoScale, logoScale)
    MenuButtons.draw(buttons, selectedButton, bigFont, buttonFontScale, {1, 1, 0}, {1, 1, 1})

    local splashX = vw * 0.1 + (logo:getWidth() * logoScale) * 0.85
    local splashY = logoY + logo:getHeight() * logoScale
    splashtext.drawAt(splashX, splashY, -math.pi / 6)

    if mainmenu.textboxGroup and mainmenu.textboxGroup:isActive() then
        mainmenu.textboxGroup:draw()
    end

    if mainmenu.selectionBox then
        mainmenu.selectionBox:draw()
    end

    local copyrightFont = love.graphics.newFont("assets/fonts/pixeloperator.ttf", 16)
    love.graphics.setFont(copyrightFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("© OmgRod 2025 - All Rights Reserved", 10, vh - 20)
end

function mainmenu.keypressed(key, scancode, isrepeat)
    if mainmenu.textboxGroup and mainmenu.textboxGroup:isActive() then
        if key == "return" or key == "kpenter" then
            mainmenu.textboxGroup:advance()

            if not mainmenu.textboxGroup:isActive() then
                local dialog = dialogwrapper.get("newgame")
                local lastDialog = dialog
                while lastDialog and lastDialog.nextDialog do
                    lastDialog = lastDialog.nextDialog
                end

                if lastDialog and lastDialog.options and #lastDialog.options > 0 then
                    local optionItems = {}
                    for i, option in ipairs(lastDialog.options) do
                        optionItems[i] = {
                            text = option.text,
                            callback = option.callback
                        }
                    end

                    local w = mainmenu.textboxGroup.width or vw
                    local h = mainmenu.textboxGroup.height or vh
                    local spacing = 20
                    local boxWidth = w
                    local boxHeight = bigFont.lineHeight * 2
                    local selBoxY = (vh - h) / 2 + h + spacing

                    mainmenu.selectionBox = SelectionBox.new(optionItems, bigFont, (vw - boxWidth) / 2, selBoxY, boxWidth, boxHeight)
                end
            end
            return
        end
    elseif mainmenu.selectionBox then
        if key == "left" then
            mainmenu.selectionBox:move(-1)
            return
        elseif key == "right" then
            mainmenu.selectionBox:move(1)
            return
        elseif key == "return" or key == "kpenter" then
            mainmenu.selectionBox:confirm()
            mainmenu.selectionBox = nil
            mainmenu.textboxGroup = nil
            return
        end
    end

    if key == "down" then
        selectedButton = selectedButton % #buttons + 1
        selectSound:play()
        MenuButtons.updateScroll(buttons, selectedButton, vh)
    elseif key == "up" then
        selectedButton = (selectedButton - 2 + #buttons) % #buttons + 1
        selectSound:play()
        MenuButtons.updateScroll(buttons, selectedButton, vh)
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        MenuButtons.activate(buttons, selectedButton)
    end
end

return mainmenu
