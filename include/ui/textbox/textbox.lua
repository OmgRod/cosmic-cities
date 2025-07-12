local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")
local parser = require("include.ui.textbox.parser")
local shake = require("include.ui.textbox.shake")

local Textbox = {}
Textbox.__index = Textbox

function Textbox:precomputeLayout()
  local lineHeight = self.font.lineHeight or 16
  local maxWidth = self.width - 10
  local font = self.font
  self.layout = {}
  local x, y = 0, 0
  for tokenIndex, token in ipairs(self.tokens) do
    local text = token.text
    local startChar = 1
    while startChar <= #text do
      local spaceIndex = text:find(" ", startChar)
      local wordEnd
      if spaceIndex then
        wordEnd = spaceIndex
      else
        wordEnd = #text + 1
      end
      local word = text:sub(startChar, wordEnd - 1)
      local space = ""
      if spaceIndex then space = " " end
      local wordWithSpace = word .. space
      local wordWidth = font:getWidth(wordWithSpace)
      if x + wordWidth > maxWidth then
        x = 0
        y = y + lineHeight
      end
      table.insert(self.layout, {
        tokenIndex = tokenIndex,
        startChar = startChar,
        endChar = wordEnd - 1 + (#space > 0 and 1 or 0),
        x = x,
        y = y,
        text = wordWithSpace,
        color = token.color,
        shake = token.shake or 0
      })
      x = x + wordWidth
      startChar = wordEnd + 1
    end
  end
  self.layoutHeight = y + lineHeight
end

function Textbox.new(x, y, text, spriteFont, typeSpeed)
  local self = setmetatable({}, Textbox)
  local vw, vh = autoscale.getVirtualSize()
  self.width = vw * 0.8
  self.height = vh * 0.3
  self.x = x or 0
  self.y = y or 0
  self.font = spriteFont
  self.text = text or ""
  self.tokens = parser.parseText(self.text)
  self.typeSpeed = typeSpeed or 30
  self.charTimer = 0
  self.finished = false
  self.delayTimer = 0
  self.currentTokenIndex = 1
  self.tokenCharIndex = 0
  self.totalChars = 0
  for _, token in ipairs(self.tokens) do
    if token.text then
      self.totalChars = self.totalChars + #token.text
    end
  end
  self:precomputeLayout()
  return self
end

function Textbox:setPosition(x,y)
  self.x = x
  self.y = y
end

function Textbox:setText(text)
  self.text = text
  self.tokens = parser.parseText(text)
  self.charTimer = 0
  self.finished = false
  self.delayTimer = 0
  self.currentTokenIndex = 1
  self.tokenCharIndex = 0
  self.totalChars = 0
  for _, token in ipairs(self.tokens) do
    if token.text then
      self.totalChars = self.totalChars + #token.text
    end
  end
  self:precomputeLayout()
end

function Textbox:update(dt)
  if self.finished then return end
  if self.delayTimer > 0 then
    self.delayTimer = self.delayTimer - dt
    if self.delayTimer < 0 then self.delayTimer = 0 end
    return
  end
  self.charTimer = self.charTimer + dt
  local charsToAdd = math.floor(self.charTimer * self.typeSpeed)
  if charsToAdd > 0 then
    self.charTimer = self.charTimer - charsToAdd / self.typeSpeed
    while charsToAdd > 0 and not self.finished do
      local token = self.tokens[self.currentTokenIndex]
      if not token then
        self.finished = true
        break
      end
      if token.delay and token.delay > 0 and self.tokenCharIndex == 0 then
        self.delayTimer = token.delay / 100
        token.delay = 0
        break
      end
      if token.instant and token.instant > 0 then
        self.tokenCharIndex = #token.text
        self.currentTokenIndex = self.currentTokenIndex + 1
        self.tokenCharIndex = 0
        charsToAdd = charsToAdd - 1
      else
        self.tokenCharIndex = self.tokenCharIndex + 1
        if self.tokenCharIndex > #token.text then
          self.tokenCharIndex = 0
          self.currentTokenIndex = self.currentTokenIndex + 1
        end
        charsToAdd = charsToAdd - 1
      end
    end
  end
end

function Textbox:draw()
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

  love.graphics.push()
  love.graphics.translate(self.x + 5, self.y + 5)

  for _, segment in ipairs(self.layout) do
    local token = self.tokens[segment.tokenIndex]
    if not token then break end
    local charsAvailable = 0
    if self.currentTokenIndex > segment.tokenIndex then
      charsAvailable = #segment.text
    elseif self.currentTokenIndex == segment.tokenIndex then
      local relChar = self.tokenCharIndex - (segment.startChar - 1)
      if relChar > 0 then
        charsAvailable = math.min(relChar, #segment.text)
      end
    end
    if charsAvailable > 0 then
      local textToDraw = segment.text:sub(1, charsAvailable)
      love.graphics.setColor(segment.color)
      local xOff, yOff = 0, 0
      if segment.shake and segment.shake > 0 then
        xOff = shake.shakeOffset(segment.shake)
        yOff = shake.shakeOffset(segment.shake)
      end
      self.font:draw(textToDraw, segment.x + xOff, segment.y + yOff)
    end
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1)
end

function Textbox:advance()
  self.finished = true
  if type(self.onFinish) == "function" then
    self.onFinish()
  end
end

return Textbox
