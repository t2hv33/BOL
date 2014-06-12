--[[ Sida's Auto Carry Plugin - Riven, by Sida ]]--

--[[
	Combo: Ult (if enabled) > W > E. Will Q between attacks.
	Harass: W > E. Will Q between attacks.
	Killsteal: Killsteal with R.
	Ult Random: If ult is about to run out and hasn't been fired, it'll find the best target and fire at them.

	Always redownload auto carry when using a new plugin, chances are chances were made that the plugin requires.

	Save this script in BoL/Scripts/Common with the name "SidasAutoCarryPlugin - Riven.lua"
]]

local lastQ = 0
local qCount = 0
local rCast = 0
local target
local nextQ = 0

local	QREADY = (myHero:CanUseSpell(_Q) == READY)
local	WREADY = (myHero:CanUseSpell(_W) == READY)
local   EREADY = (myHero:CanUseSpell(_E) == READY)
local	RREADY = (myHero:CanUseSpell(_R) == READY)

--[[ Constants ]]--
local QRange = 260
local QRadius = 112.5
local WRange = 260
local ERange = 800
local RRange = 900
local AARange = 125
local BRKid, DFGid, EXECid, YOGHid, RANOid, BWCid, HXGid = 3153, 3128, 3123, 3142, 3143, 3144, 3146
local BRKSlot, DFGSlot, EXECSlot, YOGHSlot, RANOSlot, BWCSlot, HXGSlot = nil, nil, nil, nil, nil, nil, nil

--[[ Script Variables ]]--
local ts = TargetSelector(TARGET_LOW_HP,ERange+100)
local lastHasUlt
local pCount = 0
local lastPassive
local lastdirection = 0
local lastBasicAttack = 0
local swingDelay = 150
local swing = 0 
local lastSpellCast = 0
local qCast = 0

local EQcombo = 0

function PluginOnLoad()
    AutoCarry.PluginMenu:addParam("EQ", "EQ Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	--AutoCarry.PluginMenu:addParam("StunCheck", "Auto W in range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("StunCheck", "Auto W in range", SCRIPT_PARAM_ONOFF, false, 32)
    AutoCarry.PluginMenu:addParam("autoParry", "Auto Parry", SCRIPT_PARAM_ONOFF, true)	
	AutoCarry.PluginMenu:addParam("Killsteal", "KS with R", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("KS", "Full Combo with R", SCRIPT_PARAM_ONOFF, true)

	
	
	
	
	
--ignite--	
	PrintChat("<font color='#CCCCCC'> >> Auto Ignite 1.1 loaded! <<</font>")
	AIConfig = scriptConfig("Ignite Config", "AutoIgnite")
	AIConfig:addParam("useIgnite", "Ignite when killable", SCRIPT_PARAM_ONKEYTOGGLE, true, 73)
	AIConfig:addParam("doubleI", "Dont Double Ignite", SCRIPT_PARAM_ONOFF, true)
	AIConfig:permaShow("useIgnite")
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then iSlot = SUMMONER_1
		elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then iSlot = SUMMONER_2
			else iSlot = nil
	end
--ignite--		

	
end

function PluginOnTick()
--升級大招--
DodajUlti()

	TiamatSlot = GetInventorySlotItem(3077)
	RavenousHydraSlot = GetInventorySlotItem(3074)


--ignite--
	if AIConfig.useIgnite then
		local iDmg = 0		
		if iSlot ~= nil and myHero:CanUseSpell(iSlot) == READY then
			for i = 1, heroManager.iCount, 1 do
				local target = heroManager:getHero(i)
				if ValidTarget(target) then
					iDmg = 50 + 20 * myHero.level
					if target ~= nil and target.team ~= myHero.team and not target.dead and target.visible and GetDistance(target) < 600 and target.health < iDmg then
						if AIConfig.doubleI and not TargetHaveBuff("SummonerDot", target) then
							CastSpell(iSlot, target)
							elseif not AIConfig.doubleI then
								CastSpell(iSlot, target)
						end
					end
				end
			end
		end
	end 
--ignite--


                    if AutoCarry.PluginMenu.EQ then	
                    EQ()
					end
    
	
	if  AutoCarry.PluginMenu.StunCheck then StunCheck() end
		
					


   AutoCarry.SkillsCrosshair.range = 900
	--AutoCarry.SkillsCrosshair.range = myHero.range + GetDistance(myHero.minBBox) + (getQRadius()*2)
	target = AutoCarry.GetAttackTarget()
	if myHero:CanUseSpell(_Q) ~= READY and GetTickCount() > lastQ + 1000 then qCount = 0 end
	if myHero:CanUseSpell(_W) ~= READY and GetTickCount() > lastQ + 1000 then qCount = 0 end
	if myHero:CanUseSpell(_E) ~= READY and GetTickCount() > lastQ + 1000 then qCount = 0 end
	if AutoCarry.PluginMenu.Killsteal then TerminatorVisionScanningForKillableTargetsWithUltimate() end
	if AutoCarry.PluginMenu.KS and RREADY then KS() end
	
	--if AutoCarry.PluginMenu.Combo and AutoCarry.MainMenu.AutoCarry then Combo() end
end


function EQ()

local	QREADY = (myHero:CanUseSpell(_Q) == READY)
local	WREADY = (myHero:CanUseSpell(_W) == READY)
local   EREADY = (myHero:CanUseSpell(_E) == READY)
local	RREADY = (myHero:CanUseSpell(_R) == READY)


					if ValidTarget(target) and GetDistance(target) < 650 and GetDistance(target) > 600 and EREADY and QREADY then
					if  EREADY and QREADY then
                     --CastSpell(_E, target.x, target.z)
					 CastSpell(_E, mousePos.x, mousePos.z)
				 
					 DelayAction(function() CastSpell(_Q, mousePos.x, mousePos.z) end, 0.19)   ---0.2秒以後執行QQQ		
                       -- StunCheck()
					end
					end
end






function StunCheck()
	if not myHero.dead and myHero:CanUseSpell(_W) == READY then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if not enemy.dead and enemy.team ~= myHero.team and enemy ~= nil then
				if GetDistance(enemy) < 260 then
					CastSpell(_W)
				end 
			end
		end
	end
end




function PluginOnDraw()

	-- if myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_E) == READY then
	-- --DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0xFF0000)
	-- DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0xFF0000)
    -- else
	-- --DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x992D3D)
	-- DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x992D3D)
	-- end	
	
	-- if myHero:CanUseSpell(_W) == READY then
    -- DrawCircle(myHero.x, myHero.y, myHero.z, 260, 0x891788)
    -- else
	-- DrawCircle(myHero.x, myHero.y, myHero.z, 260, 0x992D3D)
	-- end	

	
	-- if myHero:CanUseSpell(_R) == READY then
    -- DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x891788)
    -- else
	-- DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x992D3D)
	-- end		
	
	


end








-- 噴R --



function TerminatorVisionScanningForKillableTargetsWithUltimate()
	if myHero:GetSpellData(_R).level ~= 0 and myHero:CanUseSpell(_R) == READY then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy ~= nil then
				local RDamage = getDmg("R",enemy,myHero)*1.3
					if TargetValid(enemy) then
					if RDamage > enemy.health and GetDistance(enemy) < RRange then
                            if not enemy.dead then
							CastSpell(_R, enemy.x, enemy.z)
							CastSpell(_R, enemy.x, enemy.z)
						end
					
					end
				end
			end
		end
	end
end
-- 噴R --


function KS()
local	QREADY = (myHero:CanUseSpell(_Q) == READY)
local	WREADY = (myHero:CanUseSpell(_W) == READY)
local   EREADY = (myHero:CanUseSpell(_E) == READY)
local	RREADY = (myHero:CanUseSpell(_R) == READY)


	if myHero:GetSpellData(_R).level ~= 0 and myHero:CanUseSpell(_R) == READY and myHero:CanUseSpell(_E) == READY  then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy ~= nil then
				local QDamage = getDmg("Q",enemy,myHero)
     			local WDamage = getDmg("W",enemy,myHero)
				local RDamage = getDmg("R",enemy,myHero)
				local F = QDamage*3+WDamage+RDamage
					if TargetValid(enemy) then

					
					if  QDamage > enemy.health and GetDistance(enemy) < QRange then
					CastSpell(_Q, target.x, target.z)	
					end
					
					if  WDamage > enemy.health and GetDistance(enemy) < WRange then
					CastSpell(_W)	
					end
					
					
					
					if F*2.2 > enemy.health and GetDistance(enemy) < 3000 then
					PrintFloatText(enemy,0,"Full Combo to Kill!")					
					end
					
					
					
					if F*0.923 > enemy.health and GetDistance(enemy) < 650 and QREADY and WREADY and EREADY and RREADY then                
                     CastSpell(_E, target.x, target.z)	
                     CastSpell(_R)
					 StunCheck()
					end
					
					if F*1.62 > enemy.health and GetDistance(enemy) < 450 and RREADY then                                   
                     CastSpell(_R)
					 StunCheck()
					end					

					if F*1.62 > enemy.health and GetDistance(enemy) < 500 and EREADY and RREADY then                                   
                     CastSpell(_E, target.x, target.z)	
					 CastSpell(_R)
					 StunCheck()
					end						
					
					
				end
			end
		end
	end
end



function TargetValid(target)
	if target ~= nil and target.dead == false and target.team == TEAM_ENEMY and target.visible == true then
		return true
	else
		return false
	end
end





function getQRadius()
	if TargetHaveBuff("RivenFengShuiEngine", myHero) then
		if qCount == 0 or qCount == 1 or qCount == 3 then 
			return 112.5
		elseif qCount == 2 then
			return 150
		end
	else
		if qCount == 0 or qCount == 1 or qCount == 3 then 
			return 162.5
		elseif qCount == 2 then
			return 200
		end
	end
end

function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "RivenTriCleave" then
		lastQ = GetTickCount()
	elseif unit.isMe and spell.name == "RivenFengShuiEngine" then
		rCast = GetTickCount()
	end
end

function OnAttacked()
	if target and GetTickCount() > nextQ then 
		if (AutoCarry.MainMenu.MixedMode) or (AutoCarry.MainMenu.AutoCarry) then
			
			--CastSpell(_W, target.x, target.z)
            --CastSpell(TiamatSlot)			
			--CastSpell(RavenousHydraSlot)
	        CastSpell(_W)
			CastSpell(_Q, target.x, target.z)
			
			--CastSpell(_E, target.x, target.z) 

			nextQ = AutoCarry.GetNextAttackTime()
		end
	end
end

 function OnAnimation(unit,animation)    
	if unit.isMe and animation:find("Spell1a") then 
		qCount = 1
	elseif unit.isMe and animation:find("Spell1b") then 
		qCount = 2
	elseif unit.isMe and animation:find("Spell1c") then 
		qCount = 3
	end
end


--升級大招--
function DodajUlti()


    if myHero.level == 6 or myHero.level == 11 or myHero.level == 16 then
      LevelSpell(_R)
    end

end




--[[	Parry	]]--
function PluginOnProcessSpell(unit, spell)
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)

	if unit.isMe then
		LastQ = os.clock()
	end
	
	if AutoCarry.PluginMenu.autoParry  then
		if unit and unit.type == myHero.type and spell.target == myHero then
			for i=1, #Abilities do
				if (spell.name == Abilities[i] or spell.name:find(Abilities[i]) ~= 
nil) then
					if getDmg("AD", myHero, unit) >= (myHero.maxHealth*0.06) or 
getDmg("AD", myHero, unit) >= (myHero.health*0.04) and GetDistance(Target)<250 then
						CastSpell(_W)
                    end
						
						
						
					if getDmg("AD", myHero, unit) >= (myHero.maxHealth*0.08) or 
getDmg("AD", myHero, unit) >= (myHero.health*0.06) and GetDistance(Target)<250 then
									
						
						CastSpell(_E, target.x, target.z) 
					end
				end
			end
		end
	end
end

Abilities = {
"GarenSlash2", "SiphoningStrikeAttack", "LeonaShieldOfDaybreakAttack", "RenektonExecute", 
"ShyvanaDoubleAttackHit", "DariusNoxianTacticsONHAttack", "TalonNoxianDiplomacyAttack", "Parley", "MissFortuneRicochetShot", "RicochetAttack", "jaxrelentlessattack", "Attack"
}

--[[	Parry	]]--



--UPDATEURL=
--HASH=C9E2A6E16213723FB8377BE8E22CE794
