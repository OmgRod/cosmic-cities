--- Entry point to load all lpresence modules.
-- @module lpresence

local utils = require("lpresence.utils")

assert(require("classy"), "classy is required for class initialization, see https://github.com/siffiejoe/lua-classy/")
assert(
    require("cjson"),
    "lua-cjson is required for JSON encoding and decoding, see https://github.com/openresty/lua-cjson/"
)
assert(
    require("lfs"),
    "luafilesystem is required for finding Discord IPC socket, see https://lunarmodules.github.io/luafilesystem/"
)

if utils.on_windows then
    assert(
        require("winapi"),
        "winapi is required on Windows to interact with Discord, see https://stevedonovan.github.io/winapi/"
    )
else
    assert(
        require("cqueues"),
        "cqueues is required on POSIX platforms (i.e Linux, MacOS) to interact with Discord, see https://github.com/wahern/cqueues/"
    )
end

if not string.pack or not string.unpack then
    assert(
        require("vstruct"),
        "vstruct is required to work with packed bytes on environment with no string.{,un}pack (i.e Lua 5.1-5.2), see https://github.com/toxicfrog/vstruct/"
    )
end

--- Shortcut to @{lpresence.client}.
-- @table Client

--- Shortcut to @{lpresence.rpc}.
-- @table RPC
return {
    Client = require("lpresence.client"),
    RPC = require("lpresence.rpc"),
}
