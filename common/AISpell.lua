--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

AISpell - lib namespace
	void level({_Q,_W,...} spells) 
		level abilites
		spells is table ,containing _Q or _W or _E or _R per level of character
	void buy(table items) 
		buying items at shop, items is array of {float ID,{float parentID,float parentID,...}} tables
		dont call too fast OR DUPLICATES
		
	iSpell item(unit unit,float itemID) - return itemslot of itemID of unit OR nil
	iSpell ohm() - return usable slot ohmwrecker or nil
	iSpell locket() - return usable locket or nil
	iSpell ward() - return usable slot ward or nil
	iSpell shurelia() - return usable slot shurelia or nil
	iSpell dfg() - return usable slot dfg or nil
	iSpell gunblade() - return usable gunblade CHILD slot or gunblade slot or BOTRK slot or nil
	iSpell qs() - return usable quicksilver slot or scimiter slot or nil	
	iSpell randuin() - return usable randuin slot or nil
	iSpell zhonya() - return usable zhonya slot or nil
	iSpell ghostblade() - return usable yomumu ghostblade slot or nil
	iSpell iceshard() - return usable iceshard slot or nil
	iSpell crucible() - return usable mikael crucible(support QS) slot or nil
		
	iSpell summoner(name) - return usable summoner spell with name
	iSpell smite() - return usable smite slotor nil
	iSpell ghost() - return usable ghost slot or nil
	iSpell revive () - return usable revive slot or nil
	iSpell heal() - return usable  heal slot or nil
	iSpell teleport() - return usable teleport slot or nil
	iSpell flash() - return usable flash slot  or nil
	iSpell barrier() - return usable barrier slot or nil
	iSpell ignite() - return usable ignite slot or nil
	iSpell exhaust() - return usable slot exhaust
	iSpell cleanse() - return usable slot cleanse
	iSpell clarity() - return usable slot clarity

--]]

AISpell = {}

AISpell.level = function(spells)
	local count = myHero.level - myHero:GetSpellData(_Q).level - myHero:GetSpellData(_W).level - myHero:GetSpellData(_E).level - myHero:GetSpellData(_R).level
	if myHero.charName == "Jayce" or myHero.charName == "Elise" or myHero.charName == "Karma" then count = count + 1 end
	for i = myHero.level,myHero.level - count,-1  do LevelSpell(spells[i]) end 
end
	
AISpell.buy = function(items)  
	--local function
	local function parentsBought(parents)
		if parents == nil then return false end
		for i = 1,#parents,1 do if AISpell.item(myHero,parents[i]) ~= nil then return true end end
		return false
	end
	--check is parent item bought and item bought
	for i=1,#items,1 do
		if AISpell.item(myHero,items[i][1]) == nil and parentsBought(items[i][2]) == false 
		then BuyItem(items[i][1]) return end
	end
end
	
AISpell.item = function(unit,itemID)
	for i=1,6,1 do
		if unit:getInventorySlot(ITEM_1 + i -1) == itemID then return ITEM_1 + i - 1 end
	end
	return nil
end
	
AISpell.summoner = function(name)
	if myHero:GetSpellData(SUMMONER_1).name == name and CanUseSpell(SUMMONER_1) == READY then return SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name == name and CanUseSpell(SUMMONER_2) == READY then return SUMMONER_2 
	else return nil end
end
	AISpell.smite = function() return AISpell.summoner("SummonerSmite") end
	AISpell.revive = function() return AISpell.summoner("SummonerRevive") end
	AISpell.flash = function() return AISpell.summoner("SummonerFlash") end
	AISpell.exhaust = function() return AISpell.summoner("SummonerExhaust") end
	AISpell.ghost = function() return AISpell.summoner("SummonerHaste") end
	AISpell.ignite = function() return AISpell.summoner("SummonerDot") end
	AISpell.heal = function() return AISpell.summoner("SummonerHeal") end
	AISpell.clarity = function() return AISpell.summoner("SummonerMana") end
	AISpell.cleanse = function() return AISpell.summoner("SummonerBoost") end
	AISpell.barrier = function() return AISpell.summoner("SummonerBarrier") end
	AISpell.teleport = function() return AISpell.summoner("SummonerTeleport") end
	
AISpell.ward = function()
	for i=1,6,1 do
		local item = myHero:getInventorySlot(ITEM_1 + i - 1)
		if item ~= nil and (item == 2043 or item == 2044 or item == 2045 or item == 2049 or item == 3154 or item == 2050) and  CanUseSpell(ITEM_1 + i - 1) == READY then return ITEM_1 + i - 1 end
	end
	return nil
end

AISpell.locket = function() 
	local item = AISpell.item(myHero,3190)
	if item ~= nil and CanUseSpell(item) == READY then return item
	else return nil end
end

AISpell.ohm = function()
	local item = AISpell.item(myHero,3056)
	if item ~= nil and CanUseSpell(item) == READY then return item
	else return nil end
end
	
	AISpell.shurelya = function(myHero)
		local item = AISpell.item(myHero,3069)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.dfg = function()
		local item = AISpell.item(myHero,3128)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.gunblade = function()
		local item = AISpell.item(myHero,3146) or AISpell.item(myHero,3144) or AISpell.item(myHero,3153)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.qs = function()
		local item = AISpell.item(myHero,3140) or AISpell.item(myHero,3139)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.zhonya = function()
		local item = AISpell.item(myHero,3157)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.randuin = function()
		local item = AISpell.item(myHero,3143)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.iceshard = function()
		local item = AISpell.item(myHero,3092)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.crucible = function()
		local item = AISpell.item(myHero,3222)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end
	AISpell.ghostblade = function()
		local item = AISpell.item(myHero,3142)
		if item ~= nil and CanUseSpell(item) == READY then return item
		else return nil end
	end