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

return {
  colorsTable = colorsTable,
  hexToRGB = hexToRGB,
}
