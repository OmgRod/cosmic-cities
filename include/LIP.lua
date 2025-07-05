local LIP = {}

function LIP.parse(content)
  local data = {}
  local section
  for line in content:gmatch("[^\r\n]+") do
    local tempSection = line:match("^%[([^%[%]]+)%]$")
    if tempSection then
      section = tonumber(tempSection) or tempSection
      data[section] = data[section] or {}
    else
      local param, value = line:match("^([%w|_]+)%s-=%s-(.+)$")
      if param and value ~= nil and section then
        if tonumber(value) then
          value = tonumber(value)
        elseif value == "true" then
          value = true
        elseif value == "false" then
          value = false
        end
        if tonumber(param) then
          param = tonumber(param)
        end
        data[section][param] = value
      end
    end
  end
  return data
end

function LIP.encode(data)
  assert(type(data) == "table", "LIP.encode expects a table")
  local contents = ""
  for section, param in pairs(data) do
    contents = contents .. ("[%s]\n"):format(section)
    if type(param) == "table" then
      for key, value in pairs(param) do
        contents = contents .. ("%s=%s\n"):format(key, tostring(value))
      end
    end
    contents = contents .. "\n"
  end
  return contents
end

function LIP.load(fileName)
  assert(type(fileName) == "string", 'Parameter "fileName" must be a string.')
  local contents, size = love.filesystem.read(fileName)
  assert(contents, "Error loading file: " .. fileName)
  return LIP.parse(contents)
end

function LIP.save(fileName, data)
  assert(type(fileName) == "string", 'Parameter "fileName" must be a string.')
  assert(type(data) == "table", 'Parameter "data" must be a table.')
  local contents = LIP.encode(data)
  local success, err = love.filesystem.write(fileName, contents)
  assert(success, "Error saving file: " .. tostring(err))
end

return LIP
