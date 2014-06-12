require "Collision"
--[[
	Caster Class taken from iSAC (Credits to Apple)
--]]
class 'Caster'

SPELL_TARGETED = 1
SPELL_LINEAR = 2
SPELL_CIRCLE = 3
SPELL_CONE = 4
SPELL_LINEAR_COL = 5
SPELL_SELF = 6

function Caster:__init(spell, range, spellType, speed, delay, width, useCollisionLib)
	--assert(spell and (range or spellType == SPELL_SELF), "Error: Caster:__init(spell, range, spellType, [speed, delay, width, useCollisionLib]), invalid arguments.")
	self.spell = spell
	self.range = range or 0
	self.spellType = spellType or SPELL_SELF
	self.speed = speed or math.huge
	self.delay = delay or 0
	self.width = width
	self.spellData = myHero:GetSpellData(spell)
	if spellType == SPELL_LINEAR or spellType == SPELL_CIRCLE or spellType == SPELL_LINEAR_COL then
		--if type(range) == "number" and (not speed or type(speed) == "number") and (not delay type(delay) == "number" and (type(width) == "number" or not width) then
			--assert(type(range) == "number" and type(speed) == "number" and type(delay) == "number" and (type(width) == "number" or not width), "Error: Caster:__init(spell, range, [spellType, speed, delay, width, useCollisionLib]), invalid arguments for skillshot-type.")
			self.pred = VIP_USER and TargetPredictionVIP(range, speed, delay, width) or TargetPrediction(range, speed/1000, delay*1000, width)
			if spellType == SPELL_LINEAR_COL then
				self.coll = VIP_USER and useCollisionLib ~= false and Collision(range, (speed or math.huge), delay, width) or nil
			end
		--end
	end
end

function Caster:__type()
	return "Caster"
end

function Caster:Cast(target, minHitChance)
	if myHero:CanUseSpell(self.spell) ~= READY then return false end
	if self.spellType == SPELL_SELF then
		CastSpell(self.spell)
		return true
	elseif self.spellType == SPELL_TARGETED then
		if ValidTarget(target, self.range) or target ~= nil and not target.dead and GetDistance(target) < self.range and target.team == myHero.team then
			CastSpell(self.spell, target)
			return true
		end 
	elseif self.spellType == SPELL_TARGETED_FRIENDLY then
		if target ~= nil and not target.dead and GetDistance(target) < self.range and target.team == myHero.team then
			CastSpell(self.spell, target)
			return true
		end
	elseif self.spellType == SPELL_CONE then
		if ValidTarget(target, self.range) then
			CastSpell(self.spell, target.x, target.z)
			return true
		end
	elseif self.spellType == SPELL_LINEAR or self.spellType == SPELL_CIRCLE then
		if self.pred and ValidTarget(target) then
			local spellPos,_ = self.pred:GetPrediction(target)
			if spellPos and (not VIP_USER or not minHitChance or self.pred:GetHitChance(target) > minHitChance) then
				CastSpell(self.spell, spellPos.x, spellPos.z)
				return true
			end
		end
	elseif self.spellType == SPELL_LINEAR_COL then
		if self.pred and ValidTarget(target) then
			local spellPos,_ = self.pred:GetPrediction(target)
			if spellPos and (not VIP_USER or not minHitChance or self.pred:GetHitChance(target) > minHitChance) then
				if self.coll then
					local willCollide,_ = self.coll:GetMinionCollision(myHero, spellPos)
					if not willCollide then
						CastSpell(self.spell, spellPos.x, spellPos.z)
						return true
					end
				elseif not iCollision(spellPos, self.width) then
					CastSpell(self.spell, spellPos.x, spellPos.z)
					return true
				end
			end
		end
	end
	return false
end

function Caster:Ready()
	return myHero:CanUseSpell(self.spell) == READY
end

function Caster:GetPrediction(target)
	if self.pred and ValidTarget(target) then return self.pred:GetPrediction(target) end
end

function Caster:GetCollision(spellPos)
	if spellPos and spellPos.x and spellPos.z then
		if self.coll then
			return self.coll:GetMinionCollision(myHero, spellPos)
		else
			return iCollision(spellPos, self.width)
		end
	end
end

--[[
	Damage Calculation Class 
--]]
class "DamageCalculation"

local items = { -- Item Aliases for spellDmg lib, including their corresponding itemID's.
	{ name = "DFG", id = 3128},
	{ name = "HXG", id = 3146},
	{ name = "BWC", id = 3144},
	{ name = "HYDRA", id = 3074},
	{ name = "SHEEN", id = 3057},
	{ name = "KITAES", id = 3186},
	{ name = "TIAMAT", id = 3077},
	{ name = "NTOOTH", id = 3115},
	{ name = "SUNFIRE", id = 3068},
	{ name = "WITSEND", id = 3091},
	{ name = "TRINITY", id = 3078},
	{ name = "STATIKK", id = 3087},
	{ name = "ICEBORN", id = 3025},
	{ name = "MURAMANA", id = 3042},
	{ name = "LICHBANE", id = 3100},
	{ name = "LIANDRYS", id = 3151},
	{ name = "BLACKFIRE", id = 3188},
	{ name = "HURRICANE", id = 3085},
	{ name = "RUINEDKING", id= 3153},
	{ name = "LIGHTBRINGER", id = 3185},
	{ name = "SPIRITLIZARD", id = 3209}
	--["ENTROPY"] = 3184,
}

local SpellString = {
	["Q"] = _Q, 
	["W"] = _W,
	["E"] = _E, 
	["R"] = _R 
}

function DamageCalculation:__init(addItems, spellNames)
	self.addItems = addItems 
	self.spells = {}
	for _, spellName in pairs(spellNames) do
		self.spells[spellName] = {name = spellName, spell = SpellString[spellName]}
	end 
end 

function DamageCalculation:GetDamage(spell, Target)
	return getDmg(spell, Target, myHero)
end

function DamageCalculation:CalculateItemDamage(Target) 
	self.itemTotalDamage = 0
	for _, item in pairs(items) do 
		-- On hit items
		self.itemTotalDamage = self.itemTotalDamage + (GetInventoryHaveItem(item.id) and getDmg(item.name, Target, myHero) or 0)
	end
end

function DamageCalculation:CalculateBurstDamage(addItems, Target)
	local localSpells = self.spells
	local total = 0 
	for _, spell in pairs(localSpells) do
		if myHero:CanUseSpell(spell.spell) == READY then
			total = total + self:GetDamage(spell.name, Target)
		end
	end 
	if addItems then
		self:CalculateItemDamage(Target) 
		total = total + self.itemTotalDamage 
	end
	total = total + self:GetDamage("AD", Target)
	return total 
end 

function DamageCalculation:CalculateRealDamage(addItems, Target) 
	local total = 0
	for _, spell in pairs(self.spells) do 
		if myHero:CanUseSpell(spell.spell) == READY and myHero:GetSpellData(spell.spell).mana <= myHero.mana then
			total = total + self:GetDamage(spell.name, Target)
		end 
	end
	if addItems then
		self:CalculateItemDamage(Target) 
		total = total + self.itemTotalDamage 
	end
	total = total + self:GetDamage("AD", Target)
	return total 
end

function DamageCalculation:__type()
	return "DamageCalculation"
end

function DamageCalculation:LastHitMinion(Spell, spellString) 
	for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if ValidTarget(minion) and GetDistance(minion) <= Spell.range then
			if minion.health < getDmg(spellString, minion, myHero) then
				Spell:Cast(minion)
				myHero:Attack(minion)
			end
		end
	end
end 

function DamageCalculation:KillSteal(Spell, spellString)
	for i = 1, heroManager.iCount, 1 do
		local target = heroManager:getHero(i)
		if ValidTarget(target, Spell.range) then
			if target.health <= self:GetDamage(spellString, target) then
				Spell:Cast(target)
			end
		end
	end
end 


--[[
	Misc. from iSAC
--]]

local _enemyMinions, _enemyMinionsUpdateDelay, _lastMinionsUpdate = nil, 0, 0
function enemyMinions_update(range)
	if not _enemyMinions then
		_enemyMinions = minionManager(MINION_ENEMY, (range or 2000), myHero, MINION_SORT_HEALTH_ASC)
	elseif range and range > _enemyMinions.range then
		_enemyMinions.range = range
	end
	if _lastMinionsUpdate + _enemyMinionsUpdateDelay < GetTickCount() then
		_enemyMinions:update()
		_lastMinionsUpdate = GetTickCount()
	end
end

function enemyMinions_setDelay(delay)
	_enemyMinionsUpdateDelay = delay or 0
end

function getEnemyMinions()
	enemyMinions_update()
	return _enemyMinions.objects
end

local jungleCamps = {
	["TT_Spiderboss7.1.1"] = true,
	["Worm12.1.1"] = true,
	["Dragon6.1.1"] = true,
	["AncientGolem1.1.1"] = true,
	["AncientGolem7.1.1"] =  true,
	["LizardElder4.1.1"] =  true,
	["LizardElder10.1.1"] = true,
	["GiantWolf2.1.3"] = true,
	["GiantWolf8.1.3"] = true,
	["Wraith3.1.3"] = true,
	["Wraith9.1.3"] = true,
	["Golem5.1.2"] = true,
	["Golem11.1.2"] = true,
}
local _jungleMinions = nil
function getJungleMinions()
	if not _jungleMinions then
		_jungleMinions = {}
		for i = 1, objManager.maxObjects do
			local object = objManager:getObject(i)
			if object and object.type == "obj_AI_Minion" and object.name and jungleCamps[object.name] then
				_jungleMinions[#_jungleMinions+1] = object
			end
		end
		function jungleMinions_OnCreateObj(object)
			if object and object.type == "obj_AI_Minion" and object.name and jungleCamps[object.name] then
				_jungleMinions[#_jungleMinions+1] = object
			end
		end
		function jungleMinions_OnDeleteObj(object)
			if object and object.type == "obj_AI_Minion" and object.name and jungleCamps[object.name] then
				for i, minion in ipairs(_jungleMinions) do
					if minion.name == object.name then
						table.remove(_jungleMinions, i)
					end
				end
			end
		end
		AddCreateObjCallback(jungleMinions_OnCreateObj)
		AddDeleteObjCallback(jungleMinions_OnDeleteObj)
	end
	return _jungleMinions
end

function iCollision(endPos, width) -- Derp collision, altered a bit for own readability.
	enemyMinions_update()
	if not endPos or not width then return end
	for _, minion in pairs(_enemyMinions.objects) do
		if ValidTarget(minion) and myHero.x ~= minion.x then
			local myX = myHero.x
			local myZ = myHero.z
			local tarX = endPos.x
			local tarZ = endPos.z
			local deltaX = myX - tarX
			local deltaZ = myZ - tarZ
			local m = deltaZ/deltaX
			local c = myX - m*myX
			local minionX = minion.x
			local minionZ = minion.z
			local distanc = (math.abs(minionZ - m*minionX - c))/(math.sqrt(m*m+1))
			if distanc < width and ((tarX - myX)*(tarX - myX) + (tarZ - myZ)*(tarZ - myZ)) > ((tarX - minionX)*(tarX - minionX) + (tarZ - minionZ)*(tarZ - minionZ)) then
				return true
			end
		end
   end
   return false
end

--[[
	Drawing class
--]]

class "Draw"

local KillText = {"Not ready", "Wait for CD", "Kill"}
local KillColor = {0xFF0000, 0xA52A2A, 0x008000}

local SkillColor = {0xFF0000, 0x008000}

function Draw:__init(DamageClass) 
	self.damageInstance = DamageClass 
	self.spells = {}
end 

function Draw:DrawTarget(Target) 
	local totalDamage = self.damageInstance:CalculateBurstDamage(true, Target)
	local realDamage = self.damageInstance:CalculateRealDamage(true, Target)
	local i = 0
	if Target.health <= realDamage then 
		i = 3 
	elseif Target.health > realDamage and Target.health < totalDamage then 
		i = 2 
	else
		i = 1
	end
	DrawCircle(Target.x, Target.y, Target.z, 130, KillColor[i])
	PrintFloatText(Target, 0, KillText[i] .. " DMG: " .. self:round(realDamage))
	DrawArrows(myHero, Target, 30, KillColor[i], 50)
end

function Draw:AddSkill(spellString, range) 
	table.insert({spell = SpellString[spellString], name = spellString, range = range}, self.spells)
end

function Draw:DrawSkills() 
	for _, mySpell in pairs(self.spells) do
		local colorIndex = 1 -- not ready
		DrawCircle(myHero.x, myHero.y, myHero.z, mySpell.range, 0x008000)
	end 
end

function Draw:round(num)
    under = math.floor(num)
    upper = math.floor(num) + 1
    underV = -(under - num)
    upperV = upper - num
    if (upperV > underV) then
        return under
    else
        return upper
    end
end

--[[
	Monitor class
--]]

class "Monitor"

-- health monitor
local lastTick = 0
local lastHealth = 0
local healthPercentage = 15
local checkTime = 5

-- team monitor
local mPlayer = nil
local mLastTick = 0
local mPercentage = 15

-- potion monitor
local PotionSlot = nil
local tickPotions = 0

-- enemy monitor
local mePlayer = nil 
local meLastTick = 0

function Monitor:__init(PluginMenu)
	lastTick = GetTickCount()
	mLastTick = GetTickCount()
	tickPotions = GetTickCount()
	lastHealth = myHero.health 
	meLastTick = GetTickCount()
	self.PluginMenu = PluginMenu 
	self.PluginMenu:addParam("monitorSpe", "-- Monitor Options --", SCRIPT_PARAM_INFO, "")
	self.PluginMenu:addParam("mPercentage", "Monitor teamate percentage",SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	self.PluginMenu:addParam("healthPercentage", "Rapid Damage Percentage",SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	self.PluginMenu:addParam("mePercentage", "Monitor enemy percentage",SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
end 

function Monitor:TakingRapidDamage()
	--> Check if enough time has elapsed 
	if GetTickCount() - lastTick > (checkTime * 1000) then
		--> Check amount of health lost
		if myHero.health - lastHealth > myHero.maxHealth * (self.PluginMenu.healthPercentage / 100) then
			return true
		else
			--> Reset counters
			lastTick = GetTickCount()
			lastHealth = myHero.health
		end
	end
end 

function Monitor:GetLowTeamate()
	return mPlayer 
end

function Monitor:GetLowEnemy()
	return mePlayer
end 

function Monitor:MonitorLowTeamate()
	if mPlayer == nil then return end 
	if GetTickCount() - mLastTick > (5 * 1000) then 
		if mPlayer.health / mPlayer.maxHealth > (self.PluginMenu.mPercentage / 100) then
			mPlayer = nil
		end			
		mLastTick = GetTickCount()
	end 
end 

function Monitor:MonitorLowEnemy()
	if mePlayer == nil then return end 
	if GetTickCount() - meLastTick > (5 * 1000) then 
		if mePlayer.health / mePlayer.maxHealth > (self.PluginMenu.mePercentage / 100) then
			mePlayer = nil
		end
		meLastTick = GetTickCount()
	end 
end 

function Monitor:IsAlly(champion)
	return champion and champion.type == "obj_AI_Hero" and champion.team == myHero.team
end 

function Monitor:IsEnemy(champion)
	return champion and champion.type == "obj_AI_Hero" and champion.team ~= myHero.team
end 

function Monitor:MonitorTeam(range) 
	for i=1, heroManager.iCount do
		local champion = heroManager:GetHero(i)
		if self:IsAlly(champion) and champion.name ~= myHero.name and not champion.dead and GetDistance(champion) <= range then
			if champion.health / champion.maxHealth <= (self.PluginMenu.mPercentage / 100) then
				mPlayer = champion 
			end
		end
	end
end 

function Monitor:MonitorEnemies(range) 
	for i=1, heroManager.iCount do
		local champion = heroManager:GetHero(i)
		if self:IsEnemy(champion) and champion.name ~= myHero.name and not champion.dead and GetDistance(champion) <= range then
			if champion.health / champion.maxHealth <= (self.PluginMenu.mePercentage / 100) then
				mePlayer = champion 
			end
		end
	end
end 

function Monitor:GetTeamateWithMostEnemies(range) 
	local best = nil 
	local enemies = math.huge
	for i=1, heroManager.iCount do
		local champion = heroManager:GetHero(i)
		if self:IsAlly(champion) and champion.name ~= myHero.name and not champion.dead and GetDistance(champion) <= range then
			if best == nil then
				best = champion 
				enemies = Monitor:CountEnemies(champion, range)
			elseif Monitor:CountEnemies(champion, range) > enemies then
				best = champion
				enemies = Monitor:CountEnemies(champion, range)
			end
 		end
	end
	return best 
end 

function Monitor:CountEnemies(point, range)
    local ChampCount = 0
    for j = 1, heroManager.iCount, 1 do
        local enemyhero = heroManager:getHero(j)
        if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, rRange + 50) then
            if GetDistance(enemyhero, point) <= range then
                ChampCount = ChampCount + 1
            end
        end
    end            
    return ChampCount
end

function Monitor:PrintWarnings() 
	if mPlayer == nil then return end 
	PrintChat("Player has dropped below threshold health... P: " .. mPlayer.charName)
end 

function Monitor:PrintNotifications() 
	if mePlayer == nil then return end 
	PrintChat("Enemy has dropped below threshold health... P: " .. mePlayer.charName)
end 

function Monitor:AutoPotion()
	if tickPotions == nil or (GetTickCount() - tickPotions > 1000) then
		PotionSlot = GetInventorySlotItem(2003)
		if PotionSlot ~= nil then --we have potions
			if myHero.health/myHero.maxHealth < 0.60 and not TargetHaveBuff("RegenerationPotion", myHero) and not InFountain() then
				CastSpell(PotionSlot)
			end
		end
		tickPotions = GetTickCount()
	end
end 

function Monitor:GetTowers(team)
    local towers = {}
    for i=1, objManager.maxObjects, 1 do
        local tower = objManager:getObject(i)
        if tower ~= nil and tower.valid and tower.type == "obj_AI_Turret" and tower.visible and tower.team == team then
            table.insert(towers,tower)
        end
    end
    if #towers > 0 then
        return towers
    else
        return false
    end
end

--[[
	Priority Class
--]]
class "Priority"

local priorityTable = {
	AP = {
		"Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
		"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
		"Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi",
	},
	Support = {
		"Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Sona", "Soraka", "Thresh", "Zilean",
	},
	Tank = {
		"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Shen", "Singed", "Skarner", "Volibear",
		"Warwick", "Yorick", "Zac", "Nunu", "Taric", "Alistar",
	},
	AD_Carry = {
		"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "KogMaw", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
		"Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed",
	},
	Bruiser = {
		"Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nautilus", "Nocturne", "Olaf", "Poppy",
		"Renekton", "Rengar", "Riven", "Shyvana", "Trundle", "Tryndamere", "Udyr", "Vi", "MonkeyKing", "XinZhao", "Aatrox"
	},
}

local SupportTable = {
	AD_Carry = {
		"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "KogMaw", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
		"Talon", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Zed",
	},
	Bruiser = {
		"Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nautilus", "Nocturne", "Olaf", "Poppy",
		"Renekton", "Rengar", "Riven", "Shyvana", "Trundle", "Tryndamere", "Udyr", "Vi", "MonkeyKing", "XinZhao", "Aatrox"
	},
	Tank = {
		"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Shen", "Singed", "Skarner", "Volibear",
		"Warwick", "Yorick", "Zac", "Nunu", "Taric", "Alistar",
	},
	AP = {
		"Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
		"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
		"Rumble", "Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "MasterYi",
	},
	Support = {
		"Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Sona", "Soraka", "Thresh", "Zilean",
	},	
}

function Priority:__init(support)
	if support then
		priorityTable = SupportTable 
	end 
	if #GetEnemyHeroes() > 1 then
		TargetSelector(TARGET_LESS_CAST_PRIORITY, 0)
		self:arrangePrioritys(#GetEnemyHeroes())
	end
end

function Priority:SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end

function Priority:arrangePrioritys(enemies)
	local priorityOrder = {
		[2] = {1,1,2,2,2},
		[3] = {1,1,2,3,3},
		[4] = {1,2,3,4,4},
		[5] = {1,2,3,4,5},
	}
	for i, enemy in ipairs(GetEnemyHeroes()) do
		self:SetPriority(priorityTable.AD_Carry, enemy, priorityOrder[enemies][1])
		self:SetPriority(priorityTable.AP,       enemy, priorityOrder[enemies][2])
		self:SetPriority(priorityTable.Support,  enemy, priorityOrder[enemies][3])
		self:SetPriority(priorityTable.Bruiser,  enemy, priorityOrder[enemies][4])
		self:SetPriority(priorityTable.Tank,     enemy, priorityOrder[enemies][5])
	end
end