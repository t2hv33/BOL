if myHero.charName ~= "Cassiopeia" then return end


--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[							Kalman Filter, all credits too vadash for coding it		    	   	 	        ]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--
class 'Kalman' -- {
function Kalman:__init()
        self.current_state_estimate = 0
        self.current_prob_estimate = 0
        self.Q = 1
        self.R = 15
end
function Kalman:STEP(control_vector, measurement_vector)
        local predicted_state_estimate = self.current_state_estimate + control_vector
        local predicted_prob_estimate = self.current_prob_estimate + self.Q
        local innovation = measurement_vector - predicted_state_estimate
        local innovation_covariance = predicted_prob_estimate + self.R
        local kalman_gain = predicted_prob_estimate / innovation_covariance
        self.current_state_estimate = predicted_state_estimate + kalman_gain * innovation
        self.current_prob_estimate = (1 - kalman_gain) * predicted_prob_estimate
        return self.current_state_estimate
end

local CurVer = 1.72
local NeedUpdate = false
local Do_Once = true
local ScriptName = "JaKCass"
local NetFile = "http://tekilla.cuccfree.org/SidasAutoCarryPlugin%20-%20Cassiopeia.lua"
local LocalFile = BOL_PATH.."Scripts\\Common\\SidasAutoCarryPlugin - Cassiopeia.lua"


function CheckVersion(data)
	local NetVersion = tonumber(data)
	if type(NetVersion) ~= "number" then 
		return 
	end
	if NetVersion and NetVersion > CurVer then
		print("<font color='#FF4000'>-- "..ScriptName..": Update found ! Don't F9 till done...</font>") 
		NeedUpdate = true  
	else
		print("<font color='#00BFFF'>-- "..ScriptName..": You have the lastest version</font>") 
	end
end

function UpdateScript()
	if Do_Once then
		Do_Once = false
		if _G.UseUpdater == nil or _G.UseUpdater == true then 
			GetAsyncWebResult("tekilla.cuccfree.org", ScriptName.."-Ver.txt", CheckVersion) 
		end
	end

	if NeedUpdate then
		NeedUpdate = false
		DownloadFile(NetFile, LocalFile, function()
											if FileExist(LocalFile) then
												print("<font color='#00BFFF'>-- "..ScriptName..": Script updated! Please reload.</font>")
											end
										end
					)
	end
end

AddTickCallback(UpdateScript)


local lastQcastTime = 0
local QisCasting = false
local castRTick = nil
local underTurretTick = nil
local ProdictionQ, ProdictionW, ProdictionR, Prodiction
local enemyHeroes
--[[ Velocities ]]
local kalmanFilters = {}
local velocityTimers = {}
local oldPosx = {}
local oldPosz = {}
local oldTick = {}
local velocity = {}
local lastboost = {}
local velocity_TO = 10
local CONVERSATION_FACTOR = 975
local MS_MIN = 500
---------------------
local enemyList = {}
local ToInterrupt = {}
local TurretList = {}
local InteruptionSpells = {
    { charName = "FiddleSticks", 	spellName = "Crowstorm"},
    { charName = "MissFortune", 	spellName = "MissFortuneBulletTime"},
    { charName = "Nunu", 			spellName = "AbsoluteZero"},
	{ charName = "Caitlyn", 		spellName = "CaitlynAceintheHole"},
	{ charName = "Katarina", 		spellName = "KatarinaR"},
	{ charName = "Karthus", 		spellName = "FallenOne"},
	{ charName = "Malzahar",        spellName = "AlZaharNetherGrasp"},
	{ charName = "Galio",           spellName = "GalioIdolOfDurand"},
	{ charName = "Darius",          spellName = "DariusExecute"},
	{ charName = "MonkeyKing",      spellName = "MonkeyKingSpinToWin"},
}
local DashingChamps = {
    { charName = "Aatrox"},
    { charName = "Gragas"},
    { charName = "Graves"},
	{ charName = "Irelia"},
	{ charName = "Jax"},
	{ charName = "Khazix"},
	{ charName = "Leblanc"},
	{ charName = "LeeSin"},
	{ charName = "MonkeyKing"},
	{ charName = "Pantheon"},
	{ charName = "Renekton"},
	{ charName = "Shen"},
	{ charName = "Sejuani"},
	{ charName = "Tristana"},
	{ charName = "Tryndamere"},
	{ charName = "XinZhao"},
}
--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[												AutoCarry			 	    	       	 			        ]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--
function InitMenu()
	----------------------------------------------------------------------------
    Menu:addSubMenu("-----> Ultimate options", "ultsub")
	Menu.ultsub:addParam("useUlt", "Use ultimate in combo", SCRIPT_PARAM_ONOFF, true)
	Menu.ultsub:addParam("AssistedUlt", "Use assisted ultimate", SCRIPT_PARAM_ONOFF, true)
	Menu.ultsub:addParam("rEnemiesSBTW", "Total weight (in SBTW combo)",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu.ultsub:addParam("rEnemiesAUTO", "Total weight (automatic)",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu.ultsub:addParam("AutoTurretUlt", "Auto ultimate under turret", SCRIPT_PARAM_ONOFF, true)
	----------------------------------------------------------------------------
	
	
	
	----------------------------------------------------------------------------
	Menu:addSubMenu("-----> Mixed mode options", "mmsub")
	Menu.mmsub:addParam("qMix", "Harass with Q",SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	Menu.mmsub:addParam("eMix", "Harass with E", SCRIPT_PARAM_ONOFF, true)
	----------------------------------------------------------------------------
	
	
	
	--------------------------------------
	Menu:addSubMenu("-----> Farm options", "farmsub")
	Menu.farmsub:addParam("qFarm", "Spam Q on minions", SCRIPT_PARAM_ONOFF, false)
	Menu.farmsub:addParam("eFarm", "Kill poisoned minions with E", SCRIPT_PARAM_ONOFF, false)
	Menu.farmsub:addParam("jFarm", "Farm jungle with Q/E", SCRIPT_PARAM_ONOFF, true)
	--------------------------------------
	
	
	
	--------------------------------------
	Menu:addSubMenu("-----> LaneClear options", "laneclearsub")
	Menu.laneclearsub:addParam("qPush", "Use Q to clear", SCRIPT_PARAM_ONOFF, false)
	Menu.laneclearsub:addParam("ePush", "Use E to clear", SCRIPT_PARAM_ONOFF, false)
	Menu.laneclearsub:addParam("wPush", "Use W to clear", SCRIPT_PARAM_ONOFF, true)
	--------------------------------------
	
	
	
	----------------------------------------------------------------------------
	Menu:addSubMenu("-----> AutoHarass options", "ahsub")
	Menu.ahsub:addParam("qAuto", "Auto Harass with Q", SCRIPT_PARAM_ONOFF, false)
	Menu.ahsub:addParam("eAuto", "Auto Harass with E", SCRIPT_PARAM_ONOFF, false)
	----------------------------------------------------------------------------
	
	
	
	
	----------------------------------------------------------------------------
	Menu:addSubMenu("-----> Skills options", "sksub")
	Menu.sksub:addParam("eKS", "Kill steal with E", SCRIPT_PARAM_ONOFF, true)
	Menu.sksub:addParam("FastE", "Cast E before Q hit", SCRIPT_PARAM_ONOFF, false)
	Menu.sksub:addParam("SafeW", "Use W only if Q fail", SCRIPT_PARAM_ONOFF, false)
	--------------------------------------
	Menu.sksub:addSubMenu("-----> Initiate dashing champ with W", "dashingsub")
	Menu.sksub.dashingsub:addParam("initDash", "Use W on champ with dash", SCRIPT_PARAM_ONOFF, false)
	Menu.sksub.dashingsub:addParam("DashingInfo0", "----------------------------", SCRIPT_PARAM_INFO, "")
	if #enemyList > 0 then
		for _, Dashing in pairs(enemyList) do
			if Dashing.canDash then
				Menu.sksub.dashingsub:addParam(Dashing.enemy.charName, "Use on "..Dashing.enemy.charName, SCRIPT_PARAM_ONOFF, true)
			end
		end
	else
		Menu.sksub:addParam("DashingInfo1", "No champion with dash found", SCRIPT_PARAM_INFO, "")
	end
	----------------------------------------------------------------------------
	
	
	
	
	--------------------------------------
	Menu:addSubMenu("-----> Visual options", "vissub")
	Menu.vissub:addParam("dQRange", "Draw Q Range", SCRIPT_PARAM_ONOFF, false)
	Menu.vissub:addParam("dQRangeColor","--Q Range Color", SCRIPT_PARAM_COLOR, { 255, 255, 50, 50 })
	
	Menu.vissub:addParam("dWRange", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
	Menu.vissub:addParam("dWRangeColor","--W Range Color", SCRIPT_PARAM_COLOR, { 255, 255, 50, 50 })
	
	Menu.vissub:addParam("dERange", "Draw E Range", SCRIPT_PARAM_ONOFF, false)
	Menu.vissub:addParam("dERangeColor","--E Range Color", SCRIPT_PARAM_COLOR, { 255, 255, 50, 50 })
	
	Menu.vissub:addParam("dRRange", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
	Menu.vissub:addParam("dRRangeColor","--R Range Color", SCRIPT_PARAM_COLOR, { 255, 255, 50, 50 })
	--------------------------------------
	
	
	
	--------------------------------------
	Menu:addSubMenu("-----> Interuptions", "intsub")
	Menu.intsub:addParam("NinjaInteruption", "Interupt skills with R", SCRIPT_PARAM_ONOFF, false)
	Menu.intsub:addParam("InterupInfo0", "----------------------------", SCRIPT_PARAM_INFO, "")
	if #ToInterrupt > 0 then
		for _, Inter in pairs(ToInterrupt) do
			Menu.intsub:addParam(Inter.spellName, "Stop "..Inter.charName.." "..Inter.spellName, SCRIPT_PARAM_ONOFF, true)
		end
	else
		Menu.intsub:addParam("InterupInfo1", "No supported skills to interupt", SCRIPT_PARAM_INFO, "")
	end
	--------------------------------------
	
	
	
	--------------------------------------
	Menu.intsub:addParam("GeneralInfo0", "----------------------------", SCRIPT_PARAM_INFO, "")
	Menu:addParam("aaCombo", "Use Auto Attack during combo", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("incQRange", "Increased Q Range", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("buffStack", "Refresh Buff Automatically", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("AutoLevelUp", "Autolevel skill (R>E>Q>W)", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("DrawDPS", "Draw time needed to kill enemy", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("MinMana", "Mana Manager min %", SCRIPT_PARAM_SLICE, 35, 0, 100, 2)
	
	if VIP_USER then
		if Prodiction then
			Menu:addParam("Status", "---- PROdiction loaded ----", SCRIPT_PARAM_INFO, "")
		else
			Menu:addParam("minHitChance", "Min Hit Chance %", SCRIPT_PARAM_SLICE, 70, 1, 100, 0)
			Menu:addParam("Status", "---- VIP loaded ----", SCRIPT_PARAM_INFO, "")
		end
	else
		Menu:addParam("Status", "---- FREE User loaded ----", SCRIPT_PARAM_INFO, "")
	end
	--------------------------------------
	
	
	
end

function PluginOnLoad()
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
	
	if IsSACReborn then
		AutoCarry.Crosshair:SetSkillCrosshairRange(800)
		AutoCarry.Crosshair.isCaster = true
		AutoCarry.MyHero:AttacksEnabled(true)
		AutoCarry.Skills:DisableAll()
	else
		AutoCarry.SkillsCrosshair.range = 800
		AutoCarry.CanAttack = true
    end
	
	Recalling = false
	
	if CheckBL() then return false end
	
	
	-------Skills info-------
	qRange, QSpeed, QDelay, QWidth = 850, math.huge, 600, 140
	wRange, WSpeed, WDelay, WWidth = 850, math.huge, 375, 200
	eRange = 700
	rRange, RSpeed, RDelay, RWidth = 780, math.huge, 550, 0
	-------/Skills info-------
	
	tpR = VIP_USER and TargetPredictionVIP(rRange, RSpeed*1000, RDelay/1000) 		 or TargetPrediction(rRange, RSpeed, RDelay)
	tpQ = VIP_USER and TargetPredictionVIP(qRange+75, QSpeed*1000, QDelay/1000, QWidth) or TargetPrediction(qRange+75, QSpeed, QDelay, QWidth)
	tpW = VIP_USER and TargetPredictionVIP(wRange, WSpeed*1000, WDelay/1000, WWidth) or TargetPrediction(wRange, WSpeed, WDelay, WWidth)
	


	Menu = AutoCarry.PluginMenu
	
	if VIP_USER then
		if FileExist(SCRIPT_PATH..'Common/Prodiction.lua') then
			require "Prodiction"
			
			Prodiction = ProdictManager.GetInstance()
			ProdictionQ = Prodiction:AddProdictionObject(_Q, qRange+75, QSpeed*1000, QDelay/1000, 80) 
			ProdictionW = Prodiction:AddProdictionObject(_W, wRange, WSpeed*1000, WDelay/1000, 80) 
			ProdictionR = Prodiction:AddProdictionObject(_R, rRange, RSpeed*1000, RDelay/1000, 0) 
			
			PrintChat("<font color='#ab15d9'> > JaKCass, The Beautiful Snake v"..CurVer.." by TeKilla - PROdiction</font>")
		else
			PrintChat("<font color='#ab15d9'> > JaKCass, The Beautiful Snake v"..CurVer.." by TeKilla - VIP</font>")
		end
	else
		PrintChat("<font color='#ab15d9'> > JaKCass, The Beautiful Snake v"..CurVer.." by TeKilla - FREE</font>")
	end
	
	LoadInterupt()
	LoadTurret()
	JungleCreeps = minionManager(MINION_JUNGLE, qRange, player, MINION_SORT_HEALTH_DES)
	
	abilitySequence = { 1,3,3,2,3,4,1,3,3,1,4,1,1,2,2,4,2,2 }
	
	InitMenu()
end

function PluginOnTick()
	SpellsState()
	UpdateSpeed()
	if IsSACReborn then Target = AutoCarry.Crosshair:GetTarget() else Target = AutoCarry.GetAttackTarget(true) end
	if not Recalling and Menu.buffStack then buffStack() end
	-----------------
	if AutoCarry.MainMenu.AutoCarry then
		Combo()
		if Menu.aaCombo then
			if IsSACReborn then AutoCarry.MyHero:AttacksEnabled(true) else AutoCarry.CanAttack = true end
		else
			if IsSACReborn then AutoCarry.MyHero:AttacksEnabled(false) AutoCarry.MyHero:Move() else AutoCarry.CanAttack = false end
		end
	else 
		if IsSACReborn then AutoCarry.MyHero:AttacksEnabled(true) else AutoCarry.CanAttack = true end
		AutoUlt()
		-----------------
		if (AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear) and not IsMyManaLow() then
			Farm()
		end
		if (AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear) and Menu.farmsub.jFarm then
			JungleFarm()
		end
		if ((AutoCarry.MainMenu.MixedMode and Menu.mmsub.eMix) or (Menu.ahsub.eAuto and not Recalling)) and not IsMyManaLow() then 
			HarrassE() 
		end
		if (AutoCarry.MainMenu.MixedMode and Menu.mmsub.qMix) or (Menu.ahsub.qAuto and not Recalling) then 
			HarrassQ() 
		end
		if AutoCarry.MainMenu.LaneClear and (Menu.laneclearsub.qPush or Menu.laneclearsub.ePush or Menu.laneclearsub.wPush) then 
			PushLane() 
		end
		-----------------
	end
	-----------------
	if Menu.ultsub.AutoTurretUlt then AutoUltUnderTurret() end
	if Menu.sksub.eKS then eKillSteal() end
end
     

function PluginOnAnimation(unit, animation)	
	if unit.isMe then
		if animation:lower():find("recall") then
			Recalling = true
		else
			Recalling = false
		end
		if animation:lower():find("spell") then
			nextTick = os.clock() + 4.9
		end
	end
end
	 
function PluginOnDraw()
	if not myHero.dead then
		if Menu.vissub.dQRange and QReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, RGB(Menu.vissub.dQRangeColor[2], Menu.vissub.dQRangeColor[3], Menu.vissub.dQRangeColor[4]))
		end
		if Menu.vissub.dWRange and WReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, RGB(Menu.vissub.dWRangeColor[2], Menu.vissub.dWRangeColor[3], Menu.vissub.dWRangeColor[4]))
		end
		if Menu.vissub.dERange and EReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, RGB(Menu.vissub.dERangeColor[2], Menu.vissub.dERangeColor[3], Menu.vissub.dERangeColor[4]))
		end
		if Menu.vissub.dRRange and RReady then
			DrawCircle(myHero.x, myHero.y, myHero.z, rRange, RGB(Menu.vissub.dRRangeColor[2], Menu.vissub.dRRangeColor[3], Menu.vissub.dRRangeColor[4]))
		end
	end
	
	if Menu.DrawDPS then
		for i=1, #enemyList do
			if ValidTarget(enemyList[i].enemy, 3000) then
				local qdmgSec = (QReady and getDmg("Q", enemyList[i].enemy, myHero)/3) or 0
				local edmgSec = (EReady and getDmg("E", enemyList[i].enemy, myHero)/1.16) or 0
				local wdmgSec = (WReady and not Menu.sksub.SafeW and getDmg("W", enemyList[i].enemy, myHero)/9) or 0
				local aadmgSec = (Menu.aaCombo and getDmg("AD", enemyList[i].enemy, myHero)) or 0
				
				comboDmg = qdmgSec*3 + 2*(edmgSec*1.16) + wdmgSec*9 + aadmgSec
				if enemyList[i].enemy.health <= comboDmg then 
					killText = "KILL HIM"
				else
					DPS = qdmgSec + 2*edmgSec + wdmgSec + aadmgSec
					if DPS ~= 0 then
						killText = "Killable in "..string.format("%4.1f", enemyList[i].enemy.health/DPS).."s"
					end
				end
				
				DrawText3D(tostring(killText), enemyList[i].enemy.x, enemyList[i].enemy.y, enemyList[i].enemy.z, 15, RGB(222, 245, 15), true)
			end
		end
	end
		
end

function PluginOnWndMsg(msg, key)
	if msg == KEY_DOWN then
		if key == string.byte("R") then 
			AssistedUlt()
		end
	end
end

function PluginOnProcessSpell(unit, spell)
	if Menu.intsub.NinjaInteruption and RReady then
		if #ToInterrupt > 0 then
			for _, Inter in pairs(ToInterrupt) do
				if spell.name == Inter.spellName and unit.team ~= myHero.team then
					if Menu.intsub[Inter.spellName] then
						CastRunit(unit)
					end
				end
			end
		end
	end
	
	if unit.isMe and spell.name == "CassiopeiaNoxiousBlast" then 
		lastQcastTime = GetTickCount() 
		QisCasting = true
	end
end



--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[												OptionFunction			   				 	                ]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--
function CastSpellQ(target)
	if not Prodiction then
		if VIP_USER then
			if AutoCarry.PluginMenu.minHitChance ~= 0 and tpQ:GetHitChance(target) >= AutoCarry.PluginMenu.minHitChance then
				QPos,_,_ = tpQ:GetPrediction(target)
				if QPos ~= nil then
					if GetDistance(QPos) <= qRange then
						Packet('S_CAST', { spellId = _Q, fromX = QPos.x, fromY = QPos.z}):send()
					elseif GetDistance(QPos) <= (qRange+75) then
						local extended_QPos = Vector(myHero) + (Vector(QPos) - Vector(myHero)):normalized() * qRange
						if extended_QPos then
							Packet('S_CAST', { spellId = _Q, fromX = extended_QPos.x, fromY = extended_QPos.z}):send()
						end
					end
				end
			end
			
		else
			QPos,_,_ = tpQ:GetPrediction(target)
			if QPos ~= nil then
				if GetDistance(QPos) <= qRange then
					CastSpell(_Q, QPos.x, QPos.z)
				elseif GetDistance(QPos) <= (qRange+75) then
					local extended_QPos = Vector(myHero) + (Vector(QPos) - Vector(myHero)):normalized() * qRange
					if extended_QPos then
						CastSpell(_Q, extended_QPos.x, extended_QPos.z)
					end
				end
			end
		end
	else
		local QPos = ProdictionQ:GetPrediction(target)
		if QPos ~= nil then
			if GetDistance(QPos) <= qRange then
				Packet('S_CAST', { spellId = _Q, fromX = QPos.x, fromY = QPos.z}):send()
			elseif GetDistance(QPos) <= (qRange+75) then
				local extended_QPos = Vector(myHero) + (Vector(QPos) - Vector(myHero)):normalized() * qRange
				if extended_QPos then
					Packet('S_CAST', { spellId = _Q, fromX = extended_QPos.x, fromY = extended_QPos.z}):send()
				end
			end
		end
	end
end


function CastSpellW(target)
	if not Prodiction then
		if VIP_USER then
			if AutoCarry.PluginMenu.minHitChance ~= 0 and tpW:GetHitChance(target) >= AutoCarry.PluginMenu.minHitChance then
				local WPos,_,_ = tpW:GetPrediction(target)
				if WPos ~= nil then
					Packet('S_CAST', { spellId = _W, fromX = WPos.x, fromY = WPos.z}):send()
				end
			end
		else
			local WPos,_,_ = tpW:GetPrediction(target)
			if WPos ~= nil then
				CastSpell(_W, WPos.x, WPos.z)
			end
		end
	else
		local WPos = ProdictionW:GetPrediction(target)
		if WPos ~= nil then
			--CastSpell(_W, WPos.x, WPos.z)
			Packet('S_CAST', { spellId = _W, fromX = WPos.x, fromY = WPos.z}):send()
		end
	end
end


function CastSpellE(target)
	CastSpell(_E, target)
end


function CastSpellR(target)
	CastSpell(_R, target)
end

function CastSpellR(targetx, targetz)
	if not VIP_USER then 
		CastSpell(_R, targetx, targetz) 
	else 
		CastSpell(_R, targetx, targetz)
	end
end


function CastR(n)
    if RReady then
        local ultEnemies = CountEnemyHeroInRange(rRange + 300)
        if ultEnemies >= n then
            local vec = GetCassMECS(75, rRange, n, false, nil)
            if vec ~= nil and GetDistance(vec) < rRange then
                CastSpellR(vec.x, vec.z)
            end
        end
    end
end

function CastRunit(unit)
    if RReady then
        local vec = GetCassMECS(75, rRange, 1, false, unit)
        if vec ~= nil and GetDistance(vec) < rRange then
            CastSpellR(vec.x, vec.z)
        end
    end
end

function AfterDashFuncQ(unit, pos, spell)
	if GetDistance(pos) < spell.range and myHero:CanUseSpell(spell.Name) == READY then
        CastSpell(spell.Name, pos.x, pos.z)
	end
end

function AutoUlt()
    if castRTick == nil or GetTickCount()-castRTick >= 101 then
        castRTick = GetTickCount()
		if CountEnemyHeroInRange(rRange + 300) >= Menu.ultsub.rEnemiesAUTO then
			CastR(Menu.ultsub.rEnemiesAUTO)
		end
	end
end

function AutoUltUnderTurret()
    if underTurretTick == nil or GetTickCount()-underTurretTick >= 101 then
        underTurretTick = GetTickCount()
		if Target ~= nil then
			if IsUnderTurret(Target, myHero.team) then
				CastRunit(Target)
			end
		end
	end
end

function AssistedUlt()
	if Menu.ultsub.AssistedUlt then
		CastR(1)
	end
end

function Farm()
	for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if Menu.farmsub.qFarm then
			if QReady then
				if GetDistance(minion) <= qRange then
					CastSpell(_Q, minion.x, minion.z)
				end
			end
		end
		if Menu.farmsub.eFarm then
			if EReady then
				if isPoisoned(minion) then
					if GetDistance(minion) <= eRange then
						if minion.health <= getDmg("E", minion, myHero) and minion.health > getDmg("AD", minion, myHero) then
							CastSpellE(minion)
						end
					end
				end
			end
		end
	end
end

function PushLane()
    for _, minion in pairs(AutoCarry.EnemyMinions().objects) do    
		
		if Menu.laneclearsub.qPush then
			if QReady then
				if GetDistance(minion) <= qRange then
					CastSpell(_Q, minion.x, minion.z)
				end
			end
		end
        
		if Menu.laneclearsub.ePush then
			if EReady then
				if isPoisoned(minion) then
					if GetDistance(minion) <= eRange then
						CastSpellE(minion)
					end
				end
			end
		end           
		
        if Menu.laneclearsub.wPush then
			if WReady and not IsMyManaLow() then
				if not isPoisoned(minion) then
					if GetDistance(minion) <= wRange then
						CastSpell(_W, minion.x, minion.z)
					end
				end
			end
        end     
		
    end
end

function HarrassQ()
	if Target then
		if GetDistance(Target) <= qRange and HaveLowVelocity(Target, 750) then
				CastSpellQ(Target)
			end
		end
end

function HarrassE()
	if Target then
		if GetDistance(Target) <= eRange then
			if isPoisoned(Target) then
				CastSpellE(Target)
			end
		end
	end
end

function eKillSteal()
	if Target and not Target.dead then
		if EReady and GetDistance(Target) <= eRange then
			if Target.health <= getDmg("E",Target,myHero) then
				CastSpellE(Target)
			end
		end
	end
end

function Combo()
	if Target and not Target.dead then
		------------------
		if Menu.sksub.dashingsub[Target.charName] and Menu.sksub.dashingsub.initDash then
			if WReady and GetDistance(Target) <= wRange then
				CastSpellW(Target)
			end
		end
		------------------
		if QReady then
			if not isPoisoned(Target) then
				CastSpellQ(Target)
			end
		end
		------------------
		if EReady and GetDistance(Target) <= eRange then
			if isPoisoned(Target) or (Menu.sksub.FastE and QisCasting) or Target.health <= getDmg("E",Target,myHero) then
				CastSpellE(Target)
			end
		end
		------------------
		if WReady and GetDistance(Target) <= wRange then
			if (not QReady and not Menu.sksub.SafeW) or (not QisCasting and not isPoisoned(Target) and Menu.sksub.SafeW) then
				if not IsMyManaLow() then
					CastSpellW(Target)
				end
			end
		end
		------------------
		if not QReady and not EReady then
			if Menu.ultsub.useUlt then
				CastR(Menu.ultsub.rEnemiesSBTW)
			end
		end
		------------------
	end
end

nextTick = 0
function buffStack()
	if nextTick - os.clock() > 0 then
		return
	end
	local eMinions = AutoCarry.EnemyMinions()
	eMinions:update()
	for _, minion in pairs(eMinions.objects) do
		if ValidTarget(minion) then
			if QReady and GetDistance(minion) <= qRange then
				CastSpell(_Q, minion.x, minion.z)
				return
			end
		end
	end
	if not IsMyManaLow() then
		if GetDistanceFromMouse(myHero) <= qRange then
			CastSpell(_Q, mousePos.x, mousePos.z)
		else
			CastSpell(_Q, myHero.x, myHero.z)
		end
	end
end

function JungleFarm()
	JungleCreeps:update()
	for i, minion in pairs(JungleCreeps.objects) do
		if ValidTarget(minion) then
			if QReady and not isPoisoned(minion) then
				CastSpell(_Q, minion.x, minion.z)
			end
			if EReady and isPoisoned(minion) then
				CastSpell(_E, minion)
			end
		end
	end	
end

--[[       ----------------------------------------------------------------------------------------------       ]]--
--[[					     	 		     	     Utility			   	      								]]--
--[[       ----------------------------------------------------------------------------------------------       ]]--
function IsUnderTurret(target, flag) 
	local f = flag or TEAM_ENEMY	--Credits iuser99
	for i, turret in pairs(TurretList) do 
		if turret and not turret.dead and turret.team == f and not string.find(turret.name, "TurretShrine") then 
			if GetDistance(target, turret) <= 720 then 
				return true 
			end 
		end 
	end 
	return false 
end 

function CountEnemyHeroInRange(range)
    local enemyInRange = 0
    for i = 1, heroManager.iCount, 1 do
        local hero = heroManager:getHero(i)
        if ValidTarget(hero, range) then
            enemyInRange = enemyInRange + 1
        end
    end
    return enemyInRange
end

function areClockwise(testv1,testv2)
    return -testv1.x * testv2.y + testv1.y * testv2.x>0 --true if v1 is clockwise to v2
end

function sign(x)
    if x> 0 then return 1
    elseif x<0 then return -1
    end
end

local mecCheckTick = 0
function GetCassMECS(theta, radius, minimum, bForce, unit)
    if GetTickCount() - mecCheckTick < 100 then return nil end
    mecCheckTick = GetTickCount()   
    --Build table of enemies in range
    nFaced = 0
    n = 1
    v1,v2,v3 = 0,0,0
    largeN,largeV1,largeV2 = 0,0,0
    theta1,theta2,smallBisect = 0,0,0
    coneTargetsTable = {}

    for i = 1, heroManager.iCount, 1 do
        hero = heroManager:getHero(i)
		if unit == nil then
			if not Prodiction then
				enemyPos = tpR:GetPrediction(hero)
				--enemyPos = GetPredictionPos(hero,1000)
			else
				enemyPos = ProdictionR:GetPrediction(hero)
			end
			if ValidTarget(hero, 1000) and enemyPos and GetDistance(enemyPos) < radius then-- and inRadius(hero,radius*radius) then
				coneTargetsTable[n] = hero
				n=n+1
				if --(GetDistance(hero.visionPos) < GetDistance(hero)) 
					--or (killable[hero.networkID] >= 1 and killable[hero.networkID] <= 4) 
					--[[or]] bForce == false then
					nFaced = nFaced + 1
				else
					nFaced = nFaced + 0.67
				end            
			end
		elseif unit.charName == hero.charName then
			if not Prodiction then
				enemyPos = tpR:GetPrediction(hero)
			else
				enemyPos = ProdictionR:GetPrediction(hero)
			end
			if ValidTarget(hero, 1000) and enemyPos and GetDistance(enemyPos) < radius then-- and inRadius(hero,radius*radius) then
				coneTargetsTable[n] = hero
				n=n+1
				if --(GetDistance(hero.visionPos) < GetDistance(hero)) 
					--or (killable[hero.networkID] >= 1 and killable[hero.networkID] <= 4) 
					--[[or]] bForce == false then
					nFaced = nFaced + 1
				else
					nFaced = nFaced + 0.67
				end            
			end
		end
			
    end

    if #coneTargetsTable>=2 then -- true if calculation is needed
    --Determine if angle between vectors are < given theta
            for i=1, #coneTargetsTable,1 do
                    for j=1,#coneTargetsTable, 1 do
                            if i~=j then
                                    --Position vector from player to 2 different targets.
                                    v1 = Vector(coneTargetsTable[i].x-player.x , coneTargetsTable[i].z-player.z)
                                    v2 = Vector(coneTargetsTable[j].x-player.x , coneTargetsTable[j].z-player.z)
                                    thetav1 = sign(v1.y)*90-math.deg(math.atan(v1.x/v1.y))
                                    thetav2 = sign(v2.y)*90-math.deg(math.atan(v2.x/v2.y))
                                    thetaBetween = thetav2-thetav1                 

                                    if (thetaBetween) <= theta and thetaBetween>0 then --true if targets are close enough together.
                                            if #coneTargetsTable == 2 then --only 2 targets, the result is found.
                                                    largeV1 = v1
                                                    largeV2 = v2
                                            else
                                                    --Determine # of vectors between v1 and v2                                                     
                                                    tempN = 0
                                                    for k=1, #coneTargetsTable,1 do
                                                            if k~=i and k~=j then
                                                                    --Build position vector of third target
                                                                    v3 = Vector(coneTargetsTable[k].x-player.x , coneTargetsTable[k].z-player.z)
                                                                    --For v3 to be between v1 and v2
                                                                    --it must be clockwise to v1
                                                                    --and counter-clockwise to v2
                                                                    if areClockwise(v3,v1) and not areClockwise(v3,v2) then
                                                                            tempN = tempN+1
                                                                    end
                                                            end
                                                    end
                                                    if tempN > largeN then
                                                    --store the largest number of contained enemies
                                                    --and the bounding position vectors
                                                            largeN = tempN
                                                            largeV1 = v1
                                                            largeV2 = v2
                                                    end
                                            end
                                    end
                            end
                    end
            end
    elseif #coneTargetsTable==1 and minimum == 1 then
            return coneTargetsTable[1]
    end
   
    if largeV1 == 0 or largeV2 == 0 then
    --No targets or one target was found.
            return nil
    else
            --small-Bisect the two vectors that encompass the most vectors.
            if largeV1.y == 0 then
                    theta1 = 0
            else
                    theta1 = sign(largeV1.y)*90-math.deg(math.atan(largeV1.x/largeV1.y))
            end
            if largeV2.y == 0 then
                    theta2 = 0
            else
                    theta2 = sign(largeV2.y)*90-math.deg(math.atan(largeV2.x/largeV2.y))
            end

            smallBisect = math.rad((theta1 + theta2) / 2)
            vResult = {}
            vResult.x = radius*math.cos(smallBisect)+player.x
            vResult.y = player.y
            vResult.z = radius*math.sin(smallBisect)+player.z
            
            return vResult
    end
end

function LoadTurret()
	for i=1, objManager.maxObjects do
		local obj = objManager:getObject(i) 
		if obj and obj.valid and obj.type == "obj_AI_Turret" then 
			table.insert(TurretList, obj)
		end 
	end
end

function CheckBL() if myHero.name == "Team Amal" then PrintChat("Go uninstall noob")  return true end end
	
function LoadInterupt()
	enemyHeroes = GetEnemyHeroes()
	for _, enemy in pairs(enemyHeroes) do	--thank's to pqmailer
		
		for _, IsDashChamp in pairs(DashingChamps) do
			if enemy.charName == IsDashChamp.charName then
				table.insert(enemyList, {enemy = enemy, canDash = true})
				if Prodiction then
					ProdictionQ:GetPredictionAfterDash(enemy, AfterDashFuncQ)
				end
			else
				table.insert(enemyList, {enemy = enemy, canDash = false})
			end
		end
		
		kalmanFilters[enemy.networkID] = Kalman()
		velocityTimers[enemy.networkID] = 0
		oldPosx[enemy.networkID] = 0
		oldPosz[enemy.networkID] = 0
		oldTick[enemy.networkID] = 0
		velocity[enemy.networkID] = 0
		lastboost[enemy.networkID] = 0
		for _, champ in pairs(InteruptionSpells) do
			if enemy.charName == champ.charName then
				table.insert(ToInterrupt, {charName = champ.charName, spellName = champ.spellName})
			end
		end
	end
end

function HaveLowVelocity(target, time)
        if ValidTarget(target, 1200) then
                return (velocity[target.networkID] < MS_MIN and target.ms < MS_MIN and GetTickCount() - lastboost[target.networkID] > time)
        else
                return nil
        end
end
 
function _calcHeroVelocity(target, oldPosx, oldPosz, oldTick)
        if oldPosx and oldPosz and target.x and target.z then
                local dis = math.sqrt((oldPosx - target.x) ^ 2 + (oldPosz - target.z) ^ 2)
                velocity[target.networkID] = kalmanFilters[target.networkID]:STEP(0, (dis / (GetTickCount() - oldTick)) * CONVERSATION_FACTOR)
        end
end
 
function UpdateSpeed()
        local tick = GetTickCount()
        for i=1, #enemyList do
                local hero = enemyList[i].enemy
                if ValidTarget(hero) then
                        if velocityTimers[hero.networkID] <= tick and hero and hero.x and hero.z and (tick - oldTick[hero.networkID]) > (velocity_TO-1) then
                                velocityTimers[hero.networkID] = tick + velocity_TO
                                _calcHeroVelocity(hero, oldPosx[hero.networkID], oldPosz[hero.networkID], oldTick[hero.networkID])
                                oldPosx[hero.networkID] = hero.x
                                oldPosz[hero.networkID] = hero.z
                                oldTick[hero.networkID] = tick
                                if velocity[hero.networkID] > MS_MIN then
                                        lastboost[hero.networkID] = tick
                                end
                        end
                end
        end
end


--[Credits to Vadash]--
function isPoisoned(target)
    local delay = math.max(GetDistance(target), 700)/1800 + 0.100
    for i = 1, target.buffCount do
        local tBuff = target:getBuff(i)
        if BuffIsValid(tBuff) and (tBuff.name == "cassiopeianoxiousblastpoison" or tBuff.name == "cassiopeiamiasmapoison" 
            or tBuff.name == "toxicshotparticle" or tBuff.name == "bantamtraptarget" or tBuff.name == "poisontrailtarget" 
            or tBuff.name == "deadlyvenom") and tBuff.endT - delay - GetGameTimer() > 0 then
            return true
        end
    end 
    return false
end

function SpellsState()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	if not QReady and GetTickCount() > lastQcastTime + 870 then QisCasting = false end
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
	
	--qRange = 850 + (Menu.incQRange and 75 or 0)
	
	if Menu.AutoLevelUp then autoLevelSetSequence(abilitySequence) end
end

--[Credits to Kain]--
function IsMyManaLow()
    if myHero.mana < (myHero.maxMana * ( AutoCarry.PluginMenu.MinMana / 100)) then
        return true
    else
        return false
    end
end