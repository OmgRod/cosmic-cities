-- Enable compatibilty for Pluto 0.9.0+
-- @pluto_use class = false

--- API wrapper for RPC.
-- @module lpresence.rpc

local BaseClient = require("lpresence.baseclient")
local payloads = require("lpresence.payloads")
local utils = require("lpresence.utils")

local class = require("classy")

--- RPC constructor.
-- @param[type=string] params [Application ID](https://en.wikipedia.org/wiki/Snowflake_ID)
-- @param[type=?rpcoptions] options RPC options
-- @treturn RPC
-- @function constructor

--- RPC constructor options
-- @field[type=?integer] timeout TImeout for connection and response (POSIX only)
-- @field[type=?integer] pipe ID for IPC path
-- @table rpcoptions

--- RPC class, see the @{constructor}.
-- @see constructor
-- @type RPC
local RPC = class("RPC", BaseClient)

function RPC:__init(id, options)
    BaseClient.__init(self, id, options)
end

--- Initialize Rich Presence connection.
function RPC:connect()
    self:handshake()
end

--- Close the Rich Presence connection.
function RPC:close()
    self:send(2, { v = 1, client_id = self.client_id })
    if utils.on_windows then self.sock:shutdown("rw") end
    self.sock:close()
end

--- Update the Rich Presence.
-- @param[type=?table] activity [Activity object](https://discord.com/developers/docs/topics/gateway-events#activity-object) object
-- @param[type=?integer] pid Process ID
-- @treturn table Response to payload
-- @usage rpc_client:update {
--     state = "I'm in Lua!",
--     details = "I'm in Lua with lpresence."
--     timestamps = {
--         start = os.time(),
--     }
-- }
function RPC:update(activity, pid)
    local payload = payloads.set_activity(activity, pid)
    self:send(1, payload)
    return self:read().data
end

--- Clear the Rich Presence.
-- @param[type=?integer] pid Process ID
-- @treturn table Response to payload
function RPC:clear(pid)
    local payload = payloads.set_activity(nil, pid)
    self:send(1, payload)
    return self:read().data
end

return RPC
