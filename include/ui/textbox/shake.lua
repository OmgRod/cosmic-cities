local shake = {}

function shake.shakeOffset(magnitude)
  local angle = math.random() * 2 * math.pi
  local dx = math.cos(angle) * magnitude
  local dy = math.sin(angle) * magnitude
  return dx, dy
end

return shake
