--[[
State switcher class: stateswitcher.lua
Author: Daniel Duris, (CC-BY) 2014
dusoft[at]staznosti.sk
http://www.ambience.sk

License: CC-BY 4.0
This work is licensed under the Creative Commons Attribution 4.0
International License. To view a copy of this license, visit
http://creativecommons.org/licenses/by/4.0/ or send a letter to
Creative Commons, 444 Castro Street, Suite 900, Mountain View,
California, 94041, USA.

Modified by OmgRod
]]--

passvar = {}

state = {
   current = {},
   name = ""
}

function state.switch(stateName)
   passvar = {}
   local matches = {}
   for match in string.gmatch(stateName, "[^;]+") do
      matches[#matches+1] = match
   end
   stateName = matches[1]
   matches[1] = nil
   if matches[2] ~= nil then
      for i, match in ipairs(matches) do
         passvar[#passvar+1] = match
      end
   end

   package.loaded[stateName] = false
   state.name = stateName

   local modname = stateName:gsub("/", ".")
   state.current = require(modname)

   if type(state.current.load) == "function" then
      state.current.load(unpack(passvar))
   end
end

function state.clear()
   passvar = nil
end

return state
