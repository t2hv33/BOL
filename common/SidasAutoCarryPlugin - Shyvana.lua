--Shyvana Tiem for free users Credits BotHappy - Trees - Galaxix v0.1--
 
--Changelog :
--1.0 - Initial Release
 
 
if myHero.charName ~= "Shyvana" then return end
 
 
local QRange = 125
local WRange = 325
local ERange = 925
local RRange = 1000
local QAble, WAble, EAble, RAble = false, false, false, false
 
local items =
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
 
function AutoIgnite()
        if not enemy then enemy = Target end
        if enemy.health <= iDmg and GetDistance(enemy) <= 600 then
                if IREADY then CastSpell(ignite, enemy) end
        end
end
 
function PluginOnLoad()
        AutoCarry.SkillsCrosshair.range = 1100
        PrintChat("Shyvana Tiem FOR NONVIPS Edited By Galaxix")
                   Menu()
end
 
function PluginOnTick()
        Checks()
                if Target then
                if (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
                        ComboCast()
                end
                if AutoCarry.PluginMenu.Harrass and EAble then
                        CastSpell(_E, Target.x, Target.z)
                end
        end
end    
 
function Checks()
        QAble = (myHero:CanUseSpell(_Q) == READY)
        WAble = (myHero:CanUseSpell(_W) == READY)
        EAble = (myHero:CanUseSpell(_E) == READY)
        RAble = (myHero:CanUseSpell(_R) == READY)
        Target = AutoCarry.GetAttackTarget()
    hpReady = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
        if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
       -- Slots for Items / Pots / Wards --
        rstSlot, ssSlot, swSlot, vwSlot = GetInventorySlotItem(2045), GetInventorySlotItem(2049), GetInventorySlotItem(2044), GetInventorySlotItem(2043)
        hpSlot, mpSlot, fskSlot = GetInventorySlotItem(2003), GetInventorySlotItem(2004), GetInventorySlotItem(2041)
        znaSlot, wgtSlot = GetInventorySlotItem(3157), GetInventorySlotItem(3090)
end
 
function Menu()
       
                   AutoCarry.PluginMenu:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
                   AutoCarry.PluginMenu:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
                   AutoCarry.PluginMenu:addParam("KS", "KS With Q and W", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("useQ", "Use Q in combo", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("useW", "Use W in combo", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("useE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("useR", "Use R in combo", SCRIPT_PARAM_ONOFF, false)
        AutoCarry.PluginMenu:addParam("drawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("drawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("drawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
        AutoCarry.PluginMenu:addParam("Harrass", "Harrass with E", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
        AutoCarry.PluginMenu:permaShow("Harrass")
end
 
function UseConsumables()
 if AutoCarry.PluginMenu.aHP and myHero.health < (myHero.maxHealth * (AutoCarry.PluginMenu.HPHealth / 100)) and not (usingHPot or usingFlask) and (hpReady or fskReady) then
 if hpReady == false and fskReady == true then CastSpell(fskSlot)
 else CastSpell(hpSlot) end
end
 
end
 
       
 
function ComboCast()
        UseItems(Target)
        if QAble and AutoCarry.PluginMenu.useQ then
                if GetDistance(Target) <= QRange  and AutoCarry.shotFired then
                        CastSpell(_Q)
                       
                        end
        end
        if WAble and AutoCarry.PluginMenu.useW then  CastSpell(_W) end
        if EAble and AutoCarry.PluginMenu.useE then  CastSpell(_E, Target.x, Target.z) end
        if RAble and AutoCarry.PluginMenu.useR then  CastSpell(_R)  end  
end
 
function PluginOnDraw()
        if not myHero.dead then
                if (WAble or WActive) and AutoCarry.PluginMenu.drawW then
                        DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0x7CFC00)
                end
                if EAble and AutoCarry.PluginMenu.drawE then
                        DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x00FFFF)
                end
                if RAble and AutoCarry.PluginMenu.drawR then
                        DrawCircle(myHero.x, myHero.y, myHero.z, RRange, 0xFF0000)
                end
        end
end
 
function KS()
        for i, enemy in ipairs(GetEnemyHeroes()) do
                if WREADY then kDmg = getDmg("Q", enemy, myHero) + getDmg("W", enemy, myHero) else
                local kDmg = getDmg("Q", enemy, myHero)
                if enemy and not enemy.dead and enemy.health < kDmg then
                        CastSpell(_Q, enemy)
                        CastSpell(_W)
                        end
                end
        end
end
 
-- By Sida ( all credits )
function UseItems(target)
    if target == nil then return end
    for _,item in pairs(items) do
        item.slot = GetInventorySlotItem(item.id)
        if item.slot ~= nil then
            if item.reqTarget and GetDistance(target) < item.range then
                CastSpell(item.slot, target)
                elseif not item.reqTarget then
                if (GetDistance(target) - getHitBoxRadius(myHero) - getHitBoxRadius(target)) < 50 then
                    CastSpell(item.slot)
                end
            end
        end
    end
end