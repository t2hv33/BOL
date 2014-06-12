require "AIRoutine"

--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

AIData - lib namespace
	string map 
		contains map name
		params: "tt" "dom" "classic" "pg"
	table allies 
		container of allies
	table enemies 
		container of enemies
	table points 
		container of points(dominion) and inhibitors(classic ones)
	table allyTowers 
		container of ally towers, can contain destroyed(.valid == false)
	table enemyTowers 
		container of enemy towers, can contain destroyed(.valid == false)
	table allyCreeps
		contains ally pushing creeps
	table enemyCreeps
		contain enemy pushing creeps
	table wards 
		container of ally wards
	unit allySpawn 
		ally spawn unit reference
	unit enemySpawn 
		enemy spawn unit reference
	unit allyNexus 
		ally nexus reference
	unit enemyNexus
		enemy nexus reference
		
	{unit,...} scanByName(string name) 
		return units found by name
	{unit,...} scanByType(string type) 
		return units found by type
	{unit,...} scanByCondition(function condition(unit)) 
		return units by condition
		condition should return true in case unit is required
		
	handle hookByName(string name,table container) 
		all units with this name inserted to container by lib
		WARNING container will be managed by library
	handle hookByType(string type,table container) 
		all units with this type inserted to container by lib
		WARNING container will be managed by library		
	handle hookByCondition(function condition(unit),container) 
		same,condition should return true in case unit is required
		WARNING container will be managed by library
		
	void remove(void handle) 
		stop hooking objects
	string test()
		return AIData library diagnosis
--]]

AIData = {}
local dataIN = {}
local dataOUT = {}
myHero = GetMyHero()

AIData.scanByName = function(name)
	local result = {}
	for i = 1, objManager.maxObjects, 1 do
		local object = objManager:getObject(i)
		if object ~=nil and object.valid == true and string.find(object.name,name) ~= nil then result[#result+1] = object end
	end
	return result
end

AIData.scanByType = function(objType)
	local result = {}
	for i = 1, objManager.maxObjects, 1 do
		local object = objManager:getObject(i)
		if object ~=nil and object.valid == true and string.find(object.type,objType) ~= nil then result[#result+1] = object end
	end
	return result
end
	
AIData.scanByCondition = function(condition)
	local result = {}
	for i = 1, objManager.maxObjects, 1 do
		local object = objManager:getObject(i)
		if object ~=nil and object.valid == true and condition(object) == true then result[#result+1] = object end
	end
	return result
end
	
AIData.hookByName = function(name,container)
	local key = #dataIN + 1
	dataIN[key] = function(obj)  if string.find(obj.name,name) ~= nil then container[#container+1] = obj end end
	dataOUT[key] = function(obj)  
		if string.find(obj.name,name) ~= nil then  
			for i=1,#container,1 do if container[i].networkID == obj.networkID then table.remove(container,i) return end end
		end
	end
	return key
end
	
AIData.hookByType = function(objType,container)
	local key = #dataIN + 1
	dataIN[key] = function(obj) if string.find(obj.type,objType) ~= nil then container[#container+1] = obj end end
	dataOUT[key] = function(obj)  
		if string.find(obj.type,objType) ~= nil then  
			for i=1,#container,1 do if container[i].networkID == obj.networkID then table.remove(container,i) return end end
		end
	end
	return key
end
	
AIData.hookByCondition = function(condition,container)
	local key = #dataIN + 1
	dataIN[key] = function(obj) if condition(obj) == true then container[#container+1] = obj end end
	dataOUT[key] = function(obj)  
		if condition(obj) == true then  
			for i=1,#container,1 do if container[i].networkID == obj.networkID then table.remove(container,i) return end end 
		end 
	end
	return key
end
	
AIData.remove = function(handle)
	dataIN[handle] = nil
	dataOUT[handle] = nil
end
	
AIData.test = function()
	if #AIData.allies == 0 or #AIData.allies > 10 then return "AIData.allies failed"
	elseif #AIData.enemies > 10 then return "AIData.enemies failed" 
	elseif AIData.allySpawn == nil then return "AIData.allySpawn failed" 
	elseif AIData.enemySpawn == nil then return "AIData.enemySpawn failed" 
	elseif AIData.map == "unknown" then return "AIData.map failed"
	elseif (AIData.map == "classic" or AIData.map == "tt") and GetGameTimer() > 300 and (#AIData.allyCreeps == 0 or #AIData.allyCreeps > 100)  then return "AIData.allyCreeps failed"
	elseif (AIData.map == "classic" or AIData.map == "tt") and GetGameTimer() > 300 and (#AIData.enemyCreeps == 0 or #AIData.enemyCreeps > 100) then return "AIData.enemyCreeps failed"
	elseif #AIData.scanByCondition(function(obj)  return obj.name == myHero.name end)  == 0 then return "AIData.scanByName failed"
	elseif #AIData.scanByName(myHero.name) == 0 then return "AIData.scanByName failed"
	elseif #AIData.scanByType("AI") == 0 then return "AIData.scanByType failed"  end
	return "OK"
end

AddLoadCallback(function() 
		--fill spawn and turrets and points
		AIData.points,AIData.enemyTowers,AIData.allyTowers = {},{},{}
		for i=1, objManager.maxObjects, 1 do
			local candidate = objManager:getObject(i)
			if candidate ~= nil and candidate.valid == true then
				--spawn
				if candidate.type == "obj_SpawnPoint" then
					if candidate.team == TEAM_ENEMY then AIData.enemySpawn = candidate
					elseif candidate.team == myHero.team then AIData.allySpawn = candidate end
				--turrets
				elseif candidate.type == "obj_AI_Turret" and candidate.dead == false and candidate.bTargetable == true then
					if candidate.team == TEAM_ENEMY then AIData.enemyTowers[#AIData.enemyTowers+1] = candidate
					elseif candidate.team == myHero.team then AIData.allyTowers[#AIData.allyTowers+1] = candidate end
				--dom points
				elseif candidate.type == "obj_AI_Minion" and candidate.name == "OdinNeutralGuardian" then 
					AIData.points[#AIData.points + 1] = candidate
				--classic points
				elseif string.byte(candidate.type,4)==15 and candidate.maxHealth ~= 0 and candidate.maxHealth % 1000 == 0 then 
					AIData.points[#AIData.points + 1] = candidate 
				--nexus
				elseif candidate.type == "obj_HQ" then
					if candidate.team == myHero.team then AIData.allyNexus = candidate
					else AIData.enemyNexus = candidate end
				end
			end
		end

		--determine map
		local distance = AIRoutine.distance(AIData.allySpawn,AIData.enemySpawn)
		if distance > 19660 and distance < 19680 then AIData.map = "classic"
		elseif distance > 12790 and distance < 12810 then AIData.map = "dom"
		elseif distance > 15165 and distance < 15185 then AIData.map = "pg"
		elseif distance > 13250 and distance < 13270 then AIData.map = "tt" 
		else AIData.map = "unknown" end
				
		--fill allies and enemies
		AIData.allies,AIData.enemies  = {},{}
		for i = 1, heroManager.iCount, 1 do
			local candidate = heroManager:getHero(i)
			if candidate ~= nil or candidate.valid == true then
				if candidate.team == myHero.team then AIData.allies[#AIData.allies + 1] = candidate
				elseif candidate.team == TEAM_ENEMY then AIData.enemies[#AIData.enemies + 1] = candidate end
			end
		end
				
		--we begin fill wards on first request/// due performance
		AIData.wards = AIRoutine.initDelay(function()
				AIData.wards = {}
				AIData.wards = AIData.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,"Ward") ~= nil end)
				AIData.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,"Ward") ~= nil end,AIData.wards)
				return AIData.wards
			end)
				
		--we begin fill  ally creeps on first request/// due performance
		if AIData.map == "dom" then
			--detect team
			local ally = "Blue" if myHero.team == TEAM_RED then ally = "Red" end
			AIData.allyCreeps = AIRoutine.initDelay(function() 
					AIData.allyCreeps = {}
					AIData.allyCreeps = AIData.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,ally) ~= nil end)
					AIData.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,ally) ~= nil end,AIData.allyCreeps)
					return AIData.allyCreeps
				end)
		else
			--detect team
			local ally = "T100" if myHero.team == TEAM_RED then ally  = "T200" end
			AIData.allyCreeps = AIRoutine.initDelay(function()
				AIData.allyCreeps = {}
				AIData.allyCreeps = AIData.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally) ~= nil end)
					AIData.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally) ~= nil end,AIData.allyCreeps)
					return AIData.allyCreeps
				end)
		end
				
		--we begin fill  enemy creeps on first request/// due performance
		if AIData.map == "dom" then
			--detect team
			local enemy = "Red" if myHero.team == TEAM_RED then enemy = "Blue" end
			AIData.enemyCreeps = AIRoutine.initDelay(function()
					AIData.enemyCreeps = {}
					AIData.enemyCreeps = AIData.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,enemy) ~= nil end)
					AIData.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,enemy) ~= nil end,AIData.enemyCreeps)
					return AIData.enemyCreeps
				end)
		else
			--detect team
			local enemy = "T200" if myHero.team == TEAM_RED then enemy  = "T100" end
			AIData.enemyCreeps = AIRoutine.initDelay(function()
					AIData.enemyCreeps = {}
					AIData.enemyCreeps = AIData.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy) ~= nil end)
					AIData.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy) ~= nil end,AIData.enemyCreeps)
					return AIData.enemyCreeps
				end)
		end
	end)

--object processor
AddCreateObjCallback(function(obj)
		--check hooks
		for key, value in pairs(dataIN) do 
			value(obj)
		end
	end)
AddDeleteObjCallback(function(obj)
		--check hooks
		for key, value in pairs(dataOUT) do 
			value(obj)
		end
	end)
	