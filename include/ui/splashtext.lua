local SpriteFont = require("include.spritefont")
local splashtext = {}

local font = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local splashList = {
    "Hello World!",
    "Lua is love.",
    "Powered by LOVE!",
    "Pixel Perfect!",
    "Scripting Supreme!",
    "Frame it fast!",
    "Draw with bytes!",
    "Retro vibes!",
    "Modular Madness!",
    "Bouncy text!",
    "Code is poetry!",
    "Compile and conquer!",
    "Hello, bugs!",
    "Debugging mode ON",
    "Script like a wizard",
    "Stars in the code!",
    "Galactic bytes!",
    "Orbiting logic!",
    "Cosmic creativity!",
    "Zero gravity fun!",
    "404: Space not found",
    "Debugging in orbit",
    "Infinite loops in space",
    "Aliens use semicolons?",
    "My code's out of this world",
    "Lost in the star stack",
    "Function calls from Mars",
    "Black holes swallow bugs",
    "Cosmos meets compiler",
    "Interstellar if-else",
    "Quantum bits and bytes",
    "Rocket fuel for your code",
    "Deploying to the moon",
    "Spacewalk through variables",
    "Astro-debugging activated",
    "Comet tail recursion",
    "Code warp speed",
    "Binary stars align",
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
    local t = (timer / interval) * math.pi
    local scale = baseScale + (maxScale - baseScale) * math.abs(math.sin(t))
    local width = font:getWidth(currentSplash, scale)
    local height = font.lineHeight * scale

    love.graphics.push()
    love.graphics.translate(x + margin, y + margin)
    love.graphics.rotate(angle)
    love.graphics.translate(-width / 2, -height / 2)

    love.graphics.setColor(black)
    for dx = -outlineSize, outlineSize do
        for dy = -outlineSize, outlineSize do
            if dx ~= 0 or dy ~= 0 then
                font:draw(currentSplash, dx, dy, scale)
            end
        end
    end

    love.graphics.setColor(yellow)
    font:draw(currentSplash, 0, 0, scale)

    love.graphics.pop()
end

return splashtext
