local error_kind = {}

---@return string
function error_kind.invalid_pipe()
    return "Unable to connect to Discord IPC pipe, check if Discord is running"
end

---@return string
function error_kind.invalid_path()
    return "Unable to find Discord IPC pipe, check if Discord is running"
end

---@param id string|integer
function error_kind.invalid_client_id(id)
    return "Invalid client ID: " .. id
end

---@param code integer
---@param msg string
---@return string
function error_kind.handshake_failed(code, msg)
    return ("Unable to handshake [%d]: %s"):format(code, msg)
end

---@param msg string
---@return string
function error_kind.server_error(msg)
    msg = msg:gsub("[%[%]]", "")
    return msg:sub(1, 1):upper() .. msg:sub(2)
end

function error_kind.timed_out()
    return "Unable to connect, poll timed out"
end

---@param code integer
---@param msg string
---@return string
function error_kind.discord_error(code, msg)
    return ("[%d]: %s"):format(code, msg)
end
return error_kind
