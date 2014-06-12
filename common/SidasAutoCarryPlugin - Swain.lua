--[[ Sida's Auto Carry Plugin: Swain ]]--
--[[ Version 1.5 ]]--

--Local variables
    local range = 650 
    local wcastspeed = 950
    local ultactive = false
    local delayult = 500
    local timeulti = 0
    local distancetstarget = 0
    local Zslot = nil
    local player = GetMyHero()
    local HealthCurrent = 0
    local HealthBefore = 0
    local NextCheck = GetTickCount()
    local HealthProc = 0
    
function PluginOnLoad()
  AutoCarry.SkillsCrosshair.range = 1000
  SkillW = {spellKey = _W, range = 625+240, speed = 20, delay = wcastspeed}
  -- Ingame menu
  AutoCarry.PluginMenu:addParam("scriptActive", "Use Combo in Carry mode", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("harass", "Harass in Mixed mode", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawcircle", "Draw Circle", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("useult", "Use Ult", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("torment", "Auto Harras with Torment", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("X"))
  AutoCarry.PluginMenu:addParam("autoEQ", "Auto use EQ combo on snared enemy", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("V"))
end


 function PluginOnTick()
  checks()
  target = AutoCarry.GetAttackTarget(true)
  
  if AutoCarry.MainMenu.MixedMode and target ~= nil then
    harass()
  end
  
  if AutoCarry.MainMenu.AutoCarry and target ~= nil then
    docombo()
  end
  
  if AutoCarry.PluginMenu.torment and target ~= nil then
    autotorment()
  end
  
  if AutoCarry.PluginMenu.autoEQ and target ~= nil then
    autoEQ()
  end
end




  function autoEQ()
   if not target.canMove and GetDistance(target)<=625 then
    if EREADY then CastSpell(_E, target) end
    if QREADY then CastSpell(_Q, target) end
  end
end

  function harass()
    if EREADY then CastSpell(_E, target) end
    if QREADY then CastSpell(_Q, target) end
  end
  
  function docombo()
    if EREADY then CastSpell(_E, target) end
    if QREADY then CastSpell(_Q, target) end
    if WREADY and AutoCarry.PluginMenu.useW then AutoCarry.CastSkillshot(SkillW, target) end
    if RREADY and AutoCarry.PluginMenu.useult and ultactive == false and GetDistance(target)<=700 then
      CastSpell(_R)
    if RREADY and ultactive == true and GetDistance(target)>1000 then
    CastSpell(_R)
    end
  end
end

  
function autotorment()
  if EREADY and GetDistance(target)<=625 then
    CastSpell(_E, target) end
  end


 function checks()
   QREADY = (myHero:CanUseSpell(_Q) == READY)
   WREADY = (myHero:CanUseSpell(_W) == READY)
   EREADY = (myHero:CanUseSpell(_E) == READY)
   RREADY = (myHero:CanUseSpell(_R) == READY)
 end

 function PluginOnCreateObj(obj)
   if obj.name:find("swain_metamorph") then ultactive = false end
   if obj.name:find("swain_demonForm") then ultactive = true end    
 end

 function PluginOnDraw()
   if AutoCarry.PluginMenu.drawcircle and not myHero.dead then
     DrawCircle (myHero.x, myHero.y, myHero.z, range, 0x19A712)
   end
  end