local Starfield = {}

local vw, vh = 640, 480
local starCount = 100
local starSpeed = 2.5

local stars = {}
local bgColorA = {0.02, 0.05, 0.02}
local bgColorB = {0.04, 0.08, 0.04}
local bgColor = {0, 0, 0}
local bgColorTime = 0
local bgColorDuration = 10

function Starfield.init(width, height, count, speed, colorA, colorB, duration)
    vw = width or vw
    vh = height or vh
    starCount = count or starCount
    starSpeed = speed or starSpeed
    bgColorA = colorA or bgColorA
    bgColorB = colorB or bgColorB
    bgColorDuration = duration or bgColorDuration

    stars = {}
    for i = 1, starCount do
        stars[i] = {
            x = math.random(0, vw),
            y = math.random(0, vh),
            size = math.random(1, 2)
        }
    end
end

function Starfield.update(dt)
    bgColorTime = (bgColorTime + dt) % bgColorDuration

    for _, star in ipairs(stars) do
        star.x = star.x - starSpeed * dt
        if star.x < 0 then
            star.x = vw
            star.y = math.random(0, vh)
            star.size = math.random(1, 2)
        end
    end
end

function Starfield.draw()
    love.graphics.setColor(1, 1, 1, 1)
    for _, star in ipairs(stars) do
        love.graphics.rectangle("fill", star.x, star.y, star.size, star.size)
    end

    local t = bgColorTime / (bgColorDuration / 2)
    if t > 1 then t = 2 - t end
    for i = 1, 3 do
        bgColor[i] = bgColorA[i] + (bgColorB[i] - bgColorA[i]) * t
    end

    love.graphics.setColor(bgColor[1], bgColor[2], bgColor[3], 0.3)
    love.graphics.rectangle("fill", 0, 0, vw, vh)
end

return Starfield
