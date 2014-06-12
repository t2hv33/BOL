--[[
 
        Auto Carry Plugin - Jinx PROdiction Edition
		Author: Kain
		Version: See version variable below.
		Copyright 2013

		Dependency: Sida's Auto Carry
 
		How to install:
			Make sure you already have AutoCarry installed.
			Name the script EXACTLY "SidasAutoCarryPlugin - Jinx.lua" without the quotes.
			Place the plugin in BoL/Scripts/Common folder.

		Features:
			Combo: SBTW Intelligent Q, E, R 
			Killsteal: Killsteal with Q, E, or R.
			Range Circles: Smart range circles turn on and off as their respective spells are available.
			Damage Combo Calulator: Shows messages on targets when kill-able by a combo.
			Customization: Fully customizable Combo (Q, E, R), Harass (Q, E, R), and Draw.
			Menus: Extensive configuration options in two menus.
			Reborn: Fully compatible.
			Misc: Mana Manager, Auto Leveler.

		Download: https://bitbucket.org/KainBoL/bol/raw/master/Common/SidasAutoCarryPlugin%20-%20Jinx.lua

		Version History:
			Version: 1.28:
				Added PROdiction 2.0.
				Fixed Revamped compatibility for prodiction.
				Reverted: Added PROdiction CanNotMissMode.
				Added W range limiter option for combo.
				Added better harass logic. (Thanks Vadash)
			Version: 1.22:
				Added more killsteal combos.
				Improvements to damage calculation on Ultimate. (Thanks Vadash)
				Temporary fix for people with FPS lag due to BoL problem. Set "FPSProblem_UseVIPPred = true" in script.
			Version: 1.12:
				W casts full range.
				W won't cast when too close to enemy. Added slider setting for this minimum range in menu.
				Better logic on Switcheroo!
				Switcheroo! now prefers PowPow while farming.
				Targets should be acquired a bit better.
				Q Harass removed from Lane Clear.
				Ultimate should not fire when enemy just died anymore.
				Won't Ultimate killsteal if enemy is in auto-attack range anymore. Added a toggle for this.
				Implemented W, E, and WE killsteal. E disabled by default.
			Version: 1.08:
				Fixed bug with manual Ultimate.
			Version: 1.07:
				Fixed GetDamage bug.
			Version: 1.05:
				Added option and alert for manual R when enemy killable.
				Added toggle for Switcheroo! on Harass (Mixed/Lane Clear).
				Fixed bug on PowPow stack tracking.
				Fixed GetDamage bug.
			Version: 1.02:
				Fixed minion collision on W.
				Removed debugging info spam.
				Draws Pow Pow stacks and keeps track of them properly.
				Does Switcheroo! based on Q range and attack speed buffs.
			Version: 0.5
				Beta
			Version: 0.2
				Pre-Release

		To Do:
			Cleanup R Killsteal / Combo stuff.

--]]

if myHero.charName ~= "Jinx" then return end

function Vars()
	curVersion = 1.28
	
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end

	-- Disable SAC Reborn's skills. Ours are better.
	if IsSACReborn then
		AutoCarry.Skills:DisableAll()
	end

	KeyQ = string.byte("Q")
	KeyW = string.byte("W")
	KeyE = string.byte("E")
	KeyR = string.byte("R")

	QRange, WRange, ERange, RRange = 600, 1500, 950, math.huge
	QSpeed, WSpeed, ESpeed, RSpeed = 1.3, 3.3, .887, 2.15 -- WSpeed was 2.5
	QDelay, WDelay, EDelay, RDelay = 390, 600, 500, 590 -- WDelay was 500
	QWidth, WWidth, EWidth, RWidth = 200, 100, 200, 200 -- WWidth was 100

	QPowPowRange = 627
	RRadius = 225

	if IsSACReborn then
		SkillQ = AutoCarry.Skills:NewSkill(false, _Q, QRange, "Switcheroo!", AutoCarry.SPELL_LINEAR, 0, false, false, QSpeed, QDelay, QWidth, false)
		SkillW = AutoCarry.Skills:NewSkill(false, _W, WRange, "Zap!", AutoCarry.SPELL_LINEAR_COL, 0, false, false, WSpeed, WDelay, WWidth, true)
		SkillE = AutoCarry.Skills:NewSkill(false, _E, ERange, "Flame Chompers!", AutoCarry.SPELL_CIRCLE, 0, false, false, ESpeed, EDelay, EWidth, false)
		SkillR = AutoCarry.Skills:NewSkill(false, _R, RRange, "Super Mega Death Rocket!", AutoCarry.SPELL_LINEAR, 0, false, false, RSpeed, RDelay, RWidth, false)
	else
		SkillQ = {spellKey = _Q, range = QRange, speed = QSpeed, delay = QDelay, width = QWidth, minions = false }
		SkillW = {spellKey = _W, range = WRange, speed = WSpeed, delay = WDelay, width = WWidth, minions = true }
		SkillE = {spellKey = _E, range = ERange, speed = ESpeed, delay = EDelay, width = EWidth, minions = false }
		SkillR = {spellKey = _R, range = RRange, speed = RSpeed, delay = RDelay, width = RWidth, minions = false }
	end

	-- Items
	ignite = nil
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
	QReady, WReady, EReady, RReady, DFGReady, HXGReady, BWCReady, IGNITEReady, BARRIERReady, CLEANSEReady, FReady = false, false, false, false, false, false, false, false, false, false, false
	flashEscape = false

	IGNITESlot = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") and SUMMONER_2) or nil)
	BARRIERSlot = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerBarrier") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerBarrier") and SUMMONER_2) or nil)
	CLEANSESlot = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerCleanse") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerCleanse") and SUMMONER_2) or nil)

	floattext = {"Harass him","Fight him","Kill him","Murder him"} -- text assigned to enemys

	killable = {} -- our enemy array where stored if people are killable
	waittxt = {} -- prevents UI lags, all credits to Dekaron

	for i=1, heroManager.iCount do waittxt[i] = i*3 end -- All credits to Dekaron

	stacks, timer = 0, 0
	PowPowStacks = {stack = 0, endT = 0}

	BuffPowPow = "jinxqicon"
	BuffFishBones = "JinxQ"
	BuffPowPowStacks = "jinxqramp"

	AAFishBones = false

	LastSwitcheroo = GetTickCount()
	SwitherooMinTime = 2000

	AAPowPowStacks = 0

	tick = 0

	Target = nil

	debugMode = false

	-- Check to see if user failed to read the forum...
	if VIP_USER then
		if FileExist(SCRIPT_PATH..'Common/Collision.lua') then
			require "Collision"

			if type(Collision) ~= "userdata" then
				PrintChat("Your version of Collision.lua is incorrect. Please install v1.1.1 or later in Common folder.")
				return
			else
				assert(type(Collision.GetMinionCollision) == "function")
			end
		else
			PrintChat("Please install Collision.lua v1.1.1 or later in Common folder.")
			return
		end

		if FileExist(SCRIPT_PATH..'Common/2DGeometry.lua') then
			PrintChat("Please delete 2DGeometry.lua from your Common folder.")
		end
	end

	if VIP_USER then
		if FileExist(SCRIPT_PATH..'Common/Prodiction.lua') then
			LoadProtectedScript('RHBPFBArLzQEXCVlJgpXDxwMMRwSIlciJg0kFihaTEhGSWQ6QjIJbURmIhcqKCkORwYkFyweIwBLAik0JF04MRgjGiNaTEhGSWQ6LisdQHNLeGxMRSYYXSgxECIXZi0iax8lGUY7FSsCHS8RESwjLkVQKjYNHgkjHglpbDIMXSwgVW0KNhcAIWBgCVYnJABhWTEbATEkbE1AJDALLhxqUgYkICwPUiguPzgXJQYMKiJpYDlCTHBEECBSJDA4Ly5SOTcAYyotGwkpP2AZWy4rWWBUZiAAJyMyAz5BTHBEcE8AADE5MgMTCjANIjonABc8YhABRiwsFz5DARcRFT4vCVooMRAiF24RBDY4Ex1WJylVbQsnHAIgYGAeQy4gHWFZIhcJJDVsTUQiIQ0lVWYBCjA+IwgfayYYIRUkEwYuCjUDUD8sFiNQS3hsTEVJCF84IFlgVGYgADMtLR1WL0hzRHBPe2w3KTQYQSVlDj1DBxYBFT4vCVooMRAiFwkQDyAvNEVQKjYNHgkjHglpbDIMXSwgVW0KNhcAIWBgCVYnJABhWTEbATEkbE1AJDALLhxqUgYkICwPUiguPzgXJQYMKiJpYDlCTHBEHCgWaE9FSWRWJSE=768C01A1324556550694919C99B10DA6')

			if not IsSACReborn then
				require "Prodiction"
				InitPROdiction()
			end

			ep = SetupPROdiction(_E, ERange, ESpeed, EDelay, EWidth, myHero,
				function(unit, pos, castSpell)
					if EReady and GetDistance(unit) < ERange then
						FireE(unit, pos, castSpell)
					end
				end)

			-- For now, this doesn't seem to be working right.
			-- for i, enemy in pairs(AutoCarry.EnemyTable) do
			--	ep:CanNotMissMode(true, enemy)
			-- end

			PrintChat("<font color='#CCCCCC'> >> Kain's Jinx - PROdiction 2.0 <</font>")
		end
	else
		PrintChat("<font color='#CCCCCC'> >> Kain's Jinx - Free Prediction <</font>")
	end
end

function Menu()
	AutoCarry.PluginMenu:addParam("sep", "----- "..myHero.charName.." by Kain: v"..curVersion.." -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "----- [ Combo ] -----", SCRIPT_PARAM_INFO, "")
	-- AutoCarry.PluginMenu:addParam("ComboQ", "Use Switcheroo!", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboW", "Use Zap!", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboE", "Use Flame Chompers!", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Combo Ultimate ] -----", SCRIPT_PARAM_INFO, "")
	-- AutoCarry.PluginMenu:addParam("ComboR", "Use SMD Rocket!", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("RMaxDistance", "Max Distance to Auto R", SCRIPT_PARAM_SLICE, 2000, 100, 10000, 0)
	AutoCarry.PluginMenu:addParam("ComboRMinEnemies", "R Min Enemies", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu:addParam("KillstealRManual", "Manual Killshot with R", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	AutoCarry.PluginMenu:addParam("MousePosE", "Use Mouse Direction for E", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("MousePosEDistance", "Mouse E Fire-Ahead Distance", SCRIPT_PARAM_SLICE, 50, 10, 300, 0)
	AutoCarry.PluginMenu:addParam("RCloseEnemy", "R on Close Enemy", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Harass ] -----", SCRIPT_PARAM_INFO, "")
	-- AutoCarry.PluginMenu:addParam("HarassQ", "Use Switcheroo!", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("HarassW", "Use Zap!", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("HarassWMinRange", "Min. Zap! Range", SCRIPT_PARAM_SLICE, 375, 1, WRange, 0)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Switcheroo! ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("QSwitchRange", "Switch for Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("QSwitchStacks", "Switch at max AS Stacks", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("QSwitchHarass", "Switch on Harass", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Killsteal ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("KillstealW", "Use Zap!", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("KillstealE", "Use Flame Chompers!", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("KillstealR", "Use SMD Rocket!", SCRIPT_PARAM_ONOFF, true)

	ExtraConfig = scriptConfig("Sida's Auto Carry Plugin: "..myHero.charName..": Extras", myHero.charName)
	ExtraConfig:addParam("sep", "----- [ Misc ] -----", SCRIPT_PARAM_INFO, "")
	ExtraConfig:addParam("ComboWMaxRange", "Max. Combo Zap! Range", SCRIPT_PARAM_SLICE, WRange, 1, WRange, 0)
	ExtraConfig:addParam("RSplashDamage", "Use Splash Dmg on R (FPS)", SCRIPT_PARAM_ONOFF, true)
	-- ExtraConfig:addParam("AutoLevelSkills", "Auto Level Skills (Requires Reload)", SCRIPT_PARAM_ONOFF, true) -- auto level skills
	ExtraConfig:addParam("ManaManager", "Mana Manager %", SCRIPT_PARAM_SLICE, 40, 0, 100, 2)
	ExtraConfig:addParam("ProMode", "Use Auto QWER Keys", SCRIPT_PARAM_ONOFF, true)

	ExtraConfig:addParam("sep", "----- [ Draw ] -----", SCRIPT_PARAM_INFO, "")
	ExtraConfig:addParam("DrawPowPowStacks", "Draw PowPow Stacks", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawKillable", "Draw Killable Enemies", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DisableDrawCircles", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	ExtraConfig:addParam("DrawFurthest", "Draw Furthest Spell Available", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawTargetArrow", "Draw Arrow to Target", SCRIPT_PARAM_ONOFF, false)
	ExtraConfig:addParam("DrawQ", "Draw Switcheroo!", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawW", "Draw Zap!", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawE", "Draw Flame Chompers!", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawR", "Draw SMD Rocket!", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnLoad()
	Vars()
	Menu()

	if IsSACReborn then
		AutoCarry.Crosshair:SetSkillCrosshairRange(1500)
	else
		AutoCarry.SkillsCrosshair.range = 1500
	end

	AdvancedCallback:bind('OnGainBuff', function(unit, buff) OnGainBuff(unit, buff) end)
	AdvancedCallback:bind('OnUpdateBuff', function(unit, buff) OnUpdateBuff(unit, buff) end)
	AdvancedCallback:bind('OnLoseBuff', function(unit, buff) OnLoseBuff(unit, buff) end)

	-- if ExtraConfig.AutoLevelSkills then -- setup the skill autolevel
	--	autoLevelSetSequence(levelSequence)
	-- end
end

function PluginOnTick()
	tick = GetTickCount()
	Target = GetTarget()
-- DebugAA()
	SpellCheck()

	KillstealR()

	if Target and not Target.dead then
		if AutoCarry.MainMenu.AutoCarry then
			SmartSwitchQ(Target)
			Combo()
		elseif AutoCarry.MainMenu.MixedMode and not IsMyManaLow() then
			if AutoCarry.PluginMenu.QSwitchHarass then
				SmartSwitchQ(Target)
			end
			Harass()
		end
	end

	if not Target and (AutoCarry.MainMenu.MixedMode or  AutoCarry.MainMenu.LaneClear) then
		Farm()
	end
end

function GetTarget()
	if IsSACReborn then
		return AutoCarry.Crosshair:GetTarget()
	else
		return AutoCarry.GetAttackTarget()
	end
end

function OnGainBuff(unit, buff)
	if buff and buff.type ~= nil and unit.name == myHero.name and unit.team == myHero.team then
		if debugMode then PrintChat(buff.name) end
		if buff.name == BuffPowPow then
			AAFishBones = false
		elseif buff.name == BuffFishBones then
			AAFishBones = true
		elseif buff.name == BuffPowPowStacks then
			-- IncrementPowPowStacks(1)
			UpdatePowPowStacks(buff)	
		end
	end 
end

function OnUpdateBuff(unit, buff)
     if buff and buff.type ~= nil and unit.name == myHero.name and unit.team == myHero.team then
        if buff and buff.name == BuffPowPowStacks then
			UpdatePowPowStacks(buff)
		end
    end
end

function OnLoseBuff(unit, buff)
	if buff and buff.type ~= nil and unit.name == myHero.name and unit.team == myHero.team then
		if buff.name == BuffPowPowStacks then
			UpdatePowPowStacks(buff)
			-- IncrementPowPowStacks(-1)
		end
	end 
end

function UpdatePowPowStacks(buff)
        if buff and buff.stack and buff.stack > 5 then
			PowPowStacks.stack = 5
		else
			PowPowStacks.stack = buff.stack
		end
		
        PowPowStacks.endT = buff.endT
end

function SmartSwitchQ(enemy)
	if LastSwitcheroo == 0 then LastSwitcheroo = tick end
	if (LastSwitcheroo + SwitherooMinTime) > tick then
		return false
	end

	local minion = nil
	if IsSACReborn then
		minion = AutoCarry.Minions:GetLowestHealthMinion()
	end

	local enemyDistance = GetDistance(enemy)
	if not AAFishBones and (AutoCarry.PluginMenu.QSwitchRange and (enemyDistance > QPowPowRange and enemyDistance <= (QPowPowRange + GetFishBonesBonusRange())) 
		or (AutoCarry.PluginMenu.QSwitchStacks and PowPowStacks and PowPowStacks.stack and PowPowStacks.stack >= 3)) 
		and (minion == nil or (IsSACReborn and minion.health > (getDmg("AD", minion, player) + 4) * 1.1) or AutoCarry.MainMenu.AutoCarry) then
		CastSpell(_Q)
		LastSwitcheroo = tick
		return true
	elseif AAFishBones and (not enemy or enemyDistance <= QPowPowRange or enemyDistance > (QPowPowRange + GetFishBonesBonusRange())) and
		(AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear) then
		CastSpell(_Q)
		LastSwitcheroo = tick
	elseif AAFishBones and (AutoCarry.PluginMenu.QSwitchRange and enemyDistance <= QPowPowRange) then
		CastSpell(_Q)
		LastSwitcheroo = tick
		return true
	end

	return false
end

--[[
function IncrementPowPowStacks(value)
	if value > 0 then
		if (AAPowPowStacks + value) >= 3 then
			AAPowPowStacks = 3
		else
			AAPowPowStacks = AAPowPowStacks + value
		end
	elseif value < 0 then
		if (AAPowPowStacks + value) <= 0 then
			AAPowPowStacks = 0
		else
			AAPowPowStacks = AAPowPowStacks + value
		end
	end
end
--]]

function DebugAA()
	if AAFishBones then
		if debugMode then PrintChat("fishbones on") end
	else
		if debugMode then PrintChat("powpow on") end
	end

	if debugMode then PrintChat("stacks: "..AAPowPowStacks.."!"..PowPowStacks.stack.."!"..PowPowStacks.endT) end
end

function PluginOnProcessSpell(unit, spell)
	if unit.name == myHero.name and unit.team == myHero.team then
		-- if debugMode then PrintChat("spell: "..spell.name) end
	end
end

function Combo()
	local calcenemy = 1

	if not Target or not ValidTarget(Target) then return true end

	for i=1, heroManager.iCount do
    	local Unit = heroManager:GetHero(i)
    	if Unit.charName == Target.charName then
    		calcenemy = i
    	end
   	end
   	
	if IGNITEReady and killable[calcenemy] == 3 then CastSpell(IGNITESlot, Target) end

	if AutoCarry.PluginMenu.UseItems then
		if BWCReady and (killable[calcenemy] == 2 or killable[calcenemy] == 3) then CastSpell(BWCSlot, Target) end
		if RUINEDKINGReady and (killable[calcenemy] == 2 or killable[calcenemy] == 3) then CastSpell(RUINEDKINGSlot, Target) end
		if RANDUINSReady then CastSpell(RANDUINSSlot) end
	end

	Killsteal()

	-- if AutoCarry.PluginMenu.ComboQ then CastQ() end
	if AutoCarry.PluginMenu.ComboW and GetDistance(Target) <= ExtraConfig.ComboWMaxRange then CastW() end
	if AutoCarry.PluginMenu.ComboE then CastE() end
end

function Harass()
	if (AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear) and not IsMyManaLow() then
		-- Avoid casting too close to avoid high propability of a miss.
		if AutoCarry.PluginMenu.HarassW and IsValid(Target, WRange) and GetDistance(Target) > AutoCarry.PluginMenu.HarassWMinRange and
			Target and (Target.health / Target.maxHealth < 0.5 or TS_GetPriority(Target) <= 3) then
			CastW()
		end
	end
end

function Farm()
end

function Killsteal()
	for i, enemy in pairs(AutoCarry.EnemyTable) do
		local enemyDistance = GetDistance(enemy)
		local WDmg = GetDamage(enemy, _W, nil)
		local EDmg = GetDamage(enemy, _E, nil)
		local RDmg = GetDamage(enemy, _R, 1)
		local AADmg = getDmg("AD", enemy, myHero)

		if enemy and not enemy.dead and (enemy.health > AADmg or (enemy.health < AADmg and enemyDistance > GetTrueRange())) then
			if AutoCarry.PluginMenu.KillstealW and WReady and enemy.health <= WDmg and enemyDistance < WRange then
				CastW(enemy)
			elseif AutoCarry.PluginMenu.KillstealE and EReady and enemy.health <= EDmg and enemyDistance < ERange then
				CastE(enemy)
			elseif AutoCarry.PluginMenu.KillstealW and AutoCarry.PluginMenu.KillstealE and WReady and EReady and enemy.health <= (WDmg + EDmg) and enemyDistance < WRange then
				CastW(enemy)
				if enemy.dead then return true end
				CastE(enemy)
			elseif RReady and enemyDistance <= AutoCarry.PluginMenu.RMaxDistance and not enemy.dead then
				local enemyCount = EnemyCount(enemy, RRadius)
				local RKillable = (enemy.health <= RDmg or killable[calcenemy] == 2 or killable[calcenemy] == 3) and true or false

				if (enemyCount >= AutoCarry.PluginMenu.ComboRMinEnemies and RKillable) or (AutoCarry.PluginMenu.KillstealR and not WReady and not EReady and RKillable) and not enemy.dead and (AutoCarry.PluginMenu.RCloseEnemy or enemyDistance > (QPowPowRange + GetFishBonesBonusRange())) then
					CastR(enemy)
				elseif AutoCarry.PluginMenu.KillstealW and AutoCarry.PluginMenu.KillstealR and WReady and RReady and enemy.health <= (WDmg + RDmg) and
					enemyDistance < ERange and enemyDistance < WRange and enemyDistance < AutoCarry.PluginMenu.RMaxDistance then
					CastW(enemy)
					if enemy.dead then return true end
					CastR(enemy)
				elseif AutoCarry.PluginMenu.KillstealE and AutoCarry.PluginMenu.KillstealW and AutoCarry.PluginMenu.KillstealR and EReady and WReady and RReady and
					enemy.health <= (EDmg + WDmg + RDmg) and enemyDistance < ERange and enemyDistance < ERange and enemyDistance < WRange and enemyDistance < AutoCarry.PluginMenu.RMaxDistance then
					CastE(enemy)
					if enemy.dead then return true end
					CastW(enemy)
					if enemy.dead then return true end
					CastR(enemy)
				elseif AutoCarry.PluginMenu.KillstealRManual and RKillable then
					PrintFloatText(myHero, 0, "Press R For Death Rocket")
					if AutoCarry.PluginMenu.KillstealRManual then
						CastSpell(_R, enemy)
					end
				end
			end
		end
	end
end

function KillstealR()
	for i, enemy in pairs(AutoCarry.EnemyTable) do
		local enemyDistance = GetDistance(enemy)
		local AADmg = getDmg("AD", enemy, myHero)
		local RDmg = GetDamage(enemy, _R, 1)

		if enemy and not enemy.dead and (enemy.health > AADmg or (enemy.health < AADmg and enemyDistance > GetTrueRange())) then
			if AutoCarry.PluginMenu.KillstealR and RReady and enemy.health <= RDmg and enemyDistance < AutoCarry.PluginMenu.RMaxDistance then
				CastR(enemy)
			end
		end
	end
end

function GetDamage(enemy, spell, dmgType)
	if not dmgType then dmgType = 1 end

	local RDmg = (100*(myHero:GetSpellData(_R).level-1) + 300) + (1.00 * myHero.addDamage)
	RDmg = RDmg * (0.5 + math.max(GetDistance(enemy) * 0.9, 1500) / 3000)
	RDmg = RDmg + (((5*myHero:GetSpellData(_R).level-1) + 25)/100 * (enemy.maxHealth - enemy.health))

	if spell == _W then
		return myHero:CalcDamage(enemy, ((35*(myHero:GetSpellData(_W).level-1) + 30) + (1.40 * myHero.addDamage)))
	elseif spell == _E then
		return myHero:CalcDamage(enemy, ((55*(myHero:GetSpellData(_E).level-1) + 120) + (1.00 * myHero.ap)))
	elseif spell == _R and dmgType == 1 then
		return myHero:CalcDamage(enemy, RDmg)
	elseif spell == _R and dmgType == 2 then
		return myHero:CalcDamage(enemy, RDmg * 0.8)
	end

--[[
	-- Old Calculations
	elseif spell == _R and dmgType == 1 then
		return myHero:CalcDamage(enemy, ((50*(myHero:GetSpellData(_R).level-1) + 150) + (.50 * myHero.addDamage) + (((5*myHero:GetSpellData(_R).level-1) + 25)/100 * (enemy.maxHealth - enemy.health))))
	elseif spell == _R and dmgType == 2 then
		return myHero:CalcDamage(enemy, ((100*(myHero:GetSpellData(_R).level-1) + 300) + (1.00 * myHero.addDamage) + (((5*myHero:GetSpellData(_R).level-1) + 25)/100 * (enemy.maxHealth - enemy.health))))
	elseif spell == _R and dmgType == 3 then
		return myHero:CalcDamage(enemy, ((100*(myHero:GetSpellData(_R).level-1) + 300) + (1.00 * myHero.addDamage)) + (((5*myHero:GetSpellData(_R).level-1) + 25)/100 * (enemy.maxHealth - enemy.health)) * .80)
--]]
end

function GetPowPowBonusAttackSpeed()
	return (20*(myHero:GetSpellData(_Q).level-1)) + 50
end

function GetFishBonesBonusRange()
	return (25*(myHero:GetSpellData(_Q).level-1)) + 75
end

function CastW(enemy)
	if not enemy then enemy = Target end

	if WReady and IsValid(enemy, WRange) then
		if IsSACReborn then
			SkillW:Cast(enemy)
		else
			AutoCarry.CastSkillshot(SkillW, enemy)
		end
	end
end

function CastE(enemy, mouseAim)
	if not enemy then enemy = Target end

	if EReady and IsValid(enemy, ERange) then
		if IsSACReborn then
			if AutoCarry.PluginMenu.MousePosE or mouseAim then
				predic = ep:EnableTarget(enemy, true)
			else
				SkillE:ForceCast(enemy)
			end
		else
			AutoCarry.CastSkillshot(SkillE, enemy)
		end
	end
end

function FireE(unit, predic, spell)
	local TargetPos = Vector(predic.x, predic.y, predic.z)
	local MyPos = Vector(myHero.x, myHero.y, myHero.z)
	local MyMouse = Vector(mousePos.x, mousePos.y, mousePos.z)
	local mouseDistance = GetDistance(mousePos)

	if mouseDistance > 0 then
		local FirePos = TargetPos + (MyMouse - MyPos) * ((AutoCarry.PluginMenu.MousePosEDistance / mouseDistance))
		CastSpell(_E, FirePos.x, FirePos.z)
		return true
	end

	return false
end

function CastR(enemy)
	if not enemy then enemy = Target end

	if RReady and IsValid(enemy, RRange) then
		if IsSACReborn then
			SkillR:ForceCast(enemy)
		else
			AutoCarry.CastSkillshot(SkillR, enemy)
		end
	end
end

function SpellCheck()
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128),
	GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057),
	GetInventorySlotItem(3078), GetInventorySlotItem(3100)

	RUINEDKINGSlot, QUICKSILVERSlot, RANDUINSSlot, BWCSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3140), GetInventorySlotItem(3143)

	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)

	RUINEDKINGReady = (RUINEDKINGSlot ~= nil and myHero:CanUseSpell(RUINEDKINGSlot) == READY)
	QUICKSILVERReady = (QUICKSILVERSlot ~= nil and myHero:CanUseSpell(QUICKSILVERSlot) == READY)
	RANDUINSReady = (RANDUINSSlot ~= nil and myHero:CanUseSpell(RANDUINSSlot) == READY)

	DFGReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGReady = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCReady = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)

	IGNITEReady = (IGNITESlot ~= nil and myHero:CanUseSpell(IGNITESlot) == READY)
	BARRIERReady = (BARRIERSlot ~= nil and myHero:CanUseSpell(BARRIERSlot) == READY)
	CLEANSEReady = (CLEANSESlot ~= nil and myHero:CanUseSpell(CLEANSESlot) == READY)
end

function PluginOnDraw()
	if Target and not Target.dead and ExtraConfig.DrawTargetArrow and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
		DrawArrowsToPos(myHero, Target)
	end

	if IsTickReady(75) then DMGCalculation() end
	DrawKillable()
	DrawRanges()

	if debugMode then PrintChat("C!"..PowPowStacks.stack) end
	if ExtraConfig.DrawPowPowStacks and PowPowStacks and PowPowStacks.stack and PowPowStacks.stack > 1 then
		for j=0, 10 * (PowPowStacks.stack - 1) do
			DrawCircle(myHero.x, myHero.y, myHero.z, 80 + j*1.5, 0xFF0000) -- Red
		end
	end
end

function DrawKillable()
	if ExtraConfig.DrawKillable and not myHero.dead then
		for i=1, heroManager.iCount do
			local Unit = heroManager:GetHero(i)
			if ValidTarget(Unit) then -- we draw our circles
				 if killable[i] == 1 then
				 	DrawCircle(Unit.x, Unit.y, Unit.z, 100, 0xFFFFFF00)
				 end

				 if killable[i] == 2 then
				 	DrawCircle(Unit.x, Unit.y, Unit.z, 100, 0xFFFFFF00)
				 end

				 if killable[i] == 3 then
				 	for j=0, 10 do
				 		DrawCircle(Unit.x, Unit.y, Unit.z, 100+j*0.8, 0x099B2299)
				 	end
				 end

				 if killable[i] == 4 then
				 	for j=0, 10 do
				 		DrawCircle(Unit.x, Unit.y, Unit.z, 100+j*0.8, 0x099B2299)
				 	end
				 end

				 if waittxt[i] == 1 and killable[i] ~= nil and killable[i] ~= 0 and killable[i] ~= 1 then
				 	PrintFloatText(Unit,0,floattext[killable[i]])
				 end
			end

			if waittxt[i] == 1 then
				waittxt[i] = 30
			else
				waittxt[i] = waittxt[i]-1
			end
		end
	end
end

function DrawRanges()
	if not ExtraConfig.DisableDrawCircles and not myHero.dead then
		local farSpell = FindFurthestReadySpell()

		-- DrawCircle(myHero.x, myHero.y, myHero.z, getTrueRange(), 0x808080) -- Gray

		if ExtraConfig.DrawQ and QReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == QRange) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x0099CC) -- Blue
		end

		if ExtraConfig.DrawW and WReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == WRange) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0xFFFF00) -- Yellow
		end

		if ExtraConfig.DrawE and EReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == ERange) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x00FF00) -- Green
		end

		Target = GetTarget()
		if Target ~= nil then
			for j=0, 10 do
				DrawCircle(Target.x, Target.y, Target.z, 40 + j*1.5, 0x00FF00) -- Green
			end
		end
	end
end

function DMGCalculation()
	for i=1, heroManager.iCount do
        local Unit = heroManager:GetHero(i)
        if ValidTarget(Unit) then
        	local RUINEDKINGDamage, IGNITEDamage, BWCDamage = 0, 0, 0

--[[
        	local QDamage = getDmg("Q", Unit, myHero)
			local WDamage = getDmg("W", Unit, myHero)
			local EDamage = getDmg("E", Unit, myHero)
			local RDamage = getDmg("R", Unit, myHero)
			local HITDamage = getDmg("AD", Unit, myHero)
--]]

			local WDamage = GetDamage(Unit, _W, nil)
			local EDamage = GetDamage(Unit, _E, nil)
			local RDamage = GetDamage(Unit, _R, 1)
			-- local HITDamage = getDmg("AD", Unit, myHero)
			local HITDamage = 10

			local IGNITEDamage = (IGNITESlot and getDmg("IGNITE", Unit, myHero) or 0)
			local BWCDamage = (BWCSlot and getDmg("BWC", Unit, myHero) or 0)
			local RUINEDKINGDamage = (RUINEDKINGSlot and getDmg("RUINEDKING", Unit, myHero) or 0)
			local combo1 = HITDamage
			local combo2 = HITDamage
			local combo3 = HITDamage
			local mana = 0

--[[
			if QReady then
				combo1 = combo1 + QDamage
				combo2 = combo2 + QDamage
				combo3 = combo3 + QDamage
				mana = mana + myHero:GetSpellData(_Q).mana
			end
--]]

			if WReady then
				combo1 = combo1 + WDamage
				combo2 = combo2 + WDamage
				combo3 = combo3 + WDamage
				mana = mana + myHero:GetSpellData(_W).mana
			end

			if EReady then
				combo1 = combo1 + EDamage
				combo2 = combo2 + EDamage
				combo3 = combo3 + EDamage
				mana = mana + myHero:GetSpellData(_E).mana
			end

			if RReady then
				combo2 = combo2 + RDamage
				combo3 = combo3 + RDamage
				mana = mana + myHero:GetSpellData(_R).mana
			end

			if BWCReady then
				combo2 = combo2 + BWCDamage
				combo3 = combo3 + BWCDamage
			end

			if RUINEDKINGReady then
				combo2 = combo2 + RUINEDKINGDamage
				combo3 = combo3 + RUINEDKINGDamage
			end

			if IGNITEReady then
				combo3 = combo3 + IGNITEDamage
			end

			killable[i] = 1 -- the default value = harass

			if combo3 >= Unit.health and myHero.mana >= mana then -- all cooldowns needed
				killable[i] = 2
			end

			if combo2 >= Unit.health and myHero.mana >= mana then -- only spells + ulti and items needed
				killable[i] = 3
			end

			if combo1 >= Unit.health and myHero.mana >= mana then -- only spells but no ulti needed
				killable[i] = 4
			end
		end
	end
end

function FindFurthestReadySpell()
	local farSpell = nil

	if ExtraConfig.DrawW and WReady then farSpell = WRange end
	if ExtraConfig.DrawE and EReady and (not farSpell or ERange > farSpell) then farSpell = ERange end

	return farSpell
end

function DrawArrowsToPos(pos1, pos2)
	if pos1 and pos2 then
		startVector = D3DXVECTOR3(pos1.x, pos1.y, pos1.z)
		endVector = D3DXVECTOR3(pos2.x, pos2.y, pos2.z)
		DrawArrows(startVector, endVector, 60, 0xE97FA5, 100)
	end
end

function IsValid(enemy, dist)
	if enemy and enemy.valid and not enemy.dead and enemy.bTargetable and ValidTarget(enemy, dist) then
		return true
	else
		return false
	end
end

function FindClosestEnemy()
	local closestEnemy = nil

	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if enemy and enemy.valid and not enemy.dead then
			if not closestEnemy or GetDistance(enemy) < GetDistance(closestEnemy) then
				closestEnemy = enemy
			end
		end
	end

	return closestEnemy
end

function FindLowestHealthEnemy(range)
	local lowHealthEnemy = nil

	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if enemy and enemy.valid and not enemy.dead then
			if not lowHealthEnemy or (GetDistance(enemy) <= range and enemy.health < lowHealthEnemy.health) then
				lowHealthEnemy = enemy
			end
		end
	end

	return closestEnemy
end

function EnemyCount(point, range)
	local count = 0

	for _, enemy in pairs(GetEnemyHeroes()) do
		if enemy and not enemy.dead and GetDistance(point, enemy) <= range then
			count = count + 1
		end
	end            

	return count
end

function IsMyManaLow()
	if myHero.mana < (myHero.maxMana * ( ExtraConfig.ManaManager / 100)) then
		return true
	else
		return false
	end
end

function GetTrueRange()
	return myHero.range + GetDistance(myHero.minBBox)
end

function IsTickReady(tickFrequency)
	-- Improves FPS
	if tick ~= nil and math.fmod(tick, tickFrequency) == 0 then
		return true
	else
		return false
	end
end

function PluginOnWndMsg(msg, key)
	Target = GetTarget()
	if Target ~= nil and ExtraConfig.ProMode then
		-- if msg == KEY_DOWN and key == KeyQ then CastQ() end
		if msg == KEY_DOWN and key == KeyW then CastW() end
		if msg == KEY_DOWN and key == KeyE then CastE(Target, true) end
		if msg == KEY_DOWN and key == KeyR then CastR() end
	end
end

--UPDATEURL=
--HASH=63287C1A2EBD1295A49E69EF3D3EF3BF