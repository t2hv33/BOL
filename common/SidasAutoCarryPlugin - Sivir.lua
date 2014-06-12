--[[

AutoCarry Plugin - Sivir, 1.1 by Galaxix

Thanks Kain, Skeem, Trees
        Changelog :
   1.0    - Initial Release
   1.1    - Fixed And Changed a lot of thinks.
        ]] --
           

if myHero.charName ~= "Sivir" then return end
if VIP_USER then
	require "VPrediction"
 end

function PluginOnLoad()
        mainLoad() -- Loads our Variable Function
        mainMenu() -- Loads our Menu function
        SkillQ = {spellKey = _Q, range = 1075, speed = 1.35, delay = 249, width = 101}
        end

--[Plugin OnTick]--
function PluginOnTick()
	            Checks()
                KS()
                UseConsumables()
	if IsSACReborn then
		AutoCarry.Crosshair:SetSkillCrosshairRange(1075)
	else
		AutoCarry.SkillsCrosshair.range = 1075
	end
                if Carry.AutoCarry then FullCombo() end		
                if Menu.KS then KS() end
	            if Carry.MixedMode and Target then
                if Menu.qHarass and not IsMyManaLow then CastQ(Target) end
                if Menu.wHarass and not IsMyManaLow then CastW2() end
                if Menu.LaneClear and not IsMyManaLow then 
                CastW() end
                end
                  end
				  
--[/OnTick]--

function KS()
         for i=1, heroManager.iCount do
         local enemy = heroManager:GetHero(i)
                if ValidTarget(enemy) then
                        dfgDmg, hxgDmg, bwcDmg, iDmg  = 0, 0, 0, 0
                        qDmg = getDmg("Q",enemy,myHero)
                        wDmg = getDmg("W",enemy,myHero)
                        aDmg = getDmg("AD",enemy,myHero)
            if DFGREADY then dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0) end
            if HXGREADY then hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0) end
            if BWCREADY then bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0) end
            if IREADY then iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0) end
            onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            itemsDmg = dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
         
         if Target ~= nil then
         if QREADY and Target.health <= qDmg and Menu.ks and GetDistance(Target) <= qRange then
                        CastQ(Target)
         elseif QREADY and WREADY and Target.health <= (qDmg + wDmg + aDmg) and GetDistance(Target) <= qRange then
                        CastW2()
                        CastQ(Target)
                        
                        itemsDmg = dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
                        
                                KillText[i] = 1 
                                if enemy.health <= (qDmg + wDmg + itemsDmg) then
                                KillText[i] = 2
                     end
                  end
                end
             end
         end
     end
 --end
 
--Cast W For Combo
function CastW()
if WREADY and AutoCarry.PluginMenu.useW and AutoCarry.Orbwalker:IsAfterAttack() then CastSpell(_W)
        end
end

--Cast W For Harras
function CastW2()
if WREADY and AutoCarry.PluginMenu.useW and GetDistance(Target) < 500 and AutoCarry.Orbwalker:IsAfterAttack() then CastSpell(_W)
        end
end

--[Casting our Q ]--
function CastQ(Target)
if VIP_USER then
if QREADY then
  for i, target in pairs(GetEnemyHeroes()) do
  CastPosition,  HitChance,  Position = VP:GetLineCastPosition(Target, 0.25, 101, qRange, 1350, myHero)
  if HitChance >= 2 and GetDistance(CastPosition) < 1075 then
  CastSpell(_Q, CastPosition.x, CastPosition.z)
else
if QREADY then
        AutoCarry.CastSkillshot(SkillQ, Target)
end
end
end
end
end
end
--End

-- Function OnDraw --
function OnDraw()
        --> Ranges
        if not myHero.dead then
                if QREADY and Menu.qDraw then
                        DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x191970)
                end
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
--End

function UseConsumables()
        if not InFountain() and not Recalling and Target ~= nil then
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
--[Health Pots Function]--
function NeedHP()
        if myHero.health < (myHero.maxHealth * ( Extras.HPHealth / 100)) then
                return true
        else
                return false
        end
end
--end

--[[ Combo ]]--
function FullCombo()
	if Target then
		if AutoCarry.MainMenu.AutoCarry then
                        if GetDistance(Target) <= qRange and Menu.useQ then CastQ() end
                        if GetDistance(Target) <= wRange and Menu.useW then CastW() end
                        if GetDistance(Target) <= rRange and Menu.useR then CastSpell(_R) end
		end
	end
end

--> Main Menu
function mainMenu()
        Menu:addParam("sep1", "-- Full Combo Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("useQ", "Use (Q)", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("useW", "Use (W)", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("useR", "Use (R)", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("qHarass", "Use (Q) in Mixed Mode", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("wHarass", "Use (W) in Mixed Mod ", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("qDraw", "Draw (Q)", SCRIPT_PARAM_ONOFF, false)
        Menu:addParam("cDraw", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("sep4", "-- KS Options --", SCRIPT_PARAM_INFO, "")
        Menu:addParam("KS", " Use KillSteal Function", SCRIPT_PARAM_ONOFF, true)
        Extras = scriptConfig("Sida's Auto Carry Plugin: "..myHero.charName..": Extras", myHero.charName)
                Extras:addParam("sep6", "-- Misc --", SCRIPT_PARAM_INFO, "")
                Extras:addParam("MinMana", "Minimum Mana for Harras %", SCRIPT_PARAM_SLICE, 40, 0, 100, 2)
                Extras:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
                Extras:addParam("aMP", "Auto Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
                Extras:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, 2)
                
                
 end


function Checks()
        if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
        if IsSACReborn then Target = AutoCarry.Crosshair:GetTarget(true) else Target = AutoCarry.GetAttackTarget(true) end
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
        hpReady = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
        mpReady =(mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
        fskReady = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
end

function mainLoad()
                if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
                if IsSACReborn then AutoCarry.Skills:DisableAll() end
                Menu = AutoCarry.PluginMenu
                Carry = AutoCarry.MainMenu
                pReady, mpReady, fskReady = false, false, false
                QREADY, WREADY, RREADY = false, false, false
                qRange, wRange, rRange = 1075, 500, 1000
                TextList = {"Harass him!!", "Q+W KILL!!", "FULL COMBO KILL!"}
                KillText = {}
                waittxt = {} -- prevents UI lags, all credits to Dekaron
                for i=1, heroManager.iCount do waittxt[i] = i*3 end -- All credits to Dekaron
                SkillQ = {spellKey = _Q, range = 1075, speed = 1.35, delay = 249, width = 101}
               end
               
               if VIP_USER then
		       if FileExist(SCRIPT_PATH..'Common/VPrediction.lua') then
		       PrintChat("<font color='#009999'> >> JustSivir by Galaxix VIP Version v1.1 Loaded ! <<</font>")
		       end
               else
               PrintChat("<font color='#009900'> >> JustSivir by Galaxix v1.1 Loaded ! <<</font>")
               end