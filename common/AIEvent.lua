require "AITimer"
require "AIData"
require "AIFind"
require "AIMath"
--[[
AI lib version 4
by Ivan[RUSSIA]
Extragoz Skill Detector Code used

GPL v1 license

AIEvent - lib namespace
	handle onObject(function conditionFunction(unit object),function callback(unit object,void handle))
		conditionFunction must return bool value, if object match yours requests
		callback called after requested object created
	handle onObject(string name,function callback(unit object,void handle))
		callback called after object created with string name
	
	handle onSpell(bool conditionFunction(unit unit,iSpell spell),function callback(unit unit,iSpell spell,void handle))
		callback called after spell casted and match your condition
	handle onSpell(unit unit,function callback(unit unit,iSpell spell,void handle))
		callback called after unit casted spell
	handle onSpell(string name,function callback(unit unit,iSpell spell,void handle))
		callback called after spell casted with string name
		
	handle onLevel(function callback(unit lvlParticle,void handle),unit hero = myHero)
		callback called after hero leveled, does not work with invisible heroes(fog of war etc)
		
	handle onAttack(function callback(unit unit,iSpell spell,void handle),unit unit = myHero)
		callback called after unit autoattack
		
	handle onCV(function callback(unit cvObj,void handle))
		callback called after someone used clairvoiance
	
	handle onDead(function callback(void handle),unit unit = myHero)
		callback called after unit died
		
	handle onResurect(function callback(void handle),unit hero = myHero)
		callback called after hero resurected
		
	handle onSpawn(function callback(void handle),unit unit = myHero)
		callback called every 500ms while unit inside fountain area
		
	handle onEnemyTower(function callback(unit tower,void handle),unit unit = myHero)
		callback called after unit entered enemy tower area
		
	handle onAllyTower(function callback(unit tower,void handle),unit unit = myHero)
		callback called after unit entered ally tower area
		
	handle onPoint(function callback(unit point,void handle),float range = myHero.range,unit unit = myHero)
		callback called after unit in range of inhibitor/dom point
		
	handle test(function callback(string result))
		diagnos of lib and send callback with text description
		
	void remove(void handle)
		remove choosen handle from processing
--]]

AIEvent = {}
local dataObject = {}
local dataSpell = {}

AIEvent.onObject = function(condition,callback)
	--recursion if hook object by name
	if type(condition) == "string" then
		return AIEvent.onObject(function(obj)
				return string.find(obj.name,condition) ~= nil
			end,callback)
	else
		local key = #dataObject + 1
		--this hook will be processed by AddCreateObjCallback(...)
		dataObject[key] = function(obj)
			if condition(obj) == true then callback(obj,function() dataObject[key] = nil end) end 
		end
	end
	return function() dataObject[key] = nil end
end

AIEvent.onSpell = function(condition,callback)
	--if hook spell by unit, then we do recursion
	if type(condition) == "table" then
		return AIEvent.onSpell(function(unit,iSpell)
				return unit.networkID == condition.networkID
			end,callback)
	--same if hook spell by name
	elseif type(condition) == "string" then
		return AIEvent.onSpell(function(unit,iSpell)
				return string.find(iSpell.name,condition) ~= nil
			end,callback)
	else
		local key = #dataSpell + 1
		--this hook will be processed by AddProcessSpellCallback(...)
		dataSpell[key] = function(unit,iSpell)
			if condition(unit,iSpell) == true then callback(unit,iSpell,function() dataSpell[key] = nil end) end
		end
		return function() dataSpell[key] = nil end
	end
end

AIEvent.onLevel = function(callback,hero)
	hero = hero or myHero
	return AIEvent.onObject(function(obj) 
			return obj.name == "LevelUp_glb.troy" and AIMath.distance(obj,hero) < 20 
		end,callback)
end

AIEvent.onCV = function(callback)
	return AIEvent.onObject(function(obj) 
			return string.find(obj.name,"ClairvoyanceEye") ~= nil
		end,callback)
end

AIEvent.onAttack = function(callback,hero)
	hero = hero or myHero
	return AIEvent.spell(function(unit,spell)
			return hero.networkID == unit.networkID and (string.find(spellName,"BasicAttack") ~= nil or string.find(spellName,"basicattack") ~= nil 
			or string.find(spellName,"JayceRangedAttack") ~= nil or spellName == "KennenMegaProc" or spellName == "ZiggsPassiveAttack" 
			or spellName == "QuinnWEnhanced" or spellName == "SonaHymnofValorAttack" or spellName == "SonaSongofDiscordAttack" 
			or spellName == "SonaAriaofPerseveranceAttack" or spellName == "CaitlynHeadshotMissile" or spellName == "RumbleOverheatAttack" 
			or spellName == "JarvanIVMartialCadenceAttack" or spellName == "ShenKiAttack" or spellName == "MasterYiDoubleStrike" 
			or spellName == "sonahymnofvalorattackupgrade" or spellName == "sonaariaofperseveranceupgrade" 
			or spellName == "sonasongofdiscordattackupgrade" or spellName == "NocturneUmbraBladesAttack" or spellName == "NautilusRavageStrikeAttack")
		end,callback)
end

AIEvent.onDead = function(callback,hero)
	hero = hero or myHero 
	local memory = hero.dead
	local timer = AITimer.add(0.25,function(timerID)
			--check last remembered state with new state
			if hero.dead == true and memory == false then
				callback(function() AITimer.remove(timer) end)
			end
			memory = hero.dead
		end)
	return function() AITimer.remove(timer) end
end

AIEvent.onResurect = function(callback,hero)
	hero = hero or myHero 
	local memory = hero.dead
	local timer = AITimer.add(0.25,function(timerID)
			--check last remembered state with new state
			if hero.dead == false and memory == true then
				callback(function() AITimer.remove(timer) end)
			end
			memory = hero.dead
		end)
	return function() AITimer.remove(timer) end
end
	
AIEvent.onSpawn = function(callback,hero)
	hero = hero or myHero
	local timer = AITimer.add(0.5,function(timerID)
			if AIMath.distance(hero,AIData.allySpawn) <= 600 then callback(function() AITimer.remove(timer) end) end
		end)
	return function() AITimer.remove(timer) end
end
	
AIEvent.onEnemyTower = function(callback,hero)
	hero = hero or myHero
	local memory = nil
	local timer = AITimer.add(0.1,function(timerID)
			local tower = AIFind.enemyTower(hero,920)
			--check last remembered state with new state
			if tower ~= nil and memory == nil then
				callback(tower,function() AITimer.remove(timerID) end)
			end
			memory = tower
		end)
	return function() AITimer.remove(timer) end
end

AIEvent.onAllyTower = function(isOneTime,callback,hero)
	hero = hero or myHero
	local memory = nil
	local timer = AITimer.add(0.25,function(timerID)
			local tower = AIFind.allyTower(unit,920)
			--check last remembered state with new state
			if tower ~= nil and memory == nil then
				callback(tower,function() AITimer.remove(timerID) end)
			end
			memory = tower
		end)
	return function() AITimer.remove(timer) end
end
	
AIEvent.onPoint = function(callback,range,hero)
	hero = hero or myHero
	range = range or myHero.range
	local memory = nil
	local timer = AITimer.add(0.25,function(timerID)
			local point = AIFind.point(unit,range)
			--check last remembered state with new state
			if point ~= nil and memory == nil then
				callback(point,function() AITimer.remove(timerID) end)
			end
			memory = point
		end)
	return function() AITimer.remove(timer) end
end

AIEvent.test = function(callback)
	AIEvent.onObject(function() return true end,function(obj,handle) 
			AIEvent.remove(handle)
			callback("OK")
		end)
end
	
AIEvent.remove = function(handle)
	handle()
end

AddProcessSpellCallback(function(unit,spellProc)
		for key,value in pairs(dataSpell) do
			value(unit,spellProc)
		end
	end)
--
AddCreateObjCallback(function(obj)
		for key,value in pairs(dataObject) do
			value(obj)
		end
	end)