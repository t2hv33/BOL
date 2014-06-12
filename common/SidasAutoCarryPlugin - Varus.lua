--[[
 
 
 ______           __               ____                                        ____    ___                                  
/\  _  \         /\ \__           /\  _`\                                     /\  _`\ /\_ \                    __            
\ \ \L\ \  __  __\ \ ,_\   ___    \ \ \/\_\     __     _ __   _ __   __  __   \ \ \L\ \//\ \    __  __     __ /\_\    ___    
 \ \  __ \/\ \/\ \\ \ \/  / __`\   \ \ \/_/_  /'__`\  /\`'__\/\`'__\/\ \/\ \   \ \ ,__/ \ \ \  /\ \/\ \  /'_ `\/\ \ /' _ `\  
  \ \ \/\ \ \ \_\ \\ \ \_/\ \L\ \   \ \ \L\ \/\ \L\.\_\ \ \/ \ \ \/ \ \ \_\ \   \ \ \/   \_\ \_\ \ \_\ \/\ \L\ \ \ \/\ \/\ \
   \ \_\ \_\ \____/ \ \__\ \____/    \ \____/\ \__/.\_\\ \_\  \ \_\  \/`____ \   \ \_\   /\____\\ \____/\ \____ \ \_\ \_\ \_\
    \/_/\/_/\/___/   \/__/\/___/      \/___/  \/__/\/_/ \/_/   \/_/   `/___/> \   \/_/   \/____/ \/___/  \/___L\ \/_/\/_/\/_/
                                                                         /\___/                            /\____/          
                                                                         \/__/                             \_/__/            
                                                                                                                                                 
        Auto Carry Plugin - Varus Edition  by radeon
        Combo - E -> R ->
               
                Version:                0.2
                Release date:   2013.09.07
--]]
 
if myHero.charName ~= "Varus" then return end
 
local Target
 
function PluginOnLoad()
        -- Prediction
        eRange, rRange = 925, 1075
       
        SkillE = {spellKey = _E, range = eRange, speed = 1.75, delay = 240, width = 235}
        SkillR = {spellKey = _R, range = rRange, speed = 1.2, delay = 345, width = 0}
         
        AutoCarry.SkillsCrosshair.range = qRange
        AutoCarry.PluginMenu:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
        AutoCarry.PluginMenu:addParam("comboOption", "-- Combo Options --", SCRIPT_PARAM_INFO, "")
                AutoCarry.PluginMenu:addParam("useE", "Use Hail of Arrows [E]", SCRIPT_PARAM_ONOFF, true)
                AutoCarry.PluginMenu:addParam("useR", "Use Chain of Corruption [R]", SCRIPT_PARAM_ONOFF, false)
        AutoCarry.PluginMenu:addParam("drawOption", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
        AutoCarry.PluginMenu:addParam("drawE", "Draw E range", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("drawR", "Draw R range", SCRIPT_PARAM_ONOFF, true)
end
 
function PluginOnTick()
    Target = AutoCarry.GetAttackTarget()
 
    if AutoCarry.PluginMenu.combo then
        Combo()
    end
end
 
function PluginOnDraw()
    if not myHero.dead then
        if AutoCarry.PluginMenu.drawE and myHero:CanUseSpell(_E) == READY then
            DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x0099CC)
        end
        if AutoCarry.PluginMenu.drawR and myHero:CanUseSpell(_R) == READY then
            DrawCircle(myHero.x,myHero.y, myHero.z, rRange, 0x0099CC)
        end
    end
end
 
function Combo()
    if Target ~= nil then
        if AutoCarry.PluginMenu.useE and myHero:CanUseSpell(_E) == READY and GetDistance(Target) < eRange then
            AutoCarry.CastSkillshot(SkillE, Target)
        end
            if AutoCarry.PluginMenu.useR and myHero:CanUseSpell(_R) == READY and GetDistance(Target) < rRange then
            AutoCarry.CastSkillshot(SkillR, Target)
        end
    end
end
