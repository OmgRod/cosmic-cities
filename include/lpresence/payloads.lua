-- Enable compatibilty for Pluto 0.9.0+
-- @pluto_use class = false

local json = require("cjson")

local table = table
if not table.pack then
    function table.pack(...) ---@diagnostic disable-line:duplicate-set-field
        local tbl = {}
        for i = 1, select("#", ...) do
            tbl[#tbl + 1] = select(i, ...)
        end
        return tbl
    end
end

---@alias lpresence.snowflake string

local payloads = setmetatable({}, {
    __tostring = function(self)
        return json.encode(self.data)
    end,
})

---@param client_id lpresence.snowflake
---@param scopes string[]
---@return table
function payloads.authorize(client_id, scopes)
    return {
        cmd = "AUTHORIZE",
        args = {
            client_id = tostring(client_id),
            scopes = scopes,
        },
        nonce = tostring(os.time()),
    }
end

---@param token string
---@return table
function payloads.authenticate(token)
    return {
        cmd = "AUTHENTICATE",
        args = {
            access_token = token,
        },
        nonce = tostring(os.time()),
    }
end

---@param activity table?
---@param pid integer?
---@return table
function payloads.set_activity(activity, pid)
    return {
        cmd = "SET_ACTIVITY",
        args = {
            pid = tonumber(pid or table.concat(table.pack(_VERSION:sub(5, -1):byte(1, -1)))), -- We can't have unique pid, we can only rely on _VERSION.
            activity = activity,
        },
        nonce = tostring(os.time()),
    }
end

---@return table
function payloads.get_guilds()
    return {
        cmd = "GET_GUILDS",
        args = {},
        nonce = tostring(os.time()),
    }
end

---@param guild_id lpresence.snowflake
---@return table
function payloads.get_guild(guild_id)
    return {
        cmd = "GET_GUILD",
        args = {
            guild_id = tostring(guild_id),
        },
        nonce = tostring(os.time()),
    }
end

---@param guild_id lpresence.snowflake
---@return table
function payloads.get_channels(guild_id)
    return {
        cmd = "GET_CHANNELS",
        args = {
            guild_id = tostring(guild_id),
        },
        nonce = tostring(os.time()),
    }
end

---@param channel_id lpresence.snowflake
---@return table
function payloads.get_channel(channel_id)
    return {
        cmd = "GET_CHANNEL",
        args = {
            channel_id = tostring(channel_id),
        },
        nonce = tostring(os.time()),
    }
end

---@param user_id lpresence.snowflake
---@param pan_left number?
---@param pan_right number?
---@param volume integer?
---@param mute boolean?
---@return table
function payloads.set_user_voice_settings(user_id, pan_left, pan_right, volume, mute)
    return {
        cmd = "SET_USER_VOICE_SETTINGS",
        args = {
            user_id = tostring(user_id),
            pan = {
                left = pan_left,
                right = pan_right,
            },
            volume = volume,
            mute = mute,
        },
        nonce = tostring(os.time()),
    }
end

---@param channel_id lpresence.snowflake
---@return table
function payloads.select_voice_channel(channel_id)
    return {
        cmd = "SELECT_VOICE_CHANNEL",
        args = {
            channel_id = tostring(channel_id),
        },
        nonce = tostring(os.time()),
    }
end

---@return table
function payloads.get_selected_voice_channel()
    return {
        cmd = "GET_SELECTED_VOICE_CHANNEL",
        args = {},
        nonce = tostring(os.time()),
    }
end

---@param channel_id lpresence.snowflake
---@return table
function payloads.select_text_channel(channel_id)
    return {
        cmd = "SELECT_TEXT_CHANNEL",
        args = {
            channel_id = channel_id,
        },
        nonce = tostring(os.time()),
    }
end

---@return table
function payloads.get_voice_settings()
    return {
        cmd = "GET_VOICE_SETTINGS",
        args = {},
        nonce = tostring(os.time()),
    }
end

---@param voice_settings table?
---@return table
function payloads.set_voice_settings(voice_settings)
    return {
        cmd = "SET_VOICE_SETTINGS",
        args = voice_settings or {},
        nonce = tostring(os.time()),
    }
end

---@param action string
---@return table
function payloads.capture_shortcut(action)
    return {
        cmd = "CAPTURE_SHORTCUT",
        args = {
            action = action:upper(),
        },
        nonce = tostring(os.time()),
    }
end

---@param user_id lpresence.snowflake
---@return table
function payloads.send_activity_join_invite(user_id)
    return {
        cmd = "SEND_ACTIVITY_JOIN_INVITE",
        args = {
            user_id = tostring(user_id),
        },
        nonce = tostring(os.time()),
    }
end

---@param user_id lpresence.snowflake
---@return table
function payloads.close_activity_request(user_id)
    return {
        cmd = "CLOSE_ACTIVITY_REQUEST",
        args = {
            user_id = tostring(user_id),
        },
        nonce = tostring(os.time()),
    }
end

---@param event string
---@param args table?
---@return table
function payloads.subscribe(event, args)
    return {
        cmd = "SUBSCRIBE",
        args = args or {},
        evt = event:upper(),
        nonce = tostring(os.time()),
    }
end

---@param event string
---@param args table?
---@return table
function payloads.unsubscribe(event, args)
    return {
        cmd = "UNSUBSCRIBE",
        args = args or {},
        evt = event:upper(),
        nonce = tostring(os.time()),
    }
end

return payloads
