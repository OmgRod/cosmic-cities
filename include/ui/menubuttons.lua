local MenuButtons = {}

function MenuButtons.create(buttonDefs, font, fontScale, vw, vh, logoHeight, spacing)
    local buttons = {}

    local texts = {}
    for i, def in ipairs(buttonDefs) do
        texts[i] = type(def) == "table" and def.text or def
    end

    local startY = logoHeight
    local availableHeight = vh - startY

    local buttonHeight = font.lineHeight * fontScale
    local totalButtonsHeight = #texts * buttonHeight + (#texts - 1) * spacing
    local offsetY = startY + (availableHeight - totalButtonsHeight) / 2

    for i, def in ipairs(buttonDefs) do
        local text = type(def) == "table" and def.text or def
        local width = font:getWidth(text, fontScale)
        local x = (vw / 2) - (width / 2)
        local y = offsetY + (i - 1) * (buttonHeight + spacing)

        buttons[i] = {
            text = text,
            x = x,
            y = y,
            width = width,
            height = buttonHeight,
            callback = type(def) == "table" and def.callback or nil
        }
    end

    return buttons
end

function MenuButtons.draw(buttons, selectedIndex, font, fontScale, selectedColor, normalColor)
    for i, btn in ipairs(buttons) do
        if i == selectedIndex then
            love.graphics.setColor(selectedColor[1], selectedColor[2], selectedColor[3])
        else
            love.graphics.setColor(normalColor[1], normalColor[2], normalColor[3])
        end
        font:draw(btn.text, btn.x, btn.y, fontScale)
    end
end

function MenuButtons.getHoveredIndex(buttons, mx, my)
    for i, btn in ipairs(buttons) do
        if mx >= btn.x and mx <= btn.x + btn.width and my >= btn.y and my <= btn.y + btn.height then
            return i
        end
    end
    return nil
end

function MenuButtons.activate(buttons, index)
    local btn = buttons[index]

    local n = love.math.random(1, 5)
    local sound = love.audio.newSource("assets/sounds/sfx.blip." .. n .. ".wav", "static")
    sound:play()

    if btn and btn.callback then
        btn.callback()
    end
end

return MenuButtons
