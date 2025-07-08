local MenuButtons = {}

function MenuButtons.create(buttonDefs, font, fontScale, vw, vh, logoHeight, spacing, scrollBounds)
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

    buttons.scrollOffset = 0
    buttons.vh = vh
    buttons.startY = startY
    buttons.buttonHeight = buttonHeight
    buttons.spacing = spacing
    buttons.totalHeight = totalButtonsHeight
    buttons.scrollBounds = scrollBounds or {top = startY, bottom = vh} -- default bounds

    return buttons
end

function MenuButtons.updateScroll(buttons, selectedIndex)
    if not selectedIndex or selectedIndex < 1 or selectedIndex > #buttons then
        return
    end

    local btn = buttons[selectedIndex]
    local vh = buttons.vh
    local bounds = buttons.scrollBounds
    local scrollOffset = buttons.scrollOffset
    local buttonHeight = buttons.buttonHeight
    local spacing = buttons.spacing
    local totalHeight = buttons.totalHeight

    -- Calculate the button's center y relative to current scroll
    local btnCenterY = btn.y - scrollOffset + buttonHeight / 2

    -- Calculate the middle of the bounds where we want to center the button ideally
    local boundsCenter = (bounds.top + bounds.bottom) / 2

    -- Desired scroll offset to center the selected button within bounds
    local desiredScrollOffset = btn.y + buttonHeight / 2 - boundsCenter

    -- Clamp scrollOffset so that we don't scroll past the content edges
    local maxScroll = math.max(0, totalHeight - (bounds.bottom - bounds.top))
    if desiredScrollOffset < 0 then
        desiredScrollOffset = 0
    elseif desiredScrollOffset > maxScroll then
        desiredScrollOffset = maxScroll
    end

    buttons.scrollOffset = desiredScrollOffset
end

function MenuButtons.draw(buttons, selectedIndex, font, fontScale, selectedColor, normalColor)
    local scrollOffset = buttons.scrollOffset or 0

    for i, btn in ipairs(buttons) do
        local drawY = btn.y - scrollOffset
        if i == selectedIndex then
            love.graphics.setColor(selectedColor[1], selectedColor[2], selectedColor[3])
        else
            love.graphics.setColor(normalColor[1], normalColor[2], normalColor[3])
        end
        font:draw(btn.text, btn.x, drawY, fontScale)
    end
    love.graphics.setColor(1, 1, 1) -- reset color after drawing
end

function MenuButtons.getHoveredIndex(buttons, mx, my)
    local scrollOffset = buttons.scrollOffset or 0

    for i, btn in ipairs(buttons) do
        local drawY = btn.y - scrollOffset
        if mx >= btn.x and mx <= btn.x + btn.width and my >= drawY and my <= drawY + btn.height then
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
