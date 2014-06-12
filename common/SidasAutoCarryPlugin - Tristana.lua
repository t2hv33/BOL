-- Script Created by Lollita.



-- FPS manager. This will make the Drop FPS the lower as possible
class 'TickManager'

function TickManager:__init(ticksPerSecond)
	self.TPS = ticksPerSecond
	self.lastClock = 0
    self.currentClock = 0
end

function TickManager:__type()
	return "TickManager"
end

function TickManager:setTPS(ticksPerSecond)
	self.TPS = ticksPerSecond
end

function TickManager:getTPS(ticksPerSecond)
	return self.TPS
end

function TickManager:isReady()
	self.currentClock = os.clock()
	if self.currentClock < self.lastClock + (1 / self.TPS) then return false end
	self.lastClock = self.currentClock
	return true
end

local onTickTM, onDrawTM, onSpellTM = TickManager(20), TickManager(80), TickManager(15)


local ToInterrupt = {}

local InterruptList = {

    { charName = "Caitlyn", spellName = "CaitlynAceintheHole"},

    { charName = "FiddleSticks", spellName = "Crowstorm"},

    { charName = "FiddleSticks", spellName = "DrainChannel"},

    { charName = "Galio", spellName = "GalioIdolOfDurand"},

    { charName = "Karthus", spellName = "FallenOne"},

    { charName = "Katarina", spellName = "KatarinaR"},

    { charName = "Malzahar", spellName = "AlZaharNetherGrasp"},

    { charName = "MissFortune", spellName = "MissFortuneBulletTime"},

    { charName = "Nunu", spellName = "AbsoluteZero"},

    { charName = "Pantheon", spellName = "Pantheon_GrandSkyfall_Jump"},

    { charName = "Shen", spellName = "ShenStandUnited"},

    { charName = "Urgot", spellName = "UrgotSwap2"},

    { charName = "Varus", spellName = "VarusQ"},

    { charName = "Warwick", spellName = "InfiniteDuress"}

}

local RReady, EReady, QReady, WReady = nil, nil, nil, nil
local WRange, RRange = 900, 645
local QAtkSpeedBonus = {[0] = 1.0, [1] = 1.3, [2] = 1.45, [3] = 1.6, [4] = 1.75, [5] = 1.9}
local WDmg, EDmg, RDmg, comboDmg, DPS, killStatus = 0, 0, 0, 0, 0, ""
local allys, enemies = GetAllyHeroes(), GetEnemyHeroes()
local nEnemies, nEnemiesClose, nEnemiesFar = 0, 0, 0
local hpPercent = 0
local myPosVector, mousePosVector, finalVector = nil, nil, nil





function PluginOnLoad()

	AutoCarry.SkillsCrosshair.range = 600

	MainMenu = AutoCarry.MainMenu
	PluginMenu = AutoCarry.PluginMenu
	
	
	drawSeparator()
	PluginMenu:addParam("sepBasic", "Smart Jumper", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("smartCastW", "    Jump to mouse direction", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
	PluginMenu:addParam("drawWRange", "    Draw Jump range", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("drawWRadius", "    Draw Jump prediction", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("pauseSmartCastW", "    Pause Smart Jump on press", SCRIPT_PARAM_ONKEYDOWN, false, 16)
	
	
	drawSeparator()
	PluginMenu:addParam("sepBasic", "Life Insurance", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("autoPushMe", "    Auto Push Enemies from me", SCRIPT_PARAM_ONOFF, true)
	for _, ally in pairs(allys) do
		PluginMenu:addParam("autoPush" .. ally.charName, "    Auto Push Enemies from " .. ally.charName, SCRIPT_PARAM_ONOFF, false)
	end
	
	
	drawSeparator()
	PluginMenu:addParam("sepBasic", "Smart Finisher", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("killW", "    Kill Enemies with Jump", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("killWSafe", "   Dont jump if N enemies around", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
	PluginMenu:addParam("killR", "    Kill Enemies with Ultimate", SCRIPT_PARAM_ONOFF, true)
	
	
	drawSeparator()
	PluginMenu:addParam("sepBasic", "Goodies", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("drawTimeToKill", "    Draw time needed to kill", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("interrupt", "    Interrupt Channelling spells", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("pushBackCombo", "    Push back combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	
	drawSeparator()
	
	
	prepareInterupteSpells()
end

function prepareInterupteSpells()
	for _, enemy in pairs(enemies) do
		for _, champ in pairs(InterruptList) do
			if enemy.charName == champ.charName then
				table.insert(ToInterrupt, champ.spellName)
			end
		end
	end
end

function PluginOnTick()
	
	if not onTickTM:isReady() then return end
	
	CooldownHandler()

	Target = AutoCarry.GetAttackTarget()
	
	
	if PluginMenu.pauseSmartCastW == false and PluginMenu.smartCastW then smartCastW() end
	
	if (PluginMenu.killW or PluginMenu.killR) and MainMenu.AutoCarry then smartFinisher() end
	
	lifeInsurance()
	
	if Target and PluginMenu.pushBackCombo then pushBackCombo()	end
end

function PluginOnProcessSpell(unit, spell)
	if not onSpellTM:isReady() then return end

	if RReady and #ToInterrupt > 0 and PluginMenu.interrupt then
		for _, ability in pairs(ToInterrupt) do
			if spell.name == ability and unit.team ~= myHero.team then
				if RRange >= myHero:GetDistance(unit) then
					CastSpell(_R, unit)
				end
			end
		end
	end
end

function smartCastW()
	if WReady then
		CastSpell(_W, mousePos.x, mousePos.z)
	end
end

function smartFinisher()
	WDmg, RDmg = 0, 0
	for _, enemy in pairs(enemies) do
		WDmg = getDmg("W", enemy, myHero)
		RDmg = getDmg("R", enemy, myHero)
		nEnemies = countEnemiesAround(enemy)
		if PluginMenu.killW and ValidTarget(enemy, WRange) and WDmg >= enemy.health and nEnemies <= PluginMenu.killWSafe and (nEnemies == 1 or myHero.health / myHero.maxHealth > 0.4) then 
			CastSpell(_W, enemy.x, enemy.z) 
		elseif PluginMenu.killR and ValidTarget(enemy, RRange) and RDmg >= enemy.health then
			CastSpell(_R, enemy) 
		elseif PluginMenu.killW and PluginMenu.killR and ValidTarget(enemy, WRange) and RDmg + WDmg >= enemy.health and nEnemies <= PluginMenu.killWSafe and (nEnemies == 1 or myHero.health / myHero.maxHealth > 0.4) then
			CastSpell(_W, enemy.x, enemy.z) 
			CastSpell(_R, enemy) 
		end
	end
end

function lifeInsurance()
	
	if PluginMenu.autoPushMe and not myHero.dead and isInDanger(myHero) then
		local enemy = getClosestEnemy(myHero)
		CastSpell(_R, enemy)
	end
	
	for _, ally in pairs(allys) do
		if PluginMenu["autoPush" .. ally.charName] and not ally.dead and myHero:GetDistance(ally) <= RRange + 200 and isInDanger(ally) then
			local enemy = getClosestEnemy(ally)
			if myHero:GetDistance(enemy) <= RRange then CastSpell(_R, enemy) end
		end
	end
	
end

function isInDanger(hero)
	nEnemiesClose, nEnemiesFar = 0, 0
	hpPercent = hero.health / hero.maxHealth
	for _, enemy in pairs(enemies) do
		if not enemy.dead and hero:GetDistance(enemy) <= 200 then 
			nEnemiesClose = nEnemiesClose + 1 
			if hpPercent < 0.5 and hpPercent < enemy.health / enemy.maxHealth then return true end
		elseif not enemy.dead and hero:GetDistance(enemy) <= 1000 then
			nEnemiesFar = nEnemiesFar + 1 
		end
	end
	
	if nEnemiesClose > 1 then return true end
	if nEnemiesClose == 1 and nEnemiesFar > 1 then return true end
	return false
end

function countEnemiesAround(unit)
	nEnemies = 0
	for _, enemy in pairs(enemies) do
		if not enemy.dead and unit.name ~= enemy.name and unit:GetDistance(enemy) < 800 then
			nEnemies = nEnemies + 1
		end
	end
	return nEnemies
end

function getClosestEnemy(hero)
	local closest, closestDist = nil, 999999
	for _, enemy in pairs(enemies) do
		if not enemy.dead and hero:GetDistance(enemy) < closestDist then
			closestDist = hero:GetDistance(enemy)
			closest = enemy
		end
	end
	return closest
end

function pushBackCombo()
	if WReady and RReady and ValidTarget(Target, WRange - 100) then
		local TargetPosition = Vector(Target.x, Target.y, Target.z)
		local MyPosition = Vector(myHero.x, myHero.y, myHero.z)		
		local WallPosition = TargetPosition + (TargetPosition - MyPosition)*((150/myHero:GetDistance(Target)))
		CastSpell(_W, WallPosition.x, WallPosition.z)
		CastSpell(_R, Target)
		if EReady then CastSpell(_E, Target) end
	end
end

function PluginOnDraw()
	if not onDrawTM:isReady() then return end

	if PluginMenu.drawWRange and WReady then DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0x111111) end
	
	if PluginMenu.drawWRadius and WReady then 
		myPosV = Vector(myHero.x, myHero.z)
		mousePosV = Vector(mousePos.x, mousePos.z)
		
		if GetDistance(myPosV, mousePosV) < WRange - 50 then
			DrawCircle(mousePos.x, mousePos.y, mousePos.z, 250, 0x111111) 
		else
			finalV = myPosV+(mousePosV-myPosV):normalized()* (WRange - 60)
			DrawCircle(finalV.x, myHero.y, finalV.y, 250, 0x111111) 
		end		
	end
	
	if PluginMenu.drawTimeToKill then
		comboDmg, DPS = 0, 0
			
		for _, enemy in pairs(enemies) do
			if ValidTarget(enemy) then
				comboDmg = 0
				if WReady then comboDmg = comboDmg + getDmg("W", enemy, myHero) end
				if EReady then comboDmg = comboDmg + getDmg("E", enemy, myHero) end
				if RReady then comboDmg = comboDmg + getDmg("R", enemy, myHero) end
				
				if comboDmg >= enemy.health then
					killStatus = "Killable with Combo"
				else
					DPS = myHero:CalcDamage(enemy, myHero.damage) * myHero.attackSpeed * QAtkSpeedBonus[myHero:GetSpellData(_Q).level]
					killStatus = "Killable in " .. string.format("%4.1f", (enemy.health - comboDmg) / DPS) .. "s"
				end
				
				--PrintFloatText(enemy, 0, string.format("Kill in: %4.1f", timeToKill) .. " seconds")
				DrawText3D(tostring(killStatus), enemy.x, enemy.y, enemy.z, 20, RGB(255, 255, 255), true)
			end
		end
	end
end


function CooldownHandler()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function drawSeparator()
	PluginMenu:addParam("space", " ", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("space", "**********************************************", SCRIPT_PARAM_INFO, "")
end