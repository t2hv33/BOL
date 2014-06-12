if myHero.charName ~= "Vladimir" then return end

require "AoE_Skillshot_Position"

function PluginOnLoad()
	mainLoad()
	mainMenu()
end

function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	
	if Menu.autoks and QREADY then
		for i = 1, heroManager.iCount, 1 do
			local qTarget = heroManager:getHero(i)
			if ValidTarget(qTarget, qRange) then
				if qTarget.health <=  getDmg("Q", qTarget, myHero) then CastSpell(_Q, qTarget) end
			end
		end
	end
	
	if Target and (Menu2.AutoCarry or Menu2.MixedMode) then
		if QREADY and Menu.useQ and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
		if EREADY and Menu.useE and GetDistance(Target) <= eRange then CastSpell(_E) end
	end
	if Target and Menu2.AutoCarry then
		if RREADY and Menu.useR then castR(Target) end
	end
	
	if EREADY and Menu.bloodStack and GetTickCount() - eTick >= 9500 and Recalling == false then 
		CastSpell(_E) 
	end
	
	if Menu.qFarm and (Menu2.LastHit or Menu2.LaneClear) then
		for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
			if ValidTarget(minion) and QREADY and GetDistance(minion) <= qRange then
				if minion.health < getDmg("Q", minion, myHero) then CastSpell(_Q, minion) end 
			end
		end
	end
end

function PluginOnDraw()	
	if Menu.drawQ and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
	end
end

function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name == myHero:GetSpellData(_E).name then eTick = GetTickCount() end
end

function PluginOnCreateObj(object)
	if (object.name == "TeleportHomeImproved.troy" or object.name == "TeleportHome.troy") and GetDistance(myHero, object) < 50 then
		rTick = GetTickCount()
		Recalling = true
	end
end

function PluginOnDeleteObj(object)
	if (object.name == "TeleportHomeImproved.troy" or object.name == "TeleportHome.troy") and GetDistance(myHero, object) < 50 then
		Recalling = false
	end
end

function CountEnemies(point, range)
	local ChampCount = 0
	for j = 1, heroManager.iCount, 1 do
		local enemyhero = heroManager:getHero(j)
		if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, rRange+150) then
			if GetDistance(enemyhero, point) <= range then
				ChampCount = ChampCount + 1
			end
		end
	end		
	return ChampCount
end

function castR(target)
	if Menu.rMEC then
		local ultPos = GetAoESpellPosition(350, target)
		if ultPos and GetDistance(ultPos) <= rRange	then
			if CountEnemies(ultPos, 350) >= Menu.rEnemies then
				CastSpell(_R, ultPos.x, ultPos.z)
			end
		end
	elseif GetDistance(target) <= rRange then
		CastSpell(_R, target.x, target.z)
	end
end

function mainLoad()
	AutoCarry.SkillsCrosshair.range = 750
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	qRange, eRange, rRange = 600, 600, 700
	eTick, rTick = 0, 0
	QREADY, EREADY, RREADY, Recalling  = false, false, false, false
	if GetTickCount() - rTick > 7000 then Recalling = false end
end

function mainMenu()
	Menu:addParam("sep", "-- Cast Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("autoks", "Transfusion - Kill Steal", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("qFarm", "Transfusion - Lasthit", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("rMEC", "Hemoplague - Use MEC", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("rEnemies", "Hemoplague - Min Enemies",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu:addParam("bloodStack", "Tides of Blood - Stack", SCRIPT_PARAM_ONKEYTOGGLE, false, 71)
	Menu:addParam("sep", "-- Ability Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use - Transfusion", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use - Tides of Blood", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR", "Use - Hemoplague", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawQ", "Draw - Transfusion", SCRIPT_PARAM_ONOFF, false)
end