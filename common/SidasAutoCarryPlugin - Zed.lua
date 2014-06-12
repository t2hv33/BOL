if myHero.charName ~= "Zed" then return end
--[[ Sida's Zed v1.1 ]] --

local wClone = nil
local rClone = nil
local ts
local RREADY, WREADY, EREADY, QREADY
local delay, qspeed = 245, 1.81
local prediction
local lastW = 0

--DFG--
local BRKSlot, DFGSlot, HXGSlot, BWCSlot, TMTSlot, RAHSlot, RNDSlot, YGBSlot = nil, nil, nil, nil, nil, nil, nil, nil
local QREADY, WREADY, EREADY, RREADY, IREADY, BRKREADY = false, false, false, false, false, false
--DFG--


function PluginOnLoad()

--[[Perfect Poke]]--
	attackTracker = {
		attacker = nil,
		target = nil
	}
	
	
	AttackTrackerMenu = scriptConfig("  ", "AT")
		AttackTrackerMenu:addSubMenu("  ", "enableMarkers")
			AttackTrackerMenu.enableMarkers:addSubMenu("ON all of the flolloing", "allyTeam")
				for i, ally in pairs(GetAllyHeroes()) do
					AttackTrackerMenu.enableMarkers.allyTeam:addParam(ally.charName, "Enable for ".. ally.charName ..": ", SCRIPT_PARAM_ONOFF, true)
				end
			AttackTrackerMenu.enableMarkers:addSubMenu("ON all of the flolloing", "enemyTeam")
				local nopeTeam = false
				for i, enemy in pairs(GetEnemyHeroes()) do
					nopeTeam = true
					AttackTrackerMenu.enableMarkers.enemyTeam:addParam(enemy.charName, "Enable for ".. enemy.charName ..": ", SCRIPT_PARAM_ONOFF, true)
				end

				if not nopeTeam then
					AttackTrackerMenu.enableMarkers.enemyTeam:addParam("noEnemy", "No enemy found", SCRIPT_PARAM_INFO, "")
				end

	
	
--[[Perfect Poke]]--
    
 	ZedConfig = scriptConfig("Sida's Zed", "sidaszed")
	ZedConfig:addParam("pp", "Perfect Poke", SCRIPT_PARAM_ONOFF, true)
	
    ZedConfig:addParam("autoks", "Auto KS", SCRIPT_PARAM_ONOFF, true)
    ZedConfig:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	ZedConfig:addParam("AutoE", "Auto E", SCRIPT_PARAM_ONOFF, true)

	ZedConfig:addParam("Range", "Draw Range Circles", SCRIPT_PARAM_ONOFF, false)
	ZedConfig:addParam("TargetCircle", "Draw Target Circle", SCRIPT_PARAM_ONOFF, true)
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY, 2200, DAMAGE_PHYSICAL, true)
	ts.name = "Zed"
	ZedConfig:addTS(ts)
end

function PluginOnTick()
  
  DodajUlti()

  

	BRKSlot = GetInventorySlotItem(3153)
	BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)


	ts:update()
	SetCooldowns()
	if ValidTarget(ts.target) then
		if ZedConfig.AutoE then autoE() end
		prediction = qPred()
		
		if ZedConfig.Harass then Harass() end
	end
	
	if ZedConfig.autoks then
   KS()
   end

	
		
	end


function PluginOnDraw()

  	if ZedConfig.Range then
		DrawCircle(myHero.x, myHero.y, myHero.z, 290, 0xFF00FF00)

	end


	if myHero:CanUseSpell(_R) == READY then
	DrawCircle(myHero.x, myHero.y, myHero.z, 630, 0x007AFA)
	else
	DrawCircle(myHero.x, myHero.y, myHero.z, 630, 0x992D3D)
	end			

	if myHero:CanUseSpell(_Q) == READY then
	DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0xFA0300)
	end	
	if myHero:CanUseSpell(_Q) ~= READY then
	DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x992D3D)
	end		
	if ts.target ~= nil and ZedConfig.TargetCircle then
		DrawCircle(ts.target.x, ts.target.y, ts.target.z, 150, 0xFF00FF00)
		DrawCircle(ts.target.x, ts.target.y, ts.target.z, 151, 0xFF00FF00)
		DrawCircle(ts.target.x, ts.target.y, ts.target.z, 152, 0xFF00FF00)
		DrawCircle(ts.target.x, ts.target.y, ts.target.z, 153, 0xFF00FF00)
		--GetEnergyDraw()
	end
end






function PluginOnProcessSpell(unit, spell)

	if unit.isMe and spell.name == "ZedShadowDash" then
		lastW = GetTickCount()
	end
	
	--[[Perfect Poke]]--
	for i=1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)
		if enemy.team ~= myHero.team and enemy ~= nil then	
          if GetDistance(enemy) <= 1200 and not enemy.dead  then
 
		        if unit.type == myHero.type and unit ~= nil then
		        if (unit.team == myHero.team and not AttackTrackerMenu.enableMarkers.allyTeam[unit.charName]) and not AttackTrackerMenu.enableMarkers.enemyTeam[unit.charName] then return end
		    	if spell.name:lower():find("attack") then
		        	attackTracker.attacker = unit
		        	attackTracker.target = spell.target
		        end
		        end
	  
	            if myHero.mana  > 115 then 
		        if attackTracker.attacker ~= nil and attackTracker.target ~= nil then
		        if GetDistanceSqr(attackTracker.attacker, attackTracker.target) > (attackTracker.attacker.range + attackTracker.attacker:GetDistance(attackTracker.attacker.minBBox)) * (attackTracker.attacker.range + attackTracker.attacker:GetDistance(attackTracker.attacker.minBBox)) then return end
		
		        if not attackTracker.target.dead and ZedConfig.pp then
                 Harass() 			
		        end
	            end
		        end
          end
        end
	end
		--[[Perfect Poke]]--	
end

function KS()
local	QREADY = (myHero:CanUseSpell(_Q) == READY)
local	WREADY = (myHero:CanUseSpell(_W) == READY)
local   EREADY = (myHero:CanUseSpell(_E) == READY)
local	RREADY = (myHero:CanUseSpell(_R) == READY)


	if myHero:GetSpellData(_R).level ~= 0 and myHero:CanUseSpell(_R) == READY  then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy ~= nil then
				local QDamage = getDmg("Q",enemy,myHero)
     			local EDamage = getDmg("E",enemy,myHero)
				local RDamage = getDmg("R",enemy,myHero)
				
					

					
				if ZedConfig.autoks then
				if myHero.level <= 6 then
				 FinalDMG = (((QDamage+EDamage)*1.2)+RDamage)
				end
				if myHero.level <= 11 then
				 FinalDMG = (((QDamage+EDamage)*1.35)+RDamage)
				end
				if myHero.level >= 16 then
				 FinalDMG = (((QDamage+EDamage)*1.5)+RDamage)
				end			
         		end	
					
					
					--KS提示
					if FinalDMG > enemy.health and GetDistance(enemy) < 3000 then
					PrintFloatText(enemy,0,"Full Combo to Kill!")					
					end
				
				   
				if WREADY and RREADY and FinalDMG*0.8 > enemy.health  and GetDistance(enemy) <= 630 and myHero:GetSpellData(_R).name == "zedult"then
				  CastSpell(_R, enemy) 
				  Harass() 
				end
					
					
				end
			end
		end
	
end



function Harass() 
   
	
 if myHero.level == 1 then
 
 
    if prediction ~= nil and (GetDistance(prediction) < 700 and GetDistance(prediction) > 500) or (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 and GetDistance(prediction) > 500) then
	
		if myHero:GetSpellData(_W).name ~= "zedw2" and GetTickCount() > lastW + 1000  then 
			--CastSpell(_W, ts.target.x, ts.target.z) 
			--CastSpell(BRKSlot, ts.target)
			CastSpell(_Q, prediction.x, prediction.z)
		else
			CastSpell(_Q, prediction.x, prediction.z)
		end
	elseif  prediction and GetDistance(prediction) < 900 then
		CastSpell(_Q, prediction.x, prediction.z)
	end
	
    if prediction ~= nil  and (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 ) then
			CastSpell(_Q, prediction.x, prediction.z)
    end	
   
 
 end
 
 
 
 
 
 
 
 
  if myHero.level == 2 then
 
 
    if prediction ~= nil and (GetDistance(prediction) < 700 and GetDistance(prediction) > 500) or (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 and GetDistance(prediction) > 500) then
	
		if myHero:GetSpellData(_W).name ~= "zedw2" and GetTickCount() > lastW + 1000  then 
			--CastSpell(_W, ts.target.x, ts.target.z) 
			--CastSpell(BRKSlot, ts.target)
			CastSpell(_Q, prediction.x, prediction.z)
		else
			CastSpell(_Q, prediction.x, prediction.z)
		end
	elseif  prediction and GetDistance(prediction) < 900 then
		CastSpell(_Q, prediction.x, prediction.z)
	end
	
    if prediction ~= nil  and (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 ) then
			CastSpell(_Q, prediction.x, prediction.z)
    end	
   
 
 end
 
 
 
 
 -----------------------------------------------


 if myHero.level > 2 then
    if myHero:CanUseSpell(_W) == READY and HasEnergy() then 
    if prediction ~= nil and (GetDistance(prediction) < 700 and GetDistance(prediction) > 500) or (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 and GetDistance(prediction) > 500) then
	
		if myHero:GetSpellData(_W).name ~= "zedw2" and GetTickCount() > lastW + 1000 and HasEnergy() then 
			--CastSpell(_W, ts.target.x, ts.target.z) 
			--CastSpell(BRKSlot, ts.target)
			CastSpell(_Q, prediction.x, prediction.z)
		else
			CastSpell(_Q, prediction.x, prediction.z)
		end
	elseif  prediction and GetDistance(prediction) < 900 then
		CastSpell(_Q, prediction.x, prediction.z)
	end
	
    if prediction ~= nil  and (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 ) then
			CastSpell(_Q, prediction.x, prediction.z)
    end	
    end	
	end
	
	-------------------------------------------------
	
	if myHero.level > 2 then
    if myHero:CanUseSpell(_W) == COOLDOWN then 
    if prediction ~= nil and (GetDistance(prediction) < 700 and GetDistance(prediction) > 500) or (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 and GetDistance(prediction) > 500) then
	
		if myHero:GetSpellData(_W).name ~= "zedw2" and GetTickCount() > lastW + 1000  then 
			--CastSpell(_W, ts.target.x, ts.target.z) 
			--CastSpell(BRKSlot, ts.target)
			CastSpell(_Q, prediction.x, prediction.z)
		else
			CastSpell(_Q, prediction.x, prediction.z)
		end
	elseif  prediction and GetDistance(prediction) < 900 then
		CastSpell(_Q, prediction.x, prediction.z)
	end
	
    if prediction ~= nil  and (QREADY and wClone ~= nil and wClone.valid and GetDistance(prediction, wClone) < 900 ) then
			CastSpell(_Q, prediction.x, prediction.z)
    end	
    end	
	end
	
	
	
		
end

function autoE() 
local wMana = {40, 35, 30, 25, 20}
local wEnergy = wMana[myHero:GetSpellData(_W).level]

 if myHero.level > 2 then
	local box = 280
	if myHero.mana  > wEnergy+50 and myHero:CanUseSpell(_W) == READY then 
	if GetDistance(ts.target) < box or (wClone ~= nil and wClone.valid and GetDistance(ts.target, wClone) < box) or (rClone ~= nil and rClone.valid and GetDistance(ts.target, rClone) < box) then
		CastSpell(_E)
	else
		for i = 1, heroManager.iCount do
			local enemy = heroManager:getHero(i)
			if ValidTarget(enemy) and GetDistance(enemy) < box or (wClone ~= nil and wClone.valid and GetDistance(enemy, wClone) < box) or (rClone ~= nil and rClone.valid and GetDistance(enemy, rClone) < box) then
				CastSpell(_E)
			end
		end
	end
	end
	
	if myHero:CanUseSpell(_W) == COOLDOWN then 
	if GetDistance(ts.target) < box or (wClone ~= nil and wClone.valid and GetDistance(ts.target, wClone) < box) or (rClone ~= nil and rClone.valid and GetDistance(ts.target, rClone) < box) then
		CastSpell(_E)
	else
		for i = 1, heroManager.iCount do
			local enemy = heroManager:getHero(i)
			if ValidTarget(enemy) and GetDistance(enemy) < box or (wClone ~= nil and wClone.valid and GetDistance(enemy, wClone) < box) or (rClone ~= nil and rClone.valid and GetDistance(enemy, rClone) < box) then
				CastSpell(_E)
			end
		end
	end
	end	
	
	end
end



function PluginOnCreateObj(obj)
	if obj.valid and obj.name:find("Zed_Clone_idle.troy") then
		if wClone == nil then
			wClone = obj
		elseif rClone == nil then
			rClone = obj
		end
	end
end

function PluginOnDeleteObj(obj)
	if obj.valid and wClone and obj == wClone then
		wClone = nil
	elseif obj.valid and rClone and obj == rClone then
		rClone = nil
	end
end


function SetCooldowns()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
end

function HasEnergy()
	local qMana = {75, 70, 65, 60, 55}
	local wMana = {40, 35, 30, 25, 20}
	local eMana = 50
	
	local qEnergy = qMana[myHero:GetSpellData(_Q).level]
	local wEnergy = wMana[myHero:GetSpellData(_W).level]
	
	local myEnergy = myHero.mana
	
	if myEnergy < qEnergy + wEnergy then
		return false
	else
		return true
	end
end

function GetEnergyDraw()
	local qMana = {75, 70, 65, 60, 55}
	local wMana = {40, 35, 30, 25, 20}
	
	local qEnergy = (myHero:GetSpellData(_W).level > 0 and qMana[myHero:GetSpellData(_Q).level] or 0)
	local wEnergy = (myHero:GetSpellData(_W).level > 0 and wMana[myHero:GetSpellData(_W).level] or 0)
	local eEnergy = 50
	
	if myHero.mana < qEnergy + wEnergy + eEnergy then
		PrintFloatText(ts.target, 0, "Not Enough Energy!")
	else
		PrintFloatText(ts.target, 0, "Enough Energy!")
	end
end

function qPred()
	local travelDuration = (delay + GetDistance(myHero, ts.target)/qspeed)
	travelDuration = (delay + GetDistance(GetPredictionPos(ts.target, travelDuration))/qspeed)
	travelDuration = (delay + GetDistance(GetPredictionPos(ts.target, travelDuration))/qspeed)
	travelDuration = (delay + GetDistance(GetPredictionPos(ts.target, travelDuration))/qspeed) 	
	if ts.target ~= nil then
		return GetPredictionPos(ts.target, travelDuration)
	end
end

function UseItems()
	if GetInventorySlotItem(3153) ~= nil and GetDistance(ts.target) > 300 then 
		CastSpell(GetInventorySlotItem(3153), ts.target) 
	end 	
	if GetInventorySlotItem(3144) ~= nil and GetDistance(ts.target) > 300 then 
		CastSpell(GetInventorySlotItem(3144), ts.target) 
	end 
end


function DodajUlti()


    if myHero.level == 6 or myHero.level == 11 or myHero.level == 16 then
      LevelSpell(_R)
	end
  

end