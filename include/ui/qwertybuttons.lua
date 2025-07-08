local QwertyButtons = {}

function QwertyButtons.create(defs, font, scale)
    local buttons = {}
    for i, def in ipairs(defs) do
        local w, h
        if def.image then
            local scaleFactor = scale * 0.5
            w = def.image:getWidth() * scaleFactor
            h = def.image:getHeight() * scaleFactor
        else
            w = font:getWidth(def.text, scale)
            h = font.lineHeight * scale
        end
        buttons[i] = {
            text = def.text,
            origText = def.text,
            image = def.image,
            x = def.x,
            y = def.y,
            width = w,
            height = h,
            col = def.col,
            row = def.row,
            callback = def.callback
        }
    end
    buttons.uppercase = false
    return buttons
end

function QwertyButtons.setUppercase(buttons, isUpper)
    buttons.uppercase = isUpper
    for _, button in ipairs(buttons) do
        if button.origText then
            if buttons.uppercase then
                button.text = button.origText:upper()
            else
                button.text = button.origText:lower()
            end
        end
    end
end

function QwertyButtons.toggleCase(buttons)
    QwertyButtons.setUppercase(buttons, not buttons.uppercase)
end

function QwertyButtons.draw(buttons, selected, font, scale, highlightColor, defaultColor)
    for i, button in ipairs(buttons) do
        local isSelected = i == selected
        local color = isSelected and highlightColor or defaultColor
        love.graphics.setColor(color)

        if button.image then
            local img = button.image
            local imgScale = scale * 0.5
            local drawX = button.x - (img:getWidth() * imgScale) / 2
            local drawY = button.y - (img:getHeight() * imgScale) / 2
            love.graphics.draw(img, drawX, drawY, 0, imgScale, imgScale)
        elseif button.text and button.text ~= "" then
            local textWidth = font:getWidth(button.text, scale)
            local textX = button.x - textWidth / 2
            local textY = button.y
            font:draw(button.text, textX, textY, scale)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function QwertyButtons.activate(buttons, index)
    local b = buttons[index]
    local n = love.math.random(1, 5)
    local s = love.audio.newSource("assets/sounds/sfx.blip." .. n .. ".wav", "static")
    s:play()
    if b and b.callback then
        b.callback()
    end
end

return QwertyButtons
