--[[ 
	
	SAC - Brand Edition Ablaze

--]]

local SkillQ = {spellKey = _Q, range = 1000, speed = 1603, delay = 187, width = 110}
local wRange = 900
local eRange = 625
local rRange = 750

local qMana = 50
local wMana = { 70, 75, 80, 85, 90}
local eMana = { 70, 75, 80, 85, 90}
local rMana = 100 

function PluginOnLoad() 

	AutoCarry.SkillsCrosshair.range = 1100

	MainMenu = AutoCarry.MainMenu
	PluginMenu = AutoCarry.PluginMenu

	PluginMenu:addParam("sep1", "-- Spell Cast Options --", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("ESpread", "Spread Ablaze with E", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("QStun", "Stun killable targets with Q", SCRIPT_PARAM_ONOFF, true)

	QREADY, WREADY, EREADY, RREADY = false, false, false, false

end

function PluginOnTick()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)

	Target = AutoCarry.GetAttackTarget()

	--> AutoCarry
	if Target and MainMenu.AutoCarry then

		--> Ablaze check
		if IsAblaze(Target) then

			--> Stun killable
			if QREADY and PluginMenu.QStun and CalculateDamage(Target) > Target.health and GetDistance(Target) <= SkillQ.range then
				Skillshot(SkillQ, Target)
			end

			--> Spread Ablaze
			if EREADY and PluginMenu.ESpread and CountEnemyHeroInRange(300, Target) >= 2 and GetDistance(Target) <= eRange then
				CastSpell(_E, Target)
			end

		end

		--> Regular casting
		if QREADY and GetDistance(Target) <= SkillQ.range then 
			Skillshot(SkillQ, Target)
		end

		if WREADY and GetDistance(Target) <= wRange then
			CastSpell(_W, Target.x, Target.z)
		end

		if EREADY and GetDistance(Target) <= eRange then 
			CastSpell(_E, Target)
		end

		if RREADY and GetDistance(Target) <= rRange then 
			CastSpell(_R, Target)
		end 

	end
end

function PluginOnDraw() 
	if Target then
		DrawCircle(Target.x, Target.y, Target.z, 65, 0x00FF00)
		local text = ""
		if Target.health <= CalculateDamage(Target) then
			text = "Killable"
		else
			text = "Wait for Cooldowns"
		end
		PrintFloatText(Target, 0, text)
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

function Skillshot(spell, target) 
    if not AutoCarry.GetCollision(spell, myHero, target) then
        AutoCarry.CastSkillshot(spell, target)
    end
end

function IsAblaze(target)
	return TargetHaveBuff("Ablaze", target)
end