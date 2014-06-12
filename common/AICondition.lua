require "AIData"
require "AIRoutine"

--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

AICondition - lib namespace
	bool damageImmune(unit unit) - check is unit immune to damage(Poppy under ultimate always return true)
	bool ccImmune(unit unit) - check is unit immune to cc
	bool enemySide({x,z} pos) - check enemy's side of map
	bool behind({x,z} unit,{x,z} target) - check unit behind target
	bool river(unit unit) - check is unit on classic map river
	bool recallFaster({x,z} pos,float ms) - check is faster run to spawn then recall at pos
	bool recall(unit unit) - check is recalling
	bool exhaust(unit unit) - check is unit exhausted
	bool ignite(unit unit) check is unit ignited
	bool manaLess(unit unit) - check energy/mana
	bool lowMP(unit unit,float lowPercent) - check low mp%, return false on energy users,lowPercent = {0-1}
	bool low(unit unit,float lowPercent) - check low hp and mp, lowPercent = {0-1}
	bool buffed(unit unit,string buff) - check is unit buffed
--]]

AICondition = { }
local data = {}
local dataDImmune = nil
local dataCCImmune = nil
local dataRecall = nil
local dataExhaust = nil
local dataIgnite = nil

AICondition.damageImmune = function(unit)
	--first check
	if unit.bInvulnerable == 1 or unit.bTargetable == false then return true end
	--init
	if dataDImmune == nil then
		dataDImmune  = AIData.scanByCondition(function(obj) return string.find(obj.name,"UndyingRage") ~= nil or string.find(obj.name,"DiplomaticImmunity") ~= nil end)
		AIData.hookByCondition(function(obj) return string.find(obj.name,"UndyingRage") ~= nil or string.find(obj.name,"DiplomaticImmunity") ~= nil end,dataDImmune)
	end
	for i=1,#dataDImmune,1 do
		--check valid
		if dataDImmune.valid == false then 
			table.remove(dataDImmune,i)
			i = i - 1
		elseif dataDImmune.visible == true then
			--check distance
			if GetDistance(unit,dataDImmune[i]) <= 25 
			--check trynd
			and (unit.name ~= "Tryndamere" or unit.health/unit.maxHealth <= 0.1)
			--approve
			then return true end			
		end
	end
	return false
end

AICondition.ccImmune = function(unit)
	--init
	if dataCCImmune == nil then
		AI.condition.data.cc = AIData.scanByCondition(function(obj) 
				return string.find(obj.name,"DiplomaticImmunity") ~= nil or string.find(obj.name,"olaf_ragnorok") ~= nil 
				or string.find(obj.name,"Spellimmunity") ~= nil or string.find(obj.name,"SpellBlock") ~= nil 
				or string.find(obj.name,"bansheesveil") ~= nil or string.find(obj.name,"shroudofdarkness") ~= nil 
			end)
		AIData.hookByCondition(function(obj) 
				return string.find(obj.name,"DiplomaticImmunity") ~= nil or string.find(obj.name,"olaf_ragnorok") ~= nil 
				or string.find(obj.name,"Spellimmunity") ~= nil or string.find(obj.name,"SpellBlock") ~= nil 
				or string.find(obj.name,"bansheesveil") ~= nil or string.find(obj.name,"shroudofdarkness") ~= nil 
			end,AI.condition.data.cc)
	end
	for i=1,#dataCCImmune,1 do
		--check valid
		if dataCCImmune[i].valid == false then
			table.remove(dataCCImmune,i)
			i = i -1
		elseif dataCCImmune[i].visible == true then
			--check distance
			if GetDistance(unit,dataCCImmune[i]) <= 25 then return true end
		end
	end
	return false
end
	
AICondition.mid = function(pos)
	if AIData.map == "classic" then return GetDistance(pos,AIRoutine.project({x=1360,z=1630},{x=12570,z=12810},pos)) <= 750
	elseif AIData.map == "tt" then return GetDistance(pos,{x=7700,z=6700}) <= 1000
	elseif AIData.map == "dom" then return GetDistance(pos,{x=6900,z=6460}) <= 1000
	elseif AIData.map == "pg" then return true
	else return false end
end
	
AICondition.top = function(pos)
	if AIData.map == "classic" then return GetDistance(pos,{x=2000,z=12500}) <= 1000 or GetDistance(pos,AIRoutine.project({x=1000,z=1700},{x=1000,z=11500},pos)) <= 750 or GetDistance(pos,AIRoutine.project({x=12500,z=13250},{x=3400,z=13250},pos)) <= 750
	elseif AIData.map == "tt" then return GetDistance(pos,AIRoutine.project({x=2121,z=9000},{x=13285,z=9000},pos)) <= 1200
	else return false end
end
	
AICondition.bot = function(pos)
	if AIData.map == "classic" then return GetDistance(pos,{x=12100,z=2175}) <= 1000 or GetDistance(pos,AIRoutine.project({x=1330,z=1150},{x=12000,z=1150},pos)) <= 750 or GetDistance(pos,AIRoutine.project({x=13100,z=12850},{x=13100,z=3000},pos)) <= 750
	elseif AIData.map == "tt" then return GetDistance(pos,AIRoutine.project({x=2121,z=5600},{x=13285,z=5600},pos)) <= 850
	else return false end
end
	
AICondition.enemySide = function(unit)
	return GetDistance(unit,AIData.enemySpawn) < GetDistance(unit,AIData.allySpawn)
end
	
AICondition.behind = function(unit,target)
	local rad = AIRoutine.rad(target,unit)
	--check for ally
	if target.team ~= ENEMY_TEAM then
		if AICondition.enemySide(unit) == false then return math.abs(AIRoutine.rad(unit,AIData.allySpawn) - rad) <= 0.785398163
		else return math.abs(AIRoutine.rad(AIData.enemySpawn,unit) - rad) <= 0.785398163 end
	else
		if AICondition.enemySide(unit) == true then return math.abs(AIRoutine.rad(unit,AIData.enemySpawn) - rad) <= 0.785398163
		else return math.abs(AIRoutine.rad(AIData.allySpawn,unit) - rad) <= 0.785398163 end
	end
end

AICondition.river = function(unit)
	return GetDistance(unit,AIRoutine.project({x=1000,z=13600},{x=13100,z=1500},unit)) <= 500
end

AICondition.recall = function(unit)
	--check initiation
	if dataRecall == nil then
		dataRecall = AIData.scanByName("TeleportHome")
		--set hooks to refresh recalls
		AIData.hookByName("TeleportHome",dataRecall)
	end
	for i=1,#dataRecall,1 do
		if dataRecall[i].visible == true and GetDistance(dataRecall[i],unit) < 30 and AICondition.buffed(unit,"Recall") == true then return true end
	end
	return false
end

AICondition.recallFaster = function(pos,ms)
	return GetDistance(AIData.allySpawn,pos) - 600 > ms * 8.5
end
	
AICondition.exhaust = function(unit)
	--check initiation
	if dataExhaust  == nil then
		dataExhaust = AIData.scanByName("summoner_banish.troy")
		--set hooks to refresh particles
		AIData.hookByName("summoner_banish.troy",dataExhaust)
	end
	for i=1,#dataExhaust,1 do
		if dataExhaust[i].visible == true and math.abs(dataExhaust[i].x + dataExhaust[i].z - unit.x - unit.z) < 30 then return true end
	end
	return false
end
	
AICondition.ignite = function(unit)
	--default value
	isAlly = isAlly or false
	--check initiation
	if dataIgnite == nil then
		dataIgnite = AIData.scanByName("Summoner_Dot.troy")
		--set hooks to refresh cvs
		AIData.hookByName("Summoner_Dot.troy",dataIgnite)
	end
	for i=1,#dataIgnite,1 do
		if dataIgnite[i].visible == true and math.abs(dataIgnite[i].x + dataIgnite[i].z - unit.x - unit.z) < 30 then return true end
	end
	return false
end
	
AICondition.manaLess = function(unit)
	return (unit.maxMana <= 200 and unit.charName ~= "Vayne") or unit.charName == "Mordekaiser"
end
	
AICondition.lowMP = function(unit,lowPercent)
	return AI.condition.isManaLess(unit) == false and unit.mana/unit.maxMana <= lowPercent
end
	
AICondition.low = function(unit,lowPercent)
	return unit.health/unit.maxHealth <= lowPercent or AI.condition.isLowMP(unit,lowPercent)
end

AICondition.buffed = function(unit,name)
	for i = 1, unit.buffCount,1 do
		local buff = unit:getBuff(i)
		if buff.valid == true and string.find(buff.name,name) ~= nil then return true end
	end
	return false
end