--[[@diagnostic disable:duplicate-set-field]]

--- Wrapper for Love2D.
-- @module lpresence.love

--- Shortcut to this module. Exported to 'love' namespace.
-- @type love.rpc

if not love then error("This module is intended for Love2D!") end

love.rpc = {
    initialized = false,
}

local signals = {
    CONNECT = 1,
    CLOSE = 2,
    UPDATE = 3,
    CLEAR = 4,
    REGISTER = 5,
    UNREGISTER = 6,
}
local chunk = [=[
local Client = require("lpresence").Client
local ffi = require("ffi")

local getpid
if ffi.os == "Windows" then
    ffi.cdef[[
    uint32_t GetCurrentProcessId();
    ]]
    getpid = ffi.load("kernel32.dll").GetCurrentProcessId
else
    ffi.cdef[[
    int getpid();
    ]]
    getpid = ffi.C.getpid
end

local signals = {
    CONNECT = 1,
    CLOSE = 2,
    UPDATE = 3,
    CLEAR = 4,
    REGISTER = 5,
    UNREGISTER = 6,
}
local rpc_channel = love.thread.getChannel("RPCData")

local rpc = Client("%s")

while 1 do
    local signal = rpc_channel:demand()

    if signal == signals.CONNECT then
        rpc:connect()
    elseif signal == signals.CLOSE then
        rpc:close()
        break
    elseif signal == signals.UPDATE then
        rpc:set_activity(rpc_channel:demand(), getpid())
    elseif signal == signals.CLEAR then
        rpc:clear_activity(getpid())
    elseif signal == signals.REGISTER then
        rpc:register_event(rpc_channel:demand(), rpc_channel:demand()[1], rpc_channel:demand())
    elseif signal == signals.UNREGISTER then
        rpc:unregister_event(rpc_channel:demand(), rpc_channel:demand())
    end
end
]=]
local rpc_channel = love.thread.getChannel("RPCData")

--- Initialize RPC thread.
-- @param[type=string] application_id [Application ID](https://en.wikipedia.org/wiki/Snowflake_ID)
function love.rpc.init(application_id)
    if love.rpc.initialized then error("RPC thread has already been initialized") end

    love.rpc.initialized = true

    local thread = love.thread.newThread(chunk:format(application_id))
    thread:start()
    love.rpc.thread = thread
end

--- Connect to the Rich Presence.
function love.rpc.connect()
    if not love.rpc.initialized then error("RPC thread hasn't been initialized yet") end
    rpc_channel:push(signals.CONNECT)
end

--- Update Rich Presence.
-- @param[type=table] activity [Activity](https://discord.com/developers/docs/topics/gateway-events#activity-object) object
function love.rpc.update(activity)
    if not love.rpc.initialized then error("RPC thread hasn't been initialized yet") end
    rpc_channel:push(signals.UPDATE)
    rpc_channel:push(activity)
end

--- Clear Rich Presence.
function love.rpc.clear()
    if not love.rpc.initialized then error("RPC thread hasn't been initialized yet") end
    rpc_channel:push(signals.CLEAR)
end

--- Close connection to Rich Presence.
--- Also close thread holding the connection.
function love.rpc.close()
    if not love.rpc.initialized then error("RPC thread hasn't been initialized yet") end
    rpc_channel:push(signals.CLOSE)
    love.rpc.thread:wait()
    love.rpc.thread:release()
    love.rpc.initialized = false
end

--- Register an event.
-- @param[type=string] event [Event name](https://discord.com/developers/docs/topics/rpc#commands-and-events-rpc-events)
-- @param[type=function(data)] func Event callback
-- @param[type=?table] args Event args
function love.rpc.register_event(event, func, args)
    if not love.rpc.initialized then error("RPC thread hasn't been initialized yet") end
    rpc_channel:push(signals.REGISTER)
    rpc_channel:push(event)
    rpc_channel:push({ func })
    rpc_channel:push(args or {})
end

--- Unregister an event.
-- @param[type=string] event [Event name](https://discord.com/developers/docs/topics/rpc#commands-and-events-rpc-events)
-- @param[type=?table] args Event args
function love.rpc.unregister_event(event, args)
    if not love.rpc.initialized then error("RPC thread hasn't been initialized yet") end
    rpc_channel:push(signals.UNREGISTER)
    rpc_channel:push(event)
    rpc_channel:push(args or {})
end

return love.rpc
