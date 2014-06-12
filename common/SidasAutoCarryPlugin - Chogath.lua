--[[

8888888b.                         888 888                .d8888b.  888              d8b  .d8888b.           888    888      
888  "Y88b                        888 888               d88P  Y88b 888              88P d88P  Y88b          888    888      
888    888                        888 888               888    888 888              8P  888    888          888    888      
888    888  .d88b.   8888b.   .d88888 888 888  888      888        88888b.   .d88b. "   888         8888b.  888888 88888b.  
888    888 d8P  Y8b     "88b d88" 888 888 888  888      888        888 "88b d88""88b    888  88888     "88b 888    888 "88b 
888    888 88888888 .d888888 888  888 888 888  888      888    888 888  888 888  888    888    888 .d888888 888    888  888 
888  .d88P Y8b.     888  888 Y88b 888 888 Y88b 888      Y88b  d88P 888  888 Y88..88P    Y88b  d88P 888  888 Y88b.  888  888 
8888888P"   "Y8888  "Y888888  "Y88888 888  "Y88888       "Y8888P"  888  888  "Y88P"      "Y8888P88 "Y888888  "Y888 888  888 
                                               888                                                                          
                                          Y8b d88P                                                                          
                                           "Y88P"                                                                           
888                     .d8888b.   .d8888b.   .d88888b.  888b    888 888b    888                                            
888                    d88P  Y88b d88P  Y88b d88P" "Y88b 8888b   888 8888b   888                                            
888                    888    888 888    888 888     888 88888b  888 88888b  888                                            
88888b.  888  888      888        888        888     888 888Y88b 888 888Y88b 888                                            
888 "88b 888  888      888        888        888     888 888 Y88b888 888 Y88b888                                            
888  888 888  888      888    888 888    888 888     888 888  Y88888 888  Y88888                                            
888 d88P Y88b 888      Y88b  d88P Y88b  d88P Y88b. .d88P 888   Y8888 888   Y8888                                            
88888P"   "Y88888       "Y8888P"   "Y8888P"   "Y88888P"  888    Y888 888    Y888                                            
              888                                                                                                           
         Y8b d88P                                                                                                           
          "Y88P"                                                                                                            


VERSION 	1.01
UPDATED:	11/30/2013
BY:			CCONN

CHANGELOG:	VERSION 1.00		
				Initial Release
				
			VERSION 1.01
				Adjusted rupture delay time
				
PLANNED FEATURES:
	Lane Clear with spells
	Execute jungle monsters with Feast
	Baron / Dragon steal with Feast and Smite + Feast
	Feast when low HP
	Killsteal functions
	DFG + Ult Killsteal
	Stack counter - feast minions if < 6 stacks only
]]

--if myHero.charName ~= "chogath" then return end

require "Prodiction"
require "AoE_Skillshot_Position"

local qRange = 950
local wRange = 700
local rRange = 150
local QRDY
local WRDY
local ERDY
local RRDY
local Prodict = ProdictManager.GetInstance()
local ProdictQ
local ProdictW
local Target
local Minion

function PluginOnLoad()
	Menu()
	Checks()
	AutoCarry.SkillsCrosshair.range = 950 --max range of Rupture (Q)
	ProdictQ = Prodict:AddProdictionObject(_Q, qRange, math.huge, 1.225, 170)  --math.huge, .290, 170) --.915, 190
end

function Menu()
	AutoCarry.PluginMenu:addSubMenu("Deadly Cho'Gath: Auto Carry", "autocarry")
		AutoCarry.PluginMenu.autocarry:addParam("ACuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.autocarry:addParam("ACuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.autocarry:addParam("ACuseR", "Execute with Feast", SCRIPT_PARAM_ONOFF, true)
--		AutoCarry.PluginMenu.autocarry:addParam("ACuseRlowHP", "Cast R if low HP", SCRIPT_PARAM_ONOFF, true)  --for future version
	AutoCarry.PluginMenu:addSubMenu("Deadly Cho'Gath: Mixed Mode", "mixedmode")
		AutoCarry.PluginMenu.mixedmode:addParam("MMuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.mixedmode:addParam("MMuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.mixedmode:addParam("MMuseR", "Execute with Feast", SCRIPT_PARAM_ONOFF, true)
--		AutoCarry.PluginMenu.mixedmode:addParam("MMuseRlowHP", "Cast R if low HP", SCRIPT_PARAM_ONOFF, true)  --for future version
--[[	AutoCarry.PluginMenu:addSubMenu("Deadly Cho'Gath: Lane Clear", "laneclear")
		AutoCarry.PluginMenu.laneclear:addParam("LCuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.laneclear:addParam("LCuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.laneclear:addParam("LCuseR", "Last hit with R", SCRIPT_PARAM_ONOFF, true)]]
	AutoCarry.PluginMenu:addSubMenu("Deadly Cho'Gath: Draw", "draw")
		AutoCarry.PluginMenu.draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.draw:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
		AutoCarry.PluginMenu.draw:addParam("DrawXP", "Draw XP Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("FeastMinion", "Feast on Minions", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("S"))
end

function PluginOnDraw()
	if QRDY and AutoCarry.PluginMenu.draw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, 950, 0xFFFFFF)
	end
	if WRDY and AutoCarry.PluginMenu.draw.DrawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, 700, 0xFFFFFF)
	end
	if RRDY and AutoCarry.PluginMenu.draw.DrawR then
		DrawCircle(myHero.x, myHero.y, myHero.z, 150, 0xFFFFFF)
	end
	if AutoCarry.PluginMenu.draw.DrawXP then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1600, 0xFFFFFF)
	end
end

function PluginOnTick()
	Checks()
	if Target and AutoCarry.MainMenu.AutoCarry then ComboAC() end
	if Target and AutoCarry.MainMenu.MixedMode then ComboMM() end
--	if Target and AutoCarry.MainMenu.LaneClear then ComboLC() end  --for future version
	if AutoCarry.PluginMenu.FeastMinion then feastMinion() end
end

function ComboAC()
	if Target then
		if QRDY and AutoCarry.PluginMenu.autocarry.ACuseQ and GetDistance(Target) <= qRange then Q() end
		if WRDY and AutoCarry.PluginMenu.autocarry.ACuseW and GetDistance(Target) <= wRange then W() end
		if RRDY and AutoCarry.PluginMenu.autocarry.ACuseR and GetDistance(Target) <= rRange then R() end
	end
end

function ComboMM()
	if Target then
		if QRDY and AutoCarry.PluginMenu.mixedmode.MMuseQ and GetDistance(Target) <= qRange then Q() end
		if WRDY and AutoCarry.PluginMenu.mixedmode.MMuseW and GetDistance(Target) <= wRange then W() end
		if RRDY and AutoCarry.PluginMenu.mixedmode.MMuseR and GetDistance(Target) <= rRange then R() end
	end
end

--[[  For future version
function ComboLC()
	--if Minion then
		if QRDY and AutoCarry.PluginMenu.laneclear.LCuseQ and Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= qRange then CastSpell(_Q, Minion.x, Minion.z) end
		if WRDY and AutoCarry.PluginMenu.laneclear.LCuseW and Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= wRange then CastSpell(_W, Minion.x, Minion.z) end
		if RRDY and AutoCarry.PluginMenu.laneclear.LCuseR and Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= rRange and getDmg("R", Minion, myHero) then CastSpell(_R, Minion.x, Minion.z) end
	--end
end
]]

function Q()
	if QRDY then ProdictQ:GetPredictionCallBack(Target, CastQ) end
end

function W()
	if WRDY then CastSpell(_W, Target.x, Target.z) end
end

function R()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if Target and not Target.dead and Target.health < getDmg("R", enemy, myHero) and GetDistance(Target) < rRange then
			CastSpell(_R, Target)
		end
	end
end

function feastMinion()
	for i, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if GetDistance(minion) <= rRange + 100 and getDmg("R", minion, myHero) then
			CastSpell(_R, minion)
		end
	end
end

function CastQ(unit, pos, spell)
	if GetDistance(pos) - getHitBoxRadius(Target)/2 < qRange then
		CastSpell(_Q, pos.x, pos.z)
	end
end

local function getHitBoxRadius(target)
        return GetDistance(target, target.minBBox)
end

function Checks()
	Target = AutoCarry.GetAttackTarget()
	Minion = AutoCarry.GetMinionTarget()
	QRDY = (myHero:CanUseSpell(_Q) == READY)
	WRDY = (myHero:CanUseSpell(_W) == READY)
	RRDY = (myHero:CanUseSpell(_R) == READY)
end

--[[ For future version
function CountUnit(center, radius, range)
	local UnitCount = 0
	for j = 1, heroManager.iCount, 1 do
		local unit = heroManager:getHero(j)
		if myHero.team ~= unit.team and ValidTarget(unit, range) then
			if GetDistance(unit, center) <= radius then
				UnitCount = UnitCount + 1
			end
		end
	end            
	return UnitCount
end
]]