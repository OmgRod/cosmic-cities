local SpriteFont = {}
SpriteFont.__index = SpriteFont

function SpriteFont.new(fntPath, imagePathBase)
    local self = setmetatable({}, SpriteFont)
    local fntStr = love.filesystem.read(fntPath)
    local fntData = require("include.fntparser")(fntStr)

    self.pages = {}
    for id, pageInfo in pairs(fntData.page) do
        local imgPath = imagePathBase .. pageInfo.file
        local img = love.graphics.newImage(imgPath)
        img:setFilter("nearest", "nearest")
        self.pages[id] = img
    end

    self.chars = {}
    for id, charInfo in pairs(fntData.char) do
        local pageImage = self.pages[charInfo.page]
        self.chars[id] = {
            quad = love.graphics.newQuad(
                charInfo.x, charInfo.y,
                charInfo.width, charInfo.height,
                pageImage:getDimensions()
            ),
            xoffset = charInfo.xoffset,
            yoffset = charInfo.yoffset,
            xadvance = charInfo.xadvance,
            page = charInfo.page,
            width = charInfo.width,
            height = charInfo.height
        }
    end

    self.lineHeight = fntData.common.lineHeight or 0

    self.kerning = {}
    if fntData.kerning then
        for _, kern in pairs(fntData.kerning) do
            self.kerning[kern.first] = self.kerning[kern.first] or {}
            self.kerning[kern.first][kern.second] = kern
        end
    end

    return self
end

function SpriteFont:getWidth(text, scale)
    scale = scale or 1
    local width = 0
    for i = 1, #text do
        local c = text:byte(i)
        local charData = self.chars[c]
        if charData then
            width = width + charData.xadvance * scale
            local nextChar = text:byte(i + 1)
            if nextChar and self.kerning[c] and self.kerning[c][nextChar] then
                width = width + self.kerning[c][nextChar].amount * scale
            end
        end
    end
    return width
end

function SpriteFont:draw(text, x, y, scale, outlineColor, outlineSize)
    scale = scale or 1
    outlineSize = outlineSize or 1
    local cursorX = x
    local cursorY = y

    for i = 1, #text do
        local c = text:byte(i)
        local charData = self.chars[c]
        if charData then
            local img = self.pages[charData.page]
            local baseX = cursorX + charData.xoffset * scale
            local baseY = cursorY + charData.yoffset * scale

            if outlineColor then
                love.graphics.setColor(outlineColor)
                for dx = -outlineSize, outlineSize do
                    for dy = -outlineSize, outlineSize do
                        if dx ~= 0 or dy ~= 0 then
                            local ox = math.floor(baseX + dx + 0.5)
                            local oy = math.floor(baseY + dy + 0.5)
                            love.graphics.draw(img, charData.quad, ox, oy, 0, scale, scale)
                        end
                    end
                end
                love.graphics.setColor(1, 1, 1, 1)
            end

            local drawX = math.floor(baseX + 0.5)
            local drawY = math.floor(baseY + 0.5)
            love.graphics.draw(img, charData.quad, drawX, drawY, 0, scale, scale)

            cursorX = cursorX + charData.xadvance * scale
            local nextChar = text:byte(i + 1)
            if nextChar and self.kerning[c] and self.kerning[c][nextChar] then
                cursorX = cursorX + self.kerning[c][nextChar].amount * scale
            end
        end
    end
end

return SpriteFont
