local autoscale = require("include.autoscale")
local SpriteFont = require("include.spritefont")

local colorsTable = {
  cb = {74/255, 82/255, 225/255},
  cg = {64/255, 227/255, 72/255},
  cl = {96/255, 171/255, 239/255},
  cj = {50/255, 200/255, 255/255},
  cy = {1, 1, 0},
  co = {1, 90/255, 75/255},
  cr = {1, 90/255, 90/255},
  cp = {1, 0, 1},
  ca = {150/255, 50/255, 1},
  cd = {1, 150/255, 1},
  cc = {1, 1, 150/255},
  cf = {150/255, 1, 1},
  cs = {1, 220/255, 65/255},
  c  = {1, 0, 0},
}

local function hexToRGB(hex)
  hex = hex:gsub("#", "")
  local r = tonumber(hex:sub(1,2), 16) / 255
  local g = tonumber(hex:sub(3,4), 16) / 255
  local b = tonumber(hex:sub(5,6), 16) / 255
  return {r, g, b}
end

local function parseText(input)
  local tokens = {}
  local colorStack = { {1,1,1} }
  local instantStack = {}
  local delayStack = {}
  local shakeStack = {}
  local currentText = ""
  local i = 1
  local len = #input

  local function flushText()
    if #currentText > 0 then
      local token = {
        text = currentText,
        color = colorStack[#colorStack],
        instant = (#instantStack > 0) and instantStack[#instantStack] or 0,
        delay = (#delayStack > 0) and delayStack[#delayStack] or 0,
        shake = (#shakeStack > 0) and shakeStack[#shakeStack] or 0
      }
      table.insert(tokens, token)
      currentText = ""
    end
  end

  while i <= len do
    local c = input:sub(i,i)
    if c == "<" then
      local closeTagStart = input:find(">", i, true)
      if not closeTagStart then
        currentText = currentText .. "<"
        i = i + 1
      else
        local tag = input:sub(i+1, closeTagStart-1)
        flushText()
        if tag == "/c" then
          if #colorStack > 1 then table.remove(colorStack) end
        elseif tag == "/i" then
          if #instantStack > 0 then table.remove(instantStack) end
        elseif tag == "/d" then
          if #delayStack > 0 then table.remove(delayStack) end
        elseif tag == "/s" then
          if #shakeStack > 0 then table.remove(shakeStack) end
        else
          if tag:match("^c#%x%x%x%x%x%x$") then
            table.insert(colorStack, hexToRGB(tag:sub(2)))
          elseif colorsTable[tag] then
            table.insert(colorStack, colorsTable[tag])
          elseif tag:match("^i%d+$") then
            local val = tonumber(tag:sub(2))
            table.insert(instantStack, val)
          elseif tag:match("^d%d+$") then
            local val = tonumber(tag:sub(2))
            table.insert(delayStack, val)
          elseif tag:match("^s%d+$") then
            local val = tonumber(tag:sub(2))
            table.insert(shakeStack, val)
          else
            currentText = currentText .. "<" .. tag .. ">"
          end
        end

        local nextChar = input:sub(closeTagStart + 1, closeTagStart + 1)
        if nextChar == " " then
          currentText = currentText .. " "
          i = closeTagStart + 2
        else
          i = closeTagStart + 1
        end
      end
    else
      currentText = currentText .. c
      i = i + 1
    end
  end
  flushText()
  return tokens
end

local function shakeOffset(intensity)
  return (math.random() - 0.5) * 2 * intensity
end

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
  self.tokens = parseText(self.text)
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
  self.tokens = parseText(text)
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
        xOff = shakeOffset(segment.shake)
        yOff = shakeOffset(segment.shake)
      end
      self.font:draw(textToDraw, segment.x + xOff, segment.y + yOff)
    end
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1)
end

return {
    Textbox = Textbox
}