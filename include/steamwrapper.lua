local cpathutil = require("include.cpathutil")

local steamwrapper = {}

function steamwrapper.init()
    if steamwrapper.steam then return steamwrapper.steam end

    cpathutil.enable(true)
    local ok, result = pcall(require, "luasteam")
    cpathutil.disable()

    if not ok then
        error("Failed to require luasteam: " .. tostring(result))
    end

    result.init()
    steamwrapper.steam = result
    return result
end

return steamwrapper
