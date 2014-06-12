if myHero.charName ~= "Gragas" then return end
 
require "AoE_Skillshot_Position"
 
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 1050
        --> Main Load
        mainLoad()
        --> Main Menu
        mainMenu()
end
 
function PluginOnTick()
        Checks()
        if Target and (AutoCarry.MainMenu.MixedMode) then
                if QREADY and Menu.useQ2 and GetDistance(Target) < qRange then Cast(SkillQ, Target) end
                if EREADY and Menu.useE2 and GetDistance(Target) < eRange then Cast(SkillE, Target) end
                if RREADY and Menu.useR2 then castR(Target) end
        end
        if Target and (AutoCarry.MainMenu.AutoCarry) then
                if QREADY and Menu.useQ and GetDistance(Target) < qRange then Cast(SkillQ, Target) end
                if EREADY and Menu.useE and GetDistance(Target) < eRange then Cast(SkillE, Target) end
                if RREADY and Menu.useR then castR(Target) end
        end
        if Menu.ultKS and RREADY then ultKS() end
        if Menu.barrelKS and QREADY then barrelKS() end
end
 
function PluginOnDraw()
        --> Ranges
        if not Menu.drawMaster and not myHero.dead then
                if QREADY and Menu.drawQ then
                        DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FFFF)
                end
                if EREADY and Menu.drawE then
                        DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x00FF00)
                end
                if RREADY and Menu.drawR then
                        DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x00FF00)
                end
        end
end
 
 
--> Ult KS
function ultKS()
        for i, enemy in ipairs(GetEnemyHeroes()) do
                local rDmg = getDmg("R", enemy, myHero)
                if enemy and not enemy.dead and enemy.health < rDmg then
                        Cast(SkillR, enemy)
                end
        end
end
 
--> barrel KS
function barrelKS()
        for i, enemy in ipairs(GetEnemyHeroes()) do
                local qDmg = getDmg("Q", enemy, myHero)
                if enemy and not enemy.dead and enemy.health < qDmg then
                        Cast(SkillQ, enemy)
                end
        end
end
 
--> Checks
function Checks()
        Target = AutoCarry.GetAttackTarget()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
end
 
--> MEC
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
                local ultPos = GetAoESpellPosition(500, target)
                if ultPos and GetDistance(ultPos) <= rRange     then
                        if CountEnemies(ultPos, 500) >= Menu.rEnemies then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        elseif GetDistance(target) <= rRange then
                CastSpell(SkillR, target.x, target.z)
        end
end
 
--> Main Load
function mainLoad()
        qRange, eRange, rRange = 1100, 600, 1050
        QREADY, WREADY, EREADY, RREADY = false, false, false, false
        SkillQ = {spellKey = _Q, range = qRange, speed = 1.0, delay = 250}
        SkillE = {spellKey = _E, range = eRange, speed = 1.0, delay = 250}
        SkillR = {spellKey = _R, range = rRange, speed = 2.0, delay = 250}
        Cast = AutoCarry.CastSkillshot
        Menu = AutoCarry.PluginMenu
end
 
--> Main Menu
function mainMenu()
        Menu:addParam("sep", "-- KS Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("ultKS", "Kill with Explosive Cask", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("barrelKS", "Kill with Barrel Roll", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("sep", "-- Ultimate Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("rMEC", "Explosive Cask - Use MEC", SCRIPT_PARAM_ONOFF, true)
  Menu:addParam("rEnemies", "Explosive Cask - Min Enemies",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
        Menu:addParam("sep1", "-- Autocarry Mode --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("useQ", "Use - Barrel Roll", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("useE", "Use - Body Slam", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("useR", "Use - Explosive Cask", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("sep2", "-- Mixed Mode --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("useQ2", "Use - Barrel Roll", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("useE2", "Use - Body Slam", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("useR2", "Use - Explosive Cask", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("drawMaster", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("drawQ", "Draw - Barrel Roll", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("drawE", "Draw - Body Slam", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("drawR", "Draw - Explosive Cask", SCRIPT_PARAM_ONOFF, false)
end