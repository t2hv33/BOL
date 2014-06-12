--
--              aEvelynn by Anonymous v1.1
--                              Version for SAC: Revamped
--
 
require 'AoE_Skillshot_Position'
if myHero.charName ~= "Evelynn" then return end
 
local Target
local UltByScript = false
local Enemies = AutoCarry.EnemyTable
 
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 800
end
 
function PluginOnTick()
        Target = AutoCarry.GetAttackTarget()
        if AutoCarry.PluginMenu.spamQE then
                if Target ~= nil and AutoCarry.MainMenu.AutoCarry then
                        local CanQ = (myHero:CanUseSpell(_Q) == READY and GetDistance(Target, myHero) < 500)
                        local CanE = (myHero:CanUseSpell(_E) == READY and GetDistance(Target, myHero) < 225)
                        if CanQ then CastSpell(_Q) end
                        if CanE then CastSpell(_E, Target) end
                end
        end
        if AutoCarry.PluginMenu.spamQ then
                if AutoCarry.MainMenu.LaneClear and myHero.mana/myHero.maxMana*100 >= AutoCarry.PluginMenu.autoMinMana then
                        local CanQ = (myHero:CanUseSpell(_Q) == READY)
                        if CanQ then CastSpell(_Q) end
                end
        end
        if AutoCarry.PluginMenu.spamE then
                if AutoCarry.MainMenu.LaneClear and myHero.mana/myHero.maxMana*100 >= AutoCarry.PluginMenu.autoMinMana then
                        local JunngleTarget = AutoCarry.GetMinionTarget()
                        if JunngleTarget ~= nil then
                                local CanE = (myHero:CanUseSpell(_E) == READY and GetDistance(JunngleTarget, myHero) < 225)
                                if CanE then CastSpell(_E, JunngleTarget) end
                        end
                end
        end
        if AutoCarry.PluginMenu.burstTarget then
                if Target ~= nil then
                        local CanQ = (myHero:CanUseSpell(_Q) == READY and GetDistance(Target, myHero) < 500)
                        local CanE = (myHero:CanUseSpell(_E) == READY and GetDistance(Target, myHero) < 325)
                        local CanR = (myHero:CanUseSpell(_R) == READY and GetDistance(Target, myHero) < 800)
                        --AutoCarry.Items:UseAll(Target)
                        CastItem(3128, Target)
                        if CanR then
                                if VIP_USER then
                                        if AutoCarry.PluginMenu.autoUltaiming then
                                                CastSpell(_R, Target.x, Target.z)
                                        else
                                                local spellPos = GetAoESpellPosition(250, Target)
                                                CastSpell(_R, spellPos.x, spellPos.z)
                                        end
                                else
                                        local spellPos = GetAoESpellPosition(250, Target)
                                        CastSpell(_R, spellPos.x, spellPos.z)
                                        --PrintChat("NonVIPCast")
                                end
                        end -- Packets will target it better anyway :p
                        if CanE then CastSpell(_E, Target) end
                        if CanQ then CastSpell(_Q) end
                        if not AutoCarry.MainMenu.AutoCarry then myHero:Attack(Target) end
                end
        end
end
 
function PluginOnDraw()
        if myHero ~= nil and not myHero.dead and AutoCarry.PluginMenu.drawQrange then if AutoCarry.PluginMenu.drawPoly then DrawCircle2(myHero.x, myHero.y, myHero.z, 500, 0xFF80FF00) else DrawCircle(myHero.x, myHero.y, myHero.z, 500, 0xFF80FF00) end end
        if myHero ~= nil and not myHero.dead and AutoCarry.PluginMenu.drawErange then if AutoCarry.PluginMenu.drawPoly then DrawCircle2(myHero.x, myHero.y, myHero.z, 225, 0xFF80FF00) else DrawCircle(myHero.x, myHero.y, myHero.z, 225, 0xFF80FF00) end end
        if myHero ~= nil and not myHero.dead and AutoCarry.PluginMenu.drawRrange and myHero:CanUseSpell(_R) == READY then if AutoCarry.PluginMenu.drawPoly then DrawCircle2(myHero.x, myHero.y, myHero.z, 800, 0xFF80FF00) else DrawCircle(myHero.x, myHero.y, myHero.z, 800, 0xFF80FF00) end end
        if AutoCarry.PluginMenu.drawRmec then -- Test MEC IT Draws where ultimate will be casted :) You can uncomment it, and it will work.
                local ClosestEnemy = nil
                local Position1 = { x=mousePos.x, y=mousePos.y, z=mousePos.z }
                for i, Enemy in pairs(Enemies) do
                        if Enemy ~= nil and not Enemy.dead and Enemy.visible then
                                if ClosestEnemy ~= nil then
                                        if GetDistance(Enemy, Position1) < GetDistance(ClosestEnemy, Position1) then
                                                ClosestEnemy = Enemy
                                        end
                                else
                                        ClosestEnemy = Enemy
                                end
                        end
                end
                local UltTargetted = ClosestEnemy
                if UltTargetted ~= nil and GetDistance(UltTargetted, CastPosition) < 300 then
                        UltTarget = UltTargetted
                else
                        UltTarget = AutoCarry.GetAttackTarget()
                end
                if UltTarget ~= nil then
                        local ValidEnemies = 0
                        for i, Enemy in pairs(Enemies) do
                                if Enemy ~= nil and not Enemy.dead and Enemy.visible and GetDistance(Enemy, myHero) < 1050 then ValidEnemies = ValidEnemies + 1 end
                        end
                        if ValidEnemies > 1 then
                                local spellPos = GetAoESpellPosition(250, UltTarget)
                                if AutoCarry.PluginMenu.drawPoly then DrawCircle2(spellPos.x, spellPos.y, spellPos.z, 250, 0xFF80FF00) else DrawCircle(spellPos.x, spellPos.y, spellPos.z, 250, 0xFF80FF00) end
                        else
                                if AutoCarry.PluginMenu.drawPoly then DrawCircle2(UltTarget.x, UltTarget.y, UltTarget.z, 250, 0xFF80FF00) else DrawCircle(UltTarget.x, UltTarget.y, UltTarget.z, 250, 0xFF80FF00) end
                        end
                end
        end
        if myHero ~= nil and not myHero.dead and AutoCarry.PluginMenu.drawText then
                for i, Enemy in pairs(Enemies) do
                        if ValidTarget(Enemy) then
                                local TotalDMG = 0
                                local CanDFG = GetInventoryItemIsCastable(3128)
                                local CanQ = (myHero:CanUseSpell(_Q) == READY and GetDistance(Enemy, myHero) < 500)
                                local CanE = (myHero:CanUseSpell(_E) == READY and GetDistance(Enemy, myHero) < 325)
                                local CanR = (myHero:CanUseSpell(_R) == READY and GetDistance(Enemy, myHero) < 800)
                                if CanR then TotalDMG = TotalDMG + getDmg("R", Enemy, myHero) end
                                if CanE then TotalDMG = TotalDMG + getDmg("E", Enemy, myHero) end
                                if CanQ then TotalDMG = TotalDMG + getDmg("Q", Enemy, myHero) end
                                if CanDFG then
                                        TotalDMG = TotalDMG * 0.2
                                        TotalDMG = TotalDMG + getDmg("DFG", Enemy, myHero)
                                end
                                TotalDMG = TotalDMG + getDmg("AD", Enemy, myHero)
                                if TotalDMG >= Enemy.health then
                                        PrintFloatText(Enemy, 0, "Killable")
                                else
                                        local HPafter = round(Enemy.health - TotalDMG, 1)
                                        PrintFloatText(Enemy, 0, "HP: "..HPafter)
                                end
                        end
                end
        end
end
 
function round(num, idp)
  return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end
 
function PluginOnSendPacket(p)
        local packet = Packet(p)
        if packet:get('name') == 'S_CAST' then
                local SpellID = packet:get('spellId')
                if SpellID == SPELL_4 then
                        PrintChat("ULTING")
                        local CastPosition = { x = packet:get('toX'), y = packet:get('toY'), z = packet:get('toY') }
                        if AutoCarry.PluginMenu.blockR then
                                local ValidTargets = 0
                                for i, Enemy in pairs(Enemies) do
                                        if Enemy ~= nil and not Enemy.dead and Enemy.visible and GetDistance(Enemy, CastPosition) < 250 then ValidTargets = ValidTargets + 1 end
                                end
                                if ValidTargets == 0 then p:Block() PrintChat("BLOCKING") end
                        end
                        if AutoCarry.PluginMenu.autoUltaiming then
                                if UltByScript == true then
                                        UltByScript = false
                                elseif UltByScript == false then
                                        p:Block()
                                        UltByScript = true
                                        local ClosestEnemy = nil
                                        local Position1 = { x=CastPosition.x, y=CastPosition.y, z=CastPosition.z }
                                        for i, Enemy in pairs(Enemies) do
                                                if Enemy ~= nil and not Enemy.dead and Enemy.visible then
                                                        if ClosestEnemy ~= nil then
                                                                if GetDistance(Enemy, Position1) < GetDistance(ClosestEnemy, Position1) then
                                                                        ClosestEnemy = Enemy
                                                                end
                                                        else
                                                                ClosestEnemy = Enemy
                                                        end
                                                end
                                        end
                                        local UltTargetted = ClosestEnemy
                                        if UltTargetted ~= nil and GetDistance(UltTargetted, CastPosition) < 300 then
                                                UltTarget = UltTargetted
                                        else
                                                UltTarget = AutoCarry.GetAttackTarget()
                                        end
                                        if UltTarget ~= nil then
                                                local ValidEnemies = 0
                                                for i, Enemy in pairs(Enemies) do
                                                        if Enemy ~= nil and not Enemy.dead and Enemy.visible and GetDistance(Enemy, myHero) < 1050 then ValidEnemies = ValidEnemies + 1 end
                                                end
                                                if ValidEnemies > 1 then
                                                        local spellPos = GetAoESpellPosition(250, UltTarget)
                                                        CastSpell(_R, spellPos.x, spellPos.z)
                                                else
                                                        CastSpell(_R, UltTarget.x, UltTarget.z)
                                                end
                                        end
                                end
                        end
                end
        end
end
 
AutoCarry.PluginMenu:addParam("Information1", "  aEvelynn v1.1 by Anonymous", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("Information2", "== Helper-Settings: ==", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("burstTarget", "Full Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A"))
AutoCarry.PluginMenu:addParam("spamQE","Use QE in AutoCarry mode", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("spamQ","Use Q in LaneClear mode", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("spamE","Use E in LaneClear mode", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("autoMinMana","Minimum % mana (LaneClear)", SCRIPT_PARAM_SLICE, 35, 0, 100, 0)
AutoCarry.PluginMenu:addParam("Information4", "VIP only functions:", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("blockR","Block wrong ult", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("autoUltaiming","Automaticly aim with ult", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("Information3", "== Drawer-Settings: ==", SCRIPT_PARAM_INFO, "")
AutoCarry.PluginMenu:addParam("drawQrange","Draw Q range", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("drawErange","Draw E range", SCRIPT_PARAM_ONOFF, false) -- useless imo, too much circles.
AutoCarry.PluginMenu:addParam("drawRrange","Draw R range", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("drawRmec","Draw R prediction", SCRIPT_PARAM_ONOFF, false) -- This is only to let you see how it casts ultimate, imo should be disable during game.
AutoCarry.PluginMenu:addParam("drawText","Draw text on enemies", SCRIPT_PARAM_ONOFF, true) -- Killable, Murder him, etc.
AutoCarry.PluginMenu:addParam("drawPoly","Use less demanding DrawCircle", SCRIPT_PARAM_ONOFF, false) -- Killable, Murder him, etc.
AutoCarry.PluginMenu:addParam("Information5", "Check this if you have weak PC", SCRIPT_PARAM_INFO, "")
 
-- SImple Draw (replace standart draw circle with less fps intensive one and hide non visible onscreen circles)
-- by barasia, vadash and viseversa
 
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
                quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
                quality = 2 * math.pi / quality
                radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end
 
function round(num)
        if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end
 
function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75)       
    end
end
--_G.DrawCircle = DrawCircle2
