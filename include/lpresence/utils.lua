local lfs = require("lfs")

local utils = {}

utils.on_windows = package.config:sub(1, 1) == "\\"

function utils.recursive_merge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k] or false) == "table" then
            utils.recursive_merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

---@param id integer
---@return string?
function utils.get_ipc_path(id)
    local dir
    if utils.on_windows then
        dir = [[\\?\pipe\]]
    else
        dir = (os.getenv("XDG_RUNTIME_DIR") or os.getenv("TMPDIR") or os.getenv("TMP") or os.getenv("TEMP") or "/tmp"):gsub(
            "/$",
            ""
        ) .. "/"
    end

    for f in lfs.dir(dir) do
        if f:match("^discord%-ipc%-" .. (id or "")) then return dir .. f end
    end
end

return utils
