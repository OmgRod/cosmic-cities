local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local Starfield = require("include.background.starfield")
local QwertyButtons = require("include.ui.qwertybuttons")

local selectname = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local vw, vh = autoscale.getVirtualSize()
Starfield.init(vw, vh)

local buttonScale = 1
local keySpacingX = 50
local keySpacingY = 60
local startY = vh / 2 - keySpacingY

local typedText = ""

local layoutRows = {
    "QWERTYUIOP",
    "ASDFGHJKL",
    "ZXCVBNM"
}

local backspaceImage = love.graphics.newImage("assets/sprites/keys/CC_backspace_001.png")

local buttonDefs = {}

local rowWidths = {}
for i, row in ipairs(layoutRows) do
    rowWidths[i] = #row * keySpacingX
end

for rowIndex, row in ipairs(layoutRows) do
    local rowWidth = rowWidths[rowIndex]
    local rowStartX = vw / 2 - rowWidth / 2
    for col = 1, #row do
        local char = row:sub(col, col)
        table.insert(buttonDefs, {
            text = char,
            x = rowStartX + keySpacingX * (col - 1),
            y = startY + keySpacingY * (rowIndex - 1),
            row = rowIndex,
            col = col,
            callback = function() typedText = typedText .. char end
        })
    end
end

table.insert(buttonDefs, {
    text = "",
    image = backspaceImage,
    x = vw / 2 + 100,
    y = startY + keySpacingY * 3.5,
    row = 4,
    col = 6,
    callback = function()
        typedText = typedText:sub(1, -2)
    end
})

local backButtonY = startY + keySpacingY * 3.5

table.insert(buttonDefs, {
    text = "Back",
    x = vw / 2 - 150,
    y = backButtonY - (bigFont.lineHeight * buttonScale) / 2,
    row = 4,
    col = 4,
    callback = function() state.switch("states/mainmenu") end
})

local buttons = QwertyButtons.create(buttonDefs, bigFont, buttonScale)
local selectedButton = 1

function selectname.draw()
    love.graphics.clear(245 / 255, 81 / 255, 81 / 255, 1)

    love.graphics.setColor(1, 1, 1)
    local labelX = vw / 2 - bigFont:getWidth(typedText, buttonScale) / 2
    local labelY = startY - 70
    bigFont:draw(typedText, labelX, labelY, buttonScale)

    QwertyButtons.draw(buttons, selectedButton, bigFont, buttonScale, {1, 1, 0}, {1, 1, 1})
end

function selectname.keypressed(key)
    local current = buttons[selectedButton]
    local function findInDirection(dx, dy)
        local currentRow, currentCol = current.row, current.col
        local cx = current.x

        if dx ~= 0 and dy == 0 then
            local rowButtons = {}
            for i, b in ipairs(buttons) do
                if b.row == currentRow then
                    table.insert(rowButtons, {index = i, col = b.col})
                end
            end
            table.sort(rowButtons, function(a, b) return a.col < b.col end)

            local pos
            for i, b in ipairs(rowButtons) do
                if b.col == currentCol then
                    pos = i
                    break
                end
            end
            if not pos then return nil end

            local nextPos = (pos - 1 + dx) % #rowButtons + 1
            return rowButtons[nextPos].index
        elseif dy ~= 0 and dx == 0 then
            local targetRow = currentRow + dy
            local candidates = {}
            for i, b in ipairs(buttons) do
                if b.row == targetRow then
                    table.insert(candidates, {index = i, dist = math.abs(b.x - cx)})
                end
            end
            if #candidates == 0 then return nil end
            table.sort(candidates, function(a, b) return a.dist < b.dist end)
            return candidates[1].index
        end

        return nil
    end

    if key == "right" then
        selectedButton = findInDirection(1, 0) or selectedButton
    elseif key == "left" then
        selectedButton = findInDirection(-1, 0) or selectedButton
    elseif key == "down" then
        selectedButton = findInDirection(0, 1) or selectedButton
    elseif key == "up" then
        selectedButton = findInDirection(0, -1) or selectedButton
    elseif key == "return" or key == "z" then
        if love.keyboard.isDown("lalt", "ralt") then return end
        QwertyButtons.activate(buttons, selectedButton)
    end
end

return selectname
