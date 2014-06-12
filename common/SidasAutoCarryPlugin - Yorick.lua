--[[ I have a small penis so I play Yorick, a SAC Plugin

		Version 1.0d
		
		Features,
		Harass, w/ mana management
		AutoCarry
		Auto Self Ult with HP slider
		Teammate ult with toggle
		
		To Do: KS
			New harass modes (i.e. saving E until you are at % hp
			Passive tracker
			Catching with W
			
			
	Credits: Kain (he is a god), Sida (also a god), Skeem because I learned some from him as well, and everyone who paved the way.

	]]--
	
if myHero.charName ~= "Yorick" then return end

function Vars()
		curVersion =  1.0
		
		if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
		
		--Disable SAC Reborn's skills. 
		if IsSACReborn then
			AutoCarry.Skills:DisableAll()
			end
		
		QRange, WRange, ERange, RRange = 125, 600, 550, 900
		WSpeed = math.huge
		WDelay = 0.250
		WWidth = 100
		
		if IsSACReborn then
			SkillQ = AutoCarry.Skills:NewSkill (false, _Q, QRange, "Omen of War", AutoCarry.SPELL_SELF, 0, false, false, false)
			SkillW = AutoCarry.Skills:NewSkill (false, _W, WRange, "Omen of Pestilence", AutoCarry.SPELL_CIRCLE, 0, false, false, WSpeed, WDelay, WWidth, false)
			SkillE = AutoCarry.Skills:NewSkill (false, _E, ERange, "Omen of Famine", AutoCarry.SPELL_TARGETED, 0, false, false, false)
			SkillR = AutoCarry.Skills:NewSkill (false, _R, RRange, "Omen of Death", AutoCarry.SPELL_TARGETED_FRIENDLY, 0, false, false, false)
		else
			SkillQ = {spellKey = _Q, range = QRange, minions = false }
			SkillW = {spellKey = _W, range = WRange, speed = WSpeed, delay = WDelay, width = WWidth, minions = false}
			SkillE = {spellKey = _E, range = ERange, minions = false }
			SkillR = {spellKey = _R, range = RRange, minions = false }
		end
		
		-- Items 
		ignite = nil
		DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil
		QReady, WReady, EReady, RReady, DFGReady, HXGReady, BWCReady, INGNITEReady, BARRIERReady, CLEANSEReady, FReady = false, false, false, false, false, false, false, false, false, false, false
		flashEscape = false
		
		IGNITESlot = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") and SUMMONER_2) or nil)
		BARRIERSlot = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerBarrier") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerBarrier") and SUMMONER_2) or nil)
		CLEANSESlot = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerCleanse") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerCleanse") and SUMMONER_2) or nil)
		
		floattext = {"Harass Him", "Fight Him", "Kill Him", "Murder Him"} --floatingtext regarding damage potential
		
		killable = {} -- our enemy array where stored if people are killable
		waittxt = {} -- prevents UI lags, PRAISE BE TO DEKARON
		
		for i=1, heroManager.iCount do waittxt[i] = i*3 end -- Once again Dek is God
		
		standRange = 125 -- range checking for mouse
		
		tick = 0
		
		Target = nil
		
		debugMode = false
		

	
	items = 
			{
		BRK = {id=3153, range = 500, reqTarget = true, slot = nil },
		BWC = {id=3144, range = 400, reqTarget = true, slot = nil },
		DFG = {id=3128, range = 750, reqTarget = true, slot = nil },
		HGB = {id=3146, range = 400, reqTarget = true, slot = nil },
		RSH = {id=3074, range = 350, reqTarget = false, slot = nil},
		STD = {id=3131, range = 350, reqTarget = false, slot = nil},
		TMT = {id=3077, range = 350, reqTarget = false, slot = nil},
		YGB = {id=3142, range = 350, reqTarget = false, slot = nil}
	}
	end
	

function Menu()
				AutoCarry.PluginMenu:addParam("sep", "----- "..myHero.charName.." by InsertNameHere: v"..curVersion.." -----", SCRIPT_PARAM_INFO, "")
				AutoCarry.PluginMenu:addParam("sep", "----- [ Combo ] -----", SCRIPT_PARAM_INFO, "")
				AutoCarry.PluginMenu:addParam("ComboQ", "Use Omen of War", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("ComboW", "Use Omen of Pestilence", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("ComboE", "Use Omen of Famine", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("EnemyLockOn", "Lock Onto Enemy", SCRIPT_PARAM_ONOFF, false, string.byte("S"))
				AutoCarry.PluginMenu:addParam("EnemyPermLockOn", "Lock Onto Enemy Always", SCRIPT_PARAM_ONOFF, false)
				AutoCarry.PluginMenu:addParam("AutoIgnite", "Auto Ignite Killable Enemy", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("UseItems", "Use Items", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("sep", "----- [ Harass ] -----", SCRIPT_PARAM_INFO, "")
				AutoCarry.PluginMenu:addParam("HarassQ", "Use Omen of War", SCRIPT_PARAM_ONOFF, false)
				AutoCarry.PluginMenu:addParam("HarassW", "Use Omen of Pestilence", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("HarassE", "Use Omen of Famine", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("ManaManager", "Mana Manager %", SCRIPT_PARAM_SLICE, 40, 0, 100, 2)
				AutoCarry.PluginMenu:addParam("sep", "----- [ Ultimate Options ] -----", SCRIPT_PARAM_INFO, "")
				AutoCarry.PluginMenu:addParam("AutoUlt", "Self Cast Ultimate", SCRIPT_PARAM_ONOFF, true)
				AutoCarry.PluginMenu:addParam("UltHealth", "Ult Health %", SCRIPT_PARAM_SLICE, 20, 0, 100, 2)
				AutoCarry.PluginMenu:addParam("sep", "----- [ Ultimate Ally Options ] -----", SCRIPT_PARAM_INFO, "")
				AutoCarry.PluginMenu:addParam("UltAllies", "Ult Allies (G)", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("G"))
					AutoCarry.PluginMenu:permaShow("UltAllies")
					for i=1, heroManager.iCount do
						local ally = heroManager:GetHero(i)
						if ally.team == myHero.team and ally.name ~= myHero.name then AutoCarry.PluginMenu:addParam("ult"..i, "Ult "..ally.charName, SCRIPT_PARAM_ONOFF, true) end
					end
				ExtraConfig = scriptConfig("Sida's Auto Carry Plugin: "..myHero.charName..": Extras", myHero.charName)
				ExtraConfig:addParam("sep", "----- [ Draw ] -----", SCRIPT_PARAM_INFO, "")
				ExtraConfig:addParam("DrawKillable", "Draw Killable Enemies", SCRIPT_PARAM_ONOFF, true)
				ExtraConfig:addParam("DisableDrawCircles", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
				ExtraConfig:addParam("DrawFurthest", "Draw Furthest Spell Available", SCRIPT_PARAM_ONOFF, true)
				ExtraConfig:addParam("DrawTargetArrow", "Draw Arrow to Target", SCRIPT_PARAM_ONOFF, false)
				ExtraConfig:addParam("DrawQ", "Draw Omen of War", SCRIPT_PARAM_ONOFF, true)
				ExtraConfig:addParam("DrawE", "Draw Omen of Pestilence", SCRIPT_PARAM_ONOFF, true)
				ExtraConfig:addParam("DrawW", "Draw Omen of Famine", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnLoad ()
		Vars()
		Menu()
		
		if IsSACReborn then 
				AutoCarry.Crosshair:SetSkillCrosshairRange(900)
		else 
				AutoCarry.SkillsCrosshair.range = 900
end
end


function PluginOnTick()
		tick = GetTickCount()
		Target = GetTarget()
		SpellChecks()
		
		if Target then
			if AutoCarry.MainMenu.AutoCarry then
				Combo()
				end
				
				if AutoCarry.PluginMenu.UseItems then 
						UseItems(Target)
						end
						
					if AutoCarry.MainMenu.MixedMode then 
						Harass()
						end
					
						if AutoCarry.PluginMenu.AutoUlt then
							Ult()
							end
						
							if AutoCarry.PluginMenu.UltAllies then
								UltAllies()
end
		
		if AutoCarry.PluginMenu.EnemyPermLockOn or AutoCarry.PluginMenu.EnemyLockOn then
			if GetDistanceFromMouse(myHero) < 300 and GetDistance(Target) < 300 and GetDistance(Target) > (GetTrueRange() - 30) then
				if AutoCarrry.GetNextAttackTime() > tick then
					MoveHero(Target.x, Target.z)
				else
					myHero:Attack(Target)
				end
			end
		end
end
end

function inStandRange()
		return (GetDistanceFromMouse(myHero) < standRange)
end

function MoveHero(x,z)
		if IsSACReborn then
				AutoCarry.MyHero:MovementEnabled(false)
				myHero:MoveTo(x, z)
				AutoCarry.MyHero:MovementEnabled(true)
		else
				AutoCarry.CanMove = false
				myHero:MoveTo(x, z)
				AutoCarry.CanMove = true
		end
		end

function GetTarget()
		if IsSACReborn then
				return AutoCarry.Crosshair:GetTarget()
		else
				return AutoCarry.GetAttackTarget()
		end
end

function Combo()
		if Target then 
				if AutoCarry.PluginMenu.ComboQ and QReady and GetDistance(Target) <= QRange then
						CastQ(Target)
				end
				if AutoCarry.PluginMenu.ComboW and WReady and GetDistance(Target) <= WRange then 
						CastW(Target)
				end
				if AutoCarry.PluginMenu.ComboE and EReady and GetDistance(Target) <= ERange then 
						CastE(Target)
				end
			end
	end
	
function Harass()
			if Target then 
					
					if AutoCarry.PluginMenu.HarassW and WReady and GetDistance(Target) <= WRange and not IsMyManaLow() then
						CastW(Target)
				end
					if AutoCarry.PluginMenu.HarassE and EReady and GetDistance(Target) <= ERange and not IsMyManaLow() then
						CastE(Unit)
				end
					if AutoCarry.PluginMenu.HarassQ and QReady and GetDistance(Target) <= QRange and not IsMyManaLow() then
						CastQ(Target)
				end
			end
		end
	
function Ult()
		if  AutoCarry.PluginMenu.AutoUlt and AutoCarry.MainMenu.AutoCarry and IsMyHealthLow() and RReady then
			CastSpell(_R)
			else if AutoCarry.PluginMenu.UltAllies and AutoCarry.MainMenu.AutoCarry and RReady then
				for i=1, heroManager.iCount do
					local ally = heroManager:GetHero(i)
					if ally.team == myHero.team and ally.name ~= myHero.name and AutoCarry.PluginMenu.UltAllies["UltAllies"..i] and GetDistance(ally) <= 900 then
					if CheckHealth(ally) then
				if RReady then CastSpell(_R, ally) end
				end
			end
		end
	end
end
end
	
function CastQ(enemy) 
		if not enemy then enemy = Target end 
		
		if QReady and IsValid(enemy, QRange) then 
				CastSpell(_Q, enemy)
			end
end

function CastW(enemy) 
		if not enemy then enemy = Target end 
		
		if WReady and IsValid(enemy, WRange) then 
						CastSpell(_W, enemy) 
			end
end
			
			
function CastE(enemy)
		if not enemy then enemy = Target end
		
		if EReady and IsValid(enemy, ERange) then 
			CastSpell(_E, enemy)
					
			end
		end


function CastR(unit) 
	if RReady then
		if unit ~= nil and unit.team == myHero.team then
			CastSpell(_R, unit)
		end
	end
end
	
	
-- Item useage by Sida
function UseItems(enemy)
	if enemy == nil then return end
	for _,item in pairs(items) do
		item.slot = GetInventorySlotItem(item.id)
		if item.slot ~= nil then
			if item.reqTarget and GetDistance(enemy) < item.range then
				CastSpell(item.slot, enemy)
			elseif not item.reqTarget then
				if (GetDistance(enemy) - getHitBoxRadius(myHero) - getHitBoxRadius(enemy)) < 50 then
					CastSpell(item.slot)
				end
			end
		end
	end
end

function Ignite()
	IGNITEReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	if IGNITEReady then
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

function PluginOnDraw()
	if Target and not Target.dead and ExtraConfig.DrawTargetArrow and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
		DrawArrowsToPos(myHero, Target)
	end

	if IsTickReady(75) then DMGCalculation() end
	DrawKillable()
	DrawRanges()

	if ExtraConfig.DrawTargetInUltimateRange and RReady then
		local currentRRange = GetRRange()
		for _, enemy in pairs(GetEnemyHeroes()) do
			if enemy and not enemy.dead and currentRRange and GetDistance(enemy) < currentRRange then
				for j=0, 20 do
					DrawCircle(enemy.x, enemy.y, enemy.z, 30 + j*1.5, 0x0099CC) -- Blue
				end
			end
		end
	end
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

		if ExtraConfig.DrawQ and QReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == QRange) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x0099CC) -- Blue
		end
    		if ExtraConfig.DrawW and WReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == WRange) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0x0099CC) -- Blue
		end
    
		if ExtraConfig.DrawE and EReady and ((ExtraConfig.DrawFurthest and farSpell and farSpell == ERange) or not ExtraConfig.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x00FF00) -- Green
		end

		Target = GetTarget()
		if Target ~= nil then
			for j=0, 10 do
				DrawCircle(Target.x, Target.y, Target.z, 40 + j*1.5, 0x00FF00) -- Green
			end
		end
	end
end

function DMGCalculation()
	for i=1, heroManager.iCount do
        local Unit = heroManager:GetHero(i)
        if ValidTarget(Unit) then
        	local RUINEDKINGDamage, IGNITEDamage, BWCDamage = 0, 0, 0

        	local QDamage = getDmg("Q", Unit, myHero)
			local WDamage = getDmg("W", Unit, myHero)
			local EDamage = getDmg("E", Unit, myHero)
			local HITDamage = getDmg("AD", Unit, myHero)

			local IGNITEDamage = (IGNITESlot and getDmg("IGNITE", Unit, myHero) or 0)
			local BWCDamage = (BWCSlot and getDmg("BWC", Unit, myHero) or 0)
			local RUINEDKINGDamage = (RUINEDKINGSlot and getDmg("RUINEDKING", Unit, myHero) or 0)
			local combo1 = HITDamage
			local combo2 = HITDamage
			local combo3 = HITDamage
			local mana = 0

			if QReady then
				combo1 = combo1 + QDamage
				combo2 = combo2 + QDamage
				combo3 = combo3 + QDamage
				mana = mana + myHero:GetSpellData(_Q).mana
			end

			if WReady then
				combo1 = combo1 + WDamage
				combo2 = combo2 + WDamage
				combo3 = combo3 + WDamage
				mana = mana + myHero:GetSpellData(_W).mana
			end

			if EReady then
				combo1 = combo1 + EDamage
				combo2 = combo2 + EDamage
				combo3 = combo3 + EDamage
				mana = mana + myHero:GetSpellData(_E).mana
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

function IsMyManaLow()
	if myHero.mana < (myHero.maxMana * ( AutoCarry.PluginMenu.ManaManager / 100)) then
		return true
	else
		return false
	end
end

function IsMyHealthLow()
	if myHero.health < (myHero.maxHealth * ( AutoCarry.PluginMenu.UltHealth / 100)) then
		return true
	else
		return false
	end
end

function CheckHealth(unit)
	return unit.health <= unit.maxHealth * ( AutoCarry.PluginMenu.UltHealth / 100)
end


function FindFurthestReadySpell()
	local farSpell = nil

	if ExtraConfig.DrawQ and QReady then farSpell = QRange end
	if ExtraConfig.DrawE and EReady and (not farSpell or ERange > farSpell) then farSpell = ERange end
	if ExtraConfig.DrawW and WReady and (not farSpell or WRange > farSpell) then farSpell = WRange end

	return farSpell
end

function DrawArrowsToPos(pos1, pos2)
	if pos1 and pos2 then
		startVector = D3DXVECTOR3(pos1.x, pos1.y, pos1.z)
		endVector = D3DXVECTOR3(pos2.x, pos2.y, pos2.z)
		DrawArrows(startVector, endVector, 60, 0xE97FA5, 100)
	end
end

function IsValid(enemy, dist)
	if enemy and enemy.valid and not enemy.dead and enemy.bTargetable and ValidTarget(enemy, dist) then
		return true
	else
		return false
	end
end

function FindClosestEnemy()
	local closestEnemy = nil

	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if enemy and enemy.valid and not enemy.dead then
			if not closestEnemy or GetDistance(enemy) < GetDistance(closestEnemy) then
				closestEnemy = enemy
			end
		end
	end

	return closestEnemy
end

function FindLowestHealthEnemy(range)
	local lowHealthEnemy = nil

	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if enemy and enemy.valid and not enemy.dead then
			if not lowHealthEnemy or (GetDistance(enemy) <= range and enemy.health < lowHealthEnemy.health) then
				lowHealthEnemy = enemy
			end
		end
	end

	return closestEnemy
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

function IsTickReady(tickFrequency)
	-- Improves FPS
	-- Disabled for now.
	if 1 == 1 then return true end

	if tick ~= nil and math.fmod(tick, tickFrequency) == 0 then
		return true
	else
		return false
	end
end

function GetTrueRange()
	return myHero.range + GetDistance(myHero.minBBox) --just goofing off with some shit
end

function SpellChecks()
	DFGSlot, HXGSlot, BWCSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128),
	GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057),
	GetInventorySlotItem(3078), GetInventorySlotItem(3100)

	RUINEDKINGSlot, QUICKSILVERSlot, RANDUINSSlot, BWCSlot = GetInventorySlotItem(3153), GetInventorySlotItem(3140), GetInventorySlotItem(3143)

	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)

	RUINEDKINGReady = (RUINEDKINGSlot ~= nil and myHero:CanUseSpell(RUINEDKINGSlot) == READY)
	QUICKSILVERReady = (QUICKSILVERSlot ~= nil and myHero:CanUseSpell(QUICKSILVERSlot) == READY)
	RANDUINSReady = (RANDUINSSlot ~= nil and myHero:CanUseSpell(RANDUINSSlot) == READY)

	DFGReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGReady = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCReady = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)

	IGNITEReady = (IGNITESlot ~= nil and myHero:CanUseSpell(IGNITESlot) == READY)
	BARRIERReady = (BARRIERSlot ~= nil and myHero:CanUseSpell(BARRIERSlot) == READY)
	CLEANSEReady = (CLEANSESlot ~= nil and myHero:CanUseSpell(CLEANSESlot) == READY)
end