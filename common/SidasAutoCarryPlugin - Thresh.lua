--[[

	SAC Thresh plugin

--]]

require "AoE_Skillshot_Position"

local SkillQ = {spellKey = _Q, range = 1075, speed = 2000, delay = 491, width = 50}

local qRange = 1075
local wRange = 950
local eRange = 400
local rRange = 450

local qMana = 80
local wMana = { 50, 55, 60, 65, 70}
local eMana = { 60, 65, 70, 75, 80}
local rMana = 100

local wLastTick = 0
local wLastHealth = 0

function PluginOnLoad()

	AutoCarry.SkillsCrosshair.range = 600

	MainMenu = AutoCarry.MainMenu
	PluginMenu = AutoCarry.PluginMenu

	--PluginMenu:addParam("sep1", "-- Spell Cast Options --", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("WRapid", "Use W when lost rapid amount of health", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("WPercentage", "Percent of health to use W",SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	PluginMenu:addParam("WTime", "W tracking time",SCRIPT_PARAM_SLICE, 0, 2, 5, 0)
	PluginMenu:addParam("ComboW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("RMec", "Use MEC for R", SCRIPT_PARAM_ONOFF, true)
	

	QREADY, WREADY, EREADY, RREADY = false, false, false, false

	wLastTick = GetTickCount()
end

function PluginOnTick()

	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)

	Target = AutoCarry.GetAttackTarget()

	if Target and MainMenu.AutoCarry then

		if WREADY and PluginMenu.WRapid and TakingRapidDamage() then
			CastSpell(_W, myHero.x, myHero.z) 
		end

		if WREADY and PluginMenu.ComboW and GetDistance(Target) <= wRange then
			CastSpell(_W, myHero.x, myHero.z)
		end

		if QREADY and GetDistance(Target) <= qRange then
			Skillshot(SkillQ, Target)
		end

		if EREADY and GetDistance(Target) <= eRange then 
			CastSpell(_E, Target.x, Target.z)
		end

		if RREADY and GetDistance(Target) <= rRange then
			local p = GetAoESpellPosition(450, Target)
			if CalculateDamage(Target) > Target.health then
				CastR(p)
			elseif CountEnemies(p, rRange) >= 2 then
				CastR(p)
			end

		end

	end

end

function CastR(p) 
	if PluginMenu.RMec then
		if p and GetDistance(p) <= rRange then
			CastSpell(_R, p.x, p.z)
		end
	else
		CastSpell(_R, Target.x, Target.z)
	end
end

function TakingRapidDamage() 
	if GetTickCount() - wLastTick > (PluginMenu.WTime * 1000) then
		--> Check amount of health lost
		if myHero.health - wLastHealth > myHero.maxHealth * (PluginMenu.WPercentage / 100) then
			return true
		else
			--> Reset counters
			wLastTick = GetTickCount()
			wLastHealth = myHero.health
		end
	end
end

function Skillshot(spell, target) 
    if not AutoCarry.GetCollision(spell, myHero, target) then
        AutoCarry.CastSkillshot(spell, target)
    end
end

function CalculateDamage(enemy)
	local totalDamage = 0
	local currentMana = myHero.mana 
	local qReady = QREADY and currentMana >= qMana
	local wReady = WREADY and currentMana >= wMana[myHero:GetSpellData(_W).level]
	local eReady = EREADY and currentMana >= eMana[myHero:GetSpellData(_E).level]
	local rReady = RREADY and currentMana >= rMana 
	if qReady then totalDamage = totalDamage + getDmg("Q", enemy, myHero) end
	if wReady then totalDamage = totalDamage + getDmg("W", enemy, myHero) end
	if eReady then totalDamage = totalDamage + getDmg("E", enemy, myHero) end
	if rReady then totalDamage = totalDamage + getDmg("R", enemy, myHero) end
	return totalDamage 

end 

function CountEnemies(point, range)
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