-- Enable compatibilty for Pluto 0.9.0+
-- @pluto_use class = false

local error_kind = require("lpresence.error_kind")
local utils = require("lpresence.utils")

local class = require("classy")
local json = require("cjson")
local vstruct
if not (string.pack and string.unpack) then vstruct = require("vstruct") end
local winapi, socket
if utils.on_windows then
    winapi = require("winapi")
else
    socket = require("cqueues.socket")
end

local BaseClient = class "BaseClient"

function BaseClient:__init(id, options)
    self.client_id = tostring(id)
    self.options = {
        timeout = 1,
        pipe = 0,
    }

    utils.recursive_merge(self.options, options or {})
end

function BaseClient:read()
    local preamble = self.sock:read(8)
    local length
    if vstruct then
        _, length = vstruct.readvals("<(2*u4)", preamble)
    else
        _, length = string.unpack("<II", preamble)
    end
    local response = self.sock:read(length)
    local payload = json.decode(response)

    if self._on_event then
        self:_on_event(response)
    end
    if payload.evt == "ERROR" then error(error_kind.server_error(payload.data.message)) end
    return payload
end

function BaseClient:send(op, payload)
    local json_payload = json.encode(payload)

    assert(self.sock, "You'll have to connect your client before sending events")

    local data
    if vstruct then
        data = vstruct.write("<(2*u4)", { op, #json_payload })
    else
        data = string.pack("<II", op, #json_payload)
    end

    self.sock:write(data .. json_payload)
end

function BaseClient:handshake()
    local ipc_path = assert(utils.get_ipc_path(self.options.pipe), error_kind.invalid_path())

    if not utils.on_windows then
        local s = assert(socket.connect { path = ipc_path }, error_kind.invalid_pipe())

        s:settimeout(self.options.timeout)
        assert(s:connect(), error_kind.timed_out())

        self.sock = s
    elseif winapi then
        local pipe = assert(winapi.open_pipe(ipc_path), error_kind.invalid_pipe())

        self.sock = pipe
    end

    self:send(0, { v = 1, client_id = self.client_id })
    local preamble = self.sock:read(8)
    local length
    if vstruct then
        _, length = vstruct.readvals("<(2*i4)", preamble)
    else
        _, length = string.unpack("<ii", preamble)
    end
    local response = self.sock:read(length)
    local data = json.decode(response)

    if data.code then
        if data.code == 4000 then error(error_kind.invalid_client_id(self.client_id)) end
        error(error_kind.handshake_failed(data.code, data.message))
    end

    if data.cmd == "DISPATCH" and data.evt == "READY" and self._on_event then
        self:_on_event(response)
    end
end

return BaseClient
