require "AIData"
require "AICondition"
require "AIMath"

--[[
AI lib version 3
by Ivan[RUSSIA]

GPL v1 license
		
AI.jungle - lib namespace
	{x,z} nashor() - return nashor pos or nil
	{x,z} dragon() - return dragon pos or nil
	{x,z} red(bool isEnemy = false) - return nearby red buff pos or nil
	{x,z} blue(bool isEnemy = false) - return nearby blue buff pos or nil
	{unit,unit...} monsters({x,z} pos = myHero,float range = 800) - return table of jungle creeps near pos, sorted by max health 
--]]

if AI == nil then AI = {} end
AI.jungle = {
	nashor = function()
		if AI.condition.classic() == true then
			for i = 1,#AI.jungle.data.camp,1 do
				if AI.jungle.data.camp[i].name == "monsterCamp_12" then return AI.jungle.data.camp[i] end
			end
		elseif AI.condition.tt() == true then
			for i = 1,#AI.jungle.data.camp,1 do
				if AI.jungle.data.camp[i].name == "monsterCamp_8" then return AI.jungle.data.camp[i] end
			end
		end
		return nil
	end,
	dragon = function()
		if AI.condition.classic() == true then
			for i = 1,#AI.jungle.data.camp,1 do
				if AI.jungle.data.camp[i].name == "monsterCamp_6" then return AI.jungle.data.camp[i] end
			end
		elseif AI.condition.tt() == true then
			for i = 1,#AI.jungle.data.camp,1 do
				if AI.jungle.data.camp[i].name == "monsterCamp_8" then return AI.jungle.data.camp[i] end
			end
		end
		return nil
	end,
	red = function(isEnemy)
		--set default
		isEnemy = isEnemy or false
		if AI.condition.classic() == true then
			for i = 1,#AI.jungle.data.camp,1 do
				if AI.jungle.data.camp[i].name == "monsterCamp_4" and  ((myHero.team == TEAM_BLUE and isEnemy == false) or (myHero.team ~= TEAM_BLUE and isEnemy == true)) then return AI.jungle.data.camp[i] 
				elseif AI.jungle.data.camp[i].name == "monsterCamp_10" and ((myHero.team == TEAM_RED and isEnemy == false) or (myHero.team ~= TEAM_RED and isEnemy == true))  then return AI.jungle.data.camp[i] end
			end
		end
		return nil
	end,
	blue = function(isEnemy)
		--set default
		isEnemy = isEnemy or false
		if AI.condition.classic() == true then
			for i = 1,#AI.jungle.data.camp,1 do
				if AI.jungle.data.camp[i].name == "monsterCamp_1" and  ((myHero.team == TEAM_BLUE and isEnemy == false) or (myHero.team ~= TEAM_BLUE and isEnemy == true)) then return AI.jungle.data.camp[i] 
				elseif AI.jungle.data.camp[i].name == "monsterCamp_7" and ((myHero.team == TEAM_RED and isEnemy == false) or (myHero.team ~= TEAM_RED and isEnemy == true))  then return AI.jungle.data.camp[i] end
			end
		end
		return nil
	end,
	monsters = function(pos,range)
		--set default
		pos = pos or myHero
		range = range or 800
		--begin
		local result = {}
		--search
		for i=1,#AI.jungle.data.creep,1 do 
			if AI.jungle.data.creep[i].visible == true and AI.math.distance(AI.jungle.data.creep[i],pos) <= range then table.insert(result,AI.jungle.data.creep[i]) end 
		end
		--sort
		table.sort(result,function(a,b) return a.maxHealth > b.maxHealth end)
		return result
	end,
	data = {},
}
--gatherer
AddLoadCallback(function()
		--scan jungle points
		AI.jungle.data.camp = AI.data.scanByName("monsterCamp_")
		--refresh jungle points
		AI.data.hookByName("monsterCamp_",AI.jungle.data.camp)
		--scan jungle creeps function
		local function creep(obj)
			if obj.type ~= "obj_AI_Minion" then return false end
			local name = string.lower(obj.name)
			if string.find(name,"wolf") ~= nil then return true
			elseif string.find(name,"golem") ~= nil then return true
			elseif string.find(name,"lizard") ~= nil then return true
			elseif string.find(name,"wraith") ~= nil then return true
			elseif string.find(name,"dragon") ~= nil then return true
			elseif string.find(name,"worm") ~= nil then return true 
			elseif string.find(name,"spider") ~= nil then return true
			else return false end
		end
		--scan jungle creeps
		AI.jungle.data.creep = AI.data.scanByCondition(creep)
		--refresh jungle creeps
		AI.data.hookByCondition(creep,AI.jungle.data.creep)
	end)
