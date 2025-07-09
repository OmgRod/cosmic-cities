local progressbar = {}

function progressbar.draw(x, y, width, height, progress, alpha)
    love.graphics.setColor(0.2, 0.2, 0.2, alpha)
    love.graphics.rectangle("fill", x, y, width, height)

    love.graphics.setColor(0.3, 0.9, 0.3, alpha)
    love.graphics.rectangle("fill", x, y, width * math.min(progress, 1), height)
end

return progressbar
