--[[

	EasyCait - Scripted by BomD.
	Version: 0.01
	
	Credits :  How I met Katarina for EasyCait script, Bilbao for maths and skill table, Honda7 for SOW and VPred
	Hope I didn't forget somebody.
]]--

-- Hero check
if GetMyHero().charName ~= "MissFortune" then 
return 
end

local version = 0.01
local AUTOUPDATE = false
local SCRIPT_NAME = "EasyMissfortune"

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


-- Spell data's
local Qrange, Qwidth, Qspeed, Qdelay = 650, 0, 1400, 0.5	
local Wrange, Wwidth, Wspeed, Wdelay = 0, 0, 1400, 0.5	
local Erange, Ewidth, Espeed, Edelay = 800, 500, 0, 0.5	
local Rrange, Rwidth, Rspeed, Rdelay = 1400, 100, 800, 0.2
		  
--[[ Callback 1 ]]--
function OnLoad()
   PrintChat("<font color=\"#eFF99CC\">You are using Hot-MissFortune ["..version.."] by BomD.</font>")
   PrintChat("<font color=\"#eFF99CC\">Enjoy the brazil range color style, world cup heeeere</font>")
   _LoadLib()
end

-- Looks like drawing with OnDraw fix FPS drop
function OnDraw()
   if MissfortuneMenu.Drawing.DrawAA and not MissfortuneMenu.Drawing.brazil then
      if MissfortuneMenu.Drawing.lowfpscircle then
	     -- Lag free circle here, brazil style
         DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 100, 1, TARGB({255, 255, 0, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 102, 1, TARGB({255, 255, 255, 255}), 100)
	  else
         -- Draw AA hero range
         DrawCircle(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 150, 0xFF80FF)
	  end
   end
   if MissfortuneMenu.Drawing.brazil then
	     DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 94, 3, TARGB({255, 102, 204, 0}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 97, 3, TARGB({255, 255, 255, 51}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 100, 3, TARGB({255, 0, 128, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 103, 3, TARGB({255, 255, 255, 51}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, SOWi:MyRange() + 106, 3, TARGB({255, 102, 204, 0}), 100)   
   end
   --draw Q range
    if MissfortuneMenu.Drawing.DrawQ and not MissfortuneMenu.Drawing.brazil then
      if MissfortuneMenu.Drawing.lowfpscircle then
	     -- Lag free circle here, brazil style
         DrawCircle3D(myHero.x, myHero.y, myHero.z, Qrange, 1, TARGB({255, 255, 0, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, Qrange, 1, TARGB({255, 255, 255, 255}), 100)
		end
	end

	--draw E range
    if MissfortuneMenu.Drawing.DrawE and not MissfortuneMenu.Drawing.brazil then
      if MissfortuneMenu.Drawing.lowfpscircle then
	     -- Lag free circle here, brazil style
         DrawCircle3D(myHero.x, myHero.y, myHero.z, Erange, 1, TARGB({255, 255, 0, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, Erange, 1, TARGB({255, 255, 255, 255}), 100)
		end
	end


   -- draw R range
   if MissfortuneMenu.Drawing.DrawR then
      if myHero.level >= 6 and myHero.level < 18 then
         --DrawCircleMinimap(myHero.x, myHero.y, myHero.z, 2000, 1, TARGB({255, 255, 0, 255}), 100)
         if MissfortuneMenu.Drawing.lowfpscircle then
	     -- Lag free circle here, brazil style
         DrawCircle3D(myHero.x, myHero.y, myHero.z, Rrange + 100, 1, TARGB({255, 255, 0, 255}), 100)
		 DrawCircle3D(myHero.x, myHero.y, myHero.z, Rrange + 102, 1, TARGB({255, 255, 255, 255}), 100)
	  	end
	  end
   end


end

function OnTick()
   -- if autolevel on then autolevel spell
   if MissfortuneMenu.Extra.AutoLev then
      _AutoLevel()
   end	
   -- if Space (32) pressed then combo
   if MissfortuneMenu.Combo.combokey then
      _Combo() 
   end   
   -- if key C pressed then harass
   if MissfortuneMenu.Harass.harasskey then
      _Harass() 
   end
 

end

-- When ennemy in range will get controlled (stun, slow, charm,...) then it will E if ON in Combo or harass or autoW ON
function OnGainBuff(unit, buff)
   if ((MissfortuneMenu.Combo.comboE and MissfortuneMenu.Combo.CCedE) or (MissfortuneMenu.Harass.harassE and MissfortuneMenu.Harass.CCedHE) or MissfortuneMenu.autoE) and myHero:CanUseSpell(_E) == READY and unit.visible and unit ~= nil and not unit.dead and ValidTarget(unit, Erange) then
      if buff.type == 5 or buff.type == 8 or buff.type == 10 or buff.type == 11 or buff.type == 21 or buff.type == 22 or buff.type == 29 then
	     CastSpells(_E, unit.x, unit.z)
	  end
   end
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
    MissfortuneMenu = scriptConfig("MF"..version, "EasyCait "..version)
	
    MissfortuneMenu:addSubMenu("Target selector", "STS")
    STS:AddToMenu(MissfortuneMenu.STS)
	
	MissfortuneMenu:addSubMenu("Drawing", "Drawing")
	MissfortuneMenu.Drawing:addParam("lowfpscircle", "Lag free draw", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Drawing:addParam("DrawAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Drawing:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Drawing:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Drawing:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Drawing:addParam("brazil", "WORLDCUPBRAZIL", SCRIPT_PARAM_ONOFF, true)
	
	
	MissfortuneMenu:addSubMenu("Orbwalker", "Orbwalker")
	SOWi:LoadToMenu(MissfortuneMenu.Orbwalker)
    SOWi:RegisterAfterAttackCallback(AfterAttack)
	
	MissfortuneMenu:addSubMenu("Combo", "Combo")
	MissfortuneMenu.Combo:addParam("combokey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	MissfortuneMenu.Combo:addParam("comboQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Combo:addParam("ManacheckCQ", "Mana manager Q", SCRIPT_PARAM_SLICE, 10, 1, 100)
	MissfortuneMenu.Combo:addParam("comboW", "Use W", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Combo:addParam("comboE", "Use E", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Combo:addParam("CCedCE", "Use E only on controlled", SCRIPT_PARAM_ONOFF, true)

	--MissfortuneMenu.Combo:addParam("CCedW", "Use W only on controlled", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Combo:addParam("ManacheckCW", "Mana manager W", SCRIPT_PARAM_SLICE, 10, 1, 100)
	MissfortuneMenu.Combo:addParam("ManacheckCE", "Mana manager E", SCRIPT_PARAM_SLICE, 10, 1, 100)
	MissfortuneMenu.Combo:addParam("gapcloseE", "Use E anti gapcloser", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Combo:addParam("gapcloseDist", "lower if u want it to antigaplose when the ennemy is farther", SCRIPT_PARAM_SLICE, 700, 50, 950)
	
	--MissfortuneMenu:addSubMenu("Ult snipe", "Ult")
	--MissfortuneMenu.Ult:addParam("ping", "Ping alert", SCRIPT_PARAM_ONOFF, true)
	

	MissfortuneMenu:addSubMenu("Harass", "Harass")
	MissfortuneMenu.Harass:addParam("harasskey", "Harass key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	MissfortuneMenu.Harass:addParam("harassQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Harass:addParam("Manacheck", "Mana manager", SCRIPT_PARAM_SLICE, 50, 1, 100)
	MissfortuneMenu.Harass:addParam("harassW", "Use W", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Harass:addParam("harassE", "Use E", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Harass:addParam("CCedHE", "Use E only on controlled", SCRIPT_PARAM_ONOFF, true)
	MissfortuneMenu.Harass:addParam("ManacheckHW", "Mana manager W", SCRIPT_PARAM_SLICE, 10, 1, 100)
	MissfortuneMenu.Harass:addParam("ManacheckHE", "Mana manager E", SCRIPT_PARAM_SLICE, 10, 1, 100)
	
	MissfortuneMenu:addSubMenu("Extra", "Extra")
	MissfortuneMenu.Extra:addParam("AutoLev", "Auto level skill", SCRIPT_PARAM_ONOFF, false)
	
	--MissfortuneMenu:addParam("autoW", "Auto W out of combo or harass on controlled", SCRIPT_PARAM_ONOFF, false)
end

-- -- This will cast spell packet or normal depending if ON/OFF in menu and if u are VIP or not
function CastSpells(spell, posx, posz)
  -- if MissfortuneMenu.Extra.pCast and VIP_USER then
  --    Packet('S_CAST', { spellId = spell, fromX = posx, fromY = posz}):send()
  -- else
     CastSpell(spell, posx, posz)
	-- MissfortuneMenu.Extra.pCast = false
  -- end	  
end


-- Thats the combo function, declaring in range target, checking if key pressed, if spell ready, getting prediction using VPred, casting spell
function _Combo()
    -- Cast Q
    local target = STS:GetTarget(Qrange)
    if MissfortuneMenu.Combo.comboQ and myHero:CanUseSpell(_Q) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MissfortuneMenu.Combo.ManacheckCQ then
	   --local CastPosition = VP:GetLineCastPosition(target, Qdelay, Qwidth, Qrange, Qspeed, myHero, true)
	   if GetDistance(target) <= Qrange and myHero:CanUseSpell(_Q) == READY then
	      CastSpell(_Q, target)
       end
    end	
	-- Cast W
	local target = STS:GetTarget(Wrange)
	if MissfortuneMenu.Combo.comboW and not MissfortuneMenu.Combo.CCedW and myHero:CanUseSpell(_W) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MissfortuneMenu.Combo.ManacheckCW then
	--   local CastPosition = VP:GetCircularCastPosition(target, Wdelay, Wwidth, Wrange, Wspeed, myHero, true)
	   if GetDistance(target) < Qrange - 150 and myHero:CanUseSpell(_W) == READY then
	      CastSpell(_W)
       end
    end	
	--Cast E gapcloser
	local target = STS:GetTarget(Erange)
	if MissfortuneMenu.Combo.gapcloseE and myHero:CanUseSpell(_E) == READY and target ~= nil then
	   local CastPosition = VP:GetCircularCastPosition(target, Edelay, Ewidth, Erange, Espeed, myHero, true)
	   if GetDistance(target) <= Erange+300 - MissfortuneMenu.Combo.gapcloseDist and myHero:CanUseSpell(_E) == READY then
	      CastSpell(_E, CastPosition.x, CastPosition.z)
       end
    end	
--Cast E
   -- cast E harass on controlled
   local target = STS:GetTarget(Erange)
   if MissfortuneMenu.Combo.comboE and not MissfortuneMenu.Combo.CCedCE and myHero:CanUseSpell(_E) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MissfortuneMenu.Combo.ManacheckCE then
	   local CastPosition = VP:GetCircularCastPosition(target, Edelay, Ewidth, Erange, Espeed, myHero, true)
	   if GetDistance(target) < Erange and myHero:CanUseSpell(_E) == READY then
	      CastSpells(_E)
       end
    end	   


end

-- That's the harass function hell yeahh
function _Harass()
    -- cast Q harass
    local target = STS:GetTarget(Qrange)
    if MissfortuneMenu.Harass.harassQ and myHero:CanUseSpell(_Q) == READY and target ~= nil and (myHero.mana / myHero.maxMana * 100) >= MissfortuneMenu.Harass.Manacheck then
	   local CastPosition = VP:GetLineCastPosition(target, Qdelay, Qwidth, Qrange, Qspeed, myHero, true)
	   if GetDistance(target) <= Qrange and myHero:CanUseSpell(_Q) == READY then
	       CastSpell(_Q, target)
       end
   end	
end

-- Auto level spell function
function _AutoLevel()
   Sequence = { 1,2,1,3,1,4,1,2,1,2,4,2,2,3,3,4,3,3 }
   autoLevelSetSequence(Sequence)
end


