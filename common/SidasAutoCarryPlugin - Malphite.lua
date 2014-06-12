--[[

AutoCarry Plugin - Malphite, Shard of the Monolith 1.0 by Galaxix

With Code from Kain, Skeem
        Changelog :
   1.0    - Initial Release
        ]] --
           
if myHero.charName ~= "Malphite" then return end

--[ Plugin Loads] --
function PluginOnLoad()
        
        loadMain() -- Loads Global Variables
        menuMain() -- Loads AllClass Menu
        PrintChat(" [ JustMalphite Loaded ] ")
        
end
--[/Loads]

--[Plugin OnTick]--
function PluginOnTick()
                Checks()
                SmartKS()
                UseConsumables()
                
                if not IsMyManaLow() and Menu.qFarm and not Carry.AutoCarry then qFarm()
                        elseif not IsMyManaLow() and Menu.eFarm and not Carry.AutoCarry then eFarm() end
                if Carry.AutoCarry then Combo() end
                if Menu.sKS then SmartKS() end
                if Target and Carry.MixedMode then
                if Menu.qHarass and QREADY and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
                if Menu.eHarass and EREADY and GetDistance(Target) <= eRange then CastSpell(_E, Target) end
                       
     end
  end
--[/OnTick]--

-- Farm Functions --

function qFarm()
        for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
                local qDmg = getDmg("Q",minion,myHero)
                   if ValidTarget(minion) and QREADY and GetDistance(minion) <= qRange then
            if qDmg >= minion.health then CastSpell(_Q, minion) end
        end
   end
end

function eFarm()
        for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
                local eDmg = getDmg("E",minion,myHero)
                   if ValidTarget(minion) and EREADY and GetDistance(minion) <= eRange then
            if eDmg >= minion.health then CastSpell(_E, minion.x, minion.y) end
        end
   end
end

--[/FARM]--

--[Combo Function]--
function Combo()
        if Target then
                if DFGREADY then CastSpell(dfgSlot, Target) end
                if HXGREADY then CastSpell(hxgSlot, Target) end
                if BWCREADY then CastSpell(bwcSlot, Target) end
                if BRKREADY then CastSpell(brkSlot, Target) end
                if RREADY and Menu.useR and GetDistance(Target) <= rRange then CastR(Target) end
                if EREADY and Menu.useE and GetDistance(Target) <= eRange then CastSpell(_E, Target) end
                if QREADY and Menu.useQ and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
                if WREADY and Menu.useW and GetDistance(Target) <= eRange then CastSpell(_W)
        end
    end
end

--[/Combo Function]--

function CastR(Target)
    if RREADY then
                local ultPos = GetAoESpellPosition(1000, Target)
                if ultPos and GetDistance(ultPos) <= rRange then
                        CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        end

 
--[Smart KS Function]--
function SmartKS()
         for i=1, heroManager.iCount do
         local enemy = heroManager:GetHero(i)
                if ValidTarget(enemy) then
                        dfgDmg, hxgDmg, bwcDmg, iDmg  = 0, 0, 0, 0
                        qDmg = getDmg("Q",enemy,myHero)
                        eDmg = getDmg("E",enemy,myHero)
                        rDmg = getDmg("R",enemy,myHero)
                        if DFGREADY then dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0)        end
            if HXGREADY then hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0) end
            if BWCREADY then bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0) end
            if IREADY then iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0) end
            onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            itemsDmg = dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
                        if Menu.sKS then
                                if enemy.health <= (qDmg) and GetDistance(enemy) <= qRange and QREADY then
                                        if QREADY then CastSpell(_Q, enemy) end
                                
                                elseif enemy.health <= (eDmg) and GetDistance(enemy) <= eRange and EREADY then
                                        if EREADY then CastSpell(_E, enemy) end
                                
                                elseif enemy.health <= (qDmg + eDmg) and GetDistance(enemy) <= eRange and EREADY and QREADY then
                                        if QREADY then CastSpell(_Q, enemy) end
                                        if WREADY then CastSpell(_W, enemy) end
                                
                                elseif enemy.health <= (qDmg + itemsDmg) and GetDistance(enemy) <= qRange and QREADY then
                                        if DFGREADY then CastSpell(dfgSlot, enemy) end
                                        if HXGREADY then CastSpell(hxgSlot, enemy) end
                                        if BWCREADY then CastSpell(bwcSlot, enemy) end
                                        if BRKREADY then CastSpell(brkSlot, enemy) end
                                        if QREADY then CastSpell(_Q, enemy) end
                                
                                elseif enemy.health <= (eDmg + itemsDmg) and GetDistance(enemy) <= eRange and EREADY then
                                        if DFGREADY then CastSpell(dfgSlot, enemy) end
                                        if HXGREADY then CastSpell(hxgSlot, enemy) end
                                        if BWCREADY then CastSpell(bwcSlot, enemy) end
                                        if BRKREADY then CastSpell(brkSlot, enemy) end
                                        if WREADY then CastSpell(_E, enemy) end
                                
                                elseif enemy.health <= (qDmg + eDmg + itemsDmg) and GetDistance(enemy) <= eRange
                                        and EREADY and QREADY then
                                                if DFGREADY then CastSpell(dfgSlot, enemy) end
                                                if HXGREADY then CastSpell(hxgSlot, enemy) end
                                                if BWCREADY then CastSpell(bwcSlot, enemy) end
                                                if BRKREADY then CastSpell(brkSlot, enemy) end
                                                if EREADY and GetDistance(enemy) <= eRange then CastSpell(_E, enemy) end
                                                if QREADY then CastSpell(_Q, enemy) end
                                
                                elseif enemy.health <= (qDmg + eDmg + rDmg + itemsDmg) and GetDistance(enemy) <= qRange
                                        and QREADY and EREADY and WREADY and RREADY and enemy.health > (qDmg + eDmg) then
                                                if DFGREADY then CastSpell(dfgSlot, enemy) end
                                                if HXGREADY then CastSpell(hxgSlot, enemy) end
                                                if BWCREADY then CastSpell(bwcSlot, enemy) end
                                                if BRKREADY then CastSpell(brkSlot, enemy) end
                                                if RREADY and GetDistance(enemy) <= rRange then CastR(enemy) end
                                                if QREADY and GetDistance(enemy) <= qRange then CastSpell(_Q, enemy) end
                                                if EREADY and GetDistance(enemy) <= eRange then CastSpell(_E, enemy) end
                                                
                                
                                elseif enemy.health <= (rDmg + itemsDmg) and GetDistance(enemy) <= rRange
                                        and not QREADY and not EREADY and RREADY then
                                                if DFGREADY then CastSpell(dfgSlot, enemy) end
                                                if HXGREADY then CastSpell(hxgSlot, enemy) end
                                                if BWCREADY then CastSpell(bwcSlot, enemy) end
                                                if BRKREADY then CastSpell(brkSlot, enemy) end
                                                if RREADY then CastR(enemy) end
                                
                                end
                        end
                        KillText[i] = 1 
                        if enemy.health <= (qDmg + eDmg + itemsDmg) and QREADY and EREADY then
                                KillText[i] = 2
                        end
                        if enemy.health <= (qDmg + eDmg + rDmg + itemsDmg) and QREADY and EREADY and RREADY then
                                KillText[i] = 3
                        end
                        if enemy.health <= iDmg and GetDistance(enemy) <= 600 then
                                if IREADY then CastSpell(ignite, enemy) end
                        end
                end
        end
end
--[/Smart KS Function]--

--[USING POTS ETC.]

function UseConsumables()
        if not InFountain() and Target ~= nil then
                if Extras.aHP and myHero.health < (myHero.maxHealth * (Extras.HPHealth / 100))
                        and not (usingHPot or usingFlask) and (hpReady or fskReady)        then
                                CastSpell((hpSlot or fskSlot)) 
                end
                if Extras.aMP and myHero.mana < (myHero.maxMana * (Extras.MinMana / 100))
                        and not (usingMPot or usingFlask) and (mpReady or fskReady) then
                                CastSpell((mpSlot or fskSlot))
                end
        end
end                

--[Low Mana Function by Kain]--
function IsMyManaLow()
    if myHero.mana < (myHero.maxMana * ( Extras.MinMana / 100)) then
        return true
    else
        return false
    end
end

--[/Low Mana Function by Kain]--

--[Low Health Function Trololz]--
function IsMyHealthLow()
        if myHero.health < (myHero.maxHealth * ( Extras.ZWHealth / 100)) then
                return true
        else
                return false
        end
end

--[/Low Health Function Trololz]--

--[Health Pots Function]--
function NeedHP()
        if myHero.health < (myHero.maxHealth * ( Extras.HPHealth / 100)) then
                return true
        else
                return false
        end
end

--[/]

function PluginOnDraw()
        --> Ranges
        if not myHero.dead then
                if QREADY and Menu.qDraw then 
                        DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x191970)
                end
                if EREADY and Menu.eDraw then 
                        DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x191970)
                end
                if RREADY and Menu.rDraw then 
                        DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x191970)
                end
                if Target and Menu.DrawTarget then
                                DrawText("Targetting: " .. Target.charName, 15, 100, 100, 0xFFFF0000)
                end
                if Menu.cDraw then
                                for i=1, heroManager.iCount do
                                        local Unit = heroManager:GetHero(i)
                                        if ValidTarget(Unit) then
                                                if waittxt[i] == 1 and (KillText[i] ~= nil or 0 or 1) then
                                                        PrintFloatText(Unit, 0, TextList[KillText[i]])
                                                end
                                        end
                                        if waittxt[i] == 1 then
                                waittxt[i] = 30
                        else
                                waittxt[i] = waittxt[i]-1
                        end
                                end
                end
        
        
        end
end

--[/DRAW]--

function loadMain()
                if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
                if IsSACReborn then AutoCarry.Skills:DisableAll() end
                Menu = AutoCarry.PluginMenu
                Carry = AutoCarry.MainMenu
        if IsSACReborn then
                AutoCarry.Crosshair:SetSkillCrosshairRange(1000)
                else
                AutoCarry.SkillsCrosshair.range = 1000
                end
                hpReady, mpReady, fskReady = false, false, false
                HK1, HK2, HK3 = string.byte("Z"), string.byte("G"), string.byte("T")
                qRange, wRange, eRange, rRange = 625, 0, 200, 1000
                rPos = nil
                TextList = {"Harass him !!", "Rape Him !!", "Combo Kill !!"}
                KillText = {}
                waittxt = {} -- prevents UI lags, all credits to Dekaron
                for i=1, heroManager.iCount do waittxt[i] = i*3 end -- All credits to Dekaron
                 
end

function menuMain()
        Menu:addParam("sep", "-- Farm Options --", SCRIPT_PARAM_INFO, "")
               Menu:addParam("qFarm", "(Q) - Farm ", SCRIPT_PARAM_ONKEYTOGGLE, false, HK1)
               Menu:addParam("eFarm", "(E) - Farm ", SCRIPT_PARAM_ONKEYTOGGLE, false, HK2)
                Menu:addParam("sep1", "-- Combo Options --", SCRIPT_PARAM_INFO, "")
                Menu:addParam("useR", "Use (R) In Combo", SCRIPT_PARAM_ONKEYTOGGLE, true, HK3)
                Menu:addParam("useE", "Use (E) In Combo", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("useQ", "Use (Q) In Combo", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("useW", "Use (W) In Combo", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
                Menu:addParam("qHarass", "Use (Q) for Harass", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("eHarass", "Use (E) for Harass", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("sep3", "-- KS Options --", SCRIPT_PARAM_INFO, "")
                Menu:addParam("sKS", "Use Smart Combo KS", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("sep5", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
                Menu:addParam("qDraw", "Draw (Q)", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("eDraw", "Draw (E)", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("rDraw", "Draw (R)", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("DrawTarget", "Draw Target", SCRIPT_PARAM_ONOFF, true)
                Menu:addParam("cDraw", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
                
                Extras = scriptConfig("Sida's Auto Carry Plugin: "..myHero.charName..": Extras", myHero.charName)
                Extras:addParam("sep6", "-- Misc --", SCRIPT_PARAM_INFO, "")
                Extras:addParam("MinMana", "Minimum Mana for Q Farm %", SCRIPT_PARAM_SLICE, 40, 0, 100, 2)
                Extras:addParam("ZWItems", "Auto Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, true)
                Extras:addParam("ZWHealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, 2)
                Extras:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
                Extras:addParam("aMP", "Auto Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
                Extras:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
                
                end

--[Certain Checks]--
function Checks()
        if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
        if IsSACReborn then Target = AutoCarry.Crosshair:GetTarget() else Target = AutoCarry.GetAttackTarget() end
        dfgSlot, hxgSlot, bwcSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
        brkSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
        znaSlot, wgtSlot = GetInventorySlotItem(3157),GetInventorySlotItem(3090)
        hpSlot, mpSlot, fskSlot = GetInventorySlotItem(2003),GetInventorySlotItem(2004),GetInventorySlotItem(2041)
        QREADY = (myHero:CanUseSpell(_Q) == READY)
        WREADY = (myHero:CanUseSpell(_W) == READY)
        EREADY = (myHero:CanUseSpell(_E) == READY)
        RREADY = (myHero:CanUseSpell(_R) == READY)
        DFGREADY = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
        HXGREADY = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
        BWCREADY = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
        BRKREADY = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
        ZNAREADY = (znaSlot ~= nil and myHero:CanUseSpell(znaSlot) == READY)
        WGTREADY = (wgtSlot ~= nil and myHero:CanUseSpell(wgtSlot) == READY)
        IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
        HPREADY = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
        MPREADY =(mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
        FSKREADY = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
end

--------------------------------------- END OF SCRIPT ----------------------------------------------------------                

--[[ 
        AoE_Skillshot_Position 2.0 by monogato
        
        GetAoESpellPosition(radius, main_target, [delay]) returns best position in order to catch as many enemies as possible with your AoE skillshot, making sure you get the main target.
        Note: You can optionally add delay in ms for prediction (VIP if avaliable, normal else).
]]

function GetCenter(points)
        local sum_x = 0
        local sum_z = 0
        
        for i = 1, #points do
                sum_x = sum_x + points[i].x
                sum_z = sum_z + points[i].z
        end
        
        local center = {x = sum_x / #points, y = 0, z = sum_z / #points}
        
        return center
end

function ContainsThemAll(circle, points)
        local radius_sqr = circle.radius*circle.radius
        local contains_them_all = true
        local i = 1
        
        while contains_them_all and i <= #points do
                contains_them_all = GetDistanceSqr(points[i], circle.center) <= radius_sqr
                i = i + 1
        end
        
        return contains_them_all
end


function FarthestFromPositionIndex(points, position)
        local index = 2
        local actual_dist_sqr
        local max_dist_sqr = GetDistanceSqr(points[index], position)
        
        for i = 3, #points do
                actual_dist_sqr = GetDistanceSqr(points[i], position)
                if actual_dist_sqr > max_dist_sqr then
                        index = i
                        max_dist_sqr = actual_dist_sqr
                end
        end
        
        return index
end

function RemoveWorst(targets, position)
        local worst_target = FarthestFromPositionIndex(targets, position)
        
        table.remove(targets, worst_target)
        
        return targets
end

function GetInitialTargets(radius, main_target)
        local targets = {main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if target.networkID ~= main_target.networkID and ValidTarget(target) and GetDistanceSqr(main_target, target) < diameter_sqr then table.insert(targets, target) end
        end
        
        return targets
end

function GetPredictedInitialTargets(radius, main_target, delay)
        if VIP_USER and not vip_target_predictor then vip_target_predictor = TargetPredictionVIP(nil, nil, delay/1000) end
        local predicted_main_target = VIP_USER and vip_target_predictor:GetPrediction(main_target) or GetPredictionPos(main_target, delay)
        local predicted_targets = {predicted_main_target}
        local diameter_sqr = 4 * radius * radius
        
        for i=1, heroManager.iCount do
                target = heroManager:GetHero(i)
                if ValidTarget(target) then
                        predicted_target = VIP_USER and vip_target_predictor:GetPrediction(target) or GetPredictionPos(target, delay)
                        if target.networkID ~= main_target.networkID and GetDistanceSqr(predicted_main_target, predicted_target) < diameter_sqr then table.insert(predicted_targets, predicted_target) end
                end
        end
        
        return predicted_targets
end


function GetAoESpellPosition(radius, main_target, delay)
        local targets = delay and GetPredictedInitialTargets(radius, main_target, delay) or GetInitialTargets(radius, main_target)
        local position = GetCenter(targets)
        local best_pos_found = true
        local circle = Circle(position, radius)
        circle.center = position
        
        if #targets > 2 then best_pos_found = ContainsThemAll(circle, targets) end
        
        while not best_pos_found do
                targets = RemoveWorst(targets, position)
                position = GetCenter(targets)
                circle.center = position
                best_pos_found = ContainsThemAll(circle, targets)
        end
        
        return position, #targets
end 


--END AOE SKILLSHOT--