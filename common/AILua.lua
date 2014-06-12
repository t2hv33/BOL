--[[
AI lib version 3
by Ivan[RUSSIA]

GPL v1 license

AI.lua - lib namespace
	value,value,value... unpack(table container)
		unpack container
	value,value,value... unpack(function foo)
		use function, and return theirs result
	value,value,value... unpack(void  void)
		return void
	string freeKey(table container)
		generate unused key for container
--]]

if AI == nil then AI = {} end
AI.lua = {
	unpack = function(container)
		if type(container) == "function" then return ivanAI.lua.unpack(container())
		elseif type(container) ~= "table" then return container
		else return table.unpack(container) end
	end,
	freeKey = function(container)
		local entropy = 100
		local key = tostring(math.random(entropy))
		while container[key] ~= nil do 
			entropy = entropy ^ 2
			key = tostring(math.random(entropy))
		end
		return key
	end,
}