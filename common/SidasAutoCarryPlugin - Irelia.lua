--[[    Items   ]]--
local QREADY, WREADY, EREADY, RREADY  = false, false, false, false
local SheenSlot, TrinitySlot, IcebornSlot = nil, nil, nil
 
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 1300
        --> Load
        mainLoad()
        --> Main Menu
        mainMenu()
end
 
function PluginOnTick()
        Checks()
       
        --[[    Auto Stun       ]]--
        if Target and Menu.autoStun then
                if GetDistance(Target) < eRange and EREADY then
                        if (myHero.health / myHero.maxHealth) < (Target.health / Target.maxHealth) then
                                CastSpell(_E, Target)
                        end
                end
        end
 
        --[[    Basic Combo     ]]--
        if Target and AutoCarry.MainMenu.AutoCarry then
                if RNDREADY and GetDistance(Target) < 375 then CastSpell(RNDSlot) end
                --[[    Abilities       ]]--
                if QREADY and WREADY and GetDistance(Target) <= qRange then
                        CastSpell(_W)
                elseif WREADY and GetDistance(Target) <= 300 then
                        CastSpell(_W)
                end
               
                if QREADY and GetDistance(Target) <= qRange then
                        if not Menu.limitQ then
                                CastSpell(_Q, Target)
                        elseif Menu.limitQ then
                                if QREADY and Target.health < qDamage(Target) then CastSpell(_Q, Target) end
                        end
                end
               
                if EREADY and GetDistance(Target) < eRange then
                        if Menu.eStun and (myHero.health / myHero.maxHealth) < (Target.health / Target.maxHealth) then
                                CastSpell(_E, Target)
                        elseif not Menu.eStun then
                                CastSpell(_E, Target)
                        end
                end
               
                if RREADY and Menu.useR then CastR(Target) end
        end
 
        --[[    Auto Q  ]]--
        if Menu.autoQ and QREADY then
                for i=1, heroManager.iCount do
                        champ = heroManager:GetHero(i)
                        if champ and champ.team ~= myHero.team and not champ.dead then
                                if GetDistance(champ) <= qRange and champ.health < qDamage(champ) then
                                        CastSpell(_Q, champ)
                                end
                        end
                end
        end
       
        --[[    Last Hit        ]]--
        if QREADY and Menu.iFarm then
                if AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.LaneClear then
                        for _, minion in pairs(farmMinions.objects) do
                                if GetDistance(minion) <= qRange and GetDistance(minion) > Menu.qBuffer and minion.health < qDamage(minion) then
                                        CastSpell(_Q, minion)
                                end
                        end
                        for _, jMinion in pairs(jungleMinions.objects) do
                                if GetDistance(jMinion) <= qRange and GetDistance(jMinion) > Menu.qBuffer and jMinion.health < qDamage(jMinion) then
                                        CastSpell(_Q, jMinion)
                                end
                        end
                end
        end
end
 
function PluginOnDraw()
        if Menu.drawQ and not myHero.dead then
                DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
        end
end
 
function PluginOnProcessSpell(unit, spell)
        if unit.isMe and spell.name == "IreliaHitenStyle" then
                lasthiten = os.clock()
                hitendmg = spell.level*15
        end
end
 
function qDamage(target)
        local qDmg = getDmg("Q", target, myHero) + getDmg("AD", target, myHero)
        local bDmg = ((SheenSlot and getDmg("SHEEN", target, myHero) or 0)+(TrinitySlot and getDmg("TRINITY", target, myHero) or 0)+(IcebornSlot and getDmg("ICEBORN", target, myHero) or 0))-15
        local totalQDmg = qDmg + bDmg + hitendmg
        return totalQDmg
end
 
function totalDamage(target)
        return qDamage(target) + getDmg("R", target, myHero)*4
end
 
function CastR(target)
        local damagetoTarget = totalDamage(target)
        if IsSACReborn and VIP_USER then
                if not Menu.limitR then
                        SkillR:ForceCast(target)
                elseif target.health < damagetoTarget then
                        SkillR:ForceCast(target)
                end
        else
                if not Menu.limitR then
                        Cast(SkillR, target)
                elseif target.health < damagetoTarget then
                        Cast(SkillR, target)
                end
        end
end
 
function Checks()
        farmMinions:update()
        jungleMinions:update()
        Target = AutoCarry.GetAttackTarget()
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        RNDREADY = (RNDSlot ~= nil and myHero:CanUseSpell(RNDSlot) == READY)
       
        SheenSlot, TrinitySlot, IcebornSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3057), GetInventorySlotItem(3078)
        if os.clock() > lasthiten + hitendelay then hitendmg = 0 end
end
 
function mainLoad()
        if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
       
        lasthiten, hitendelay, hitendmg = 0, 6, 0
        qRange, eRange, rRange = 650, 425, 1200
       
        if IsSACReborn and VIP_USER then
                SkillR = AutoCarry.Skills:NewSkill(true, _R, rRange, "Transcendent Blades", AutoCarry.SPELL_LINEAR, 0, false, false, 1700, 250, 60, false)
        else
                SkillR = {spellKey = _R, range = rRange, speed = 1700, delay = 250, width = 60, minions = false}
        end
        RNDSlot, RNDREADY = nil, false
        Menu = AutoCarry.PluginMenu
        Cast = AutoCarry.CastSkillshot
        farmMinions = minionManager(MINION_ENEMY, qRange+200, player)
        jungleMinions = minionManager(MINION_JUNGLE, qRange+200, player)
end
 
function mainMenu()
        Menu:addParam("autoStun", "Auto Stun", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("autoQ", "Auto Q killable", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("limitQ", "Limit Q usage", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("limitR", "Limit R usage", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("useR", "Use ultimate", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("eStun", "Only use E to stun", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("iFarm", "Farm with Q", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("qBuffer", "Min Range to Q Farm",SCRIPT_PARAM_SLICE, 0, 0, 650, 1)
        Menu:addParam("drawQ", "Draw - Bladesurge", SCRIPT_PARAM_ONOFF, false)
end
