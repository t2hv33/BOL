--[[

	EasyCait - Scripted by BomD.
	Version: 0.01
	
	Credits :  How I met Katarina for EasyCait script, Bilbao for maths and skill table, Honda7 for SOW and VPred
	Hope I didn't forget somebody.
]]--

-- Hero check
if GetMyHero().charName ~= "Urgot" then 
return 
end

local version = 0.01
local AUTOUPDATE = false
local SCRIPT_NAME = "BS_Urgot"

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DOWNLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
	SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/S4CHQQ/Scripting/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/S4CHQQ/version/master/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
	RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
	RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
	RequireI:Check()

if RequireI.downloadNeeded == true then return end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
poisonedtimets = 0
poisonedtime = {}
poisontime = 0
towers = {}

local IsSACReborn = false
-- Spell data's
local qrange2 = 1200
local Qrange, Qwidth, Qspeed, Qdelay = 1000, 80, 1600, 0.15
local Wrange, Wwidth, Wspeed, Wdelay = 700, 0, 1500, 0.75	
local Erange, Ewidth, Espeed, Edelay = 900 , 150, 1750, 0.25
local Rrange, Rwidth, Rspeed, Rdelay = 550, 70, 1800, 0.65 --550,700,850

	

		  
--[[ Callback 1 ]]--
function OnLoad()
   PrintChat("<font color=\"#eFF99CC\">You are using BS_Urgot ["..version.."] by BomD.</font>")
   QREADY, WREADY, EREADY, RREADY = false, false, false, false
	MuraSlot = GetInventorySlotItem(3042)
   	for i=1, heroManager.iCount do
		poisonedtime[i] = 0
	end

   _LoadLib()
   towersUpdate()
end

-- Looks like drawing with OnDraw fix FPS drop
function OnDraw()
   if UrgotMenu.Drawing.DrawAA then
      if UrgotMenu.Drawing.lowfpscircle then
	     -- Lag free circle here
         DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange(), 1, TARGB({255, 255, 0, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange(), 1, TARGB({255, 255, 255, 255}), 100)
	  else
         -- Draw AA hero range
         DrawCircle(myHero.x, myHero.y, myHero.z, SOWi:MyRange(), 0xFF80FF)
	  end
   end

   --draw Q range
    if UrgotMenu.Drawing.DrawQ then
      if UrgotMenu.Drawing.lowfpscircle then
	     -- Lag free circle here, brazil style
         DrawCircle3D(myHero.x, myHero.y, myHero.z, Qrange, 1, TARGB({255, 255, 0, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, Qrange, 1, TARGB({255, 255, 255, 255}), 100)
		   else
         -- Draw Q hero range
         DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0xFF80FF)
	  end
	end


	--draw E range
    if UrgotMenu.Drawing.DrawE then
      if UrgotMenu.Drawing.lowfpscircle then
	     -- Lag free circle here
         DrawCircle3D(myHero.x, myHero.y, myHero.z, Erange, 1, TARGB({255, 255, 0, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, Erange, 1, TARGB({255, 255, 255, 255}), 100)
		  else
         -- Draw E hero range
         DrawCircle(myHero.x, myHero.y, myHero.z, Erange, 0xFF80FF)
	  
		end
	end
	--draw R range
    if UrgotMenu.Drawing.DrawR  and myHero.level >=6  then
      if UrgotMenu.Drawing.lowfpscircle then
	     -- Lag free circle here
			DrawCircle3D(myHero.x, myHero.y, myHero.z, Rrange, 1, TARGB({255, 255, 0, 255}), 100)		
		else 
         -- Draw R hero range
         DrawCircle(myHero.x, myHero.y, myHero.z, Rrange, 0xFF80FF)			
	  end
	end


end --end draw

function OnTick()
	Checks()
   -- if autolevel on then autolevel spell
   if UrgotMenu.Extra.AutoLev then
      _AutoLevel()
   end	
   -- if Space (32) pressed then combo
   if UrgotMenu.Combo.combokey then
      _Combo() 

   end   
   -- if key C pressed then harass
   if UrgotMenu.Harass.harasskey then
      _Harass() 
   end
   
   	if UrgotMenu.Extra.rTower then 
	towerTeleport() 
	end

	if UrgotMenu.Extra.ToggleMuramana then
		MuramanaToggle()
	end
	--FARM
	-- if QREADY and UrgotMenu.Farm and UrgotMenu.Orbwalker.LaneClear then
		-- if Minion and not Minion.type == "obj_Turret" and not Minion.dead and GetDistance(Minion) <= Qrange and Minion.health < getDmg("Q", Minion, myHero) then 
			-- CastSpell(_Q, Minion.x, Minion.z)
		-- else 
			-- for _, minion in pairs(EnemyMinions.objects) do
				-- if minion and not minion.dead and GetDistance(minion) <= qRange and minion.health < getDmg("Q", minion, myHero) then 
					-- CastSpell(_Q, minion.x, minion.z)
				-- end
			-- end
		-- end
	-- end
	--AUTO Q
	-- if Target and QREADY and UrgotMenu.Combo.comboQ then 
		-- if GetDistance(Target) < qRange2 and 0 <= (GetTickCount() - poisonedtimets) < 5000  then
			-- CastSpell(_Q, Target.x, Target.z)
		-- end
	-- end

end

--[[ Personal Function ]]--

-- Load lib
function _LoadLib()
    VP = VPrediction(true)
    STS = SimpleTS(STS_LESS_CAST_PHYSICAL)
    SOWi = SOW(VP, STS)
	
	_LoadMenu()
end
-- Load my menu adding SOW Orbwalking..
function _LoadMenu()
  
    UrgotMenu = scriptConfig("BS_Urgot", "Urgot - BomD"..version)
	
    UrgotMenu:addSubMenu("Target selector", "STS")
    STS:AddToMenu(UrgotMenu.STS)
	
	UrgotMenu:addSubMenu("Drawing", "Drawing")
	UrgotMenu.Drawing:addParam("lowfpscircle", "Lag free draw", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Drawing:addParam("DrawAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Drawing:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Drawing:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, false)
	UrgotMenu.Drawing:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, false)	
	
	UrgotMenu:addSubMenu("Orbwalker", "Orbwalker")
	SOWi:LoadToMenu(UrgotMenu.Orbwalker)
    SOWi:RegisterAfterAttackCallback(AfterAttack)
	
	UrgotMenu:addSubMenu("Combo", "Combo")
	UrgotMenu.Combo:addParam("combokey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	UrgotMenu.Combo:addParam("comboQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Combo:addParam("poisonOnly", "Dùng Q only khi dinh' E", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Combo:addParam("ManacheckCQ", "Mana manager Q", SCRIPT_PARAM_SLICE, 10, 1, 100)
	UrgotMenu.Combo:addParam("comboW", "Use W", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Combo:addParam("comboE", "Use E", SCRIPT_PARAM_ONOFF, true)

	UrgotMenu.Combo:addParam("ManacheckCW", "Mana manager W", SCRIPT_PARAM_SLICE, 10, 1, 100)
	UrgotMenu.Combo:addParam("ManacheckCE", "Mana manager E", SCRIPT_PARAM_SLICE, 10, 1, 100)
	UrgotMenu.Combo:addParam("gapcloseE", "Use E anti gapcloser", SCRIPT_PARAM_ONOFF, true)

	UrgotMenu:addSubMenu("Farm", "Farm")
	UrgotMenu.Farm:addParam("qfarm", "Farm Q", SCRIPT_PARAM_ONOFF, true)

	
	UrgotMenu:addSubMenu("Harass", "Harass")
	UrgotMenu.Harass:addParam("harasskey", "Harass key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	UrgotMenu.Harass:addParam("harassQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Harass:addParam("Manacheck", "Mana manager", SCRIPT_PARAM_SLICE, 50, 1, 100)
	UrgotMenu.Harass:addParam("harassW", "Use W", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Harass:addParam("harassE", "Use E", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Harass:addParam("CCedHE", "Use E only on controlled", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Harass:addParam("ManacheckHW", "Mana manager W", SCRIPT_PARAM_SLICE, 10, 1, 100)
	UrgotMenu.Harass:addParam("ManacheckHE", "Mana manager E", SCRIPT_PARAM_SLICE, 10, 1, 100)
	
	UrgotMenu:addSubMenu("Extra", "Extra")
	UrgotMenu.Extra:addParam("AutoLev", "Auto level skill", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Extra:addParam("rTower", "Auto Telepot enemy to turret", SCRIPT_PARAM_ONOFF, true)
	UrgotMenu.Extra:addParam("ToggleMuramana", "Muramana - Toggle", SCRIPT_PARAM_ONOFF, true)

end


-- Thats the combo function, declaring in range target, checking if key pressed, if spell ready, getting prediction using VPred, casting spell
function _Combo()
    -- Cast Q, need more logic
    local target = STS:GetTarget(Qrange)
    if UrgotMenu.Combo.comboQ and myHero:CanUseSpell(_Q) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= UrgotMenu.Combo.ManacheckCQ then
	   local CastPosition = VP:GetLineCastPosition(target, Qdelay, Qwidth, Qrange, Qspeed, myHero, true)
	   if GetDistance(target) <= Qrange and myHero:CanUseSpell(_Q) == READY then
	      CastSpell(_Q, CastPosition.x, CastPosition.z)
       end
    end	
	-- Cast W to make target slow
	local target = STS:GetTarget(Wrange)
	if UrgotMenu.Combo.comboW and not UrgotMenu.Combo.CCedW and myHero:CanUseSpell(_W) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= UrgotMenu.Combo.ManacheckCW then
	   if GetDistance(target) < Qrange - 150 and myHero:CanUseSpell(_W) == READY then
	      CastSpell(_W)
       end
    end	

    -- Cast E before combo
	local target = STS:GetTarget(Erange)
	 if UrgotMenu.Combo.comboE and myHero:CanUseSpell(_E) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= UrgotMenu.Combo.ManacheckCQ then
	   local CastPosition = VP:GetCircularCastPosition(target, Edelay, Ewidth, Erange, Espeed, myHero, true)
	   if GetDistance(target) <= Erange and myHero:CanUseSpell(_E) == READY then
	      CastSpell(_E, CastPosition.x, CastPosition.z)
       end
    end	

--HasBuff(enemy, "UndyingRage")

end
function OnCreateObj(obj)
        if obj ~= nil and string.find(obj.name, "UrgotCorrosiveDebuff_buf") then
		PrintChat("<font color='#EDED00'>Poisoned</font>")
                for i=1, heroManager.iCount do
                        local enemy = heroManager:GetHero(i)
                        if enemy.team ~= myHero.team and GetDistance(obj,enemy) < 80 then
                                poisonedtime[i] = GetTickCount()
								
                        end
                end
        end
end
--> Acid Hunter Cast
function CastQ(target)
        if GetDistance(target) <= qRange2 and GetTickCount()-poisonedtimets < 5000 then
                CastSpell(_Q, target.x, target.z)
        elseif not UrgotMenu.Combo.poisonOnly and GetDistance(target) < Qrange then
                if IsSACReborn then
                        SkillQ:ForceCast(target)
                else
                        -- if not 
						-- --Col(SkillQ, myHero, target)
						-- then
						CastSpell(Q, target) 
						--end
                end
        end
end

function towerTeleport()
        for i, enemy in ipairs(GetEnemyHeroes()) do
                if enemy and GetDistance(enemy) <= Rrange and inTurretRange(myHero) then
                        if CountEnemies(enemy, 600) <= 3 then 
						CastSpell(_R, enemy)
						PrintChat("<font color='#EDED00'>Telepot vào tru.</font>")
						end
                end
        end
end

function MuramanaToggle()
	if target and target.type == myHero.type and GetDistance(target) <= qRange2 and not MuramanaIsActive() and (UrgotMenu.Combo.combokey or UrgotMenu.Combo.harasskey) then
		MuramanaOn()
	elseif not Target and MuramanaIsActive() then
		MuramanaOff()
	end
end
function CountEnemies(point, range)
	local ChampCount = 0
	for j = 1, heroManager.iCount, 1 do
		local enemyhero = heroManager:getHero(j)
		if myHero.team ~= enemyhero.team and not enemyhero.dead then
			if GetDistance(enemyhero, point) <= range then
				ChampCount = ChampCount + 1
			end
		end
	end
	return ChampCount
end

--> Tower Checks
function towersUpdate()
	for i = 1, objManager.iCount, 1 do
		local obj = objManager:getObject(i)
		if obj and obj.type == "obj_Turret" and obj.health > 0 then
			if not string.find(obj.name, "TurretShrine") and obj.team == player.team then
				table.insert(towers, obj)
			end
		end
	end
end

function inTurretRange(unit)
	local check = false
	for i, tower in ipairs(towers) do
		if tower.health > 0 then
			if math.sqrt((tower.x - unit.x) ^ 2 + (tower.z - unit.z) ^ 2) < 750 then
				check = true
			end
		else
			table.remove(towers, i)
		end
	end
	return check
end

function Checks()
	 Target = STS:GetTarget(Qrange)
	 Minion = minionManager(MINION_ENEMY, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)

--
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	MREADY = (MuraSlot and myHero:CanUseSpell(MuraSlot) == READY)
--
	if Target then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy.charName == Target.charName then
				poisonedtimets = poisonedtime[i]
			end
		end
	end
--
	Rrange = 400 + (player:GetSpellData(_R).level*150)
end


-- That's the harass function hell yeahh
function _Harass()
    -- cast Q harass
    local target = STS:GetTarget(Qrange)
    if UrgotMenu.Harass.harassQ and myHero:CanUseSpell(_Q) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= UrgotMenu.Harass.Manacheck then
	   local CastPosition = VP:GetLineCastPosition(target, Qdelay, Qwidth, Qrange, Qspeed, myHero, true)
	   if GetDistance(target) <= Qrange and myHero:CanUseSpell(_Q) == READY then
	       CastSpell(_Q, target)
       end
   end	
end

-- Auto level spell function Urgot
--http://www.mobafire.com/league-of-legends/build/urgot-the-lane-bully-season-4-159925
function _AutoLevel()
   Sequence = { 3,1,1,2,1,4,1,2,1,3,4,2,3,2,3,4,2,3 }
   autoLevelSetSequence(Sequence)
end


