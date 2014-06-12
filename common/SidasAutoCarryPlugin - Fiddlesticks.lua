if myHero.charName ~= "FiddleSticks" then return end

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 750
	wChanneling = false
	qRange, wRange, eRange = 575, 475, 750
	mainMenu()
end

function PluginOnTick()
	if wChanneling then
		AutoCarry.CanAttack = false
		AutoCarry.CanMove = false
	else
		AutoCarry.CanAttack = true
		AutoCarry.CanMove = true
	end
	Target = AutoCarry.GetAttackTarget(true)
	if AutoCarry.MainMenu.AutoCarry then Combo() end
	if AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LaneClear then Farm() end
	if AutoCarry.MainMenu.MixedMode then Harrass() end
end

function Combo()
	if Target then
		if GetDistance(Target) <= eRange and not wChanneling then CastSpell(_E, Target) end
		if GetDistance(Target) <= qRange and not wChanneling and myHero:CanUseSpell(_E) ~= READY then CastSpell(_Q, Target) end
		if GetDistance(Target) <= wRange and myHero:CanUseSpell(_Q) ~= READY and myHero:CanUseSpell(_E) ~= READY then CastSpell(_W, Target) end
	end
end

function Farm()
	for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if ValidTarget(minion) then
			if GetDistance(minion) <= eRange and AutoCarry.PluginMenu.eFarm then
				if minion.health <= getDmg("E", minion, myHero) then CastSpell(_E, minion) end
			end
			if GetDistance(minion) <= wRange and AutoCarry.PluginMenu.wFarm then
				if minion.health <= getDmg("W", minion, myHero)*5 and minion.health > getDmg("W", minion, myHero) then CastSpell(_W, minion) end
			end
		end
	end
end

function Harrass()
	if Target then
		if GetDistance(Target) <= qRange and AutoCarry.PluginMenu.qHarrass then CastSpell(_Q, Target) end
		if GetDistance(Target) <= wRange and AutoCarry.PluginMenu.wHarrass then CastSpell(_W, Target) end
	end
end

function PluginOnAnimation(unit, animationName)
		if unit.isMe and (animationName == "Spell4" or animationName == "Spell4_Loop" or animationName == "Spell4_Winddown") then 
			wChanneling = true
		end
		if unit.isMe and animationName ~= "Spell4" and animationName ~="Spell4_Loop" and animationName ~= "Spell4_Winddown" then
			wChanneling = false
		end
end

function PluginOnDraw()
	if not myHero.dead then
		if myHero:CanUseSpell(_Q) == READY and AutoCarry.PluginMenu.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x191970)
		end
		if myHero:CanUseSpell(_W) == READY and AutoCarry.PluginMenu.wDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x20B2AA)
		end
		if myHero:CanUseSpell(_E) == READY and AutoCarry.PluginMenu.eDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x800080)
		end
	end
end

function mainMenu()
	AutoCarry.PluginMenu:addParam("sep1", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("wHarrass", "Harrass with Dark Wind (E)", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("qHarrass", "Harrass with Terrify (Q)", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("sep2", "-- Farm Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("wFarm", "Farm with Life Drain (W)", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("eFarm", "Farm with Dark Wind (E)", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("qDraw", "Terrify (Q) Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("wDraw", "Life Drain (W) Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("eDraw", "Dark Wind (E) Range", SCRIPT_PARAM_ONOFF, true)
end