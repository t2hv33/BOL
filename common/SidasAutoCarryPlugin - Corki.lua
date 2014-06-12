--[[
 
        Auto Carry Plugin - Corki Edition
		Author: Kain
		Version: See version variable below.
		Copyright 2013

		Dependency: Sida's Auto Carry
 
		How to install:
			Make sure you already have AutoCarry installed.
			Name the script EXACTLY "SidasAutoCarryPlugin - Corki.lua" without the quotes.
			Place the plugin in BoL/Scripts/Common folder.

		Features:
			Combo: SBTW Intelligent Q, E, R 
			Killsteal: Killsteal with Q, E, or R.
			Valkyrie towards Mouse: Flies in the direction of your mouse, so you don't have to fully aim and hit another button.
			Phosphorus Bomb AoE: Uses AoE lib for max multi-target damage.
			Missile Barrage: Keeps track of missile explosion range and damage and hits multiple targets with splash damage based on your menu setting. Tracks "The Big One" missile, with increased explosion range and damage. 
			Missile Barrage Custom Collision: Custom splash damage minion collection detection detects splash damage on Missile Barrage including "The Big One". If it will hit a minion before the target, but target is within full splash damage range of the minion, it fires. If a minion is a collision and out of splash damage range, it does not fire.
			Range Circles: Smart range circles turn on and off as their respective spells are available.
			Damage Combo Calulator: Shows messages on targets when kill-able by a combo.
			Customization: Fully customizable Combo (Q, E, R), Harass (Q, E, R), and Draw.
			Menus: Extensive configuration options in two menus.
			Reborn: Fully compatible.
			Misc: Mana Manager, Auto Leveler.
		
		Download: https://bitbucket.org/KainBoL/bol/raw/master/Common/SidasAutoCarryPlugin%20-%20Corki.lua

		Version History:
			Version: 1.1b:
				Missile Barrage Custom Collision
				Added checks for missing or old collision lib.
				Added "BoL Studio Script Updater" url and hash.
			Version: 1.0
				Release

		To Do: Known issue: The Big One missile tracking can become out of sync in Reborn if script is started after missiles have been accrued, due to lack of Buff function support in Reborn. Revamped works great.
--]]

if myHero.charName ~= "Corki" then return end

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

function Vars()
	version = "1.1b"

	KeyQ = string.byte("Q")
	KeyW = string.byte("W")
	KeyE = string.byte("E")
	KeyR = string.byte("R")

	QRange, WRange, ERange, RRange = 840, 800, 600, 1225
	QNormalRange = 600
	QRadius, RRadius = 250, 75

	QReady, WReady, EReady, RReady = false, false, false, false

	SkillQ = {spellKey = _Q, range = QRange, speed = math.huge, delay = 200, width = 475}
	SkillW = {spellKey = _W, range = WRange, speed = .650, delay = 200, width = 450}
	SkillR = {spellKey = _R, range = RRange, speed = 2.0, delay = 175, width = 60, minions = true}

	tick = nil

	levelSequence = { 1,2,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2 }

	floattext = {"Harass him","Fight him","Kill him","Murder him"}
	killable = {}
	waittxt = {} -- prevents UI lags, all credits to Dekaron
	for i=1, heroManager.iCount do waittxt[i] = i*3 end -- All credits to Dekaron

	missileCount = 0
	BuffTheBigOne = "mbcheck2"
	SpellMissileBarrage = "MissileBarrage"
	missileTheBigOne = false

	debugMode = false
end

function Menu()
	AutoCarry.PluginMenu:addParam("sep", "----- Corki by Kain: v"..version.." -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "----- [ Combo ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("ComboQ", "Use Phosphorus Bomb", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboE", "Use Gatling Gun", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboR", "Use Missile Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboRMinEnemies", "R Min Enemies", SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Harass ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("HarassQ", "Use Phosphorus Bomb", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("HarassE", "Use Gatling Gun", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("HarassR", "Use Missile Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("HarassRMinEnemies", "R Min Enemies", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Valkyrie Options ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("SmartW", "Valkyrie Towards Mouse", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("WMinMouseDiff", "Valkyrie Min. Mouse Diff.", SCRIPT_PARAM_SLICE, 400, 100, 1000, 0)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Killsteal ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("KillstealR", "Missile - Kill Steal", SCRIPT_PARAM_ONOFF, true)

	ExtraConfig = scriptConfig("Sida's Auto Carry Plugin: Corki: Extras", "Corki")
	ExtraConfig:addParam("sep", "----- [ Misc ] -----", SCRIPT_PARAM_INFO, "")
	ExtraConfig:addParam("RSplashDamage", "Use Splash Dmg on R (FPS)", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("AutoLevelSkills", "Auto Level Skills (Requires Reload)", SCRIPT_PARAM_ONOFF, true) -- auto level skills
	ExtraConfig:addParam("ManaManager", "Mana Manager %", SCRIPT_PARAM_SLICE, 40, 0, 100, 2)
	ExtraConfig:addParam("ProMode", "Use Auto QWER Keys", SCRIPT_PARAM_ONOFF, true)

	ExtraConfig:addParam("sep", "----- [ Draw ] -----", SCRIPT_PARAM_INFO, "")
	ExtraConfig:addParam("DrawKillable", "Draw Killable Enemies", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DisableDrawCircles", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	ExtraConfig:addParam("DrawFurthest", "Draw Furthest Spell Available", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawTargetArrow", "Draw Arrow to Target", SCRIPT_PARAM_ONOFF, false)
	ExtraConfig:addParam("DrawQ", "Draw Phosphorus Bomb", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawW", "Draw Valkyrie", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawE", "Draw Gatling Gun", SCRIPT_PARAM_ONOFF, true)
	ExtraConfig:addParam("DrawR", "Draw Missile Barrage", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1300

	Vars()
	Menu()

	if ExtraConfig.AutoLevelSkills then -- setup the skill autolevel
		autoLevelSetSequence(levelSequence)
	end
end

function PluginOnTick()
	DisableRebornJunk()
	tick = GetTickCount()
	Target = AutoCarry.GetAttackTarget()

	SpellCheck()

	if Target and not Target.dead then
		if AutoCarry.MainMenu.AutoCarry then
			Combo()
		elseif AutoCarry.MainMenu.MixedMode and not IsMyManaLow() then
			Harass()
		end
	end

	if AutoCarry.PluginMenu.KillstealR and RReady then KillstealR() end
end

function Combo()
	if QReady and AutoCarry.PluginMenu.ComboQ then
		CastQ()
	end

	if EReady and AutoCarry.PluginMenu.ComboE then
		CastE()
	end

	if RReady and AutoCarry.PluginMenu.ComboR then
		CastR(Target, AutoCarry.PluginMenu.ComboRMinEnemies)
	end
end

function Harass()
	if QReady and AutoCarry.PluginMenu.HarassQ then
		CastQ()
	end

	if EReady and AutoCarry.PluginMenu.HarassE then
		CastE()
	end

	if RReady and AutoCarry.PluginMenu.HarassR then
		CastR(Target, AutoCarry.PluginMenu.HarassRMinEnemies)
	end
end

function OnGainBuff(unit, buff)
	if buff and buff.type ~= nil and unit.name == myHero.name and unit.team == myHero.team then
		if buff.name == BuffTheBigOne then
			if debugMode then PrintChat("buff: "..buff.name) end
			missileTheBigOne = true
		end
	end 
end

function OnLoseBuff(unit, buff)
	if buff and buff.type ~= nil and unit.name == myHero.name and unit.team == myHero.team then
		if buff.name == BuffTheBigOne then
			if debugMode then PrintChat("bufflose: "..buff.name) end
			missileTheBigOne = false
		end
	end 
end

function SpellCheck()
	if missileCount > 2 then missileCount = 0 end

	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
end

function DisableRebornJunk()
		-- Disable SAC Reborn's auto spells. Ours are better.
	if AutoCarry.Skills then
		AutoCarry.Skills:GetSkill(SkillQ.spellKey).Enabled = false
		AutoCarry.Skills:GetSkill(SkillR.spellKey).Enabled = false
	end
end

function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name == SpellMissileBarrage then
		missileCount = missileCount + 1
	end
end

function CastQ(enemy)
	if not enemy then enemy = Target end
	if not enemy or enemy.dead or not ValidTarget(enemy, QRange) then return false end

	if EnemyCount(enemy, QRadius) >= 2 then
		local spellPos = GetAoESpellPosition(QRadius, enemy, SkillQ.delay)

		if spellPos and GetDistance(spellPos) <= QNormalRange then
			if EnemyCount(spellPos, QRadius) >= 2 then
				if debugMode then PrintChat("Q AoE") end
				CastSpell(SkillQ.spellKey, spellPos.x, spellPos.z)
				return true
			end
		end
	else
		predPos = AutoCarry.GetPrediction(SkillQ, enemy)
		if predPos and GetDistance(predPos) <= QRange then
			if GetDistance(predPos) > QNormalRange then
				Distance = GetDistance(predPos) - QNormalRange
				castPos = Vector(predPos) + (Vector(predPos) - Vector(myHero)) * ((-Distance / GetDistance(predPos)))
				if debugMode then PrintChat("Q 1") end
				CastSpell(SkillQ.spellKey, castPos.x, castPos.z)
				return true
			elseif GetDistance(predPos) <= QNormalRange then
				if debugMode then PrintChat("Q 2") end
				CastSpell(SkillQ.spellKey, predPos.x, predPos.z)
				return true
			end
		end
	end

	return false
end

function CastE()
	if not enemy then enemy = Target end
	if GetDistance(enemy) < ERange then
		CastSpell(_E)
		return true
	end

	return false
end

function CastW()
	if AutoCarry.PluginMenu.SmartW then
		if (GetDistance(mousePos) > AutoCarry.PluginMenu.WMinMouseDiff) then
			local dashSqr = math.sqrt((mousePos.x - myHero.x)^2 + (mousePos.z - myHero.z)^2)
			local dashX = myHero.x + WRange * ((mousePos.x - myHero.x) / dashSqr)
			local dashZ = myHero.z + WRange * ((mousePos.z - myHero.z) / dashSqr)

			CastSpell(SkillW.spellKey, dashX, dashZ)
			return true
		end
	end

	return false
end

function CastR(enemy, minEnemies)
	if not minEnemies then minEnemies = 1 end
	if not enemy then enemy = Target end

	if enemy and not enemy.dead and ValidTarget(enemy, SkillR.range) then
		predPos = AutoCarry.GetPrediction(SkillR, enemy)

		if predPos then
			local enemyCount = 0
			local splashRadius = nil
			if missileTheBigOne or (AutoCarry.Skills and missileCount == 2) then -- The Big One
				splashRadius = RRadius * 2
			else
				splashRadius = RRadius
			end

			enemyCount = EnemyCount(predPos, splashRadius)

			if enemyCount >= minEnemies then
				local collision = false

				if ExtraConfig.RSplashDamage then
					local m, minions = GetMinionCollision(SkillR, nil, myHero, enemy)

					if m then
						for index, minion in pairs(minions) do
							if GetDistance(minion, enemy) > splashRadius then
								collision = true
								break
							end
						end 
					end
				else
					collision = AutoCarry.GetCollision(SkillR, myHero, enemy)
				end
				
				if not collision then
					AutoCarry.CastSkillshot(SkillR, enemy)
					return true
				end
			end
		end
	end

	return false
end

function KillstealR()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy and not enemy.dead and ValidTarget(enemy, SkillR.range) then
			if (missileTheBigOne or (AutoCarry.Skills and missileCount == 2)) then -- The Big One
				RDmg = getDmg("R", enemy, myHero) * 1.5 
			else
				RDmg = getDmg("R", enemy, myHero) 
			end

			if enemy.health < RDmg then
				CastR(enemy, 1)
				return true
			end
		end
	end

	return false
end

function GetMinionCollision(skill, altRange, source, destination)
	if not altRange then altRange = skill.range end

	if VIP_USER then
		local col = Collision(altRange, skill.speed*1000, skill.delay/1000, skill.width)

		if col then
			local ret, minions = col:GetMinionCollision(source, destination)
			return ret, minions
		else
			return false, nil
		end
	else
		local minion = GetNonVIPMinionCollision(destination, skill.width)
		if minion then
			return true, minion
		else
			return false, nil
		end
	end
end

function GetNonVIPMinionCollision(predic, width)
	local minions = {}
	for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if minion ~= nil and minion.valid and string.find(minion.name,"Minion_") == 1 and minion.team ~= player.team and minion.dead == false then
			if predic ~= nil and predic.x ~= nil and predic.z ~= nil then
				ex = player.x
				ez = player.z
				tx = predic.x
				tz = predic.z

				if ex ~= nil and ez ~= nil and tx ~= nil and tz ~= nil then
					dx = ex - tx
					dz = ez - tz
					if dx ~= 0 then
						m = dz/dx
						c = ez - m*ex
					end
					mx = minion.x
					mz = minion.z
					distanc = (math.abs(mz - m*mx - c))/(math.sqrt(m*m+1))
					if distanc < width and math.sqrt((tx - ex)*(tx - ex) + (tz - ez)*(tz - ez)) > math.sqrt((tx - mx)*(tx - mx) + (tz - mz)*(tz - mz)) then
						table.insert(minions, minion)
					end
				end
			end
		end
	end

	return minions
end

function IsMyManaLow()
	if myHero.mana < (myHero.maxMana * ( ExtraConfig.ManaManager / 100)) then
		return true
	else
		return false
	end
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

function PluginOnWndMsg(msg,key)
	Target = AutoCarry.GetAttackTarget(true)
	if ExtraConfig.ProMode then
		if Target then
			if msg == KEY_DOWN and key == KeyQ then CastQ() end
		
	--		if msg == KEY_DOWN and key == KeyE then CastE() end
			if msg == KEY_DOWN and key == KeyR then CastR(Target, 1) end
		end

		if msg == KEY_DOWN and key == KeyW then CastW() end
	end
end

function DMGCalculation()
	for i=1, heroManager.iCount do
        local Unit = heroManager:GetHero(i)
        if ValidTarget(Unit) then
        	local RUINEDKINGDamage, IGNITEDamage, BWCDamage = 0, 0, 0
        	local QDamage = getDmg("Q",Unit,myHero)
			local WDamage = getDmg("W",Unit,myHero)
			local EDamage = getDmg("E",Unit,myHero)
			local RDamage = getDmg("R", Unit, myHero)
			local HITDamage = getDmg("AD",Unit,myHero)
			local IGNITEDamage = (IGNITESlot and getDmg("IGNITE",Unit,myHero) or 0)
			local BWCDamage = (BWCSlot and getDmg("BWC",Unit,myHero) or 0)
			local RUINEDKINGDamage = (RUINEDKINGSlot and getDmg("RUINEDKING",Unit,myHero) or 0)
			local combo1 = HITDamage
			local combo2 = HITDamage
			local combo3 = HITDamage
			local mana = 0

			if QReady then
				combo1 = combo1 + QDamage
				combo2 = combo2 + QDamage
				combo3 = combo3 + QDamage
				mana = mana + myHero:GetSpellData(SkillQ.spellKey).mana
			end

			if WReady then
				combo1 = combo1 + WDamage
				combo2 = combo2 + WDamage
				combo3 = combo3 + WDamage
				mana = mana + myHero:GetSpellData(SkillW.spellKey).mana
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
				mana = mana + myHero:GetSpellData(SkillR.spellKey).mana
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

function IsTickReady(tickFrequency)
	-- Improves FPS
	if tick ~= nil and math.fmod(tick, tickFrequency) == 0 then
		return true
	else
		return false
	end
end

function PluginOnDraw()
	if Target ~= nil and not Target.dead and ExtraConfig.DrawTargetArrow and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
		DrawArrowsToPos(myHero, Target)
	end

	if IsTickReady(75) then DMGCalculation() end

	DrawKillable()
	DrawRanges()
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

		if ExtraConfig.DrawQ and QReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == SkillQ.range) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, 0x0099CC) -- Blue
		end

		if ExtraConfig.DrawW and WReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == SkillW.range) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, 0xFFFF00) -- Yellow
		end

		if ExtraConfig.DrawE and EReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == ERange) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x00FF00) -- Green
		end

		if ExtraConfig.DrawR and RReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == SkillR.range) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, 0xFF0000) -- Red
		end

		Target = AutoCarry.GetAttackTarget(true)
		if Target ~= nil then
			for j=0, 10 do
				DrawCircle(Target.x, Target.y, Target.z, 40 + j*1.5, 0x00FF00) -- Green
			end
		end
	end
end

function FindFurthestReadySpell()
	local farSpell = nil

	if ExtraConfig.DrawQ and QReady then farSpell = SkillQ.range end
	if ExtraConfig.DrawW and RReady and (not farSpell or SkillW.range > farSpell) then farSpell = SkillW.range end
	if ExtraConfig.DrawE and EReady and (not farSpell or ERange > farSpell) then farSpell = ERange end
	if ExtraConfig.DrawR and RReady and (not farSpell or SkillR.range > farSpell) then farSpell = SkillR.range end

	return farSpell
end

function DrawArrowsToPos(pos1, pos2)
	if pos1 and pos2 then
		startVector = D3DXVECTOR3(pos1.x, pos1.y, pos1.z)
		endVector = D3DXVECTOR3(pos2.x, pos2.y, pos2.z)
		DrawArrows(startVector, endVector, 60, 0xE97FA5, 100)
	end
end

function GetTrueRange()
	return myHero.range + GetDistance(myHero.minBBox)
end

-- End of Corki script

--[[ 
	AoE_Skillshot_Position 2.0 by monogato
	
	GetAoESpellPosition(radius, main_target, [delay]) returns best position in order to catch as many enemies as possible with your AoE skillshot, making sure you get the main target.
	Note: You can optionally add delay in ms for prediction (VIP if avaliable, normal else).
]]

function GetCenter(points)
	local sum_x = 0
	local sum_z = 0
	
	for i = 1, #points do
		sum_x = sum_x + points[i].x
		sum_z = sum_z + points[i].z
	end
	
	local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
	
	return center
end

function ContainsThemAll(circle, points)
	local radius_sqr = circle.radius*circle.radius
	local contains_them_all = true
	local i = 1
	
	while contains_them_all and i <= #points do
		contains_them_all = GetDistanceSqr(points[i], circle.center) <= radius_sqr
		i = i + 1
	end
	
	return contains_them_all
end

-- The first element (which is gonna be main_target) is untouchable.
function FarthestFromPositionIndex(points, position)
	local index = 2
	local actual_dist_sqr
	local max_dist_sqr = GetDistanceSqr(points[index], position)
	
	for i = 3, #points do
		actual_dist_sqr = GetDistanceSqr(points[i], position)
		if actual_dist_sqr > max_dist_sqr then
			index = i
			max_dist_sqr = actual_dist_sqr
		end
	end
	
	return index
end

function RemoveWorst(targets, position)
	local worst_target = FarthestFromPositionIndex(targets, position)
	
	table.remove(targets, worst_target)
	
	return targets
end

function GetInitialTargets(radius, main_target)
	local targets = {main_target}
	local diameter_sqr = 4 * radius * radius
	
	for i=1, heroManager.iCount do
		target = heroManager:GetHero(i)
		if target.networkID ~= main_target.networkID and ValidTarget(target) and GetDistanceSqr(main_target, target) < diameter_sqr then table.insert(targets, target) end
	end
	
	return targets
end

function GetPredictedInitialTargets(radius, main_target, delay)
	if VIP_USER and not vip_target_predictor then vip_target_predictor = TargetPredictionVIP(nil, nil, delay/1000) end
	local predicted_main_target = VIP_USER and vip_target_predictor:GetPrediction(main_target) or GetPredictionPos(main_target, delay)
	local predicted_targets = {predicted_main_target}
	local diameter_sqr = 4 * radius * radius
	
	for i=1, heroManager.iCount do
		target = heroManager:GetHero(i)
		if ValidTarget(target) then
			predicted_target = VIP_USER and vip_target_predictor:GetPrediction(target) or GetPredictionPos(target, delay)
			if target.networkID ~= main_target.networkID and GetDistanceSqr(predicted_main_target, predicted_target) < diameter_sqr then table.insert(predicted_targets, predicted_target) end
		end
	end
	
	return predicted_targets
end

-- I don't need range since main_target is gonna be close enough. You can add it if you do.
function GetAoESpellPosition(radius, main_target, delay)
	local targets = delay and GetPredictedInitialTargets(radius, main_target, delay) or GetInitialTargets(radius, main_target)
	local position = GetCenter(targets)
	local best_pos_found = true
	local circle = Circle(position, radius)
	circle.center = position
	
	if #targets > 2 then best_pos_found = ContainsThemAll(circle, targets) end
	
	while not best_pos_found do
		targets = RemoveWorst(targets, position)
		position = GetCenter(targets)
		circle.center = position
		best_pos_found = ContainsThemAll(circle, targets)
	end
	
	return position
end

--UPDATEURL=https://bitbucket.org/KainBoL/bol/raw/master/Common/SidasAutoCarryPlugin%20-%20Corki.lua
--HASH=436A72245C9800F46718883526B52B4B