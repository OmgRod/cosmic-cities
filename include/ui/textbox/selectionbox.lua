local SelectionBox = {}
SelectionBox.__index = SelectionBox

function SelectionBox.new(options, font, x, y, width, height)
  local self = setmetatable({}, SelectionBox)
  self.options = options or {}
  self.font = font
  self.selected = 1
  self.x = x or 0
  self.y = y or 0
  self.width = width or 400
  self.height = height or 50
  self.paddingX = 10
  self.paddingY = 8
  self.spacing = 20
  self.layout = {}

  self:computeLayout()

  return self
end

function SelectionBox:computeLayout()
  self.layout = {}
  local totalWidth = 0
  for i, option in ipairs(self.options) do
    local w = self.font:getWidth(option.text)
    self.layout[i] = { text = option.text, width = w }
    totalWidth = totalWidth + w
  end
  totalWidth = totalWidth + self.spacing * (#self.options - 1)

  local startX = self.x + (self.width - totalWidth) / 2
  local baseY = self.y + (self.height - self.font.lineHeight) / 2

  local curX = startX
  for i, opt in ipairs(self.layout) do
    opt.x = curX
    opt.y = baseY
    curX = curX + opt.width + self.spacing
  end
end

function SelectionBox:move(dir)
  self.selected = self.selected + dir
  if self.selected < 1 then
    self.selected = #self.options
  elseif self.selected > #self.options then
    self.selected = 1
  end
end

function SelectionBox:confirm()
  local opt = self.options[self.selected]
  if opt and opt.callback then
    opt.callback()
  end
end

function SelectionBox:update(dt)
  -- nothing needed here for now
end

function SelectionBox:draw()
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

  for i, opt in ipairs(self.layout) do
    local textHeight = self.font.lineHeight or self.font:getHeight()
    local maxHeight = self.height - self.paddingY * 2
    local scale = math.min(1, maxHeight / textHeight)

    local drawX = opt.x
    local drawY = opt.y + (textHeight - textHeight * scale) / 2

    if i == self.selected then
      love.graphics.setColor(1, 1, 0)
    else
      love.graphics.setColor(1, 1, 1)
    end

    love.graphics.push()
    love.graphics.translate(drawX, drawY)
    love.graphics.scale(scale, scale)
    self.font:draw(opt.text, 0, 0)
    love.graphics.pop()
  end

  love.graphics.setColor(1, 1, 1)
end

function SelectionBox:keypressed(key)
  if key == "left" then
    self:move(-1)
    return true
  elseif key == "right" then
    self:move(1)
    return true
  elseif key == "return" or key == "kpenter" then
    self:confirm()
    return true
  end
  return false
end

return SelectionBox
