local state = require("include.stateswitcher")
local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local QwertyButtons = require("include.ui.qwertybuttons")
local GameSaveManager = require("include.gamesave")

local selectname = {}

local bigFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
local vw, vh = autoscale.getVirtualSize()

local buttonScale = 1
local keySpacingX = 50
local keySpacingY = 70

local startY = vh / 2 - 80

local typedText = ""
local saveName = passvar[1] or "defaultslot"
local slotIndex = tonumber(saveName:match("slot_(%d+)"))
local saveFile
if slotIndex then
    saveFile = "save" .. slotIndex .. ".ini"
elseif saveName:sub(-4) == ".ini" then
    saveFile = saveName
else
    saveFile = saveName .. ".ini"
end

local layoutRows = {
    "QWERTYUIOP",
    "ASDFGHJKL",
    "ZXCVBNM"
}

local backspaceImage = love.graphics.newImage("assets/sprites/keys/CC_backspace_001.png")

local uppercase = false

local buttonDefs = {}
local letterButtonIndices = {}

for rowIndex, row in ipairs(layoutRows) do
    local rowWidth = #row * keySpacingX
    local rowStartX = vw / 2 - rowWidth / 2
    for col = 1, #row do
        local char = row:sub(col, col)
        local btn = {
            text = uppercase and char:upper() or char:lower(),
            x = rowStartX + keySpacingX * (col - 1),
            y = startY + keySpacingY * (rowIndex - 1),
            row = rowIndex,
            col = col,
            callback = function()
                if #typedText < 15 then
                    typedText = typedText .. (uppercase and char:upper() or char:lower())
                end
            end
        }
        table.insert(buttonDefs, btn)
        table.insert(letterButtonIndices, #buttonDefs)
    end
end

local controlRow = 4
local controlY = startY + keySpacingY * (controlRow - 1)

local controlRowWidth = #layoutRows[1] * keySpacingX
local controlRowStartX = vw / 2 - controlRowWidth / 2

local controlButtonCount = 3
local controlSpacingX = controlRowWidth / (controlButtonCount - 1)

table.insert(buttonDefs, {
    text = "Back",
    x = controlRowStartX,
    y = controlY,
    row = controlRow,
    col = 1,
    callback = function()
        state.switch("states/selectsave")
    end
})

table.insert(buttonDefs, {
    text = uppercase and "AB" or "ab",
    x = controlRowStartX + controlSpacingX,
    y = controlY,
    row = controlRow,
    col = 2,
    callback = nil
})
local toggleButtonIndex = #buttonDefs

table.insert(buttonDefs, {
    text = "",
    image = backspaceImage,
    x = controlRowStartX + controlSpacingX * 2,
    y = controlY,
    row = controlRow,
    col = 3,
    callback = function()
        typedText = typedText:sub(1, -2)
    end
})

local continueRow = 5
local continueY = startY + keySpacingY * (continueRow - 1)
table.insert(buttonDefs, {
    text = "Continue",
    x = vw / 2,
    y = continueY,
    row = continueRow,
    col = 1,
    callback = function()
        if #typedText > 0 then
            local save = GameSaveManager.load(saveFile)
            save:set("playername", typedText, "Meta")
            save:save()
            state.switch("states/game;" .. saveFile)
        end
    end
})

local buttons = QwertyButtons.create(buttonDefs, bigFont, buttonScale)

buttons[toggleButtonIndex].callback = function()
    uppercase = not uppercase
    for _, i in ipairs(letterButtonIndices) do
        local b = buttons[i]
        b.text = uppercase and b.text:upper() or b.text:lower()
    end
    buttons[toggleButtonIndex].text = uppercase and "AB" or "ab"
end

local selectedButton = 1

function selectname.draw()
    love.graphics.clear(245 / 255, 81 / 255, 81 / 255, 1)

    love.graphics.setColor(1, 1, 1)
    local title = "Select Your Name"
    local titleScale = 2
    local titleX = vw / 2 - bigFont:getWidth(title, titleScale) / 2
    local titleY = startY - 80 - 25 - 30
    bigFont:draw(title, titleX, titleY, titleScale)

    local labelX = vw / 2 - bigFont:getWidth(typedText, buttonScale) / 2
    local labelY = startY - 30 - 25
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
