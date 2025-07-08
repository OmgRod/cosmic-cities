passvar = {}

state = {
   current = {},
   name = ""
}

local function forceUnloadModule(mod)
   local dotname = mod:gsub("/", ".")
   print("[StateSwitcher] Unloading modules:", mod, dotname)

   package.loaded[mod] = nil
   package.loaded[dotname] = nil
   _G[dotname] = nil
   _G[mod] = nil
end

function state.switch(stateName)
   passvar = {}
   local matches = {}
   for match in string.gmatch(stateName, "[^;]+") do
      matches[#matches + 1] = match
   end

   print("[StateSwitcher] Raw stateName:", stateName)
   print("[StateSwitcher] Parsed base state:", matches[1])
   for i, v in ipairs(matches) do
      print(string.format("[StateSwitcher] Param %d: %s", i, v))
   end

   stateName = matches[1]
   table.remove(matches, 1)

   for i = 1, #matches do
      passvar[i] = matches[i]
   end

   print("[StateSwitcher] passvar contents:")
   for i, v in ipairs(passvar) do
      print(string.format(" passvar[%d] = %s", i, v))
   end

   forceUnloadModule(stateName)

   local modname = stateName:gsub("/", ".")
   state.name = stateName
   state.current = require(modname)

   if type(state.current.load) == "function" then
      state.current.load(unpack(passvar))
   end
end

function state.clear()
   print("[StateSwitcher] Clearing passvar")
   passvar = {}
end

return state
