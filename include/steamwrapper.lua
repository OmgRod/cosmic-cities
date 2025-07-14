local ffi = require("ffi")

local steamwrapper = {}

function steamwrapper.init()
    if steamwrapper.steam then return steamwrapper.steam end

    local luasteam = ffi.load("luasteam")
    steamwrapper.steam = luasteam
    return luasteam
end

return steamwrapper
