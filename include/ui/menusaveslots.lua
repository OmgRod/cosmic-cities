local MenuSaveSlots = {}

function MenuSaveSlots.create(slotDefs, font, fontScale, vw, vh, startY, spacing, slotWidth, slotHeight)
    local slots = {}

    if #slotDefs == 0 then
        local text = "Create New Save"
        local textWidth = font:getWidth(text, fontScale)
        local textHeight = font.lineHeight * fontScale
        local x = (vw - textWidth) / 2
        local y = (vh - textHeight) / 2

        slots[1] = {
            isEmpty = true,
            x = x,
            y = y,
            text = text,
            callback = nil
        }

        return slots
    end

    local totalHeight = (#slotDefs * slotHeight) + ((#slotDefs - 1) * spacing)
    local offsetY = startY + (vh - startY - totalHeight) / 2

    for i, def in ipairs(slotDefs) do
        local x = (vw - slotWidth) / 2
        local y = offsetY + (i - 1) * (slotHeight + spacing)

        slots[i] = {
            x = x,
            y = y,
            width = slotWidth,
            height = slotHeight,
            slotName = def.slotName or ("Slot " .. i),
            playtime = def.playtime or "00:00:00",
            playerName = def.playerName or "Unknown",
            callback = def.callback
        }
    end

    return slots
end

function MenuSaveSlots.draw(slots, selectedIndex, font, fontScale, selectedColor, normalColor)
    if slots[1] and slots[1].isEmpty then
        love.graphics.setColor(1, 1, 1)
        font:draw(slots[1].text, slots[1].x, slots[1].y, fontScale)
        return
    end

    for i, slot in ipairs(slots) do
        local color = (i == selectedIndex) and selectedColor or normalColor

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", slot.x, slot.y, slot.width, slot.height)

        love.graphics.setColor(color[1], color[2], color[3])
        love.graphics.rectangle("line", slot.x, slot.y, slot.width, slot.height)

        local padding = 10

        font:draw(slot.slotName, slot.x + padding, slot.y + padding, fontScale)
        font:draw(slot.playtime, slot.x + padding, slot.y + slot.height - font.lineHeight * fontScale - padding, fontScale)

        local nameWidth = font:getWidth(slot.playerName, fontScale)
        font:draw(slot.playerName, slot.x + slot.width - nameWidth - padding, slot.y + padding, fontScale)
    end
end

function MenuSaveSlots.getHoveredIndex(slots, mx, my)
    if slots[1] and slots[1].isEmpty then return nil end

    for i, slot in ipairs(slots) do
        if mx >= slot.x and mx <= slot.x + slot.width and my >= slot.y and my <= slot.y + slot.height then
            return i
        end
    end
    return nil
end

function MenuSaveSlots.activate(slots, index)
    local slot = slots[index]
    if not slot or slot.isEmpty then return end

    local n = love.math.random(1, 5)
    local sound = love.audio.newSource("assets/sounds/sfx.blip." .. n .. ".wav", "static")
    sound:play()

    if slot.callback then
        slot.callback()
    end
end

return MenuSaveSlots
