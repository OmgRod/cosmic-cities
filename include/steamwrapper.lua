local ffi = require("ffi")

local steamwrapper = {}

local function addDllPath(path)
    ffi.cdef [[ int _putenv(const char *envstring); ]]
    local current_path = os.getenv("PATH") or ""
    local sep = package.config:sub(1,1) == "\\" and ";" or ":"
    ffi.C._putenv(("PATH=%s%s%s"):format(current_path, sep, path))

    local dll_ext = ".dll"
    local so_ext = ".so"
    local dylib_ext = ".dylib"
    local osName = love.system.getOS()

    if osName == "Windows" then
        package.cpath = package.cpath .. ";" .. path .. "/?.dll"
    elseif osName == "Linux" then
        package.cpath = package.cpath .. ";" .. path .. "/?.so"
    elseif osName == "OS X" then
        package.cpath = package.cpath .. ";" .. path .. "/?.dylib;" .. path .. "/?.so"
    else
        package.cpath = package.cpath .. ";" .. path .. "/?.dll;" .. path .. "/?.so;" .. path .. "/?.dylib"
    end
end

function steamwrapper.init()
    if steamwrapper.steam then return steamwrapper.steam end

    local osName = love.system.getOS()
    local arch = jit.arch

    local dll_path
    if osName == "Windows" then
        if arch == "x64" then
            dll_path = "bin/win64"
        else
            dll_path = "bin/win32"
        end
    elseif osName == "Linux" then
        if arch == "x64" then
            dll_path = "bin/linux64"
        else
            dll_path = "bin/linux32"
        end
    elseif osName == "OS X" then
        dll_path = "bin/osx"
    else
        print("Steamworks API unavailable in this device/architecture.")
        return nil
    end

    addDllPath(dll_path)

    local ok, steam = pcall(require, "luasteam")
    if not ok then
        error("Failed to require luasteam: " .. tostring(steam))
    end

    steam.init()
    steamwrapper.steam = steam

    return steam
end

return steamwrapper
