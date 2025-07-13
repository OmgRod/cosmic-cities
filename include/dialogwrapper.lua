local TextboxGroup = require("include.ui.textbox").TextboxGroup
local SelectionBox = require("include.ui.textbox.selectionbox")
local SpriteFont = require("include.spritefont")

local dialogwrapper = {}

local dialogdata = require("locale.dialog.en")

local function createDialogNode(node)
  local dialog = {
    name = node.name,
    icon = node.icon,
    text = node.text,
    options = node.options or nil,
    nextDialog = nil,
  }
  if node["next-dialog"] then
    dialog.nextDialog = createDialogNode(node["next-dialog"])
  end
  return dialog
end

for key, node in pairs(dialogdata) do
  dialogwrapper[key] = createDialogNode(node)
end

local spriteFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")

local currentDialog
local currentTextboxGroup
local currentSelectionBox

local dialogX, dialogY = 100, 100
local dialogWidth = 400

local function createSelectionBox(node)
  if not node.options or #node.options == 0 then return nil end

  local optionItems = {}
  for i, option in ipairs(node.options) do
    optionItems[i] = {
      text = option.text,
      callback = option.callback
    }
  end

  local spacing = 20
  local boxWidth = dialogWidth
  local boxHeight = spriteFont.lineHeight * 2

  local layoutHeight = (currentTextboxGroup and currentTextboxGroup.height) or (spriteFont.lineHeight * 3)
  local selBoxY = dialogY + layoutHeight + spacing

  return SelectionBox.new(optionItems, spriteFont, dialogX, selBoxY, boxWidth, boxHeight)
end

function dialogwrapper.show(key, x, y)
  local node = dialogwrapper[key]
  if not node then return end

  dialogX = x or 100
  dialogY = y or 100
  currentDialog = node

  local textList = {}
  if type(node.text) == "table" then
    textList = node.text
  else
    for line in node.text:gmatch("[^\r\n]+") do
      table.insert(textList, line)
    end
  end

  currentTextboxGroup = TextboxGroup.new(textList, spriteFont, function()
    currentSelectionBox = createSelectionBox(currentDialog)
  end)

  currentTextboxGroup:setPosition(dialogX, dialogY)
  currentTextboxGroup:skip()

  if currentTextboxGroup:isFinished() then
    currentSelectionBox = createSelectionBox(node)
  else
    currentSelectionBox = nil
  end
end

function dialogwrapper.update(dt)
  if currentTextboxGroup then
    currentTextboxGroup:update(dt)
  end
  if currentSelectionBox then
    currentSelectionBox:update(dt)
  end
end

function dialogwrapper.draw()
  if not currentDialog or not currentTextboxGroup then return end
  currentTextboxGroup:draw()
  if currentSelectionBox then
    currentSelectionBox:draw()
  end
end

function dialogwrapper.keypressed(key)
  if not currentDialog then return false end

  if currentTextboxGroup and currentTextboxGroup:isActive() then
    if key == "x" then
      currentTextboxGroup:handleKeypress(key)
      if currentTextboxGroup:isFinished() then
        currentSelectionBox = createSelectionBox(currentDialog)
      end
      return true
    elseif key == "return" or key == "kpenter" then
      currentTextboxGroup:handleKeypress(key)
      if currentTextboxGroup:isFinished() then
        currentSelectionBox = createSelectionBox(currentDialog)
      end
      return true
    end
  elseif currentTextboxGroup and not currentTextboxGroup:isActive() then
    if currentSelectionBox then
      if key == "left" then
        currentSelectionBox:move(-1)
        return true
      elseif key == "right" then
        currentSelectionBox:move(1)
        return true
      elseif key == "return" or key == "kpenter" then
        currentSelectionBox:confirm()
        return true
      elseif key == "x" then
        currentDialog = nil
        currentTextboxGroup = nil
        currentSelectionBox = nil
        return true
      end
    else
      if key == "x" or key == "return" or key == "kpenter" then
        if currentDialog.nextDialog then
          dialogwrapper.show(currentDialog.nextDialog.name, dialogX, dialogY)
        else
          currentDialog = nil
          currentTextboxGroup = nil
          currentSelectionBox = nil
        end
        return true
      end
    end
  else
    if key == "x" then
      currentDialog = nil
      currentTextboxGroup = nil
      currentSelectionBox = nil
      return true
    end
  end

  return false
end

function dialogwrapper.get(key)
  return dialogwrapper[key]
end

function dialogwrapper.isActive()
  return currentDialog ~= nil
end

return dialogwrapper
