local ffi = require("ffi")

local cpathutil = {
    original_cpath = package.cpath,
    path_modified = false
}

ffi.cdef [[ int _putenv(const char *envstring); ]]

local sep = package.config:sub(1,1) == "\\" and ";" or ":"
local osName = love.system.getOS()
local arch = jit.arch

local function guessPath()
    if osName == "Windows" then
        return arch == "x64" and "bin/win64" or "bin/win32"
    elseif osName == "Linux" then
        return arch == "x64" and "bin/linux64" or "bin/linux32"
    elseif osName == "OS X" then
        return "bin/osx"
    end
    return nil
end

function cpathutil.enable(autopath, customPath)
    if cpathutil.path_modified then return end
    cpathutil.path_modified = true

    local path = customPath
    if autopath or not path then
        path = guessPath()
        if not path then return end
    end

    local current_path = os.getenv("PATH") or ""
    ffi.C._putenv(("PATH=%s%s%s"):format(current_path, sep, path))

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

function cpathutil.disable()
    if not cpathutil.path_modified then return end
    package.cpath = cpathutil.original_cpath
    cpathutil.path_modified = false
end

return cpathutil
