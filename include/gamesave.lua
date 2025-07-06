local LIP = require("include.LIP")

local GameSaveManager = {}

local SaveFile = {}
SaveFile.__index = SaveFile

function SaveFile.new(filename)
  assert(type(filename) == "string", "Filename must be a string.")
  assert(filename:match("%.ini$"), "Filename must end in .ini")

  local self = setmetatable({}, SaveFile)
  self.filename = filename
  self.data = {}

  self:load()
  return self
end

function SaveFile:load()
  if not love.filesystem.getInfo(self.filename) then
    self.data = {}
    return false
  end
  local success, result = pcall(LIP.load, self.filename)
  if success and type(result) == "table" then
    self.data = result
    return true
  else
    self.data = {}
    return false
  end
end

function SaveFile:save()
  local success, err = LIP.save(self.filename, self.data)
  if success then
    love.filesystem.sync()
    return true
  else
    print("Error saving file:", err)
    return false, err
  end
end

function SaveFile:getGroup(group)
  if group then
    self.data[group] = self.data[group] or {}
    return self.data[group]
  else
    return self.data
  end
end

function SaveFile:set(key, value, group)
  local target = self:getGroup(group)
  target[key] = value
  return self:save()
end

function SaveFile:get(key, group)
  local target = self:getGroup(group)
  return target[key]
end

function SaveFile:removeKey(key, group)
  local target = self:getGroup(group)
  if target[key] ~= nil then
    target[key] = nil
    return self:save()
  end
  return false
end

function SaveFile:removeGroup(group)
  if self.data[group] then
    self.data[group] = nil
    return self:save()
  end
  return false
end

function SaveFile:delete()
  if love.filesystem.getInfo(self.filename) then
    love.filesystem.remove(self.filename)
  end
  self.data = {}
end

function SaveFile:exists()
  return love.filesystem.getInfo(self.filename) ~= nil
end

function GameSaveManager.load(filename)
  return SaveFile.new(filename)
end

return GameSaveManager
