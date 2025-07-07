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
   name = "",
   music = nil,
   musicId = nil
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

   local menuStates = {
      ["states/credits"] = true,
      ["states/options"] = true,
      ["states/options/eastereggs"] = true,
      ["states/mainmenu"] = true,
      ["states/selectsave"] = true
   }

   if menuStates[stateName] then
      if state.music == nil or state.musicId ~= "intro" then
         if state.music and state.music:isPlaying() then
            state.music:stop()
         end
         state.music = love.audio.newSource("assets/sounds/music.intro.wav", "stream")
         state.music:setLooping(true)
         state.music:play()
         state.musicId = "intro"
      elseif not state.music:isPlaying() then
         state.music:play()
      end
   else
      if state.music and state.music:isPlaying() and state.musicId == "intro" then
         state.music:stop()
         state.music = nil
         state.musicId = nil
      end
   end
end

function state.clear()
   passvar = nil
end

return state
