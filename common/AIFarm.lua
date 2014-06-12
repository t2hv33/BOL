require "AIData"
require "AIMath"

--[[
AI lib version 3
by Ivan[RUSSIA]

GPL v1 license

AI.farm - lib namspace
	table allyCreeps({x,z} pos = myHero, range = myHero.range)
		return friendly monsters in range of pos
	table enemyCreeps({x,z} pos = myHero, range = myHero.range)
		return monsters in range of pos
	unit bot() 
		return first botlane ally creep or nil
	unit top() 
		return first toplane ally creep or nil
	unit mid() 
		return first midlane ally creep or nil
--]]

if AI == nil then AI = {} end
AI.farm = {
	allyCreeps = function(pos,range)
		pos = pos or myHero
		range = range or myHero.range
		local result = {}
		if AI.condition.classic() == true then
			--scan botlane creeps
			if AI.condition.bot(pos) == true then
				for i=1,#AI.farm.data.ally[1],1 do
					if AI.farm.data.ally[1][i].dead == false and AI.math.distance(AI.farm.data.ally[1][i],pos) <= range then table.insert(result,AI.farm.data.ally[1][i]) end
				end
			end
			--scane midlane creeps
			if AI.condition.mid(pos) == true then
				for i=1,#AI.farm.data.ally[2],1 do
					if AI.farm.data.ally[2][i].dead == false and AI.math.distance(AI.farm.data.ally[2][i],pos) <= range then table.insert(result,AI.farm.data.ally[2][i]) end
				end
			end
			--scan toplane creeps
			if AI.condition.top(pos) == true then
				for i=1,#AI.farm.data.ally[3],1 do
					if AI.farm.data.ally[3][i].dead == false and AI.math.distance(AI.farm.data.ally[3][i],pos) <= range then table.insert(result,AI.farm.data.ally[3][i]) end
				end
			end
		elseif AI.condition.tt() == true then 
			--scan botlane creeps
			if AI.condition.bot(pos) == true then
				for i=1,#AI.farm.data.ally[1],1 do
					if AI.farm.data.ally[1][i].dead == false and AI.math.distance(AI.farm.data.ally[1][i],pos) <= range then table.insert(result,AI.farm.data.ally[1][i]) end
				end
			end
			--scan toplane creeps
			if AI.condition.top(pos) == true then
				for i=1,#AI.farm.data.ally[2],1 do
					if AI.farm.data.ally[2][i].dead == false and AI.math.distance(AI.farm.data.ally[2][i],pos) <= range then table.insert(result,AI.farm.data.ally[2][i]) end
				end
			end
		elseif AI.condition.pg() == true then 
			--scane midlane creeps
			for i=1,#AI.farm.data.ally[1],1 do
				if AI.farm.data.ally[1][i].dead == false and AI.math.distance(AI.farm.data.ally[1][i],pos) <= range then table.insert(result,AI.farm.data.ally[1][i]) end
			end
		elseif AI.condition.dom() == true then
			--scan dominion creeps
			for i=1,#AI.farm.data.ally[1],1 do
				if AI.farm.data.ally[1][i].dead == false and AI.math.distance(AI.farm.data.ally[1][i],pos) <= range then table.insert(result,AI.farm.data.ally[1][i]) end
			end
		end
		return result
	end,
	enemyCreeps = function(pos,range)
		pos = pos or myHero
		range = range or (myHero.range)
		local result = {}
		if AI.condition.classic() == true then
			--scan botlane creeps
			if AI.condition.bot(pos) == true then
				for i=1,#AI.farm.data.enemy[1],1 do
					if AI.farm.data.enemy[1][i].dead == false and AI.farm.data.enemy[1][i].visible == true and AI.math.distance(AI.farm.data.enemy[1][i],pos) <= range then table.insert(result,AI.farm.data.enemy[1][i]) end
				end
			end
			--scane midlane creeps
			if AI.condition.mid(pos) == true then
				for i=1,#AI.farm.data.enemy[2],1 do
					if AI.farm.data.enemy[2][i].dead == false and AI.farm.data.enemy[2][i].visible == true and AI.math.distance(AI.farm.data.enemy[2][i],pos) <= range then table.insert(result,AI.farm.data.enemy[2][i]) end
				end
			end
			--scan toplane creeps
			if AI.condition.top(pos) == true then
				for i=1,#AI.farm.data.enemy[3],1 do
					if AI.farm.data.enemy[3][i].dead == false and AI.farm.data.enemy[3][i].visible == true and AI.math.distance(AI.farm.data.enemy[3][i],pos) <= range then table.insert(result,AI.farm.data.enemy[3][i]) end
				end
			end
		elseif AI.condition.tt() == true then 
			--scan botlane creeps
			if AI.condition.bot(pos) == true then
				for i=1,#AI.farm.data.enemy[1],1 do
					if AI.farm.data.enemy[1][i].dead == false and AI.farm.data.enemy[1][i].visible == true and AI.math.distance(AI.farm.data.enemy[1][i],pos) <= range then table.insert(result,AI.farm.data.enemy[1][i]) end
				end
			end
			--scan toplane creeps
			if AI.condition.top(pos) == true then
				for i=1,#AI.farm.data.enemy[2],1 do
					if AI.farm.data.enemy[2][i].dead == false and AI.farm.data.enemy[2][i].visible == true and AI.math.distance(AI.farm.data.enemy[2][i],pos) <= range then table.insert(result,AI.farm.data.enemy[2][i]) end
				end
			end
		elseif AI.condition.pg() == true then 
			--scane midlane creeps
			for i=1,#AI.farm.data.enemy[1],1 do
				if AI.farm.data.enemy[1][i].dead == false and AI.farm.data.enemy[1][i].visible == true and AI.math.distance(AI.farm.data.enemy[1][i],pos) <= range then table.insert(result,AI.farm.data.enemy[1][i]) end
			end
		elseif AI.condition.dom() == true then
			--scan dominion creeps
			for i=1,#AI.farm.data.enemy[1],1 do
				if AI.farm.data.enemy[1][i].dead == false and AI.farm.data.enemy[1][i].visible == true and AI.math.distance(AI.farm.data.enemy[1][i],pos) <= range then table.insert(result,AI.farm.data.enemy[1][i]) end
			end
		end
		return result
	end,
	bot = function()
		local result = nil
		if AI.condition.classic() == true or AI.condition.tt() == true then 
			for i=1,#AI.farm.data.ally[1],1 do
				if AI.farm.data.ally[1][i].dead == false and (result == nil or AI.math.distance(AI.farm.data.ally[1][i],AI.data.enemySpawn) < AI.math.distance(result,AI.data.enemySpawn)) then result = AI.farm.data.ally[1][i] end
			end
		end
		return result
	end,
	top = function() 
		local result = nil
		if AI.condition.classic() == true then 
			for i=1,#AI.farm.data.ally[3],1 do
				if AI.farm.data.ally[3][i].dead == false and (result == nil or AI.math.distance(AI.farm.data.ally[3][i],AI.data.enemySpawn) < AI.math.distance(result,AI.data.enemySpawn)) then result = AI.farm.data.ally[3][i] end
			end
		elseif AI.condition.tt() == true then
			for i=1,#AI.farm.data.ally[2],1 do
				if AI.farm.data.ally[2][i].dead == false and (result == nil or AI.math.distance(AI.farm.data.ally[2][i],AI.data.enemySpawn) < AI.math.distance(result,AI.data.enemySpawn)) then result = AI.farm.data.ally[2][i] end
			end
		end
		return result
	end,
	mid = function()
		local result = nil
		if AI.condition.classic() == true then 
			for i=1,#AI.farm.data.ally[2],1 do
				if AI.farm.data.ally[2][i].dead == false and (result == nil or AI.math.distance(AI.farm.data.ally[2][i],AI.data.enemySpawn) < AI.math.distance(result,AI.data.enemySpawn)) then result = AI.farm.data.ally[2][i] end
			end
		elseif AI.condition.pg() == true then
			for i=1,#AI.farm.data.ally[1],1 do
				if AI.farm.data.ally[1][i].dead == false and (result == nil or AI.math.distance(AI.farm.data.ally[1][i],AI.data.enemySpawn) < AI.math.distance(result,AI.data.enemySpawn)) then result = AI.farm.data.ally[1][i] end
			end
		end
		return result
	end,
	data = {ally = {{},{},{}},enemy = {{},{},{}}},
}
AddLoadCallback(function()
		if AI.condition.dom() == true then
			--detect teams
			local ally,enemy = "Blue","Red"
			if myHero.team == TEAM_RED then ally,enemy = "Red","Blue" end
			--fill dominion creeps
			AI.farm.data.ally[1] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,ally) ~= nil end)
			AI.farm.data.enemy[1] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,enemy) ~= nil end)
			--refresh dominion creeps
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,ally) ~= nil end,AI.farm.data.ally[1])
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.sub(obj.name,1,4) == "Odin" and string.find(obj.name,enemy) ~= nil end,AI.farm.data.enemy[1])
		else
			--detect teams
			local ally,enemy = "T100","T200"
			if myHero.team == TEAM_RED then ally,enemy  = "T200","T100" end
			--fill first lane 
			AI.farm.data.ally[1] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally.."L0S") ~= nil end)
			AI.farm.data.enemy[1] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy.."L0S") ~= nil end)
			--refresh first lane
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally.."L0S") ~= nil end,AI.farm.data.ally[1])
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy.."L0S") ~= nil end,AI.farm.data.enemy[1])
			--fill second lane 
			AI.farm.data.ally[2] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally.."L1S") ~= nil end)
			AI.farm.data.enemy[2] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy.."L1S") ~= nil end)
			--refresh second lane
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally.."L1S") ~= nil end,AI.farm.data.ally[2])
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy.."L1S") ~= nil end,AI.farm.data.enemy[2])
			--fill third lane 
			AI.farm.data.ally[3] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally.."L2S") ~= nil end)
			AI.farm.data.enemy[3] = AI.data.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy.."L2S") ~= nil end)
			--refresh third lane
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,ally.."L2S") ~= nil end,AI.farm.data.ally[3])
			AI.data.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,enemy.."L2S") ~= nil end,AI.farm.data.enemy[3])
		end
	end)