require "AICondition"
require "AIData"
require "AITimer"
require "AISpell"
--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

dev comment - AIStat is not 100% reliable source 

AIStat - lib namespace
	float magicTaken(unit unit,float percentPen = 0,float digitPen = 0) - return % of magic damage taken. 0 to 2
	float physicTaken(unit unit,float percentPen = 0,float digitPen = 0)  - return % of physic damage taken. 0 to 2
	float miss(unit enemy) - return time of 'miss'
	float afk(unit ally) - return time of afk at base
	float hps(unit unit) - return HPS of unit(kinda recount), first second return ~ZERO
	float aaDps(unit unit) - return aa damage per second
	float heal(unit unit,float amount) - return amount of heal, unit gonna recieve from AMOUNT of heal
	float gold(unit unit) - return amount of gold in stats
	string role(unit unit) - return Hybrid/AD/AP/Support
	float elo(unit unit,float creepScore = unit.creepScore) - return amount of unit's elo. 2/2/2013 default value does not work
	float pvp(table allies,table enemies,table gankingEnemies = {}) - return pvp chanses, from 0 to 1
	
	string test() - return library diagnosis description
--]]

AIStat = {}
local dataMiss = nil
local dataAfk = {}
local dataHps = {}

AIStat.physicTaken = function(unit,procentPen,digitPen)
	digitPen = digitPen or 0 
	procentPen = procentPen or 0
	if unit.armor - unit.armor * procentPen - digitPen < 0 then return (2 - 100 / (100 - unit.armor - unit.armor * procentPen - digitPen))
	else return (100 / (100 + unit.armor - unit.armor * procentPen - digitPen)) end
end
	
AIStat.magicTaken = function(unit,procentPen,digitPen)
	digitPen = digitPen or 0 
	procentPen = procentPen or 0
	if unit.magicArmor - unit.magicArmor * procentPen - digitPen < 0 then return (2 - 100 / (100 - unit.magicArmor - unit.magicArmor * procentPen - digitPen))
	else return (100 / (100 + unit.magicArmor - unit.magicArmor * procentPen - digitPen)) end
end
	
AIStat.heal = function(target,amount)
	local amplifier = 1
	--check for increasing heal item
	if AISpell.item(target,3065) ~= nil then amplifier = amplifier + 0.2 end
	--check for ignite
	if AICondition.ignite(target) == true then amplifier = amplifier/2 end
	--calc
	if target.maxHealth - target.health >= amount * amplifier then return amount * amplifier
	else return target.maxHealth - target.health end
end

AIStat.aaDps = function(unit)
	return unit.damage * unit.attackSpeed * (1 + ( unit.critChance/100 * (unit.critDmg/100 - 1)))
end
	
AIStat.gold = function(unit)
	local result = 0
	--ad
	result = result + unit.damage * 34.4
	--attack speed
	result = result + (unit.attackSpeed - 1) * 100 * 31.6
	--crit
	result = result + (unit.critChance * 100) * 48.6
	--cdr
	result = result + (-unit.cdr * 100) * 77
	--hp
	result = result +  (unit.health - unit.maxHealth) *  2.63
	--hpregen
	result = result + unit.hpRegen * 5 * 36
	--ap
	result = result + unit.ap  * 20
	--armor & mr
	result = result + (unit.armor + unit.magicArmor) * 18
	--lifesteel
	result = result + (unit.lifeSteal) * 80
	--spellvamp
	result = result + (unit.spellVamp) * 100
	--mana
	if AICondition.manaLess(unit) == false then result = result + (unit.mana - unit.maxMana)* 2 else result = result + unit.level * 70 end
	--mana regen
	if AICondition.manaLess(unit) == false then result = result + unit.mpRegen * 5 * 60 else result = result + 300 end
	--movespeed
	result = result + (unit.ms - 325) * 14
	return result
end

AIStat.hps = function(unit)
	local key = unit.networkID
	--begin calc hps
	if dataHps[key] == nil then
		dataHps[key] = {}
		--second six
		dataHps[key][1],dataHps[key][2] = unit.health,unit.health
		--second five
		dataHps[key][3],dataHps[key][4] = unit.health,unit.health
		--second four
		dataHps[key][5],dataHps[key][6] = unit.health,unit.health
		--second three
		dataHps[key][7],dataHps[key][8] = unit.health,unit.health
		--second two
		dataHps[key][9],dataHps[key][10] = unit.health,unit.health
		--second zero
		dataHps[key][11],dataHps[key][12] = unit.health,unit.health
		--settings
		AITimer.add(0.5,function(timerID)
				--check target dead
				if unit.valid == false or unit.dead == true then 
					--remove hps refresher
					AITimer.remove(timerID)
					dataHps[key] = nil
				else
					--add health
					table.remove(dataHps[key],1)
					dataHps[key][12] = unit.health 
				end
			end)
	end
	--calc hps with diminishing
	local result = 0
	for i = 1,#dataHps[key],1 do result = result + dataHps[key][i] end
	return dataHps[key][12] - (result / 12) 
end

AIStat.miss = function(enemy)
	--get time
	local time = os.clock()
	--check initiation
	if dataMiss == nil then
		--init
		dataMiss = {}
		--refresh
		for i=1,#AIData.enemies,1 do
			if AIData.enemies[i].dead == false and AIData.enemies[i].visible == false then dataMiss[AIData.enemies[i].networkID] = time end
		end
		--refresh timer
		AITimer.add(1,function() 
				for i=1,#AIData.enemies,1 do
					if dataMiss[AIData.enemies[i].networkID] == nil and AIData.enemies[i].dead == false and AIData.enemies[i].visible == false then dataMiss[AIData.enemies[i].networkID] = os.clock()
					elseif dataMiss[AIData.enemies[i].networkID] ~= nil and (AIData.enemies[i].dead == true or AIData.enemies[i].visible == true) then dataMiss[AIData.enemies[i].networkID] = nil end
				end
			end)
	end
	--calc
	if dataMiss[enemy.networkID] == nil then return 0
	else return time - dataMiss[enemy.networkID] end
end
	
AIStat.afk = function(ally)
	--check initiation
	if dataAfk[ally.networkID] == nil then
		--init
		if ally:GetDistance(AIData.allySpawn) <= 600 then dataAfk[ally.networkID] = os.clock()
		else dataAfk[ally.networkID] = false end
		--refresh timer
		AITimer.add(10,function() 
				if ally:GetDistance(AIData.allySpawn) <= 600 then 
					if dataAfk[ally.networkID] == false then dataAfk[ally.networkID] = os.clock() end
				else dataAfk[ally.networkID] = false end
			end)
	end
	if dataAfk[ally.networkID] == false then return 0
	else return os.clock() - dataAfk[ally.networkID] end
end

AIStat.role = function(unit)
	--check is support
	if unit.ap + unit.addDamage * 1.7 < 12.5 + 4 * unit.level then return "Support"
	--check is mage
	elseif unit.ap/(math.max(unit.addDamage,1) * 1.7) > 1.5 then return "AP"
	--it  is ad
	elseif unit.ap/(math.max(unit.addDamage,1) * 1.7) < 0.5 then return "AD"
	--it is hybrid
	else return "Hybrid" end
end
	
AIStat.pvp = function(allies,enemies,gankingEnemies)
	--check ganking enemies
	gankingEnemies = gankingEnemies or {}
	local result = 0.5
	--calc gold
	local allyGold = 0
	local enemyGold = 0
	for i = 1, #allies,1 do allyGold = allyGold + AIStat.gold(allies[i]) * allies[i].health/allies[i].maxHealth end
	for i = 1, #enemies,1 do enemyGold = enemyGold + AIStat.gold(enemies[i]) * enemies[i].health/enemies[i].maxHealth end
	for i = 1, #gankingEnemies,1 do enemyGold = enemyGold + AIStat.gold(gankingEnemies[i]) * 0.75 end
	result = result * allyGold/enemyGold
	--check levels
	local allyLevels = 0
	local enemyLevels = 0
	for i = 1, #allies,1 do allyLevels = allyLevels + allies[i].level end
	for i = 1, #enemies,1 do enemyLevels = enemyLevels + enemies[i].level end
	for i = 1, #gankingEnemies,1 do enemyLevels = enemyLevels + gankingEnemies[i].level * 0.75 end
	result = result + (allyLevels - enemyLevels) * 0.075
	--fix chanses to 0%...100%
	result = math.max(math.min(result,1),0)
	return result
end

AIStat.test = function()
	if myHero.armor > 100 and AIStat.physicTaken(myHero) > 0.55 then return "AIStat.physicTaken failed"
	elseif myHero.magicArmor < 50 and AIStat.physicTaken(myHero) < 0.6 then return "AIStat.magicTaken failed"
	elseif AIStat.gold(myHero) < 800 then return "AIStat.gold failed"
	elseif AIStat.pvp({myHero},{}) ~= 1 then return "AIStat.pvp failed"
	else return "OK" end
end
