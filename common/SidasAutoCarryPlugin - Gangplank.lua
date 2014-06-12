if myHero.charName ~= "Gangplank" then return end

local SheenSlot, TrinitySlot, IcebornSlot = nil, nil, nil

function PluginOnLoad()
	mainLoad()
	mainMenu()
end

function PluginOnTick()
	farmMinions:update()
	jungleMinions:update()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
SheenSlot, TrinitySlot, IcebornSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3057), GetInventorySlotItem(3078)

	if Menu.autoks and QREADY then
		for i = 1, heroManager.iCount, 1 do
			local qTarget = heroManager:getHero(i)
			if ValidTarget(qTarget, qRange) then
				if qTarget.health <= qDamage(qTarget) then
					CastSpell(_Q, qTarget)
				end
			end
		end
	end
	
	if Target and Menu2.AutoCarry then
		if EREADY and Menu.useE and GetDistance(Target) <= eRange then
			CastSpell(_E)
		end
		if QREADY and Menu.useQ then
			if Menu.qChase and GetDistance(Target) > Menu.qDistance then
				CastSpell(_Q, Target)
			elseif Target.health <  qDamage(Target) then
				CastSpell(_Q, Target)
			end
		end
	end
	if Menu.qFarm and Menu2.LastHit or Menu2.LaneClear then
		for _, minion in pairs(farmMinions.objects) do
			if minion and ValidTarget(minion) and QREADY and GetDistance(minion) <= qRange then
				if minion.health < qDamage(minion) then
					CastSpell(_Q, minion)
				end 
			end
		end
		for _, jMinion in pairs(jungleMinions.objects) do
			if jMinion and ValidTarget(jMinion) and QREADY and GetDistance(jMinion) <= qRange then
				if jMinion.health < qDamage(jMinion) then
					CastSpell(_Q, jMinion)
				end 
			end
		end
	end
end

function OnAttacked()
	if Target and Menu2.AutoCarry then
		if QREADY and Menu.useQ and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
	end
end

function PluginOnDraw()	
	if Menu.drawQ and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
	end
end

function qDamage(target)
	local qDmg = myHero:CalcDamage(target, (20+(15*myHero:GetSpellData(_Q).level)+myHero.totalDamage))
	local bDmg = ((SheenSlot and getDmg("SHEEN", target, myHero) or 0)+(TrinitySlot and getDmg("TRINITY", target, myHero) or 0)+(IcebornSlot and getDmg("ICEBORN", target, myHero) or 0))-15
	return qDmg + bDmg
end

function mainLoad()
	AutoCarry.SkillsCrosshair.range = 700
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	qRange, eRange = 625, 600
	QREADY, EREADY  = false, false
	farmMinions = minionManager(MINION_ENEMY, qRange+200, player)
	jungleMinions = minionManager(MINION_JUNGLE, qRange+200, player)
end

function mainMenu()
	Menu:addParam("sep", "-- Cast Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("autoks", "Auto Kill with Parrrley!", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("qDistance", "Parrrley! buffer range",SCRIPT_PARAM_SLICE, 400, 0, 625, 0)
	Menu:addParam("qChase", "Parrrley! target when out of range", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("qFarm", "Farm with Parrrley!", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep", "-- Ability Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use - Parrrley!", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use - Raise Morale", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawQ", "Draw - Parrrley!", SCRIPT_PARAM_ONOFF, false)
end