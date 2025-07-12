local colors = require("include.ui.textbox.colors")

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
            table.insert(colorStack, colors.hexToRGB(tag:sub(2)))
          elseif colors.colorsTable[tag] then
            table.insert(colorStack, colors.colorsTable[tag])
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

return {
  parseText = parseText,
}
