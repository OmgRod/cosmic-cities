local Textbox = require("include.ui.textbox.textbox")

local TextboxGroup = {}
TextboxGroup.__index = TextboxGroup

function TextboxGroup.new(textList, spriteFont, onFinish)
  local self = setmetatable({}, TextboxGroup)
  self.textboxes = {}
  for i, text in ipairs(textList) do
    self.textboxes[i] = Textbox.new(0, 0, text, spriteFont, 30)
  end
  self.currentIndex = 1
  self.active = true
  self.onFinish = onFinish
  self.x = 0
  self.y = 0

  local maxWidth, maxHeight = 0, 0
  for _, box in ipairs(self.textboxes) do
    if box.width and box.width > maxWidth then maxWidth = box.width end
    if box.height and box.height > maxHeight then maxHeight = box.height end
  end
  self.width = maxWidth
  self.height = maxHeight

  for _, box in ipairs(self.textboxes) do
    box.x = 0
    box.y = 0
  end

  return self
end

function TextboxGroup:setPosition(x, y)
  self.x = x
  self.y = y
end

function TextboxGroup:update(dt)
  if not self.active then return end
  self.textboxes[self.currentIndex]:update(dt)
end

function TextboxGroup:draw()
  if not self.active then return end
  love.graphics.push()
  love.graphics.translate(self.x, self.y)
  self.textboxes[self.currentIndex]:draw()
  love.graphics.pop()
end

function TextboxGroup:skip()
  if not self.active then return end
  local box = self.textboxes[self.currentIndex]
  box.tokenCharIndex = 0
  box.currentTokenIndex = #box.tokens + 1
  box.finished = true
end

function TextboxGroup:advance()
  if not self.active then return end
  local box = self.textboxes[self.currentIndex]
  if not box.finished then return end
  self.currentIndex = self.currentIndex + 1
  if not self.textboxes[self.currentIndex] then
    self.active = false
    if type(self.onFinish) == "function" then
      self.onFinish()
    end
  end
end

function TextboxGroup:isActive()
  return self.active
end

function TextboxGroup:handleKeypress(key)
  if not self.active then return end
  local box = self.textboxes[self.currentIndex]
  if key == "x" then
    self:skip()
  elseif key == "return" or key == "kpenter" then
    if box.finished then
      self:advance()
    end
  end
end

return TextboxGroup
