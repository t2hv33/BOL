--[[
ivanAI lib version 1

+Hello to zynox
+Leveling spells by GrEy

FAQ
-WTF is it?
	Its created for AI scripts based on actions and conditions and utility functions
-How it is licensed?
	under GPL
-What is pos?
	container with defined x,z
-How to convert degree to radians?
	float math.rad(deg)
-What is unit?
	container returned by heroManager
-How to start brain?
	1. add actions
	2. add actions' next actions
	3. add conditions to actions
	4. set starting action with ivahAI.brain.setActive(handle)
	5. turn on by ivanAI.brain.setEnabled(true)
-How brain work?
	1. Before every action execution, brain check conditions, if condition return true, condition's next action executed
	2. After conditions checked, action executed
	3. After action return true, next action executed

documentation:

table ivanAI - lib namespace
+	table lua - function container used to extend lua 
+		train unpack(container) - return container values
+		string freeKey(container) - return nonexistent key for container
+	table timer - function container used to make actions per large time
+		handle add(isOneTime,cooldown,callback) - add timer, callback will be called after ~cooldown time elapse, callback should be function(handle)
+		void remove(handle) - remove timer
+	table math - function containers used to 2d paths/position
+		{x,z} normalized(pos1,pos2) - function return normalized vector based on degree of these two points
+		float rad(pos1,pos2) - function return radian of points based on .Z axis of pos1
+		float distance(pos1,pos2) - function return distance
+		{x,z} pos(pos,rad,range) - function return pos in radian and range of other pos
+		{x,z} project(linePos1,linePos2,dotPos) - return dot perpendicular falled to line[linePos1->linePos2], if dot cant fall undefined 
+		float greenToRed(coef) - return RGB float of green-red gradient, coef is 0...1(0 = red, 0.5 = yellow,1 = green)
+	table stat - function container used to calc stats, in ideal
+		string role(unit) return Hybrid/AD/AP/Support
+		float spawnDistance(pos) - return unit to ally base distance 
+		float spawnDistance(pos,isAlly) - return unit to ally/enemy base distance 
+		float heal(unit,amount) - return amount of heal, unit gonna recieve from AMOUNT of heal
+		float magicTaken(unit) - return % of magic damage taken
+		float magicTaken(unit,procentPen,digitPen) - return % of magic damage taken, with params
+		float physicTaken(unit) - return % of physic damage taken
+		float physicTaken(unit,procentPen,digitPen)  - return % of physic damage taken, with params
+		float gold(unit) - return amount of gold in stats
+		float aaDps(unit) - return aa damage per second
+		float pvp(allies,enemies) - return pvp chanses, from 0 to 1
+		float pvp(allies,enemies,gankingEnemies) - return pvp chanses, from 0 to 1
+	table object - function container used to collect created objects
+		handle hookByName(name,container) - type(container)==table,all objects with this name inserted to container by lib,WARNING container will be cleared out of DELETED OBJECTS BY LIB
+		{obj,obj,...} scanByName(name) - return objects found by name
+		handle hookByType(type,container) - type(container)==table,all objects with this type inserted to container by lib,WARNING container will be cleared out of DELETED OBJECTS BY LIB
+		{obj,obj,...} scanByType(type) - return objects found by type
+		handle hookByPattern(pattern,container) - type(container)==table,all objects with this pattern in name inserted to container by lib,WARNING container will be cleared out of DELETED OBJECTS BY LIB
+		{obj,obj,...} scanByPattern(pattern) - return objects found by pattern
+		handle hookByCondition(condition,container) - type(condition)==function(obj) returning true in case object is required
+		{obj,obj,...} scanByCondition(condition) - type(condition)==function(obj) returning true in case object is required
+		void remove(handle) - stop managing object
+	table find - function container used to find objects ai needs
+		{x,y} minimap() - return minimap position in coef 0...1
+		{buff,buff,...} buffs(unit) - return unit buffs in table
+		unit safeTower(pos) - return safe tower near or nil, undefined in Dominion
+		unit enemyTower(pos,range) - return enemy tower in range or nil
+		{unit,unit,...} enemies(pos,range) - return array of enemies in pos range
+		unit enemy(pos,range) - same, but return one the most nearby or nil
+		unit weakEnemy(pos,range) - same, but return the weakest in range or nil
+		{unit,unit,...} allies(pos,range,isRecallIncluded = false,isMySelfIncluded = false) -  return allies in range
+		unit ally(pos,range,isRecallIncluded = false,isMySelfIncluded = false) - return close ally
+		unit weakAlly(pos,range,isRecallIncluded = false,isMySelfIncluded = false) - return ally with least hp
+		unit depletedAlly(pos,range,isRecallIncluded = false,isMySelfIncluded = false) - return ally with least mana
+		{unit,unit,...} gankingEnemies(pos,timeline) - return array of missing enemies can gank pos in future timeline 
+		{unit,unit,...} missingEnemies() - return array of missing enemies
+	table item
+		iSpell slot(unit,itemID) - return itemslot of itemID of unit OR nil
+		void buy(items) - buying items 1by1,skips already bought items and child items, items = {{itemID1,{parentID1,parentID2}},{itemID2,{parentID1}}...etc}, HOWTO: use several times,while in shop
+	table condition - table of usefull checks
+		bool isAtEnemySide(unit) - check is unit at enemy's side of map
+		bool isTarget(unit) - check can unit be target
+		bool isBehind(unit,target) - check is unit behind target
+		bool isAtSpawn(unit) - check distance to spawn
+		bool isRecallFaster(pos,ms) - check is faster run to spawn then recall at pos
+		bool isWarded(pos,range) - check is point ally-warded
+		bool isRecall(unit) - check is recalling
+		bool isManaLess(unit) - check energy/mana
+		bool isLowHP(unit,lowPercent) - check low hp%
+		bool isLowMP(unit,lowPercent) - check low mp%, return false on energy users
+		bool isLow(unit,lowPercent) - check low hp and mp
+		bool isMissing(enemy) - check is enemy SS
+		bool isBuffed(unit,buff) - check is unit buffed, type(buff) == string
+		bool isAFK = function(allyUnit) - check is ally at spawn for 2.5 minutes already
+	table action - return true in completed case
+		bool spawn() - your char goes to spawn
+		bool river() - your char goes to river, river defined only at Classic map
+		bool allySide() - your char goes to ally side of map, defined only at Classic map
+		bool move(pos) - your char moves to pos
+		bool recall() - your char recalls
+		bool behind(unit,range) - your char goes to behind unit
+		bool holdBehind(unit,range) - your char hold itself behind unit, without attacking
+		bool level(spells) - levels spells, type(spells)==table, example #{_Q,_W,_Q,_E,_W,_R,...} == 18
+		bool ward(pos) - your char wards at pos
+		bool regen() - your char waits regen
+	table draw - function container used to draw some usefull things,x y are proportions from 0 to 1
+		handle text(text,x,y,ARGB = YELLOW)
+		handle list({text1,text2,text3},x,y,ARGB = YELLOW)
+		handle box(x,y,width,height,ARGB = BROWN)
+		handle line(x1,y1,x2,y2,ARGB = YELLOW)
+		void timeline(handle,timeline) - after timeline handle will fade
+		void remove(handle) - removing handle from screen
+	table print - function container used to print usefull things to BoL-only user's chat
+		unit(unit) - unit stats
+		buffs(unit) - unit buffs
+	table brain - minibrain for AI,
+		handle addAction(action) - (type(action)==table of functions without params returning boolean or nil) or type(action)==function without params returning boolean or nil
+		void setActive(handle) - set action to be executed by brain next iteration
+		void setNext(handle,nextHandle) - set next action after previous complete
+		void setCondition(handle,condition,nextHandle) - type(condition)==function without params returning boolean or type(condition)==boolean
+		void setEnabled(check,pause = 0.2) - turn on/off your brain, with pause time between decisions
+		void reset() - reset brain to child state
+	table data - DO NOT EDIT, information container updated by ivanAI.forward
+		table brain -  ai related table
+		table missingEnemies - here placed enemies by their #, containing time missing
+ 		table afk - here placed allies on spawn by their #, containing time on spawn
+		table wards - here placed wards
+		table allies,enemies,allyTowers,enemyTowers - here are units	
+		table draw - here are drawing info saved
+	table forward - DO NOT TOUCH,container to BoL callbacks, used to update info
+		void OnCreateObj(object) - refresh objects info
+		void OnDeleteObj(object) - refresh objects info
+		void OnLoad() - update players, towers, wards array, missing enemies
+		void OnTick() - timer feature
--]]
-------------------BEGIN
ivanAI = {}
-------------------LUA EXTEND FUNCTION
ivanAI.lua = {
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
-------------------TIMER
ivanAI.timer = {
	add = function(isOneTime,cooldown,callback)
		local key = ivanAI.lua.freeKey(ivanAI.data.timers)
		ivanAI.data.timers[key] = {}
		ivanAI.data.timers[key].callback = callback
		ivanAI.data.timers[key].isOneTime = isOneTime
		ivanAI.data.timers[key].cooldown = cooldown
		ivanAI.data.timers[key].lastcall = GetGameTimer()
		return key
	end,
	remove = function(handle)
		if handle ~= nil then ivanAI.data.timers[handle] = nil end
	end
}
-------------------MATH,2D FUNCTIONS
ivanAI.math = {
	normalized = function(pos1,pos2)
		local rad = ivanAI.math.rad(pos1,pos2)
		return {x = math.sin(rad),z = math.cos(rad)}
	end,
	rad = function(pos1,pos2)
		local a = ivanAI.math.distance({x=pos1.x,z=pos2.z},{x=pos2.x,z=pos2.z})
		local b = ivanAI.math.distance({x=pos1.x,z=pos1.z},{x=pos1.x,z=pos2.z})
		local c = ivanAI.math.distance({x=pos1.x,z=pos1.z},{x=pos2.x,z=pos2.z})
		if pos2.z > pos1.z then
			if pos1.x < pos2.x then return math.acos(b/c)
			else return 6.283185307 - math.acos(b/c) end
		else 
			if pos1.x < pos2.x then return 1.570796327 + math.acos(a/c)
			else return 4.712388980 - math.acos(a/c) end
		end
	end,
	pos = function(pos,rad,range)
		return {x = pos.x + math.sin(rad) * range, z = pos.z + math.cos(rad) * range}
	end,
	distance = function(pos1,pos2)
		return math.sqrt((pos1.x-pos2.x)^2+(pos1.z-pos2.z)^2)
	end,
	greenToRed = function(coef)
		return RGB(255*(1-coef),255*coef,0)
	end,
	project = function(linePos1,linePos2,dotPos)
		local dotRad = ivanAI.math.rad(linePos1,dotPos)
		local lineRad = ivanAI.math.rad(linePos1,linePos2)
		local distance = math.cos(lineRad - dotRad) *  ivanAI.math.distance(linePos1,dotPos)
		return ivanAI.math.pos(linePos1,lineRad,distance)
	end,
}
-------------------STATS FUNCTIONS BASED ON IDEAL SITUATIONS
ivanAI.stat = {
	spawnDistance = function(pos,isAlly)
		if isAlly == nil  or isAlly == true then return ivanAI.math.distance(pos,ivanAI.data.allySpawn)
		else return ivanAI.math.distance(pos,ivanAI.data.enemySpawn) end
	end,
	physicTaken = function(unit,procentPen,digitPen)
		if digitPen == nil then digitPen = 0 procentPen = 0 end
		if unit.armor - unit.armor * procentPen - digitPen < 0 then return (2 - 100 / (100 - unit.armor - unit.armor * procentPen - digitPen))
		else return (100 / (100 + unit.armor - unit.armor * procentPen - digitPen)) end
	end,
	magicTaken = function(unit,procentPen,digitPen)
		if digitPen == nil then digitPen = 0 procentPen = 0 end
		if unit.magicArmor - unit.magicArmor * procentPen - digitPen < 0 then return (2 - 100 / (100 - unit.magicArmor - unit.magicArmor * procentPen - digitPen))
		else return (100 / (100 + unit.magicArmor - unit.magicArmor * procentPen - digitPen)) end
	end,
	heal = function(target,amount)
		local amplifier = 1
		--check for increasing heal item
		if ivanAI.item.slot(target,3065) ~= nil then amplifier = amplifier + 0.2 end
		--check for ignite
		if ivanAI.condition.isBuffed(target,"Grievous Wounds") == true then amplifier = amplifier/2 end
		--calc
		if target.maxHealth - target.health >= amount * amplifier then return amount * amplifier
		else return target.maxHealth - target.health end
	end,	
	role = function(unit)
		--check is support
		if unit.ap + unit.addDamage * 1.7 < 12.5 + 4 * unit.level then return "Support"
		--check is mage
		elseif unit.ap/(math.max(unit.addDamage,1) * 1.7) > 1.5 then return "AP"
		--it  is ad
		elseif unit.ap/(math.max(unit.addDamage,1) * 1.7) < 0.5 then return "AD"
		--it is hybrid
		else return "Hybrid" end
	end,
	gold = function(unit)
		local result = 0
		--ad
		result = result + unit.damage * 34
		--attack speed
		result = result + (unit.attackSpeed - 1) * 100 * 11.6
		--crit
		result = result + (unit.critChance * 100) * 48.6
		--cdr
		result = result + (-unit.cdr * 100) * 85
		--hp
		result = result +  (unit.health - unit.maxHealth) *  2.5
		--hpregen
		result = result + unit.hpRegen * 5 * 36
		--ap
		result = result + unit.ap  * 20
		--armor & mr
		result = result + (unit.armor + unit.magicArmor) * 18
		--lifesteel
		result = result + (unit.lifeSteal) * 80
		--spellvamp
		result = result + (unit.spellVamp) * 70
		--mana
		if ivanAI.condition.isManaLess(unit) == false then result = result + (unit.mana - unit.maxMana)* 2 else result = result + unit.level * 70 end
		--mana regen
		if ivanAI.condition.isManaLess(unit) == false then result = result + unit.mpRegen * 5 * 60 else result = result + 300 end
		--movespeed
		result = result + (unit.ms - 325) * 14
		return result
	end,
	aaDps = function(unit)
		return unit.damage * unit.attackSpeed * (1 + ( unit.critChance/100 * (unit.critDmg/100 - 1)))
	end,
	pvp = function(allies,enemies,gankingEnemies)
		--check gankign enemies
		if gankingEnemies == nil then gankingEnemies = {} end
		local result = 0.5
		--calc gold
		local allyGold = 0
		local enemyGold = 0
		for i = 1, #allies,1 do allyGold = allyGold + ivanAI.stat.gold(allies[i]) * allies[i].health/allies[i].maxHealth end
		for i = 1, #enemies,1 do enemyGold = enemyGold + ivanAI.stat.gold(enemies[i]) * enemies[i].health/enemies[i].maxHealth end
		for i = 1, #gankingEnemies,1 do enemyGold = enemyGold + ivanAI.stat.gold(gankingEnemies[i]) * 0.75 end
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
	end,
}
-------------------OBJECT COLLECTOR
ivanAI.object = {
	scanByName = function(name)
		local result = {}
		for i = 1, objManager.maxObjects, 1 do
			local object = objManager:getObject(i)
			if object ~=nil and object.valid == true and object.name == name then table.insert(result,object) end
		end
		return result
	end,
	scanByType = function(objType)
		local result = {}
		for i = 1, objManager.maxObjects, 1 do
			local object = objManager:getObject(i)
			if object ~=nil and object.valid == true and object.type == objType then table.insert(result,object) end
		end
		return result
	end,
	scanByPattern = function(pattern)
		local result = {}
		for i = 1, objManager.maxObjects, 1 do
			local object = objManager:getObject(i)
			if object ~=nil and object.valid == true and string.find(object.name,pattern) ~= nil then table.insert(result,object) end
		end
		return result
	end,
	scanByCondition = function(condition)
		local result = {}
		for i = 1, objManager.maxObjects, 1 do
			local object = objManager:getObject(i)
			if object ~=nil and object.valid == true and condition(object) == true then table.insert(result,object) end
		end
		return result
	end,
	hookByName = function(name,container)
		local key = ivanAI.lua.freeKey(ivanAI.data.objects)
		ivanAI.data.objects[key] = {}
		ivanAI.data.objects[key].container = container
		ivanAI.data.objects[key].validate = function(obj) return obj.name == name end
		return key
	end,
	hookByType = function(objType,container)
		local key = ivanAI.lua.freeKey(ivanAI.data.objects)
		ivanAI.data.objects[key] = {}
		ivanAI.data.objects[key].container = container
		ivanAI.data.objects[key].validate = function(obj) return obj.type == objType end
		return key
	end,
	hookByPattern = function(pattern,container)
		local key = ivanAI.lua.freeKey(ivanAI.data.objects)
		ivanAI.data.objects[key] = {}
		ivanAI.data.objects[key].container = container
		ivanAI.data.objects[key].validate = function(obj) return string.find(obj.name,pattern) ~= nil end
		return key
	end,
	hookByCondition = function(condition,container)
		local key = ivanAI.lua.freeKey(ivanAI.data.objects)
		ivanAI.data.objects[key] = {}
		ivanAI.data.objects[key].container = container
		ivanAI.data.objects[key].validate = condition
		return key
	end,
	remove = function(handle)
		ivanAI.data.objects[handle] = nil
	end
}
-------------------FIND OBJECTS FUNCTION
ivanAI.find = {
	miniMap = function()
		return {x = 0.7085 + WINDOW_W/WINDOW_H * 0.1, y = 0.79}
	end,
	buffs = function(unit)
		local result = {}
		for i = 1, unit.buffCount,1 do
			local buff = unit:getBuff(i)
			if buff.valid == true then table.insert(result,buff) end
		end
		return result
	end,
	safeTower = function(pos)
		local spawnDistance = ivanAI.math.distance(pos,ivanAI.data.allySpawn)
		local result = nil
		--check towers
		for i=1,#ivanAI.data.allyTowers,1 do
			--check valid  object
			if ivanAI.condition.isTarget(ivanAI.data.allyTowers[i]) == true
			--check hp
			and ivanAI.data.allyTowers[i].health/ivanAI.data.allyTowers[i].maxHealth > 0.1 
			--check enemies
			and ivanAI.find.enemy(ivanAI.data.allyTowers[i],1000) == nil
			--check is this tower on the way to spawn
			and ivanAI.math.distance(ivanAI.data.allyTowers[i],ivanAI.data.allySpawn) < spawnDistance + 500
			--check is it best distance tower
			and (result == nil or  ivanAI.math.distance(pos,ivanAI.data.allyTowers[i]) <  ivanAI.math.distance(pos,result)) then
				result = ivanAI.data.allyTowers[i]
			end
		end
		return result
	end,
	enemyTower = function(pos,range)
		local result = nil
		--check towers
		for i=1,#ivanAI.data.enemyTowers,1 do
			--check valid  object
			if ivanAI.data.enemyTowers[i].valid == true
			--check is it best distance tower
			and ((result == nil and ivanAI.math.distance(pos,ivanAI.data.enemyTowers[i]) < range) or  (ivanAI.math.distance(pos,ivanAI.data.enemyTowers[i]) < ivanAI.math.distance(pos,result))) then
				result = ivanAI.data.enemyTowers[i]
			end
		end
		return result
	end,
	enemies = function(pos,range)
		local result = {}
		for i = 1,#ivanAI.data.enemies,1 do
			if ivanAI.condition.isTarget(ivanAI.data.enemies[i]) then
				if ivanAI.math.distance(ivanAI.data.enemies[i],pos) <= range then table.insert(result,ivanAI.data.enemies[i]) end
			end
		end
		return result
	end,
	enemy = function(pos,range)
		local result = nil
		for i = 1,#ivanAI.data.enemies,1 do
			if  ivanAI.condition.isTarget(ivanAI.data.enemies[i]) and ivanAI.math.distance(ivanAI.data.enemies[i],pos) <= range then
				if result == nil or ivanAI.math.distance(ivanAI.data.enemies[i],pos) < ivanAI.math.distance(result,pos) then result = ivanAI.data.enemies[i] end
			end
		end
		return result
	end,
	weakEnemy = function(pos,range)
		local result = nil
		for i = 1,#ivanAI.data.enemies,1 do
			--check valid
			if ivanAI.condition.isTarget(ivanAI.data.enemies[i])
			--check distance
			and ivanAI.math.distance(ivanAI.data.enemies[i],pos) <= range 
			--check hp
			and (result == nil or ivanAI.data.enemies[i].health < result.health)
			then result = ivanAI.data.enemies[i] end
		end
		return result
	end,
	allies = function(pos,range,isRecallIncluded,isMySelfIncluded)
		local result = {}
		--search through allies
		for i = 1,#ivanAI.data.allies,1 do
			--check valid
			if ivanAI.condition.isTarget(ivanAI.data.allies[i])
			--check myself
			and (ivanAI.data.allies[i].name ~= myHero.name or isMySelfIncluded == true)
			--check recall
			and (isRecallIncluded == true or ivanAI.condition.isRecall(ivanAI.data.allies[i]) == false)
			--check distance
			and ivanAI.math.distance(ivanAI.data.allies[i],pos) <= range 
			then table.insert(result,ivanAI.data.allies[i]) end
		end
		return result
	end,
	ally = function(pos,range,isRecallIncluded,isMySelfIncluded)
		local result = nil
		--search through allies
		for i = 1,#ivanAI.data.allies,1 do
			--check valid
			if ivanAI.condition.isTarget(ivanAI.data.allies[i])
			--check mySelf
			and (ivanAI.data.allies[i].name ~= myHero.name or isMySelfIncluded == true)
			--check recall
			and (isRecallIncluded == true or ivanAI.condition.isRecall(ivanAI.data.allies[i]) == false)
			--check distance
			and ivanAI.math.distance(ivanAI.data.allies[i],pos) <= range and  (result == nil or ivanAI.math.distance(ivanAI.data.allies[i],pos) < ivanAI.math.distance(result,pos)) 
			then result = ivanAI.data.allies[i] end
		end
		return result
	end,
	weakAlly = function(pos,range,isRecallIncluded,isMySelfIncluded)
		local result = nil
		--search through allies
		for i = 1,#ivanAI.data.allies,1 do
			--check valid
			if ivanAI.condition.isTarget(ivanAI.data.allies[i])
			--check mySelf
			and (ivanAI.data.allies[i].name ~= myHero.name or isMySelfIncluded == true)
			--check recall
			and (isRecallIncluded == true or ivanAI.condition.isRecall(ivanAI.data.allies[i]) == false)
			--check distance
			and ivanAI.math.distance(ivanAI.data.allies[i],pos) <= range
			--check hp
			and (result == nil or ivanAI.data.allies[i].health < result.health)
			then result = ivanAI.data.allies[i] end
		end
		return result
	end,
	depletedAlly = function(pos,range,isRecallIncluded,isMySelfIncluded)
		local result = nil
		--search through allies
		for i = 1,#ivanAI.data.allies,1 do
			--check valid
			if ivanAI.condition.isTarget(ivanAI.data.allies[i])
			--check mySelf
			and (ivanAI.data.allies[i].name ~= myHero.name or isMySelfIncluded == true)
			--check recall
			and (isRecallIncluded == true or ivanAI.condition.isRecall(ivanAI.data.allies[i]) == false)
			--check distance
			and ivanAI.math.distance(ivanAI.data.allies[i],pos) <= range
			--check mana
			and ivanAI.condition.isManaLess(ivanAI.data.allies[i]) == false and (result == nil or ivanAI.data.allies[i].mana < result.mana)
			then result = ivanAI.data.allies[i] end
		end
		return result
	end,
	gankingEnemies = function(pos,timeline)
		local result = {}
		--search through missing enemies
		for i = 1,#ivanAI.data.enemies,1 do
			if ivanAI.data.missingEnemies[i] ~= nil then 
				--check spawn way
				if ivanAI.math.distance(ivanAI.data.enemySpawn,pos) * 1.1 - 500 < (GetGameTimer() - ivanAI.data.missingEnemies[i] - 9 + timeline) * ivanAI.data.enemies[i].ms then table.insert(result,ivanAI.data.enemies[i])
				--check last position
				elseif ivanAI.math.distance(ivanAI.data.enemies[i],pos) * 1.1 - 500 < (GetGameTimer() - ivanAI.data.missingEnemies[i] + timeline) * ivanAI.data.enemies[i].ms then table.insert(result,ivanAI.data.enemies[i]) end
			end
		end
		return result
	end,
	missingEnemies = function()
		local result = {}
		for i = 1,#ivanAI.data.enemies,1 do
			if ivanAI.data.missingEnemies[i] ~= nil then
				if IsWallOfGrass(ivanAI.data.enemies[i]) == true and GetGameTimer() - ivanAI.data.missingEnemies[i] > 20 then table.insert(result,ivanAI.data.enemies[i])
				elseif GetGameTimer() - ivanAI.data.missingEnemies[i] > 10 then table.insert(result,ivanAI.data.enemies[i])  end
			end
		end
		return result
	end,
}
-------------------DRAW FUNCTIONS
ivanAI.draw = {
	text = function(text,x,y,ARGB)
		if ARGB == nil then ARGB = 0xAAFFFF00 end
		local key = ivanAI.lua.freeKey(ivanAI.data.draw)
		ivanAI.data.draw[key] = function()
			DrawText(text,WINDOW_H/1200 * 30,WINDOW_W * x,WINDOW_H * y,ARGB)
		end
		return key
	end,	
	list = function(list,x,y,ARGB)
		if ARGB == nil then ARGB = 0xAAFFFF00 end
		local key = ivanAI.lua.freeKey(ivanAI.data.draw)
		ivanAI.data.draw[key] = function()
			DrawLine(WINDOW_W * (x - 7/1200),WINDOW_H * (y + 15/1900), WINDOW_W * (x - 7/1200), WINDOW_H * y + (#list - 0.23)*(WINDOW_H/1200 * 30),4,ARGB)
			for i = 1,#list,1 do
				DrawText(list[i],WINDOW_H/1200 * 30,WINDOW_W * x,WINDOW_H * y + (i - 1)*(WINDOW_H/1200 * 30),ARGB)
			end
		end
		return key
	end,
	box = function(x,y,width,height,ARGB)
		if ARGB == nil then ARGB = 0x88964B00 end
		local key = ivanAI.lua.freeKey(ivanAI.data.draw)
		ivanAI.data.draw[key] = function()
			DrawLine(WINDOW_W * x,WINDOW_H * (y + height/2),WINDOW_W * (x + width), WINDOW_H * (y + height/2),WINDOW_H * height,ARGB)
		end
		return key
	end,
	line = function(x1,y1,x2,y2,ARGB)
		if ARGB == nil then ARGB = 0xAAFFFF00 end
		local key = ivanAI.lua.freeKey(ivanAI.data.draw)
		ivanAI.data.draw[key] = function()
			DrawLine(WINDOW_W * x1,WINDOW_H * y1,WINDOW_W * x2, WINDOW_H * y2,4,ARGB)
		end
		return key
	end,
	timeline = function(handle, timeline)
		ivanAI.timer.add(true,timeline,function() ivanAI.data.draw[handle] = nil end)
	end,
	remove = function(handle)
		ivanAI.data.draw[handle] = nil
	end,
}
-------------------PRINT FUNCTIONS
ivanAI.print = {
	unit = function(unit)
		PrintChat(">>>>>"..unit.charName)
		PrintChat("       ".."Name: "..unit.name)
		PrintChat("       ".."dead: "..tostring(unit.dead))
		PrintChat("       ".."visible: "..tostring(unit.visible))
		PrintChat("       ".."x: "..math.floor(unit.x+0.5))
		PrintChat("       ".."z: "..math.floor(unit.z+0.5))
		PrintChat("       ".."y: "..math.floor(unit.y+0.5))
		PrintChat("       ".."spawn disance: "..math.floor(ivanAI.stat.spawnDistance(unit,unit.team ~= TEAM_ENEMY) + 0.5))
		if unit.team == TEAM_BLUE then PrintChat("       ".."team: BLUE")
		elseif unit.team == TEAM_RED then PrintChat("       ".."team: PINK")
		elseif unit.team == TEAM_NEUTRAL then PrintChat("       ".."team: NEUTRAL")
		else PrintChat("       ".."team: NONE") end
		PrintChat("<<<<<"..unit.charName)
	end,
	buffs = function(unit)
		local buffs = ivanAI.find.buffs(unit)
		PrintChat(">>>>>"..unit.charName.." buffs")
		for i = 1, #buffs do
			PrintChat("       "..tostring(i)..". "..buffs[i].name)
		end
		PrintChat("<<<<<"..unit.charName.." buffs")
	end,
}
-------------------ITEMS FUNCTIONS
ivanAI.item = {
	slot = function(unit,itemID)
		for i=1,6,1 do
			if unit:getInventorySlot(ITEM_1 + i -1) == itemID then return ITEM_1 + i - 1 end
		end
		return nil
	end,
	buy = function(items) --  items is {{ID,cost,{destination(parent)items}},...} array
		--get game timer for saving cpu
		local gameTime = GetGameTimer()
		--check CD
		if shopCD ~= nil and gameTime < shopCD then return end
		--local function
		local function areParentsBought(parents)
			if parents == nil then return false end
			for x = 1,#parents,1 do
				if ivanAI.item.slot(myHero,parents[x]) ~= nil then return true end
			end
			return false
		end
		--check is parent item bought and item bought and gold
		if areParentsBought(items[1][2]) == false and ivanAI.item.slot(myHero,items[1][1]) == nil then BuyItem(items[1][1])
		else table.remove(items,1) end
		--refresh cd
		shopCD = gameTime + 1
	end,
	ward = function(unit)
		for i=1,6,1 do
			local item = unit:getInventorySlot(ITEM_1 + i - 1)
			if item ~= nil and unit:CanUseSpell(ITEM_1 + i - 1) and (item == 2043 or item == 2044 or item == 2045 or item == 2049 or item == 3154 or item == 2050) then return ITEM_1 + i - 1 end
		end
		return nil
	end,
}
-------------------TABLE OF CONDITIONS USED BY AI
ivanAI.condition = {
	isAtEnemySide = function(unit)
		return ivanAI.math.distance(unit,ivanAI.data.enemySpawn) < ivanAI.math.distance(unit,ivanAI.data.allySpawn)
	end,
	isTarget = function(unit)
		if unit.valid == false or unit.dead == true or unit.visible == false or (unit.bTargetable == false and unit.bTargetableToTeam == false) then return false
		else return true end
	end,
	isBehind = function(unit,target)
		local rad = ivanAI.math.rad(target,unit)
		--check for ally
		if target.team ~= ENEMY_TEAM then
			if ivanAI.math.distance(unit,ivanAI.data.allySpawn) < ivanAI.math.distance(unit,ivanAI.data.enemySpawn) then return math.abs(ivanAI.math.rad(unit,ivanAI.data.allySpawn) - rad) <= 0.785398163
			else return math.abs(ivanAI.math.rad(ivanAI.data.enemySpawn,unit) - rad) <= 0.785398163 end
		else
			if ivanAI.math.distance(unit,ivanAI.data.enemySpawn) < ivanAI.math.distance(unit,ivanAI.data.allySpawn) then return math.abs(ivanAI.math.rad(unit,ivanAI.data.enemySpawn) - rad) <= 0.785398163
			else return math.abs(ivanAI.math.rad(ivanAI.data.allySpawn,unit) - rad) <= 0.785398163 end
		end
	end,
	isAtSpawn = function(unit)
		return ivanAI.math.distance(ivanAI.data.allySpawn,unit) <= 500
	end,
	isRecallFaster = function(pos,ms)
		return pos ~= nil and ivanAI.math.distance(ivanAI.data.allySpawn,pos) > ms * 8
	end,
	isWarded = function(pos,range)
		if ivanAI.data.wards == nil then
			ivanAI.data.wards = ivanAI.object.scanByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,"Ward") ~= nil end)
			--set hooks to refresh wards
			ivanAI.object.hookByCondition(function(obj) return obj.type == "obj_AI_Minion" and string.find(obj.name,"Ward") ~= nil end,ivanAI.data.wards)
		end
		for i = 1,#ivanAI.data.wards,1 do
			if ivanAI.math.distance(ivanAI.data.wards[i],pos) <= range then return true end
		end
		return false
	end,
	isRecall = function(unit)
		if ivanAI.data.recall == nil then
			ivanAI.data.recall = ivanAI.object.scanByPattern("TeleportHome")
			--set hooks to refresh recalls
			ivanAI.object.hookByPattern("TeleportHome",ivanAI.data.recall)
		end
		if unit.team ~= TEAM_ENEMY then
			for key, value in pairs(ivanAI.data.recall) do
				if math.abs(value.x + value.z - unit.x - unit.z) < 20 then return true end
			end
			return false
		else return ivanAI.condition.isBuffed(unit,"Recall") == true or ivanAI.condition.isBuffed(unit,"ImprovedRecall") == true end
	end,
	isLowHP = function(unit,lowPercent)
		return unit.health/unit.maxHealth <= lowPercent
	end,
	isManaLess = function(unit)
		return (unit.maxMana <= 200 and unit.charName ~= "Vayne") or unit.charName == "Mordekaiser"
	end,
	isLowMP = function(unit,lowPercent)
		return (not ivanAI.condition.isManaLess(unit)) and unit.mana/unit.maxMana <= lowPercent
	end,
	isLow = function(unit,lowPercent)
		return ivanAI.condition.isLowHP(unit,lowPercent) or ivanAI.condition.isLowMP(unit,lowPercent)
	end,
	isMissing = function(enemy)
		if ivanAI.data.missingEnemies[enemy.name] == nil then return false
		elseif IsWallOfGrass(enemy) == true and GetGameTimer() - ivanAI.data.missingEnemies[enemy] > 20 then return true
		elseif IsWallOfGrass(enemy) == false and GetGameTimer() - ivanAI.data.missingEnemies[enemy] > 10 then return true
		else return false end
	end,
	isBuffed = function(unit,buff)
		for i = 1, unit.buffCount,1 do
			local buff = unit:getBuff(i)
			if buff.valid == true and buff.name == name then return true end
		end
		return false
	end,
	isAFK = function(allyUnit)
		for i = 1, #ivanAI.data.allies, 1 do
			if unit.name == ivanAI.data.allies[i].name and ivanAI.data.afk[i] ~= nil then 
				return ivanAI.data.afk[i] > 3.5 * 60
			end
		end
		return false
	end,
}
-------------------TABLE OF ACTIONS USED BY AI
ivanAI.action = {
	spawn = function()
		return ivanAI.action.move(ivanAI.data.allySpawn)
	end,
	move = function(pos)
		if ivanAI.math.distance(myHero,pos) <= 50 then return true end
		myHero:MoveTo(pos.x,pos.z)
		return false
	end,
	recall = function()
		if ivanAI.condition.isAtSpawn(myHero) == true then return true end
		CastSpell(RECALL)
		return false
	end,
	safeTower = function()
		local safeTower = ivanAI.find.safeTower(myHero)
		return ivanAI.action.behind(safeTower,450)
	end,
	river = function()
		local project = ivanAI.math.project({x=0,z=13250},{x=15250,z=0},myHero)
		if ivanAI.math.distance(myHero,project) <= 150 then return true end
		myHero:MoveTo(project.x,project.z)
		return false
	end,
	allySide = function()
		if ivanAI.math.distance(myHero,ivanAI.data.allySpawn) < ivanAI.math.distance(myHero,ivanAI.data.enemySpawn) then return true
		else return ivanAI.action.river() end
	end,
	behind = function(unit,range)
		if ivanAI.condition.isAtSpawn(myHero) == true and ivanAI.condition.isAtSpawn(unit) == true then return true
		--check is already complete
		elseif ivanAI.math.distance(myHero,unit) < range * 1.25 and ivanAI.condition.isBehind(myHero,unit) == true then return true
		--proceed movement
		elseif ivanAI.math.distance(unit,ivanAI.data.allySpawn) < ivanAI.math.distance(unit,ivanAI.data.enemySpawn) then
			--oriented by ally spawn
			local pos = ivanAI.math.pos(unit,ivanAI.math.rad(unit,ivanAI.data.allySpawn),range + math.random(-(range/8),range/8))
			myHero:MoveTo(pos.x,pos.z)
		else
			--oriented by enemy spawn
			local pos = ivanAI.math.pos(unit,ivanAI.math.rad(unit,ivanAI.data.enemySpawn),-range + math.random(-(range/8),range/8))
			myHero:MoveTo(pos.x,pos.z)
		end
		return false
	end,
	holdBehind = function(unit,range)
		--check reached
		if ivanAI.action.behind(unit,range) == true then myHero:StopPosition() end
		return false
	end,
	level = function(spells)
		local count = myHero.level - myHero:GetSpellData(_Q).level - myHero:GetSpellData(_W).level - myHero:GetSpellData(_E).level - myHero:GetSpellData(_R).level
		if myHero.charName == "Jayce" or myHero.charName == "Elise" or myHero.charName == "Karma" then count = count + 1 end
		if spells ~= nil and myHero.level ~= 0 and count ~= 0 then
			for i = myHero.level,myHero.level - count,-1  do LevelSpell(spells[i]) end 
		end
		return true
	end,	
	ward = function(pos)
		local slot = ivanAI.item.ward(myHero)
		if slot == nil or ivanAI.condition.isWarded(pos,1100) then return true end
		--get game timer to prevent triple ward
		local gameTime = GetGameTimer()
		--check cd
		if wardCD == nil or gameTime > wardCD then
			CastSpell(slot,pos.x,pos.z)
			wardCD = gameTime + 1
		end
		return false
	end,
	regen = function()
		return myHero.dead == false and myHero.health == myHero.maxHealth and (ivanAI.condition.isManaLess(myHero) == true or myHero.mana == myHero.maxMana)
	end,
}
-------------------TABLE OF BRAIN USED BY AI
ivanAI.brain = {
	add = function(action)
		local key = ivanAI.lua.freeKey(ivanAI.data.brain)
		--add table
		ivanAI.data.brain[key] = {}
		--add action
		if type(action) == "table" then ivanAI.data.brain[key].actions = action
		else ivanAI.data.brain[key].action = action end
		--add current action count
		ivanAI.data.brain[key].active = 1
		--add condition table
		ivanAI.data.brain[key].conditions = {}
		--set next itself
		ivanAI.data.brain[key].next = key
		--check is first 
		if ivanAI.data.brain.active == nil then ivanAI.brain.setActive(key) end
		--return handle
		return key
	end,
	setActive = function(handle)
		if ivanAI.data.brain.active ~= nil then ivanAI.data.brain[ivanAI.data.brain.active].active = 1 end
		ivanAI.data.brain.active = handle
	end,
	setNext = function(handle,nextHandle)
		--add next
		ivanAI.data.brain[handle].next = nextHandle
	end,
	setCondition = function(handle,condition,nextHandle)
		local key = ivanAI.lua.freeKey(ivanAI.data.brain[handle].conditions)
		--add table 
		ivanAI.data.brain[handle].conditions[key] = {}
		--add condition
		ivanAI.data.brain[handle].conditions[key].condition = condition
		--add next
		ivanAI.data.brain[handle].conditions[key].next = nextHandle
	end,
	setEnabled = function(check,pause)
		if check == false then
			if ivanAI.data.brain.timer ~= nil then
				if ivanAI.data.brain.active ~= nil then ivanAI.data.brain[ivanAI.data.brain.active].active = 1 end
				ivanAI.timer.remove(ivanAI.data.brain.timer) 
				ivanAI.data.brain.timer = nil
			end
		else
			if pause == nil then pause = 0.2 end
			ivanAI.data.brain.timer = ivanAI.timer.add(false,pause,function()
				--check conditions
				for key, value in pairs(ivanAI.data.brain[ivanAI.data.brain.active].conditions) do
					--check boolean condition complete
					if value.condition == true 
					--check boolean function complete
					or (type(value.condition) == "function" and value.condition() == true) 
					then 
						--reset active action of list
						ivanAI.data.brain[ivanAI.data.brain.active].active = 1
						--change active
						ivanAI.data.brain.active = value.next 
						--end brain iteration
						return
					end
					
				end
				--check list of actions
				if ivanAI.data.brain[ivanAI.data.brain.active].actions ~= nil then
					--check action nil
					if ivanAI.data.brain[ivanAI.data.brain.active].actions[ivanAI.data.brain[ivanAI.data.brain.active].active] == nil
					--check action complete
					or ivanAI.data.brain[ivanAI.data.brain.active].actions[ivanAI.data.brain[ivanAI.data.brain.active].active]() == true 
					--change active
					then ivanAI.data.brain[ivanAI.data.brain.active].active = ivanAI.data.brain[ivanAI.data.brain.active].active + 1 end
					--check is it last active
					if ivanAI.data.brain[ivanAI.data.brain.active].active > #ivanAI.data.brain[ivanAI.data.brain.active].actions then 
						--reset counter
						ivanAI.data.brain[ivanAI.data.brain.active].active = 1
						--change active 
						ivanAI.data.brain.active = ivanAI.data.brain[ivanAI.data.brain.active].next
					end
				--check action nil
				elseif ivanAI.data.brain[ivanAI.data.brain.active].action == nil 
				--check action complete
				or ivanAI.data.brain[ivanAI.data.brain.active].action() == true 
				--change active
				then ivanAI.data.brain.active = ivanAI.data.brain[ivanAI.data.brain.active].next end
			end)
		end
	end,
	isEnabled = function()
		return ivanAI.data.brain.timer ~= nil
	end,
	reset = function()
		if ivanAI.data.brain.timer ~= nil then 
			ivanAI.timer.remove(ivanAI.data.brain.timer) 
			ivanAI.data.brain.timer = nil
		end
		ivanAI.data.brain = {}
	end,
}
-------------------DATA TABLE USED BY LIB
ivanAI.data = {
	--objects hooks
	objects = {},
	--timers info
	timers = {},
	--enemies miss time
	missingEnemies = {},
	--allies afk time
	afk = {},
	--allies and enemies
	allies = {},
	enemies = {},
	--spawns and towers
	allyTowers = {},
	enemyTowers = {},
	--brain
	brain = {},
	--draw
	draw = {},
}
-------------------FORWARD CALLBACKS
ivanAI.forward ={
	OnDraw = function()
		--check requests
		for key, value in pairs(ivanAI.data.draw) do value() end
	end,
	OnCreateObj = function(object)
		--check hooks
		for key, value in pairs(ivanAI.data.objects) do if value.validate(object) == true then table.insert(value.container,object) end end
	end,
	OnDeleteObj = function(object)
		--check hooks
		for key, value in pairs(ivanAI.data.objects) do if value.validate(object) == true then
				for i = 1, #value.container,1 do 
					if value.container[i].networkID == object.networkID then 
						table.remove(value.container,i)  
						return
					end
				end
			end
		end
	end,
	OnLoad = function()
		--fill tables
		for i=1, objManager.maxObjects, 1 do
			local candidate = objManager:getObject(i)
			if candidate ~= nil and candidate.valid == true then
				if candidate.type == "obj_SpawnPoint" and candidate.team == TEAM_ENEMY then ivanAI.data.enemySpawn = candidate
				elseif candidate.type == "obj_SpawnPoint" and candidate.team == myHero.team then ivanAI.data.allySpawn = candidate
				elseif candidate.type == "obj_AI_Turret" and candidate.dead == false and candidate.team == TEAM_ENEMY then table.insert(ivanAI.data.enemyTowers,candidate)
				elseif candidate.type == "obj_AI_Turret" and candidate.dead == false and candidate.team == myHero.team then table.insert(ivanAI.data.allyTowers,candidate) end
			end
		end
		--fill heroes
		for i = 1, heroManager.iCount, 1 do
			local candidate = heroManager:getHero(i)
			if candidate ~= nil or candidate.valid == true then
				if candidate.team == myHero.team then table.insert(ivanAI.data.allies,candidate)
				elseif candidate.team == TEAM_ENEMY then table.insert(ivanAI.data.enemies,candidate) end
			end
		end
		for i = 1,#ivanAI.data.enemies,1 do
			if ivanAI.data.enemies[i].dead == false and ivanAI.data.enemies[i].visible == false then ivanAI.data.missingEnemies[i] = GetGameTimer() end
		end
		--missing enemies refresh
		ivanAI.timer.add(false,0.5,
			function()
				for i = 1,#ivanAI.data.enemies,1 do
					if ivanAI.data.enemies[i].dead == false and ivanAI.data.enemies[i].visible == false then
						if ivanAI.data.missingEnemies[i] == nil then ivanAI.data.missingEnemies[i] = GetGameTimer() end
					else ivanAI.data.missingEnemies[i] = nil end
				end
			end)
		--afk reset
		for i = 1,#ivanAI.data.allies,1 do
			if ivanAI.condition.isAtSpawn(ivanAI.data.allies[i]) then ivanAI.data.afk[i] = GetGameTimer() end
		end
		--afk allies refresh
		ivanAI.timer.add(false,1,
			function()
				--refresh afk time
				for i = 1,#ivanAI.data.allies,1 do
					if ivanAI.data.afk[i] == nil and ivanAI.condition.isAtSpawn(ivanAI.data.allies[i]) == true then ivanAI.data.afk[i] = GetGameTimer()
					else ivanAI.data.afk[i] = nil end
				end
			end)
	end,
	OnTick = function()
		--check timers
		local gameTime = GetGameTimer()
		for key, value in pairs(ivanAI.data.timers) do
			local mistake = gameTime - value.lastcall - value.cooldown
			if mistake >= 0 then
				value.callback(key)
				if value.isOneTime == true then ivanAI.data.timers[key] = nil
				else value.lastcall = gameTime - mistake end
			end
		end
	end
}
--fix myHero
if myHero == nil then myHero = GetMyHero() end
--setup callbacks
AddLoadCallback(ivanAI.forward.OnLoad)
AddTickCallback(ivanAI.forward.OnTick)
AddDrawCallback(ivanAI.forward.OnDraw)
AddCreateObjCallback(ivanAI.forward.OnCreateObj)
AddDeleteObjCallback(ivanAI.forward.OnDeleteObj)