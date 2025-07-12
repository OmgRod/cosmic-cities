local Textbox = require("include.ui.textbox").Textbox
local SelectionBox = require("include.ui.textbox.selectionbox")
local SpriteFont = require("include.spritefont")

local dialogwrapper = {}

local dialogdata = require("locale.dialog.en")

local function createDialogNode(node)
  print("createDialogNode called for node with name:", node.name)
  local dialog = {
    name = node.name,
    icon = node.icon,
    text = node.text,
    options = node.options or nil,
    nextDialog = nil,
  }
  if node["next-dialog"] then
    print("Node has next-dialog, creating recursively")
    dialog.nextDialog = createDialogNode(node["next-dialog"])
  end
  return dialog
end

for key, node in pairs(dialogdata) do
  print("Processing dialogdata key:", key)
  dialogwrapper[key] = createDialogNode(node)
end

local spriteFont = SpriteFont.new("assets/fonts/pixel_operator.fnt", "assets/fonts/")
print("SpriteFont loaded:", spriteFont)

local currentDialog
local currentTextbox
local currentSelectionBox

local dialogX, dialogY = 100, 100
local dialogWidth = 400

function dialogwrapper.show(key, x, y)
  print("dialogwrapper.show called with key:", key, "x:", x, "y:", y)
  local node = dialogwrapper[key]
  if not node then
    print("Dialog key not found:", key)
    return
  end
  currentDialog = node
  dialogX = x or 100
  dialogY = y or 100

  print("Creating Textbox with text:", node.text)
  currentTextbox = Textbox.new(dialogX, dialogY, node.text, spriteFont, dialogWidth)
  print("Textbox created, layoutHeight:", currentTextbox.layoutHeight)

  if node.options and #node.options > 0 then
    print("Node has options:", #node.options)
    local optionItems = {}

    for i, option in ipairs(node.options) do
      print("Adding option:", option.text)
      optionItems[i] = {
        text = option.text,
        callback = option.callback
      }
    end

    local spacing = 20
    local boxWidth = dialogWidth
    local boxHeight = spriteFont.lineHeight * 2

    local layoutHeight = currentTextbox.layoutHeight
    local selBoxY
    if type(layoutHeight) == "number" and layoutHeight > 0 then
      selBoxY = dialogY + layoutHeight + spacing
    else
      selBoxY = dialogY + spacing + spriteFont.lineHeight * 3
    end

    print("Creating SelectionBox at", dialogX, selBoxY)
    currentSelectionBox = SelectionBox.new(optionItems, spriteFont, dialogX, selBoxY, boxWidth, boxHeight)
  else
    print("Node has no options")
    currentSelectionBox = nil
  end
end

function dialogwrapper.update(dt)
  if currentTextbox then
    currentTextbox:update(dt)
  end
  if currentSelectionBox then
    currentSelectionBox:update(dt)
  end
end

function dialogwrapper.draw()
  if not currentDialog or not currentTextbox then
    print("draw skipped: no currentDialog or currentTextbox")
    return
  end
  currentTextbox:draw()
  if currentSelectionBox then
    print("Drawing SelectionBox")
    currentSelectionBox:draw()
  else
    print("No SelectionBox to draw")
  end
end

function dialogwrapper.keypressed(key)
    print("Key pressed:", key)
    if key == "x" then
        print("Skip dialog requested with 'x' key")
        currentDialog = nil
        currentTextbox = nil
        currentSelectionBox = nil
        return true
    end
    if currentSelectionBox then
        print("SelectionBox active, selected option:", currentSelectionBox.selected)
        if key == "left" then
            currentSelectionBox:move(-1)
            print("Moved SelectionBox left to", currentSelectionBox.selected)
            return true
        elseif key == "right" then
            currentSelectionBox:move(1)
            print("Moved SelectionBox right to", currentSelectionBox.selected)
            return true
        elseif key == "return" or key == "kpenter" then
            print("Confirming SelectionBox option:", currentSelectionBox.selected)
            currentSelectionBox:confirm()
            return true
        end
    elseif currentTextbox and (key == "return" or key == "kpenter") then
        if not currentTextbox.finished then
            print("Advancing Textbox text")
            currentTextbox:advance()
        elseif currentDialog.nextDialog then
            print("Moving to next dialog:", currentDialog.nextDialog.name)
            dialogwrapper.show(currentDialog.nextDialog.name, dialogX, dialogY)
        end
        return true
    end
    return false
end

function dialogwrapper.get(key)
  return dialogwrapper[key]
end

return dialogwrapper
