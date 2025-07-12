local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local Starfield = require("include.background.starfield")
local SpriteFont = require("include.spritefont")
local MenuButtons = require("include.ui.menubuttons")
local musicmanager = require("include.musicmanager")
local discord = require("include.discordRPC")
local splashtext = require("include.ui.splashtext")
local TextboxModule = require("include.ui.textbox")
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
    -- { 
    --     text = "Test", 
    --     callback = function()
    --         if not mainmenu.textbox then
    --             mainmenu.textbox = TextboxModule.Textbox.new(0, 0,
    --             "Hello <cb>blue</c> and <c#ff8800>orange</c>! This is the <cs>Test</c> textbox. <i50>Instant text here.</i> <s3>Shaking!</s> Wait <d30>30 centiseconds.",
    --             bigFont, 30)
    --             mainmenu.textbox:setPosition((vw - mainmenu.textbox.width)/2, (vh - mainmenu.textbox.height)/2)
    --         end
    --     end 
    -- },
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

    if mainmenu.textbox then
        mainmenu.textbox:update(dt)
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

    if mainmenu.textbox then
        mainmenu.textbox:draw()
    end

    local copyrightFont = love.graphics.newFont("assets/fonts/pixeloperator.ttf", 16)
    love.graphics.setFont(copyrightFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("© OmgRod 2025 - All Rights Reserved", 10, vh - 20)
end

function mainmenu.keypressed(key, scancode, isrepeat)
    if mainmenu.textbox then
        if key == "escape" or key == "return" or key == "z" then
            mainmenu.textbox = nil
            return
        end
    else
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
end

return mainmenu
