require "AIData"
require "AIRoutine"
require "AICondition"
require "AIStat"
--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

AIFind - lib namespace
	unit ward({x,y} pos, range = 1100) - return ally ward in range or nil
	
	unit safeTower({x,z} pos) - return tower without enemies on the way to spawn or nil
	unit allyTower({x,z} pos,float range) - return ally tower in range or nil
	unit enemyTower({x,z} pos,float range) - return enemy tower in range or nil
	unit point({x,z} pos, float range,isAlly = false) - return point(dominion) or inhibitor(others) or nil
	
	unit enemyCreep({x,z} pos,float range) - return enemy creep in range or nil
	unit allyCreep({x,z} pos,float range) - return ally creep in range or nil
	
	{unit,unit,...} enemies(table pos,float range) - return array of enemies in pos range
	{unit,unit,...} missingEnemies() - return array of missing enemies
	unit enemy(table pos,float range) - same, but return one the most nearby or nil
	unit weakEnemy(table pos,flaot range) - same, but return the weakest in range or nil
	unit weakPhysicEnemy(table pos,float range,float percentPen = 0,float digitPen = 0) - return weak enemy for physical damage OR nil
	unit physicEnemy(table pos,float range) - return enemy with most physical DPS
	unit weakMagicEnemy(table pos,float range,float percentPen = 0,float digitPen = 0)  - return weak enemy for magical damage OR nil
	unit magicEnemy(table pos,float range) - return enemy with most magic DPS
	{unit,unit,...} gankingEnemies(table pos,float timeline) - return array of missing enemies can gank pos in future timeline 
	
	{unit,unit,...} allies(table pos,float range,bool isRecallIncluded = false,bool isMySelfIncluded = false) -  return allies in range
	unit ally(table pos,float range,bool isRecallIncluded = false,bool isMySelfIncluded = false) - return close ally OR nil
	unit weakAlly(table pos,range,bool isRecallIncluded = false,bool isMySelfIncluded = false) - return ally with least hp OR nil
	unit depletedAlly(table pos,range,bool isRecallIncluded = false,bool isMySelfIncluded = false) - return ally with least mana OR nil
	
	string test() - return description of lib diagnosis
	
--]]

AIFind = {}

AIFind.ward = function(pos,range)
	range = range or 1100
	return AIRoutine.findMatch(AIData.wards,function(this) return this.valid == true and AIRoutine.distance(pos,this) <= range end,function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end

AIFind.safeTower = function(pos)
	return AIRoutine.findMatch(AIData.allyTowers,
		function(this) return this.valid == true and this.health > 450 and AIRoutine.distance(AIData.allySpawn,pos) > AIRoutine.distance(AIData.allySpawn,this) - 200 and AIFind.enemy(this,1000) == nil end,
		function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end

AIFind.allyTower = function(pos,range)
	return AIRoutine.findMatch(AIData.allyTowers,
		function(this) return this.valid == true and this.dead == false and AIRoutine.distance(pos,this) <= range end,
		--check distance
		function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end
	
AIFind.enemyTower = function(pos,range)
	return AIRoutine.findMatch(AIData.enemyTowers,
		function(this) return this.valid == true and this.dead == false and AIRoutine.distance(pos,this) <= range end,
		--check distance
		function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end
		
AIFind.point = function(pos,range,isAlly)
	isAlly = isAlly or false
	return AIRoutine.findMatch(AIData.points,
		function(this) return this.valid == true and AIRoutine.distance(pos,this) <= range and (isAlly == false or this.team == myHero.team)  end,
		--check distance
		function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end

AIFind.allyCreep = function(pos,range)
	return AIRoutine.findMatch(AIData.allyCreeps,
		function(this) return this.visible == true and AIRoutine.distance(pos,this) <= range  end,
		--check distance
		function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end

AIFind.enemyCreep = function(pos,range)
	return AIRoutine.findMatch(AIData.enemyCreeps,
		function(this) return this.visible == true and AIRoutine.distance(pos,this) <= range  end,
		--check distance
		function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end
	
AIFind.enemies = function(pos,range)
	return AIRoutine.findMatches(AIData.enemies,function(this) return this.visible == true and this.dead == false and this.bTargetable == true and AIRoutine.distance(pos,this) <= range end)
end
	
AIFind.missingEnemies = function()
	return AIRoutine.findMatches(AIData.enemies,function(this) return this.visible == false and this.dead == false end)
end
	
AIFind.enemy = function(pos,range)
	return AIRoutine.findMatch(AIData.enemies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true and AIRoutine.distance(pos,this) <= range end,
		--check distance
		function(a,b) return AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end
	
AIFind.weakEnemy = function(pos,range)
	return AIRoutine.findMatch(AIData.enemies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true and AIRoutine.distance(pos,this) <= range end,
		--check least hp
		function(a,b) return a.health < b.health end)
end
	
AIFind.weakPhysicEnemy = function(pos,range,percentPen,digitPen)
	return AIRoutine.findMatch(AIData.enemies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true and AIRoutine.distance(pos,this) <= range end,
		--check least armor hp
		function(a,b) return a.health * (2 - AIStat.physicTaken(a,percentPen,digitPen)) < b.health * (2 - AIStat.physicTaken(b,percentPen,digitPen)) end)
end
	
AIFind.physicEnemy = function(pos,range)
	return AIRoutine.findMatch(AIData.enemies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true and AIRoutine.distance(pos,this) <= range end,
		--check best damage				 ADCaster                               ADCarry                                                                         ADCaster                           ADCarry
		function(a,b) return math.max(a.totalDamage * ( 1 - a.cdr),a.totalDamage * a.attackSpeed) > math.max(b.totalDamage * ( 1 - b.cdr),b.totalDamage * b.attackSpeed) end)
end	

AIFind.weakMagicEnemy = function(pos,range,percentPen,digitPen)
	return AIRoutine.findMatch(AIData.enemies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true and AIRoutine.distance(pos,this) <= range end,
		--check least mres hp
		function(a,b) return a.health * (2 - AIStat.magicTaken(a,percentPen,digitPen)) < b.health * (2 - AIStat.magicTaken(b,percentPen,digitPen)) end)
end

AIFind.magicEnemy = function(pos,range)
	return AIRoutine.findMatch(AIData.enemies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true and AIRoutine.distance(pos,this) <= range end,
		--check best ap
		function(a,b) return a.ap * ( 1 - a.cdr) > b.ap * ( 1 - b.cdr) end)
end
		
AIFind.gankingEnemies = function(pos,timeline)
	return AIRoutine.findMatches(AIData.enemies,
		function(this) return this.visible == false and 
					--check enemy could recall to spawn already
					(AIRoutine.distance(AIData.enemySpawn,pos) - 500 < (AIStat.miss(this) - 9 + timeline) * this.ms
					--check enemy could run to you
					or AIRoutine.distance(pos,this) - 500 < (AIStat.miss(this) + timeline) * this.ms) end)
end

AIFind.allies = function(pos,range,isRecallIncluded,isMySelfIncluded)
	return AIRoutine.findMatches(AIData.allies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true 
					--check range 
					and AIRoutine.distance(pos,this) <= range 
					--check yourself
					and (isMySelfIncluded == true or this.networkID ~= myHero.networkID) 
					--check recalling dudes
					and (isRecallIncluded == true or AICondition.recall(this) == false) end)
end
	
AIFind.ally = function(pos,range,isRecallIncluded,isMySelfIncluded)
	return AIRoutine.findMatch(AIData.allies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true 
					--check range 
					and AIRoutine.distance(pos,this) <= range 
					--check yourself
					and (isMySelfIncluded == true or this.networkID ~= myHero.networkID) 
					--check recalling dudes
					and (isRecallIncluded == true or AICondition.recall(this) == false) end,
		function(a,b) return  AIRoutine.distance(pos,a) < AIRoutine.distance(pos,b) end)
end
	
AIFind.weakAlly = function(pos,range,isRecallIncluded,isMySelfIncluded)
	return AIRoutine.findMatch(AIData.allies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true 
					--check range 
					and AIRoutine.distance(pos,this) <= range 
					--check yourself
					and (isMySelfIncluded == true or this.networkID ~= myHero.networkID) 
					--check recalling dudes
					and (isRecallIncluded == true or AICondition.recall(this) == false) end,
					--check hp
		function(a,b) return a.health/math.min(a.maxHealth,145*a.level) < b.health/math.min(b.maxHealth,145*b.level) end)
end
	
AIFind.depletedAlly = function(pos,range,isRecallIncluded,isMySelfIncluded)
	return AIRoutine.findMatch(AIData.allies,
		function(this) return this.visible == true and this.dead == false and this.bTargetable == true 
					--check range 
					and AIRoutine.distance(pos,this) <= range 
					--check manaless
					and AICondition.manaLess(this) == false
					--check yourself
					and (isMySelfIncluded == true or this.networkID ~= myHero.networkID) 
					--check recalling dudes
					and (isRecallIncluded == true or AICondition.recall(this) == false) end,
					--check mp
		function(a,b) return a.mana/math.min(a.maxMana,75*a.level) < b.mana/math.min(b.maxMana,75*b.level) end)
end

AIFind.test = function()
	if #AIData.wards ~= 0 and AIFind.ward(myHero,math.huge) == nil then return "AIFind.ward failed"
	elseif GetGameTimer() < 600 and #AIData.allyTowers ~= 0 and AIFind.allyTower(myHero,math.huge) == nil then return "AIFind.allyTower failed"
	elseif GetGameTimer() < 600 and #AIData.enemyTowers ~= 0 and AIFind.enemyTower(myHero,math.huge) == nil then return "AIFind.allyTower failed"
	elseif myHero.dead == false and AIFind.ally(myHero,50,true,true) == nil then return "AIFind.ally failed" 
	else return "OK" end
end
