local LIP = require("include.LIP")

local GameSave = {}

local saveFileName = "save.ini"
local data = {}

local function getGroup(tbl, group)
  if group then
    data[group] = data[group] or {}
    return data[group]
  else
    return data
  end
end

function GameSave.load()
  if not love.filesystem.getInfo(saveFileName) then
    data = {}
    return false
  end
  local success, loadedData = pcall(LIP.load, saveFileName)
  if success and type(loadedData) == "table" then
    data = loadedData
    return true
  else
    data = {}
    return false
  end
end

function GameSave.save()
  LIP.save(saveFileName, data)
end

function GameSave.set(key, value, group)
  local tbl = getGroup(data, group)
  tbl[key] = value
  GameSave.save()
end

function GameSave.get(key, group)
  local tbl = getGroup(data, group)
  return tbl[key]
end

function GameSave.removeKey(key, group)
  local tbl = getGroup(data, group)
  if tbl[key] ~= nil then
    tbl[key] = nil
    GameSave.save()
    return true
  end
  return false
end

function GameSave.removeGroup(group)
  if data[group] then
    data[group] = nil
    GameSave.save()
    return true
  end
  return false
end

function GameSave.exists()
  return love.filesystem.getInfo(saveFileName) ~= nil
end

function GameSave.delete()
  if love.filesystem.getInfo(saveFileName) then
    love.filesystem.remove(saveFileName)
  end
  data = {}
end

return GameSave
