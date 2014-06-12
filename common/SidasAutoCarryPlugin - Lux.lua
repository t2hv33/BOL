--[[
 
        Auto Carry Plugin - Lux Public Edition
                Author: Chancity
                Version: See version variable below.
                Copyright 2013

                Dependency: Sida's Auto Carry
 
                How to install:
                        Make sure you already have AutoCarry installed.
                        Name the script EXACTLY "SidasAutoCarryPlugin - Lux.lua" without the quotes.
                        Place the plugin in BoL/Scripts/Common folder.

                Features:
					Best used with Auto Shield
					Uses passive while farming (Can be disabled)
					Smart Combos (Checks for mana, ability damage, and cool downs), can be disabled
					Draw text for smart combo is shown on target
					Fully customizable ability options in Mixed Mode (Q, E)
					Mixed Mode Harass with mana management
					Draws Skill Ranges based on what skills are ready
				
                
                Download: 

                Version History:
                        Version: 1.0
                                Release         
--]]

if myHero.charName ~= "Lux" then return end

local curVersion = 1.0
local enemyHeros = {}
local enemyHerosCount = 0
local useIgnite = true
local EParticle = nil

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

function Vars()
	QRange, QSpeed, QDelay, QWidth = 1150, 1.175, 240, 80
	WRange, WSpeed, WDelay, WWidth = 1075, 1.4, 150, 275
	ERange, ESpeed, EDelay, EWidth = 1100, 1.3, 150, 275
	RRange, RSpeed, RDelay, RWidth = 3000, math.huge, 700, 200
	QReady, WReady, EReady, RReady = false, false, false, false
	
	ignite = nil
	DFGSlot = nil, nil
	DFGReady, IReady =  false, false

    KeyQ = string.byte("Q")
    KeyE = string.byte("E")
	
	SkillQ = {spellKey = _Q, range = QRange, speed = QSpeed, delay = QDelay, width = QWidth, configName = "lightbinding", displayName = "Q (Light Binding)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = false }
	SkillW = {spellKey = _W, range = WRange, speed = WSpeed, delay = WDelay, width = WWidth, configName = "prismaticbarrier", displayName = "W (Prismatic Barrier)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
	SkillE = {spellKey = _E, range = ERange, speed = ESpeed, delay = EDelay, width = EWidth, configName = "lucentsingularity", displayName = "E (Lucent Singularity)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
	SkillR = {spellKey = _R, range = RRange, speed = RSpeed, delay = RDelay, width = RWidth, configName = "finalspark", displayName = "R (Final Spark)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = false }
		
				
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
	end
	
	--PrintChat("<font color='#e066a3'> >> Ahri Auto Carry Plugin:</font> <font color='#f4cce0'> Running Version "..curVersion.."</font>")
	--PrintChat("<font color='#e066a3'> >> Ahri Auto Carry Plugin:</font> <font color='#f4cce0'> Lux</font>")
	--PrintChat("<font color='#e066a3'> >> Ahri Auto Carry Plugin:</font> <font color='#f4cce0'> Created By: Chancey</font>")
end

function LuxMenu()
	Menu = AutoCarry.PluginMenu
		Menu:addSubMenu("["..myHero.charName.." Auto Carry: Auto Carry]", "autocarry")
			Menu.autocarry:addParam("SmartCombo","Use Smart Combo", SCRIPT_PARAM_ONOFF, true)
				
		Menu:addSubMenu("["..myHero.charName.." Auto Carry: Mixed Mode]", "mixedmode")
			Menu.mixedmode:addParam("MixedUseQ","Use Q (Light Binding)", SCRIPT_PARAM_ONOFF, true)
			Menu.mixedmode:addParam("MixedUseE","Use E (Lucent Singularity)", SCRIPT_PARAM_ONOFF, true)
			Menu.mixedmode:addParam("MixedMinMana","Mana Manager %", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
		
		Menu:addSubMenu("["..myHero.charName.." Auto Carry: Farming]", "farming")
			Menu.farming:addParam("UsePassive","Use Passive", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("["..myHero.charName.." Auto Carry: Other]", "other")
			Menu.other:addParam("ProMode","Use Auto Q & E Keys", SCRIPT_PARAM_ONOFF, false)
			Menu.other:addParam("KS","Kill Steal Q, E, & R", SCRIPT_PARAM_ONOFF, true)
			Menu.other:addParam("Ignite","Use Ignite", SCRIPT_PARAM_ONOFF, true)
			Menu.other:addParam("DrawKillable","Draw Killable", SCRIPT_PARAM_ONOFF, true)
			Menu.other:addParam("DrawKillableTextSize","Draw Killable Text Size", SCRIPT_PARAM_SLICE, 15, 0, 40, 0)
			Menu.other:addParam("DrawTextTargetColor","Target Color", SCRIPT_PARAM_COLOR, {255,255,0,0})
			Menu.other:addParam("DrawTextUnitColor","Unit Color", SCRIPT_PARAM_COLOR, { 255, 255, 50, 50 })
			Menu.other:addParam("DrawRange","Draw Skill Range", SCRIPT_PARAM_ONOFF, true)
		
		Menu:addSubMenu("["..myHero.charName.." Auto Carry: Info]", "scriptinfo")
			Menu.scriptinfo:addParam("sep","["..myHero.charName.." Auto Carry: Version "..curVersion.."]", SCRIPT_PARAM_INFO, "")
			Menu.scriptinfo:addParam("sep1","Created By: Chancity, Please Enjoy!!", SCRIPT_PARAM_INFO, "")		
end

function PluginOnLoad()
	LoadEnemies()
	LuxMenu()
	Vars()
	AutoCarry.SkillsCrosshair.range = ERange
end

function PluginOnTick()	
	SpellCheck()
	damageCalculation()
	
	if Menu.other.KS then KS() end
	
	if EParticle ~= nil and not EParticle.valid then 
		EParticle = nil 
	elseif EParticle ~= nil and EParticle.valid and GetDistance(EParticle, Target) <= 275 then
		CastSpell(_E)
	end 
	
	if Target ~= nil and AutoCarry.MainMenu.AutoCarry then
		FullCombo()
	end
	
	if AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear then
		if Menu.farming.UsePassive then PassiveFarm() end
		if Target ~= nil and CheckMana() then HarassCombo() end
	end
	
	if AutoCarry.MainMenu.LastHit then 
		if Menu.farming.UsePassive then PassiveFarm() end
	end
	
	if Menu.other.Ignite and ignite and IReady then doIgnite() end
end

function FullCombo()
	if Menu.autocarry.SmartCombo then
		for i = 1, enemyHerosCount do
			local Unit = enemyHeros[i].object
			local q = enemyHeros[i].q
			local e = enemyHeros[i].e
			local r = enemyHeros[i].r
			local dfg = enemyHeros[i].dfg
			local myDamage = enemyHeros[i].myDamage
			if Unit.name == Target.name and myDamage >= Target.health then
				if ig == 0 then 
					useIgnite = false 
				else
					useIgnite = true
				end	
				
				if dfg == 1 then
					if DFGReady then CastSpell(DFGSlot, Target) end
				end
				if e == 1 then CastE(Target) end
				if q == 1 then CastQ(Target) end
				if r == 1 then CastR(Target) end
			elseif myDamage < Target.health then
				CastE(Target)
				CastQ(Target)
			end
		end
	else
		CastE(Target)
		CastQ(Target)
	end
end

function CastR(Unit)
	if RReady and IsValid(Target, RRange) then 
		AutoCarry.CastSkillshot(SkillR, Unit)
	end
end

function CastQ(Unit)
	if QReady and IsValid(Target, QRange) then 
		AutoCarry.CastSkillshot(SkillQ, Unit)
	end
end

function CastW()	
end

function CastE()
	if EReady and EParticle == nil and IsValid(Target, ERange) then 
		AutoCarry.CastSkillshot(SkillE, Target)
	end
end

function KS()
	for i = 1, enemyHerosCount do
		local Unit = enemyHeros[i].object
		QDamage, EDamage, RDamage = getDmg("Q", Unit, myHero), getDmg("E", Unit, myHero), getDmg("R", Unit, myHero)
		if EDamage >= Unit.health and EReady then
			CastE(Unit)
		elseif QDamage >= Unit.health and QReady then
			CastQ(Unit)
		elseif RDamage >= Unit.health and RReady then
			CastR(Unit)
		end	
	end
end
	
function HarassCombo()
	if Menu.mixedmode.MixedUseE and EReady and EParticle == nil and CheckMana() and IsValid(Target, SkillE.Range) then 
		AutoCarry.CastSkillshot(SkillE, Target)
	end
	
	if Menu.mixedmode.MixedUseQ and QReady and CheckMana() and IsValid(Target, SkillQ.Range) then
		AutoCarry.CastSkillshot(SkillQ, Target)
	end
end

function doIgnite()
    for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, 600) and useIgnite and enemy.health <= 50 + (20 * player.level) and not IsIgnited(enemy) then
        	CastSpell(ignite, enemy)
        end
    end
end

function IsIgnited(target)
	if TargetHaveBuff("SummonerDot", target) then
		igniteTick = GetTickCount()
		return true
	elseif igniteTick == nil or GetTickCount()-igniteTick>500 then
		return false
	end
end

function IsValid(enemy, dist)
	if enemy and enemy.valid and not enemy.dead and enemy.bTargetable and ValidTarget(enemy, dist) then
		return true
	else
		return false
	end
end

function CheckMana()
	if myHero.mana >= myHero.maxMana*(Menu.mixedmode.MixedMinMana/100) then
		return true
	else
		return false
	end	
end

function SpellCheck()
	Target = AutoCarry.GetAttackTarget()
	DFGSlot = GetInventorySlotItem(3128)

	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)

	DFGReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	IReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function PassiveFarm()
    for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if GetDistance(minion) <= 550 and TargetHaveBuff("luxilluminatingfraulein", minion) then
			if (getDmg("AD", minion, myHero) + getDmg("P", minion, myHero)) >= minion.health then
				myHero:Attack(minion)
			end
		end
	end
end

function PluginOnCreateObj(object)
	if object.name:find("LuxLightstrike_tar") then
		EParticle = object
	end
end

function OnDeleteObj(object)
	if object.name:find("LuxLightstrike_tar") or (EParticle and EParticle.rawHash == object.rawHash) then
		EParticle = nil
	end 
end

function LoadEnemies()
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= player.team then
			local enemyCount = enemyHerosCount + 1
			enemyHeros[enemyCount] = {object = hero, q = 0, e = 0, r = 0, dfg = 0, ig = 0, myDamage = 0, manaCombo = 0}
			enemyHerosCount = enemyCount
		end
	end
end

function damageCalculation()
	for i = 1, enemyHerosCount do
		local Unit = enemyHeros[i].object
		if ValidTarget(Unit) then
			dfgdamage, ignitedamage = 0, 0
			manaCombo, myDamage, QDamage, EDamage, WDamage, RDamage = 0, 0, getDmg("Q", Unit, myHero), getDmg("E", Unit, myHero), getDmg("W", Unit, myHero), getDmg("R", Unit, myHero)
			dfgdamage = (DFGSlot and getDmg("DFG",Unit,myHero) or 0)
			ignitedamage = (ignite and getDmg("IGNITE",Unit,myHero) or 0)
			
			if EReady then
				if myHero.mana >= myHero:GetSpellData(_E).mana and myHero.mana >= manaCombo then
					manaCombo = manaCombo + myHero:GetSpellData(_E).mana
					myDamage = myDamage + EDamage
					enemyHeros[i].e = 1
				else
					enemyHeros[i].e = 0
				end
			else
				enemyHeros[i].e = 0
			end
			
			if QReady then
				if myHero.mana >= myHero:GetSpellData(_Q).mana and myHero.mana >= manaCombo and myDamage < Unit.health then
					manaCombo = manaCombo + myHero:GetSpellData(_Q).mana
					myDamage = myDamage + QDamage
					enemyHeros[i].q = 1
				else
					enemyHeros[i].q = 0
				end
			else
				enemyHeros[i].q = 0
			end
			
			if RReady then
				if myHero.mana >= myHero:GetSpellData(_R).mana and myHero.mana >= manaCombo and myDamage < Unit.health then
					manaCombo = manaCombo + myHero:GetSpellData(_R).mana
					myDamage = myDamage + RDamage
					enemyHeros[i].r = 1
				else
					enemyHeros[i].r = 0
				end
			else
				enemyHeros[i].r = 0
			end
			
			if DFGReady and myDamage < Unit.health then
				myDamage = myDamage * 1.2
				myDamage = myDamage + dfgdamage
				enemyHeros[i].dfg = 1
			else
				enemyHeros[i].dfg = 0
			end
			
			if IReady and myDamage < Unit.health then
				myDamage = myDamage + ignitedamage
				enemyHeros[i].ig = 1
			else
				enemyHeros[i].ig = 0
			end
			
			enemyHeros[i].manaCombo = manaCombo
			enemyHeros[i].myDamage = myDamage
		end
	end
end

function PluginOnDraw()
	if Menu.other.DrawRange and EReady and EParticle == nil then
		DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0xe066a3)
	elseif Menu.other.DrawRange and QReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0xe066a3)
	elseif Menu.other.DrawRange and WReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0xe066a3)
	end
	
	if Menu.other.DrawKillable then
		for i = 1, enemyHerosCount do
			local Unit = enemyHeros[i].object
			local q = enemyHeros[i].q
			local e = enemyHeros[i].e
			local r = enemyHeros[i].r
			local dfg = enemyHeros[i].dfg
			local ig = enemyHeros[i].ig
			local myDamage = enemyHeros[i].myDamage
			local manaCombo = enemyHeros[i].manaCombo
			local comboMessage = ""
			local a = Menu.other.DrawTextTargetColor
			local b = Menu.other.DrawTextUnitColor
			if ValidTarget(Unit) then
				if myDamage >= Unit.health and manaCombo <= myHero.mana and not myHero.dead then
					if e == 1 then
						comboMessage = comboMessage.." E"
					end
					if q == 1 then
						comboMessage = comboMessage.." Q"
					end
					if r >= 1 then
						comboMessage = comboMessage.." R"
					end
					if dfg == 1 then
						comboMessage = comboMessage.." DFG"
					end
					if ig == 1 then
						comboMessage = comboMessage.." IG"
					end
					if Unit == Target then
						DrawText3D("Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.other.DrawKillableTextSize,ARGB(a[1],a[2],a[3],a[4]), true)
					else
						DrawText3D("Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.other.DrawKillableTextSize,ARGB(b[1],b[2],b[3],b[4]), true)
					end
				elseif myDamage < Unit.health and QReady or WReady or EReady then
					if Unit == Target then
						DrawText3D("Harass"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.other.DrawKillableTextSize,ARGB(a[1],a[2],a[3],a[4]), true)
					else
						DrawText3D("Harass"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.other.DrawKillableTextSize,ARGB(b[1],b[2],b[3],b[4]), true)
					end
				elseif not myHero.dead then
					if Unit == Target then
						DrawText3D("Not Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.other.DrawKillableTextSize,ARGB(a[1],a[2],a[3],a[4]), true)
					else
						DrawText3D("Not Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.other.DrawKillableTextSize,ARGB(b[1],b[2],b[3],b[4]), true)
					end
				end
			end
		end 
	end
end

function PluginOnWndMsg(msg, key)
        if Target ~= nil and Menu.other.ProMode then
                if msg == KEY_DOWN and key == KeyQ then CastQ() end
                if msg == KEY_DOWN and key == KeyE then CastE() end
        end
end