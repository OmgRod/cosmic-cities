local SpriteFont = require("include.spritefont")
local autoscale = require("include.autoscale")
local splashtext = {}

local font = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local vw, vh = autoscale.getVirtualSize()
local splashList = {
    "Hello World!",
    "Pixel Perfect!",
    "Retro vibes!",
    "Bouncy text!",
    "Galactic bytes!",
    "Orbiting logic!",
    "Cosmic creativity!",
    "Zero gravity fun!",
    "404: Space not found",
    "Lost in the star stack",
    "Black holes swallow bugs",
    "The stars remember",
    "Don't forget your soul",
    "* [[Hyperlink blocked]]",
    "The void is listening",
    "This one's watching you",
    "You feel like you've seen this before",
    "Another world, another time",
    "Somewhere, someone is waiting",
    "* It's still loading. Or is it?",
    "You hear distant laughter",
    "Don't trust the stars",
    "The sky hums softly",
    "Everything feels a bit... off",
    "Your name is missing",
    "This reality is temporary",
    "You are not alone",
    "PRESS [Z] TO BELIEVE",
    "There's a door somewhere",
    "The darkness knows your name",
}

love.math.setRandomSeed(os.time())

local function pickSplash()
    return splashList[love.math.random(#splashList)]
end

local currentSplash = pickSplash()
local timer = 0
local interval = 2.5
local baseScale = 0.75
local maxScale = 1
local margin = 20
local yellow = {1, 1, 0, 1}
local black = {0, 0, 0, 1}
local outlineSize = 1

function splashtext.init()
    currentSplash = pickSplash()
    timer = 0
end

function splashtext.update(dt)
    timer = timer + dt
    if timer >= interval then
        timer = timer - interval
    end
end

function splashtext.drawAt(x, y, angle)
    local baseMaxScale = 1

    local fullWidthAtScale1 = font:getWidth(currentSplash, 1)
    local maxAllowedScale = (vw - margin * 2) / fullWidthAtScale1

    local maxScaleDynamic = math.min(baseMaxScale, maxAllowedScale)
    local baseScaleDynamic = maxScaleDynamic * 0.75

    local t = (timer / interval) * math.pi
    local animScale = baseScaleDynamic + (maxScaleDynamic - baseScaleDynamic) * math.abs(math.sin(t))

    local width = font:getWidth(currentSplash, animScale)
    local height = font.lineHeight * animScale

    love.graphics.push()
    love.graphics.translate(x + margin, y + margin)
    love.graphics.rotate(angle)
    love.graphics.translate(-width / 2, -height / 2)

    love.graphics.setColor(black)
    for dx = -outlineSize, outlineSize do
        for dy = -outlineSize, outlineSize do
            if dx ~= 0 or dy ~= 0 then
                font:draw(currentSplash, dx, dy, animScale)
            end
        end
    end

    love.graphics.setColor(yellow)
    font:draw(currentSplash, 0, 0, animScale)

    love.graphics.pop()
end

return splashtext
