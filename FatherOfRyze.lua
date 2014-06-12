-- #################################################################################################
-- ##                                                                                             ##
-- ##                     Father of Ryze Script                                                   ##
-- ##                                Version Final                                                ##
-- ##                                         BomD							                      ##
-- ##                                                                                             ##
-- ##                            Completely Rewritten by BomD                                     ##
-- ##                                                                                             ##
-- #################################################################################################

-- #################################################################################################
-- ##                               Main Features & Changelog                                     ##
-- #################################################################################################
-- ## 2.0 - First Rewritten Release                                                               ##
-- ## 2.1 - New Long Combo                                                                        ##
-- ##     - Cage fleeing Enemies                                                                  ##
-- ## 2.2 - New Harass (Auto Q Enemy in Range)                                                    ##
-- ##     - Combo Switcher (Burst > Long                                                          ##
-- ## 2.3 - Auto AA Farm                                                                          ##
-- ## 2.4 - Fixed Bugs + Siege and Super Minion W and Q Farm if Q Framing Enabled                 ##
-- ## 2.41- Fixed Critical Typo                                                                   ##
-- ## 2.42- AA Farm was Toggle should be Hotkey so fixed as Hotkey                                ##
-- ## 2.43- Fixed Bug that Siege Minion caused Auto Q stop working for smaller Minions            ##
-- ## 2.44- Mouse Follow Toggle                                                                   ##
-- ## 2.5 - Auto Cage if Enemy under Tower Harass (Many Thx at vadash)                            ##
-- ## 2.6 - W Cage Only Nearest Champion  (Thx at Trus for findClosestEnemy)                      ##
-- ## 2.7 - Improved OnDraw (Show Killable-Text even with Circles Disabled)                       ##
-- ##     - New Menu "Ryze Combo Config" En- and Disable all PermaShow Info (Need Reload F9)      ##
-- ## 3.0 - Power Farmer:                                                                         ##
-- ##     - Combo Jungle Creeps if no Target is around (Thx at AutoSmite by eXtragoZ)             ##
-- ##       Q - R(if Activated in Settings) - Q - W - Q - E - Q and so on...                      ##
-- ##     - Fixed a possible Bug in Long Combo                                                    ##
-- ##     - Redesigned Settings Menu for some Cleanup                                             ##
-- ## 3.1 - New Item Support (DFG,HXG,BWC) and Ignite Support (Thx at Burn)                       ##
-- ## 3.2 - Improved Tower Caging (Cage if Enemy casts against you in Tower Range -> No flee)     ##
-- ## 3.3 - New Steal Objectives Mode                                                             ##
-- ## 3.4 - Multiple Changes at Combos                                                            ##
-- ## 3.5 - Jungle Creeps Combo now a Hotkey                                                      ##
-- ##     - Added small Camps to Combo                                                            ##
-- ##     - New Follow Cursor Modes:                                                              ##
-- ##                                - Follow Cursor if Combo Key pressed                         ##
-- ##                                - Follow Cursor if Spell is Casted                           ##
-- ## 3.6 - Auto Muramana Toggle :)                                                               ##
-- ## 3.61- Bugfixed!                                                                             ##
-- ## 3.7 - I hope this Relese fixed the non Save of Settings                                     ##
-- ## 3.71- Use Ultimate in Jungle Combo is a Key Toggle again (L by default)                     ##
-- ## 3.8 - Auto Level Up (Q or W,if 1. W then Q or 1. Q then W,E,Q,Q,R,Q,W,Q,W,R,W,W,E,E,R,E,E)  ##
-- ## 4.0 -BomD																					  ##	
-- ##	  -Auto Using Item																		  ##
-- ##     http://www.alanwood.net/demos/ansi.html												  ##
-- ##     http://www.indigorose.com/webhelp/ams/Program_Reference/Misc/Virtual_Key_Codes.htm      ##
-- #################################################################################################
-- #################################################################################################
-- #################################################################################################

-- #################################################################################################

-- #################################################################################################
-- ## TODO: Drawing System using SourceLib                                                        ##
-- #################################################################################################

-- #################################################################################################
-- ## Please Send me your Feedback so I can improve this Script further :)                        ##
-- #################################################################################################


if GetMyHero().charName ~= "Ryze" then return end
--Spell Data
--local Ranges = {[_Q] = 650, [_W] = 625, [_E] = 625, [_R] = 200}

qRange = 650
wRange = 625
eRange = 625 -- Real range is 675
rRange = 200 -- Range of your ulti AOE
AARange = 550
JungleRange = 1000
turretRange = 950
local waittxt = {}
local calculationenemy = 1
local tick = nil
killable = {}
turrets = {}
qcasted = true
waitDelay = 400
nextTick = 0
CageTurret = nil
Switch = false
targeting = false
local ignite = nil
local DFGSlot, HXGSlot, BWCSlot = nil, nil, nil
local DFGREADY, HXGREADY, BWCREADY, IREADY = false, false, false, false
local floattext = {"Cooldown!","Rape No' ^^"}
local levelSequence = {nil,0,3,1,1,4,1,2,1,2,4,2,2,3,3,4,3,3}
--Add new version
--require("SourceLib")

--Add Auto Shield Quyen Truong Thien Su
local typeshield
local spellslot
local typeheal
local healslot
local typeult
local ultslot
local wallslot
local range = 0
local healrange = 0
local ultrange = 0
local shealrange = 300
local lisrange = 600
local FotMrange = 700


local sbarrier = nil
local sheal = nil
local useitems = true
local spelltype = nil
local casttype = nil
local BShield,SShield,Shield,CC = false,false,false,false
local shottype,radius,maxdistance = 0,0,0
local hitchampion = false
--End Quyen Truong


function OnLoad()
--Add Quyen Truong
if myHero:GetSpellData(SUMMONER_1).name:find("SummonerBarrier") then sbarrier = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerBarrier") then sbarrier = SUMMONER_2 end
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerHeal") then sheal = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerHeal") then sheal = SUMMONER_2 end
	if typeshield ~= nil then
		ASConfig = scriptConfig("(AS) Auto Shield", "AutoShield")
		for i=1, heroManager.iCount do
			local teammate = heroManager:GetHero(i)
			if teammate.team == myHero.team then ASConfig:addParam("teammateshield"..i, "Shield "..teammate.charName, SCRIPT_PARAM_ONOFF, true) end
		end
		ASConfig:addParam("maxhppercent", "Max percent of hp", SCRIPT_PARAM_SLICE, 100, 0, 100, 0)	
		ASConfig:addParam("mindmgpercent", "Min dmg percent", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
		ASConfig:addParam("mindmg", "Min dmg approx", SCRIPT_PARAM_INFO, 0)
		ASConfig:addParam("skillshots", "Shield Skillshots", SCRIPT_PARAM_ONOFF, true)
		ASConfig:addParam("shieldcc", "Auto Shield Hard CC", SCRIPT_PARAM_ONOFF, true)
		ASConfig:addParam("shieldslow", "Auto Shield Slows", SCRIPT_PARAM_ONOFF, true)
		ASConfig:addParam("drawcircles", "Draw Range", SCRIPT_PARAM_ONOFF, true)
		ASConfig:permaShow("mindmg")
	end
	if typeheal ~= nil then
		AHConfig = scriptConfig("(AS) Auto Heal", "AutoHeal")
		for i=1, heroManager.iCount do
			local teammate = heroManager:GetHero(i)
			if teammate.team == myHero.team then AHConfig:addParam("teammateheal"..i, "Heal "..teammate.charName, SCRIPT_PARAM_ONOFF, true) end
		end
		AHConfig:addParam("maxhppercent", "Max percent of hp", SCRIPT_PARAM_SLICE, 100, 0, 100, 0)	
		AHConfig:addParam("mindmgpercent", "Min dmg percent", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
		AHConfig:addParam("mindmg", "Min dmg approx", SCRIPT_PARAM_INFO, 0)
		AHConfig:addParam("skillshots", "Heal Skillshots", SCRIPT_PARAM_ONOFF, true)
		AHConfig:addParam("drawcircles", "Draw Range", SCRIPT_PARAM_ONOFF, true)
		AHConfig:permaShow("mindmg")
	end

	if sbarrier ~= nil then
		ASBConfig = scriptConfig("Ryze-Dùng Lá Chän'", "AutoSummonerBarrier")
		ASBConfig:addParam("barrieron", "Barrier", SCRIPT_PARAM_ONOFF, false)
		ASBConfig:addParam("maxhppercent", "Max percent of hp", SCRIPT_PARAM_SLICE, 100, 0, 100, 0)
		ASBConfig:addParam("mindmgpercent", "Min dmg percent", SCRIPT_PARAM_SLICE, 95, 0, 100, 0)
		ASBConfig:addParam("mindmg", "Min dmg approx", SCRIPT_PARAM_INFO, 0)
		ASBConfig:addParam("skillshots", "Shield Skillshots", SCRIPT_PARAM_ONOFF, true)
	end
	if sheal ~= nil then
		ASHConfig = scriptConfig("Ryze-Hô`i Máu", "AutoSummonerHeal")
		for i=1, heroManager.iCount do
			local teammate = heroManager:GetHero(i)
			if teammate.team == myHero.team then ASHConfig:addParam("teammatesheal"..i, "Heal "..teammate.charName, SCRIPT_PARAM_ONOFF, false) end
		end
		ASHConfig:addParam("maxhppercent", "Max % of hp", SCRIPT_PARAM_SLICE, 100, 0, 100, 0)
		ASHConfig:addParam("mindmgpercent", "Min damage percent", SCRIPT_PARAM_SLICE, 95, 0, 100, 0)
		ASHConfig:addParam("mindmg", "Min dmg - khoang? tâ`m", SCRIPT_PARAM_INFO, 0)
		ASHConfig:addParam("skillshots", "Heal Skillshots", SCRIPT_PARAM_ONOFF, true)
	end
	if useitems then
		ASIConfig = scriptConfig("Ryze-BomD-Ðô`Kích Hoat.", "AutoShieldItems")
		for i=1, heroManager.iCount do
			local teammate = heroManager:GetHero(i)
			if teammate.team == myHero.team then ASIConfig:addParam("teammateshieldi"..i, "Shield "..teammate.charName, SCRIPT_PARAM_ONOFF, false) end
		end
		ASIConfig:addParam("maxhppercent", "Max % of hp", SCRIPT_PARAM_SLICE, 100, 0, 100, 0)
		ASIConfig:addParam("mindmgpercent", "Min damage percent", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		ASIConfig:addParam("mindmg", "Min dmg - khoang? tâ`m", SCRIPT_PARAM_INFO, 0)
		ASIConfig:addParam("skillshots", "Buff Khiên Skillshots", SCRIPT_PARAM_ONOFF, true)
	end
--End


	lastcast = _R
	RyzeConfig = scriptConfig("Ryze BomD Combo", "Ryze_Config")
	RyzeConfigConfig = scriptConfig("Ryze-BomD-Visual Config", "Ryze_Config_Config")
	RyzeSettings = scriptConfig("Ryze-BomD-Cài Ðät.", "Ryze_Settings")
	RyzeConfig:addParam("BurstActive", "Combo Nhanh (Space)", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	RyzeConfig:addParam("LongActive", "Combo Dài (QRQEQWQ) (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
	RyzeConfig:addParam("Ignite", "Thiêu Ðôt' nê'u sát dc.", SCRIPT_PARAM_ONKEYTOGGLE, true, 79)
	RyzeConfig:addParam("JungleActive", "Combo Red,Blue,Dragon,Baron (~)", SCRIPT_PARAM_ONKEYDOWN, false, 192)
	RyzeConfig:addParam("useUlti", "Dùng ultimate khi combos", SCRIPT_PARAM_ONOFF, true)
	RyzeConfig:addParam("useUltiJungle", "Dùng ultimate combo Quái Rùng (L)", SCRIPT_PARAM_ONKEYDOWN, true, 76)
	RyzeConfig:addParam("useMura", "Auto dùng Muramana nê'u có Ðich.", SCRIPT_PARAM_ONOFF, true)
	RyzeSettings:addParam("minMuraMana", "Min Mana Muramana", SCRIPT_PARAM_SLICE, 25, 0, 100, 2)
	RyzeConfig:addParam("cageW", "Trói Ðich. trong tru. quâ'y rô'i (U)", SCRIPT_PARAM_ONKEYTOGGLE, true, 85)
	RyzeConfig:addParam("autoQFarm", "Auto Q Farm (T)", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)
	RyzeConfig:addParam("PowerFarm", "Power QWE Farm (I)", SCRIPT_PARAM_ONKEYTOGGLE, false, 73)
	RyzeConfig:addParam("autoAAFarm", "Auto AA Farm (K)", SCRIPT_PARAM_ONKEYDOWN, false, 75)
	RyzeSettings:addParam("autoAAFollow", "ON/OFF Auto Attack Theo Sau Mouse", SCRIPT_PARAM_ONOFF, true)
	RyzeSettings:addParam("autoMouseFollow", "Theo sau mouse khi dùng chiêu", SCRIPT_PARAM_ONOFF, false)
	RyzeSettings:addParam("autoComboFollow", "Theo sau mouse khi dùng combo", SCRIPT_PARAM_ONOFF, true)
	RyzeConfig:addParam("autoQToggle", "Auto Q Harass (On/Off) (Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, 90)
	RyzeConfig:addParam("autoQHarass", "Auto Q Harass (Hotkey) (J)", SCRIPT_PARAM_ONKEYDOWN, false, 74)
	RyzeSettings:addParam("qMinMana", "Auto Q Farm min mana %",  SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
	RyzeSettings:addParam("qMinManaHarass", "Auto Q Harass min mana %", SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
	RyzeSettings:addParam("PowerMinMana", "Power Farm min mana %", SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
	RyzeConfig:addParam("CageHunter", "Trói kë Ðich. gâ`n nhâ't (W)", SCRIPT_PARAM_ONKEYDOWN, false, 87)
	RyzeSettings:addParam("whunt", "Trói W ngay khi trong tâ`m", SCRIPT_PARAM_SLICE, 550, 0, 625, 0)
	RyzeSettings:addParam("wflee", "Trói W khi Combo nê'u out-range (N)", SCRIPT_PARAM_SLICE, 550, 0, 625, 0)
	RyzeSettings:addParam("winsta", "Trói W ngay khi Ðich.Bay Ði (M)", SCRIPT_PARAM_ONKEYTOGGLE, true, 77)
	RyzeSettings:addParam("ComboSwitch", "Chuyê?n Combo", 	SCRIPT_PARAM_ONKEYTOGGLE, true, 78)
	RyzeSettings:addParam("minCDRnew", "CDR % Ðê? Chuyên? Combo", SCRIPT_PARAM_SLICE, 35, 0, 40, 0)
	RyzeConfigConfig:addParam("BurstActiveshow", "Hiên?Thi: Combo Nhanh", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("LongActiveshow", "Hiên?Thi: Combo Dài", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("useUltishow", "Hiên?Thi: Dùng ultimate khi combos", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("cageWshow", "Hiên?Thi: Trói Ðich. trong tru. quâ'y rô'i", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("CageHuntershow", "Hiên?Thi: Trói kë Ðich. gâ`n nhâ't", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("winstashow", "Hiên?Thi: Trói W ngay khi Ðich.Bay Ði", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoQFarmshow", "Hiên?Thi: Auto Q Farm", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("PowerFarmshow", "Hiên?Thi: Power Farm", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoAAFarmshow", "Hiên?Thi: autoAAFarm", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoQToggleshow", "Hiên?Thi: Auto Q Harass (Toggle)", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("autoQHarassshow", "Hiên?Thi: Auto Q Harass (Hotkey)", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("ComboSwitchshow", "Hiên?Thi: Chuyên? Combo", SCRIPT_PARAM_ONOFF, true)
	RyzeConfigConfig:addParam("drawcircles", "Show Range", SCRIPT_PARAM_ONOFF, false)
	RyzeConfigConfig:addParam("drawtexts", "Show Text", SCRIPT_PARAM_ONOFF, true)

	if RyzeConfigConfig.BurstActiveshow then RyzeConfig:permaShow("BurstActive") end
	if RyzeConfigConfig.LongActiveshow then RyzeConfig:permaShow("LongActive") end
	if RyzeConfigConfig.useUltishow then RyzeConfig:permaShow("useUlti") end
	if RyzeConfigConfig.cageWshow then RyzeConfig:permaShow("cageW") end
	if RyzeConfigConfig.CageHuntershow then RyzeConfig:permaShow("CageHunter") end
	if RyzeConfigConfig.winstashow then RyzeSettings:permaShow("winsta") end
	if RyzeConfigConfig.autoQFarmshow then RyzeConfig:permaShow("autoQFarm") end
	if RyzeConfigConfig.PowerFarmshow then RyzeConfig:permaShow("PowerFarm") end
	if RyzeConfigConfig.autoAAFarmshow then RyzeConfig:permaShow("autoAAFarm") end
	if RyzeConfigConfig.autoQToggleshow then RyzeConfig:permaShow("autoQToggle") end
	if RyzeConfigConfig.autoQHarassshow then RyzeConfig:permaShow("autoQHarass") end
	if RyzeConfigConfig.ComboSwitchshow then RyzeSettings:permaShow("ComboSwitch") end

	
	
	
	PrintChat ("<font color='#7fe8c2'>Father</font> <font color='#7fe8c2'>of</font> <font color='#a4e87f'>Ryze</font> <font color='#7fe8c2'>best version by</font> <font color='#e97fa5'>BomD</font></font>")
	PrintChat ("<font color='#E97FA5'> Road to the Challenger :)</font>")
	ts = TargetSelector(TARGET_LOW_HP,qRange,DAMAGE_MAGIC,false)
	ts.name = "Ryze"
	ASLoadMinions()
	RyzeConfig:addTS(ts)
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
	enemyMinions = minionManager(MINION_ENEMY, qRange, player, MINION_SORT_HEALTH_ASC)
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2 
	end
	for i = 1, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object ~= nil and object.type == "obj_AI_Turret" then
			local turretName = object.name
			turrets[turretName] = 
			{
				object = object,
				team = object.team,
				range = turretRange,
				x = object.x,
				y = object.y,
				z = object.z,
				active = false,
			}
		end
	end
	autoLevelSetSequence(levelSequence)
	autoLevelSetFunction(onChoiceFunction)
end


function doSpell(ts, spell, range)
	if ts.target ~= nil and GetMyHero():CanUseSpell(spell) == READY and GetDistance(ts.target)<=range then
		CastSpell(spell, ts.target)
	end
end

function findClosestEnemy()
local closestEnemy = nil
local currentEnemy = nil
for i=1, heroManager.iCount do
	currentEnemy = heroManager:GetHero(i)
	if currentEnemy.team ~= myHero.team and not currentEnemy.dead and currentEnemy.visible then
		if closestEnemy == nil then
			closestEnemy = currentEnemy
		elseif GetDistance(currentEnemy) < GetDistance(closestEnemy) then
			closestEnemy = currentEnemy
		end
	end
end
return closestEnemy
end

function OnDraw()
	if myHero.dead then return end  
	if RyzeConfig.LongActive then DrawCircle(myHero.x, myHero.y, myHero.z, RyzeSettings.wflee, 0xFFFF0000) end
	if RyzeConfigConfig.drawcircles and not myHero.dead then
		if QREADY then DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x19A712)
		else DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x992D3D) end
		--if WREADY then DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x19A712)
		--else DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x992D3D) end
		--if EREADY then DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x19A712)
		--else DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x992D3D) end
	end
	for i=1, heroManager.iCount do
		local enemydraw = heroManager:GetHero(i)
		if ValidTarget(enemydraw) then
			if RyzeConfigConfig.drawtexts then
				if killable[i] == 1 then
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0x0000FF)
				elseif killable[i] == 2 then
						DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 80, 0xFF0000)
				end
				if waittxt[i] == 1 and killable[i] ~= 0 then
					PrintFloatText(enemydraw,0,floattext[killable[i]])
				end
				if waittxt[i] == 1 then 
					waittxt[i] = 30
				else waittxt[i] = waittxt[i]-1
				end
			end
		end
	end
	if RyzeConfigConfig.drawcircles and ValidTarget(ts.target) then
		DrawCircle(ts.target.x, ts.target.y, ts.target.z, 100, 0xFF80FF00)
	end
	if MonsterTarget ~= nil and ValidTarget(MonsterTarget) then
		if RyzeConfigConfig.drawcircles then DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 100, 0xFF80FF00) end
		if MonsterKillable == true and RyzeConfigConfig.drawcircles then
			DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 150, 0xFF0000)
			DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 160, 0xFF0000)
			DrawCircle(MonsterTarget.x, MonsterTarget.y, MonsterTarget.z, 170, 0xFF0000)
		end
	end
end


function RyzeDmg()
	local enemy = heroManager:GetHero(calculationenemy)
	if ValidTarget(enemy) then
		local qdamage = getDmg("Q",enemy,myHero) --Normal
		local wdamage = getDmg("W",enemy,myHero)
		local edamage = getDmg("E",enemy,myHero)
		local hitdamage = getDmg("AD",enemy,myHero)
		local dfgdamage = (DFGSlot and getDmg("DFG",enemy,myHero) or 0)
		local hxgdamage = (HXGSlot and getDmg("HXG",enemy,myHero) or 0)
		local bwcdamage = (BWCSlot and getDmg("BWC",enemy,myHero) or 0)
		local brkdamage = (BRKREADY and getDmg("RUINEDKING",enemy,myHero,2) or 0)
		local ignitedamage = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
		local onhitdmg = (SheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemy,myHero) or 0)+(LBSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)
		local onspelldamage = (LTSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(BTSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
		local combo1 = qdamage + qdamage + wdamage + edamage + onhitdmg + onspelldamage
		local combo2 = 0
		if myHero:CanUseSpell(_Q) == READY then
			combo2 = qdamage + combo2
		end
		if myHero:CanUseSpell(_E) == READY then
			combo2 = edamage + combo2
		end
		if myHero:CanUseSpell(_W) then
			combo2 = wdamage + combo2
		end
		if myHero:CanUseSpell(_Q) and myHero:CanUseSpell(_E) and myHero:CanUseSpell(_W) == READY then
			combo2 = qdamage + combo2
		end
		if myHero:CanUseSpell(_Q) or myHero:CanUseSpell(_E) or myHero:CanUseSpell(_W) == READY then
			combo2 = combo2 + onhitdmg + onspelldamage
		end
		if DFGREADY then
			combo1 = combo1 + dfgdamage
			combo2 = combo2 + dfgdamage
		end
		if HXGREADY then               
			combo1 = combo1 + hxgdamage*(DFGREADY and 1.2 or 1)
			combo2 = combo2 + hxgdamage*(DFGREADY and 1.2 or 1)
		end
		if BWCREADY then
			combo1 = combo1 + bwcdamage*(DFGREADY and 1.2 or 1)
			combo2 = combo2 + bwcdamage*(DFGREADY and 1.2 or 1)
		end
		if BRKREADY then
			combo1 = combo1 + brkdamage
			combo2 = combo2 + brkdamage
		end
		if IREADY then
			combo1 = combo1 + ignitedamage
			combo2 = combo2 + ignitedamage
		end
		if combo2 >= enemy.health then killable[calculationenemy] = 2
		elseif combo1 >= enemy.health then killable[calculationenemy] = 1
		else killable[calculationenemy] = 0
		end
	end
	if calculationenemy == 1 then
		calculationenemy = heroManager.iCount
	else
		calculationenemy = calculationenemy-1
	end
end

function OnTick()
checkTurretState()
ts:update()
enemyMinions:update()
if tick == nil or GetTickCount()-tick >= 100 then
	tick = GetTickCount()
	RyzeDmg()
	RyzeItem()
end
if math.abs(myHero.cdr*100) >= RyzeSettings.minCDRnew and RyzeSettings.ComboSwitch then
	Switch = true
else
	Switch = false
end
CageTurret = findClosestTurret()
if myHero:GetDistance(CageTurret.object) <= 1250 and CageTurret.team == player.team then
	InTurretRange = true
else
	InTurretRange = false
end
if not myHero.dead then
	if RyzeConfig.useMura then
		MuramanaToggle(1000, ((player.mana / player.maxMana) > (RyzeSettings.minMuraMana / 100)))
	end
	if RyzeConfig.BurstActive and ValidTarget(ts.target) and Switch == false then
		if DFGREADY then
			CastSpell(DFGSlot, ts.target)
		end
		if HXGREADY then
			CastSpell(HXGSlot, ts.target)
		end
		if BWCREADY then
			CastSpell(BWCSlot, ts.target)
		end
		if myHero:CanUseSpell(_W) == READY and myHero:GetDistance(ts.target) > RyzeSettings.whunt then
			doSpell(ts, _W, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
		elseif myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(ts.target) <= RyzeSettings.whunt then
			doSpell(ts, _Q, qRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			if RyzeConfig.useUlti and myHero:CanUseSpell(_R) == READY then
				CastSpell(_R)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			end
		elseif myHero:CanUseSpell(_Q) == READY then
			doSpell(ts, _Q, qRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
		elseif RyzeConfig.useUlti and myHero:CanUseSpell(_R) == READY then
			CastSpell(_R)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
		elseif myHero:CanUseSpell(_E) == READY then
			doSpell(ts, _E, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
		elseif myHero:CanUseSpell(_W) == READY then
			doSpell(ts, _W, eRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
		end
	elseif (RyzeConfig.LongActive or (Switch and RyzeConfig.BurstActive)) and ValidTarget(ts.target) then
		if DFGREADY then
			CastSpell(DFGSlot, ts.target)
		end
		if HXGREADY then
			CastSpell(HXGSlot, ts.target)
		end
		if BWCREADY then
			CastSpell(BWCSlot, ts.target)
		end
		if myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(ts.target) <= RyzeSettings.whunt then
			doSpell(ts, _Q, qRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = true
			if RyzeConfig.useUlti and myHero:CanUseSpell(_R) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
				CastSpell(_R)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			end
		elseif myHero:CanUseSpell(_W) == READY and myHero:GetDistance(ts.target) > RyzeSettings.whunt then
			doSpell(ts, _W, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
			if myHero:CanUseSpell(_Q) == READY then
				doSpell(ts, _Q, qRange)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = true
			end
		elseif myHero:CanUseSpell(_Q) == READY then
			doSpell(ts, _Q, qRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = true
		elseif RyzeConfig.useUlti and myHero:CanUseSpell(_R) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
			CastSpell(_R)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		elseif myHero:CanUseSpell(_W) == READY and ((qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN and myHero:GetDistance(ts.target) >= RyzeSettings.wflee) or (RyzeSettings.winsta == true and myHero:GetDistance(ts.target) >= RyzeSettings.wflee)) then
			doSpell(ts, _W, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		elseif myHero:CanUseSpell(_E) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
			doSpell(ts, _E, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		elseif myHero:CanUseSpell(_W) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN then
			doSpell(ts, _W, wRange)
			if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			qcasted = false
		end
	elseif RyzeConfig.JungleActive then
		closest = findClosestEnemy()
		if ValidTarget(closest) then
			if myHero:GetDistance(closest) > JungleRange then
				SaveJungle = true 
			end
		elseif closest == nil then
			SaveJungle = true 
		else
			SaveJungle = false
		end
		if ValidTarget(MonsterTarget) then 
			if myHero:GetDistance(MonsterTarget) > eRange then
				MiniMonster = false
				CheckMonster(Vilemaw)
				CheckMonster(Nashor)
				CheckMonster(Dragon)
				CheckMonster(Golem1)
				CheckMonster(Golem2)
				CheckMonster(Lizard1)
				CheckMonster(Lizard2)
			end
		else
			MiniMonster = false
			CheckMonster(Vilemaw)
			CheckMonster(Nashor)
			CheckMonster(Dragon)
			CheckMonster(Golem1)
			CheckMonster(Golem2)
			CheckMonster(Lizard1)
			CheckMonster(Lizard2)
		end
		if SaveJungle == true and MiniMonster == false and targeting == true then
			if myHero:CanUseSpell(_Q) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
				CastSpell(_Q, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = true
			elseif RyzeConfig.useUltiJungle and myHero:CanUseSpell(_R) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
				CastSpell(_R)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			elseif myHero:CanUseSpell(_E) == READY and qcasted == true and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
				CastSpell(_E, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			elseif myHero:CanUseSpell(_W) == READY and qcasted == true and myHero:CanUseSpell(_Q) == COOLDOWN and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=wRange then
				CastSpell(_W, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
				qcasted = false
			end
		if ValidTarget(MonsterTarget) then
			if ((MonsterDMG("Q",_Q,MonsterTarget,qRange) + MonsterDMG("W",_W,MonsterTarget,wRange)) >= MonsterTarget.health) then
				MonsterKillable = true
				if myHero:CanUseSpell(_Q) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
					CastSpell(_Q, MonsterTarget)
				end
				if myHero:CanUseSpell(_W) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=wRange then
					CastSpell(_W, MonsterTarget)
				end
				if myHero:CanUseSpell(_E) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
					CastSpell(_E, MonsterTarget)
				end
			else
				MonsterKillable = false
			end
		end
		end
		if SaveJungle == true and (not ValidTarget(MonsterTarget) or (MiniMonster == true and targeting == true)) then
			MiniMonster = true
			CheckMonster(Wolf1)
			CheckMonster(Wolf2)
			CheckMonster(GolemRock1)
			CheckMonster(GolemRock2)
			CheckMonster(Wraith1)
			CheckMonster(Wraith2)
			if myHero:CanUseSpell(_R) == READY and RyzeConfig.useUltiJungle and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
				CastSpell(_R)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_E) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=eRange then
				CastSpell(_E, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_Q) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=qRange then
				CastSpell(_Q, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			elseif myHero:CanUseSpell(_W) == READY and ValidTarget(MonsterTarget) and GetDistance(MonsterTarget)<=wRange then
				CastSpell(_W, MonsterTarget)
				if RyzeSettings.autoMouseFollow then player:MoveTo(mousePos.x, mousePos.z) end
			end
		end
	elseif RyzeConfig.autoQFarm and RyzeSettings.qMinMana<=((myHero.mana/myHero.maxMana)*100) and RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false and RyzeConfig.autoQHarass == false and RyzeConfig.autoQToggle == false then
		for index, minion in pairs(enemyMinions.objects) do
			local myQ = getDmg("Q",minion,myHero)
			local myW = getDmg("W",minion,myHero)
			if (minion.maxHealth >= 700+27*math.floor(GetGameTimer()/180000)) then
				local ProMinion = minion
				if myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(ProMinion) ~= nil and myHero:GetDistance(ProMinion) <= qRange and ProMinion.health ~= nil and ProMinion.health <= player:CalcDamage(ProMinion, myQ) and ProMinion.visible ~= nil and ProMinion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
					CastSpell(_Q, ProMinion)
				elseif myHero:CanUseSpell(_W) == READY and myHero:GetDistance(ProMinion) ~= nil and myHero:GetDistance(ProMinion) <= wRange and ProMinion.health ~= nil and ProMinion.health <= player:CalcDamage(ProMinion, myW) and ProMinion.visible ~= nil and ProMinion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
					CastSpell(_W, ProMinion)
				end
			end
			if myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= qRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myQ) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_Q, minion)
			end
		end
	elseif RyzeConfig.PowerFarm and RyzeSettings.PowerMinMana<=((myHero.mana/myHero.maxMana)*100) and RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false and RyzeConfig.autoQHarass == false and RyzeConfig.autoQToggle == false then
		for index, minion in pairs(enemyMinions.objects) do
			local myQ = getDmg("Q",minion,myHero)
			local myW = getDmg("W",minion,myHero)
			local myE = getDmg("E",minion,myHero)
			if etarget ~= minion and wtarget ~= minion and myHero:CanUseSpell(_Q) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= qRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myQ) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_Q, minion)
				qtarget = minion
			end
			if etarget ~= minion and qtarget ~= minion and myHero:CanUseSpell(_W) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= wRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myW) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_W, minion)
				wtarget = minion
			end
			if qtarget ~= minion and wtarget ~= minion and myHero:CanUseSpell(_E) == READY and myHero:GetDistance(minion) ~= nil and myHero:GetDistance(minion) <= eRange and minion.health ~= nil and minion.health <= player:CalcDamage(minion, myE) and minion.visible ~= nil and minion.visible == true and  RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false then
				CastSpell(_E, minion)
				etarget = minion
			end
		end
	end
	if RyzeConfig.autoAAFarm and GetTickCount() > nextTick then
		if RyzeSettings.autoAAFollow then
			player:MoveTo(mousePos.x, mousePos.z)
		end
		for index, minion in pairs(enemyMinions.objects) do
			local myAA = getDmg("AD",minion,myHero)
			if myHero:GetDistance(minion) ~= nil and  myHero:GetDistance(minion) <= AARange and minion.health ~= nil and minion.health <= myAA and minion.visible ~= nil and minion.visible == true then
				player:Attack(minion)
			end
		 nextTick = GetTickCount() + waitDelay
		end
	end
	if (RyzeConfig.autoQHarass or RyzeConfig.autoQToggle) and RyzeSettings.qMinManaHarass<=((myHero.mana/myHero.maxMana)*100) and RyzeConfig.BurstActive == false and RyzeConfig.LongActive == false and ValidTarget(ts.target) then
		if myHero:CanUseSpell(_Q) == READY then
			doSpell(ts, _Q, qRange)
		end
	end
	if RyzeConfig.CageHunter and myHero:CanUseSpell(_W) == READY then
		closest = findClosestEnemy()
		if ValidTarget(closest) then
			if myHero:GetDistance(closest) < wRange and ValidTarget(closest) then
				CastSpell(_W, closest)
			end
		end
	end
	if RyzeConfig.Ignite then       
		if IREADY then
			local ignitedmg = 0    
			for j = 1, heroManager.iCount, 1 do
				local enemyhero = heroManager:getHero(j)
				if ValidTarget(enemyhero,600) then
					ignitedmg = 50 + 20 * myHero.level
					if enemyhero.health <= ignitedmg then
						CastSpell(ignite, enemyhero)
					end
				end
			end
		end
	end
	if RyzeSettings.autoComboFollow and (RyzeConfig.BurstActive == true or RyzeConfig.LongActive == true) then
		player:MoveTo(mousePos.x, mousePos.z)
	end
end
end

function OnProcessSpell(unit, spell)
--[[	if (spell.name:find("ChaosTurret") and myHero.team == TEAM_RED) or (spell.name:find("OrderTurret") and myHero.team == TEAM_BLUE) and RyzeConfig.cageW then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				if GetDistance(spell.endPos, enemy)<80 and GetDistance(enemy)<=wRange and myHero:CanUseSpell(_W) == READY then
					CastSpell(_W, enemy)
				end
			end
		end            
	end
-- ]]
if InTurretRange == true then
	if unit.team == TEAM_ENEMY and GetDistance(unit) < wRange and GetDistance(spell.endPos, myHero)<10 then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				if enemy.name == unit.name then
					if GetDistance(enemy)<=wRange and myHero:CanUseSpell(_W) == READY then
						if enemy:GetDistance(CageTurret.object) < 800 then
							CastSpell(_W, enemy)
						end
					end
				end
			end
		end
	end
end
end

function findClosestTurret()
local closestTurret = nil
local currentTurret = nil
for name, turret in pairs(turrets) do
	if turret.object.valid ~= false then 
		currentTurret = turret
	end
	if turret.team == myHero.team then
		if closestTurret == nil then
			closestTurret = currentTurret
		elseif GetDistance(currentTurret) < GetDistance(closestTurret) then
			closestTurret = currentTurret
		end
	end
end
return closestTurret
end


function OnCreateObj(obj)
	if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil then
		if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
		elseif obj.name == "Worm12.1.1" then Nashor = obj
		elseif obj.name == "Dragon6.1.1" then Dragon = obj
		elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
		elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
		elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
		elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj
		elseif obj.name == "GiantWolf2.1.3" then Wolf1 = obj 
		elseif obj.name == "GiantWolf8.1.3" then Wolf2 = obj
		elseif obj.name == "Wraith3.1.3" then Wraith1 = obj
		elseif obj.name == "Wraith9.1.3" then Wraith2 = obj
		elseif obj.name == "Golem5.1.2" then Golem1 = obj
		elseif obj.name == "Golem11.1.2" then Golem2 = obj
		end
	end
end

function OnDeleteObj(object)
	if object ~= nil and object.type == "obj_AI_Turret" then
		for name, turret in pairs(turrets) do
			if name == object.name then
				turrets[name] = nil
				return
			end
		end
	end
end

function ASLoadMinions()
	for i = 1, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj ~= nil and obj.type == "obj_AI_Minion" and obj.name ~= nil then
			if obj.name == "TT_Spiderboss7.1.1" then Vilemaw = obj
			elseif obj.name == "Worm12.1.1" then Nashor = obj
			elseif obj.name == "Dragon6.1.1" then Dragon = obj
			elseif obj.name == "AncientGolem1.1.1" then Golem1 = obj
			elseif obj.name == "AncientGolem7.1.1" then Golem2 = obj
			elseif obj.name == "LizardElder4.1.1" then Lizard1 = obj
			elseif obj.name == "LizardElder10.1.1" then Lizard2 = obj 
			elseif obj.name == "GiantWolf2.1.3" then Wolf1 = obj 
			elseif obj.name == "GiantWolf8.1.3" then Wolf2 = obj
			elseif obj.name == "Wraith3.1.3" then Wraith1 = obj
			elseif obj.name == "Wraith9.1.3" then Wraith2 = obj
			elseif obj.name == "Golem5.1.2" then GolemRock1 = obj
			elseif obj.name == "Golem11.1.2" then GolemRock2 = obj
			end
		end
	end
end


function CheckMonster(minion)
if minion ~= nil and ValidTarget(minion) then
	if myHero:GetDistance(minion) < eRange then
		MonsterTarget = minion
		targeting = true
	elseif not ValidTarget(MonsterTarget) then
		targeting = false
	end
end
end

function MonsterDMG(dmgspell,spell,monster,range)
	if monster ~= nil and GetMyHero():CanUseSpell(spell) == READY and GetDistance(monster)<=range then
		return getDmg(dmgspell,monster,myHero)
	else
		return 0
	end
end

function RyzeItem()
DFGSlot, HXGSlot, BWCSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
IGSlot, LTSlot, BTSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
STISlot, ROSlot, BRKSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
QREADY = (myHero:CanUseSpell(_Q) == READY)
WREADY = (myHero:CanUseSpell(_W) == READY)
EREADY = (myHero:CanUseSpell(_E) == READY)
RREADY = (myHero:CanUseSpell(_R) == READY)
DFGREADY = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
STIREADY = (STISlot ~= nil and myHero:CanUseSpell(STISlot) == READY)
ROREADY = (ROSlot ~= nil and myHero:CanUseSpell(ROSlot) == READY)
BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function checkTurretState()
	for name, turret in pairs(turrets) do
		if turret.object.valid == false then
			turrets[name] = nil
		end
	end
end

function onChoiceFunction()
	if player:GetSpellData(SPELL_1).level < player:GetSpellData(SPELL_2).level then
		return 1
	else
		return 2
	end
end

--ADd Quyen Truong
function OnProcessSpell(object,spell)
	if object.team ~= myHero.team and not myHero.dead and not (object.name:find("Minion_") or object.name:find("Odin")) then
		local shieldREADY = typeshield ~= nil and myHero:CanUseSpell(spellslot) == READY and leesinW
		local healREADY = typeheal ~= nil and myHero:CanUseSpell(healslot) == READY and nidaleeE
		local sbarrierREADY = sbarrier ~= nil and myHero:CanUseSpell(sbarrier) == READY
		local shealREADY = sheal ~= nil and myHero:CanUseSpell(sheal) == READY
		local lisslot = GetInventorySlotItem(3190)--iron solari
		local seslot = GetInventorySlotItem(3040) --thien su
		local FotMslot = GetInventorySlotItem(3401)
		local lisREADY = lisslot ~= nil and myHero:CanUseSpell(lisslot) == READY
		local seREADY = seslot ~= nil and myHero:CanUseSpell(seslot) == READY
		local FotMREADY = FotMslot ~= nil and myHero:CanUseSpell(FotMslot) == READY
		local HitFirst = false
		local shieldtarget,SLastDistance,SLastDmgPercent = nil,nil,nil
		local healtarget,HLastDistance,HLastDmgPercent = nil,nil,nil
		YWall,BShield,SShield,Shield,CC = false,false,false,false,false
		shottype,radius,maxdistance = 0,0,0
		if object.type == "obj_AI_Hero" then
			spelltype, casttype = getSpellType(object, spell.name)
			if casttype == 4 or casttype == 5 or casttype == 6 then return end
			if spelltype == "BAttack" or spelltype == "CAttack" then
				Shield = true
				YWall = true
			elseif spell.name:find("SummonerDot") then
				Shield = true
			elseif spelltype == "Q" or spelltype == "W" or spelltype == "E" or spelltype == "R" or spelltype == "P" or spelltype == "QM" or spelltype == "WM" or spelltype == "EM" then
				HitFirst = skillShield[object.charName][spelltype]["HitFirst"]
				BShield = skillShield[object.charName][spelltype]["BShield"]
				SShield = skillShield[object.charName][spelltype]["SShield"]
				Shield = skillShield[object.charName][spelltype]["Shield"]
				CC = skillShield[object.charName][spelltype]["CC"]
				shottype = skillData[object.charName][spelltype]["type"]
				radius = skillData[object.charName][spelltype]["radius"]
				maxdistance = skillData[object.charName][spelltype]["maxdistance"]
			end
		else
			Shield = true
		end
		for i=1, heroManager.iCount do
			local allytarget = heroManager:GetHero(i)
			if allytarget.team == myHero.team and not allytarget.dead and allytarget.health > 0 then
				hitchampion = false
				local allyHitBox = getHitBox(allytarget)
				if shottype == 0 then hitchampion = spell.target and spell.target.networkID == allytarget.networkID
				elseif shottype == 1 then hitchampion = checkhitlinepass(object, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				elseif shottype == 2 then hitchampion = checkhitlinepoint(object, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				elseif shottype == 3 then hitchampion = checkhitaoe(object, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				elseif shottype == 4 then hitchampion = checkhitcone(object, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				elseif shottype == 5 then hitchampion = checkhitwall(object, spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				elseif shottype == 6 then hitchampion = checkhitlinepass(object, spell.endPos, radius, maxdistance, allytarget, allyHitBox) or checkhitlinepass(object, Vector(object)*2-spell.endPos, radius, maxdistance, allytarget, allyHitBox)
				elseif shottype == 7 then hitchampion = checkhitcone(spell.endPos, object, radius, maxdistance, allytarget, allyHitBox)
				end
				if hitchampion then
					if shieldREADY and ASConfig["teammateshield"..i] and ((typeshield<=4 and Shield) or (typeshield==5 and BShield) or (typeshield==6 and SShield)) then
						if (((typeshield==1 or typeshield==2 or typeshield==5) and GetDistance(allytarget)<=range) or allytarget.isMe) then
							local shieldflag, dmgpercent = shieldCheck(object,spell,allytarget,"shields")
							if shieldflag then
								if HitFirst and (SLastDistance == nil or GetDistance(allytarget,object) <= SLastDistance) then
									shieldtarget,SLastDistance = allytarget,GetDistance(allytarget,object)
								elseif not HitFirst and (SLastDmgPercent == nil or dmgpercent >= SLastDmgPercent) then
									shieldtarget,SLastDmgPercent = allytarget,dmgpercent
								end
							end
						end
					end
					if healREADY and AHConfig["teammateheal"..i] and Shield then
						if ((typeheal==1 or typeheal==2) and GetDistance(allytarget)<=healrange) or allytarget.isMe then
							local healflag, dmgpercent = shieldCheck(object,spell,allytarget,"heals")
							if healflag then
								if HitFirst and (HLastDistance == nil or GetDistance(allytarget,object) <= HLastDistance) then
									healtarget,HLastDistance = allytarget,GetDistance(allytarget,object)
								elseif not HitFirst and (HLastDmgPercent == nil or dmgpercent >= HLastDmgPercent) then
									healtarget,HLastDmgPercent = allytarget,dmgpercent
								end
							end		
						end
					end
				
					if sbarrierREADY and ASBConfig.barrieron and allytarget.isMe and Shield then
						local barrierflag, dmgpercent = shieldCheck(object,spell,allytarget,"barrier")
						if barrierflag then
							CastSpell(sbarrier)
						end
					end
					if shealREADY and ASHConfig["teammatesheal"..i] and Shield then
						if GetDistance(allytarget)<=shealrange then
							local shealflag, dmgpercent = shieldCheck(object,spell,allytarget,"sheals")
							if shealflag then
								CastSpell(sheal)
							end
						end
					end
					if lisREADY and ASIConfig["teammateshieldi"..i] and Shield then
						if GetDistance(allytarget)<=lisrange then
							local lisflag, dmgpercent = shieldCheck(object,spell,allytarget,"items")
							if lisflag then
								CastSpell(lisslot)
							end
						end
					end
					if FotMREADY and ASIConfig["teammateshieldi"..i] and Shield then
						if GetDistance(allytarget)<=FotMrange then
							local FotMflag, dmgpercent = shieldCheck(object,spell,allytarget,"items")
							if FotMflag then
								CastSpell(FotMslot, allytarget)
							end
						end
					end
					if seREADY and ASIConfig["teammateshieldi"..i] and allytarget.isMe and Shield then
						local seflag, dmgpercent = shieldCheck(object,spell,allytarget,"items")
						if seflag then
							CastSpell(seslot)
						end
					end
				end
			end
		end
		if shieldtarget ~= nil then
			if typeshield==1 or typeshield==5 then CastSpell(spellslot,shieldtarget)
			elseif typeshield==2 or typeshield==4 then CastSpell(spellslot,shieldtarget.x,shieldtarget.z)
			elseif typeshield==3 or typeshield==6 then CastSpell(spellslot) end
		end
		if healtarget ~= nil then
			if typeheal==1 then CastSpell(healslot,healtarget)
			elseif typeheal==2 or typeheal==3 then CastSpell(healslot) end
		end
		
	end	
end

function shieldCheck(object,spell,target,typeused)
	local configused
	if typeused == "shields" then configused = ASConfig
	elseif typeused == "heals" then configused = AHConfig
	elseif typeused == "barrier" then configused = ASBConfig 
	elseif typeused == "sheals" then configused = ASHConfig
	elseif typeused == "items" then configused = ASIConfig end
	local shieldflag = false
	if (not configused.skillshots and shottype ~= 0) then return false, 0 end
	local adamage = object:CalcDamage(target,object.totalDamage)
	local InfinityEdge,onhitdmg,onhittdmg,onhitspelldmg,onhitspelltdmg,muramanadmg,skilldamage,skillTypeDmg = 0,0,0,0,0,0,0,0

	if object.type ~= "obj_AI_Hero" then
		if spell.name:find("BasicAttack") then skilldamage = adamage
		elseif spell.name:find("CritAttack") then skilldamage = adamage*2 end
	else
		if GetInventoryHaveItem(3186,object) then onhitdmg = getDmg("KITAES",target,object) end
		if GetInventoryHaveItem(3114,object) then onhitdmg = onhitdmg+getDmg("MALADY",target,object) end
		if GetInventoryHaveItem(3091,object) then onhitdmg = onhitdmg+getDmg("WITSEND",target,object) end
		if GetInventoryHaveItem(3057,object) then onhitdmg = onhitdmg+getDmg("SHEEN",target,object) end
		if GetInventoryHaveItem(3078,object) then onhitdmg = onhitdmg+getDmg("TRINITY",target,object) end
		if GetInventoryHaveItem(3100,object) then onhitdmg = onhitdmg+getDmg("LICHBANE",target,object) end
		if GetInventoryHaveItem(3025,object) then onhitdmg = onhitdmg+getDmg("ICEBORN",target,object) end
		if GetInventoryHaveItem(3087,object) then onhitdmg = onhitdmg+getDmg("STATIKK",target,object) end
		if GetInventoryHaveItem(3153,object) then onhitdmg = onhitdmg+getDmg("RUINEDKING",target,object) end
		if GetInventoryHaveItem(3209,object) then onhittdmg = getDmg("SPIRITLIZARD",target,object) end
		if GetInventoryHaveItem(3184,object) then onhittdmg = onhittdmg+80 end
		if GetInventoryHaveItem(3042,object) then muramanadmg = getDmg("MURAMANA",target,object) end
		if spelltype == "BAttack" then
			skilldamage = (adamage+onhitdmg+muramanadmg)*1.07+onhittdmg
		elseif spelltype == "CAttack" then
			if GetInventoryHaveItem(3031,object) then InfinityEdge = .5 end
			skilldamage = (adamage*(2.1+InfinityEdge)+onhitdmg+muramanadmg)*1.07+onhittdmg --fix Lethality
		elseif spelltype == "Q" or spelltype == "W" or spelltype == "E" or spelltype == "R" or spelltype == "P" or spelltype == "QM" or spelltype == "WM" or spelltype == "EM" then
			if GetInventoryHaveItem(3151,object) then onhitspelldmg = getDmg("LIANDRYS",target,object) end
			if GetInventoryHaveItem(3188,object) then onhitspelldmg = getDmg("BLACKFIRE",target,object) end
			if GetInventoryHaveItem(3209,object) then onhitspelltdmg = getDmg("SPIRITLIZARD",target,object) end
			muramanadmg = skillShield[object.charName][spelltype]["Muramana"] and muramanadmg or 0
			if casttype == 1 then
				skilldamage, skillTypeDmg = getDmg(spelltype,target,object,1,spell.level)
			elseif casttype == 2 then
				skilldamage, skillTypeDmg = getDmg(spelltype,target,object,2,spell.level)
			elseif casttype == 3 then
				skilldamage, skillTypeDmg = getDmg(spelltype,target,object,3,spell.level)
			end
			if skillTypeDmg == 2 then
				skilldamage = (skilldamage+adamage+onhitspelldmg+onhitdmg+muramanadmg)*1.07+onhittdmg+onhitspelltdmg
			else
				if skilldamage > 0 then skilldamage = (skilldamage+onhitspelldmg+muramanadmg)*1.07+onhitspelltdmg end
			end
		elseif spell.name:find("SummonerDot") then
			skilldamage = getDmg("IGNITE",target,object)
		end
	end
	local dmgpercent = skilldamage*100/target.health
	local dmgneeded = dmgpercent >= configused.mindmgpercent
	local hpneeded = configused.maxhppercent >= (target.health-skilldamage)*100/target.maxHealth
	
	if dmgneeded and hpneeded then
		shieldflag = true
	elseif (typeused == "shields" or typeused == "wall") and ((CC == 2 and configused.shieldcc) or (CC == 1 and configused.shieldslow)) then
		shieldflag = true
	end
	return shieldflag, dmgpercent
end
function getHitBox(hero)
    local hitboxTable = { ['HeimerTGreen'] = 50.0, ['Darius'] = 80.0, ['ZyraGraspingPlant'] = 20.0, ['HeimerTRed'] = 50.0, ['ZyraThornPlant'] = 20.0, ['Nasus'] = 80.0, ['HeimerTBlue'] = 50.0, ['SightWard'] = 1, ['HeimerTYellow'] = 50.0, ['Kennen'] = 55.0, ['VisionWard'] = 1, ['ShacoBox'] = 10, ['HA_AP_Poro'] = 0, ['TempMovableChar'] = 48.0, ['TeemoMushroom'] = 50.0, ['OlafAxe'] = 50.0, ['OdinCenterRelic'] = 48.0, ['Blue_Minion_Healer'] = 48.0, ['AncientGolem'] = 100.0, ['AnnieTibbers'] = 80.0, ['OdinMinionGraveyardPortal'] = 1.0, ['OriannaBall'] = 48.0, ['LizardElder'] = 65.0, ['YoungLizard'] = 50.0, ['OdinMinionSpawnPortal'] = 1.0, ['MaokaiSproutling'] = 48.0, ['FizzShark'] = 0, ['Sejuani'] = 80.0, ['Sion'] = 80.0, ['OdinQuestIndicator'] = 1.0, ['Zac'] = 80.0, ['Red_Minion_Wizard'] = 48.0, ['DrMundo'] = 80.0, ['Blue_Minion_Wizard'] = 48.0, ['ShyvanaDragon'] = 80.0, ['HA_AP_OrderShrineTurret'] = 88.4, ['Heimerdinger'] = 55.0, ['Rumble'] = 80.0, ['Ziggs'] = 55.0, ['HA_AP_OrderTurret3'] = 88.4, ['HA_AP_OrderTurret2'] = 88.4, ['TT_Relic'] = 0, ['Veigar'] = 55.0, ['HA_AP_HealthRelic'] = 0, ['Teemo'] = 55.0, ['Amumu'] = 55.0, ['HA_AP_ChaosTurretShrine'] = 88.4, ['HA_AP_ChaosTurret'] = 88.4, ['HA_AP_ChaosTurretRubble'] = 88.4, ['Poppy'] = 55.0, ['Tristana'] = 55.0, ['HA_AP_PoroSpawner'] = 50.0, ['TT_NGolem'] = 80.0, ['HA_AP_ChaosTurretTutorial'] = 88.4, ['Volibear'] = 80.0, ['HA_AP_OrderTurretTutorial'] = 88.4, ['TT_NGolem2'] = 80.0, ['HA_AP_ChaosTurret3'] = 88.4, ['HA_AP_ChaosTurret2'] = 88.4, ['Shyvana'] = 50.0, ['HA_AP_OrderTurret'] = 88.4, ['Nautilus'] = 80.0, ['ARAMOrderTurretNexus'] = 88.4, ['TT_ChaosTurret2'] = 88.4, ['TT_ChaosTurret3'] = 88.4, ['TT_ChaosTurret1'] = 88.4, ['ChaosTurretGiant'] = 88.4, ['ARAMOrderTurretFront'] = 88.4, ['ChaosTurretWorm'] = 88.4, ['OdinChaosTurretShrine'] = 88.4, ['ChaosTurretNormal'] = 88.4, ['OrderTurretNormal2'] = 88.4, ['OdinOrderTurretShrine'] = 88.4, ['OrderTurretDragon'] = 88.4, ['OrderTurretNormal'] = 88.4, ['ARAMChaosTurretFront'] = 88.4, ['ARAMOrderTurretInhib'] = 88.4, ['ChaosTurretWorm2'] = 88.4, ['TT_OrderTurret1'] = 88.4, ['TT_OrderTurret2'] = 88.4, ['ARAMChaosTurretInhib'] = 88.4, ['TT_OrderTurret3'] = 88.4, ['ARAMChaosTurretNexus'] = 88.4, ['OrderTurretAngel'] = 88.4, ['Mordekaiser'] = 80.0, ['TT_Buffplat_R'] = 0, ['Lizard'] = 50.0, ['GolemOdin'] = 80.0, ['Renekton'] = 80.0, ['Maokai'] = 80.0, ['LuluLadybug'] = 50.0, ['Alistar'] = 80.0, ['Urgot'] = 80.0, ['LuluCupcake'] = 50.0, ['Gragas'] = 80.0, ['Skarner'] = 80.0, ['Yorick'] = 80.0, ['MalzaharVoidling'] = 10.0, ['LuluPig'] = 50.0, ['Blitzcrank'] = 80.0, ['Chogath'] = 80.0, ['Vi'] = 50, ['FizzBait'] = 0, ['Malphite'] = 80.0, ['EliseSpiderling'] = 1.0, ['Dragon'] = 100.0, ['LuluSquill'] = 50.0, ['Worm'] = 100.0, ['redDragon'] = 100.0, ['LuluKitty'] = 50.0, ['Galio'] = 80.0, ['Annie'] = 55.0, ['EliseSpider'] = 50.0, ['SyndraSphere'] = 48.0, ['LuluDragon'] = 50.0, ['Hecarim'] = 80.0, ['TT_Spiderboss'] = 200.0, ['Thresh'] = 55.0, ['ARAMChaosTurretShrine'] = 88.4, ['ARAMOrderTurretShrine'] = 88.4, ['Blue_Minion_MechMelee'] = 65.0, ['TT_NWolf'] = 65.0, ['Tutorial_Red_Minion_Wizard'] = 48.0, ['YorickRavenousGhoul'] = 1.0, ['SmallGolem'] = 80.0, ['OdinRedSuperminion'] = 55.0, ['Wraith'] = 50.0, ['Red_Minion_MechCannon'] = 65.0, ['Red_Minion_Melee'] = 48.0, ['OdinBlueSuperminion'] = 55.0, ['TT_NWolf2'] = 50.0, ['Tutorial_Red_Minion_Basic'] = 48.0, ['YorickSpectralGhoul'] = 1.0, ['Wolf'] = 50.0, ['Blue_Minion_MechCannon'] = 65.0, ['Golem'] = 80.0, ['Blue_Minion_Basic'] = 48.0, ['Blue_Minion_Melee'] = 48.0, ['Odin_Blue_Minion_caster'] = 48.0, ['TT_NWraith2'] = 50.0, ['Tutorial_Blue_Minion_Wizard'] = 48.0, ['GiantWolf'] = 65.0, ['Odin_Red_Minion_Caster'] = 48.0, ['Red_Minion_MechMelee'] = 65.0, ['LesserWraith'] = 50.0, ['Red_Minion_Basic'] = 48.0, ['Tutorial_Blue_Minion_Basic'] = 48.0, ['GhostWard'] = 1, ['TT_NWraith'] = 50.0, ['Red_Minion_MechRange'] = 65.0, ['YorickDecayedGhoul'] = 1.0, ['TT_Buffplat_L'] = 0, ['TT_ChaosTurret4'] = 88.4, ['TT_Buffplat_Chain'] = 0, ['TT_OrderTurret4'] = 88.4, ['OrderTurretShrine'] = 88.4, ['ChaosTurretShrine'] = 88.4, ['WriggleLantern'] = 1, ['ChaosTurretTutorial'] = 88.4, ['TwistedLizardElder'] = 65.0, ['RabidWolf'] = 65.0, ['OrderTurretTutorial'] = 88.4, ['OdinShieldRelic'] = 0, ['TwistedGolem'] = 80.0, ['TwistedSmallWolf'] = 50.0, ['TwistedGiantWolf'] = 65.0, ['TwistedTinyWraith'] = 50.0, ['TwistedBlueWraith'] = 50.0, ['TwistedYoungLizard'] = 50.0, ['Summoner_Rider_Order'] = 65.0, ['Summoner_Rider_Chaos'] = 65.0, ['Ghast'] = 60.0, ['blueDragon'] = 100.0, }
    return (hitboxTable[hero.charName] ~= nil and hitboxTable[hero.charName] ~= 0) and hitboxTable[hero.charName] or 65
end

--End Quyen Truong




 quotes = { 'Let\'s go, let\'s go!',
 'Unpleasant? I\'ll show you unpleasant!',
 'Take this scroll and stick it... somewhere safe.',
 'I got these tattoos in rune prison!',
 'Right back at you!'}
PrintFloatText(myHero, 10, quotes[math.random(5)])