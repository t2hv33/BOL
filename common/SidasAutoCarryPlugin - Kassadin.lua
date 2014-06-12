--  ____  __.                                 .___.__         __________.__               .__         --
-- |    |/ _|____    ______ ___________     __| _/|__| ____   \______   \  |  __ __  ____ |__| ____   --
-- |      < \__  \  /  ___//  ___/\__  \   / __ | |  |/    \   |     ___/  | |  |  \/ ___\|  |/    \  --
-- |    |  \ / __ \_\___ \ \___ \  / __ \_/ /_/ | |  |   |  \  |    |   |  |_|  |  / /_/  >  |   |  \ --
-- |____|__ (____  /____  >____  >(____  /\____ | |__|___|  /  |____|   |____/____/\___  /|__|___|  / --
--         \/    \/     \/     \/      \/      \/         \/                      /_____/         \/  --
--                                                  Generated with: http://patorjk.com/software/taag/ --
--              ____   ____    .__    .___  __      __        .__   __                                --
--              \   \ /   /___ |__| __| _/ /  \    /  \_____  |  | |  | __ ___________                --
--               \   Y   /  _ \|  |/ __ |  \   \/\/   /\__  \ |  | |  |/ // __ \_  __ \               --
--                \     (  <_> )  / /_/ |   \        /  / __ \|  |_|    <\  ___/|  | \/               --
--                 \___/ \____/|__\____ |    \__/\  /  (____  /____/__|_ \\___  >__|                  --
--                                     \/         \/        \/          \/    \/                      --
--                                                                                                    --
--                                                                                                    --
--  Features:                                                                                         --
--         - Auto Carry Mode:                                                                         --
--                - Customizable Combo                                                                --
--                       Smartly uses R (Enable "Use R As A Gap Closer")                              --
--                              If Target is not in R range, will cast R towards target to get in     --
--                              range to be able to cast Q.                                           --
--                              If Target is in R range, will cast R ontop of the Target.             --
--                       Casts Q to damage and silence the Target.                                    --
--                       Casts W if in Auto Attack range.                                             --
--                       Casts E if ready and in range to maximize damage.                            --
--         - Mixed Mode:                                                                              --
--                - If Target is in range and harass mode enabled, Kassadin will harass with Q.       --
--         - Last Hit & Lane Clear:                                                                   --
--                - Will last hit with Q if enabled.                                                  --
--                - Will cast W before attacking if enabled.                                          --
--                - Will clear lane with E if enabled.                                                --
--         - Misc:                                                                                    --
--                - Cancel Blitz Grabs                                                                --
--                        If you get pulled by a Blitzcrank then Kassadin will use R to escape.       --
--                - Auto Silence Channelled Spells                                                    --
--                        If an enemy casts a channelled spell in range then you will cast Q on them  --
--                                                                                                    --
--         - Shift Menu:                                                                              --
--                - [Cast Options]                                                                    --
--                       -  Auto Cast [KEY]                                                           --
--                              - Will cast desired spell if toggled on.                              --
--                       -  Use R As A Gap Closer                                                     --
--                              - If out of range to cast Q, Kassadin will cast R to gain ground.     --
--                - [Kill Steal Options]                                                              --
--                       - Auto Kill Steal                                                            --
--                       - Use R (Extra DMG/Gap Closer)                                               --
--                              - If out of range to cast Q then Kassadin will cast R to gain ground. --
--                              - If in range to cast Q then Kassadin will cast R for extra damage.   --
--                              - If in range to cast Q and killable, Kassadin will use R to KS.      --
--                - [Misc Options]                                                                    --
--                       - Cancel Blitz Grabs                                                         --
--                              - If a Blitzcrank grabs you then you will instantly use R away        --
--                       - Minimum Mana to Farm/harass                                                --
--                              - Using percentages, Kassadin will not cast to Farm/harass unless     --
--                                his mana percentage is greater than this.                           --
--                       - Cast R if enemies > This value                                             --
--                              - If the amount of enemies is greater than the value it will not use R--
--                       - Auto Silence Channelled Spells                                             --
--                              - Will auto silence channelled spells for more control                --
--                - [Harras Options]                                                                  --
--                       - Auto harass w/ Q                                                           --
--                              - If Kassadin's mana is greater than Minimum Mana then he will harass --
--                                with Q.                                                             --
--                       -  Use R As A Gap Closer                                                     --
--                              - If out of range to cast Q, Kassadin will cast R to gain ground.     --
--                - [Farm Options]                                                                    --
--                       - Auto Farm w/ Q                                                             --
--                              - If Kassadin's mana is greater than Minimum Mana then he will farm   --
--                                with Q.                                                             --
--                       - Auto Cast E before farming                                                 --
--                              - If Kassadin's mana is greater than Minimum Mana then he will cast   --
--                                E before attacking.                                                 --
--                       - Auto Clear Lane w/ E                                                       --
--                              - If Kassadin's mana is greater than Minimum Mana then he will farm   --
--                                with E.                                                             --
--  Change Log:                                                                                       --
--         - The Void Walker, Chapter 1                                                               --
--                - Release of the plugin                                                             --
--         - The Void Walker, Chapter 2                                                               --
--                - Added a check to see if target is dead or not.                                    --
--         - The Void Walker, Chapter 3                                                               --
--                - Will attempt to kill steal with R if in range.                                    --
--                - Added an option to not cast R if X amount of enemies are in range.                --
--                - Farm with E (Lane Clear mode only).                                               --
--                - Added option to use W when last hitting (increased damage).                       --
--                - Will silence channelled spells (Only if they casted in range first).              --
--                                                                                                    --
--                                                                                                    --
--                                                                                                    --
--                                                                                                    --
--                                                                                                    --
--                                                                                                    --
--                                                                                                    --
--                                                                                                    --
 
local blitzChamp = nil
local grabbed = false
local grab = nil
local BCTConfig = nil
 
for i = 1, heroManager.iCount, 1 do
        local enemy = heroManager:getHero(i)
        if enemy.team ~= player.team and enemy.charName == "Blitzcrank" then
                blitzChamp = enemy
        end
end
 
function PluginOnTick()
AntiPull()
if Menu.AutoLVL then
levelSequence = {1,2,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2}
autoLevelSetSequence(levelSequence)
end
Target = AutoCarry.GetAttackTarget()
        SkillHandler()
        if Menu.GCR then
                GCRange = (qRange + rRange - 50)
                else
                GCRange = 700
        end
        AutoCarry.SkillsCrosshair.range = GCRange
        -- Farm Core --
        if Menu.FarmQ and (Menu2.LastHit or Menu2.LaneClear) and (myHero.mana / myHero.maxMana) > Menu.MinMana then
            for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if ValidTarget(minion) and QREADY and GetDistance(minion) <= qRange then
					if minion.health < getDmg("Q", minion, myHero) then
						CastSpell(_Q, minion)
					end
				end
			end
        end
		if Menu.FarmW and (Menu2.LastHit or Menu2.MixedMode or Menu2.LaneClear) and (myHero.mana / myHero.maxMana) > Menu.MinMana then
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if ValidTarget(minion) and WREADY and GetDistance(minion) <= wRange then
					if minion.health < (getDmg("W", minion, myHero) + myHero:CalcDamage(minion, myHero.addDamage+myHero.damage)) and GetDistance(minion) < wRange then
						CastSpell(_W)
					end
				end
			end
		end
		if Menu.FarmE and (Menu2.LaneClear) and (myHero.mana / myHero.maxMana) > Menu.MinMana then
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if ValidTarget(minion) and EREADY and GetDistance(minion) <= eRange then
					if minion.health < getDmg("E", minion, myHero) then
						CastSpell(_E, minion)
					end
				end
			end
		end
        -- End of Farm Core --
        if Target and not Target.dead then
                -- Harass Core --
                if Menu2.MixedMode then
                        if Menu.harassQ then
                                if QREADY and GetDistance(Target) < qRange and (myHero.mana / myHero.maxMana) > Menu.MinMana then
                                        CastSpell(_Q, Target)
                                end
                        if Menu.harassQR and QREADY and RREADY and CountEnemyHeroInRange(GCRange) <= Menu.rCount then
                                        ComboMana = qMana + rMana
                                        if ComboMana <= myMana then
                                                if GetDistance(Target) > 650 then
                                                        alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                                                        locX = math.cos(alpha)*(GetDistance(Target) - (qRange - 15))
                                                        locZ = math.sin(alpha)*(GetDistance(Target) - (qRange - 15))
                                                        CastSpell(_R, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
                                                end
                                        end
                                end    
                        end
                end
                -- End of harass Core --
                if Target.charName == "Kassadin" then
                qDmg = (getDmg("Q", Target,myHero)*0.85)
                eDmg = (getDmg("E", Target,myHero)*0.85)
                rDmg = (getDmg("R", Target,myHero)*0.85)
                else
                qDmg = getDmg("Q", Target,myHero)
                eDmg = getDmg("E", Target,myHero)
                rDmg = getDmg("R", Target,myHero)
                end
                -- Combo Core --
                if Menu2.AutoCarry then
                        if QREADY and Menu.AutoQ and GetDistance(Target) < qRange then
                                CastSpell(_Q, Target)
                        end
                        if RREADY and Menu.AutoR and Menu.GCR and GetDistance(Target) > 640 and CountEnemyHeroInRange(GCRange) <= Menu.rCount then
                                alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                                locX = math.cos(alpha)*700
                                locZ = math.sin(alpha)*700
                                CastSpell(_R, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
                        end
                        if RREADY and Menu.AutoR and GetDistance(Target) < rRange then
                                Cast(SkillR, Target)
                        end
                        if WREADY and Menu.AutoW and GetDistance(Target) < wRange then
                                CastSpell(_W)
                        end
                        if EREADY and Menu.AutoE and GetDistance(Target) < eRange then
                                CastSpell(_E, Target.x, Target.z)
                        end
                end
                -- End Of Combo Core --
               
                -- Kill Stealing Core --
                if Menu.KS then
                        if QREADY then
                                if qDmg >= Target.health then
                                        if GetDistance(Target) < 650 then
                                                CastSpell(_Q, Target)
                                        end
                                end
                        end
                        if Menu.KSr then
                                if QREADY and RREADY and CountEnemyHeroInRange(GCRange) <= Menu.rCount then
                                        ComboMana = qMana + rMana
                                        if ComboMana <= myMana and qDmg >= (Target.health - 50)  then
                                                if GetDistance(Target) > 650 then
                                                        alpha = math.atan(math.abs(Target.z-myHero.z)/math.abs(Target.x-myHero.x))
                                                        locX = math.cos(alpha)*(GetDistance(Target) - (qRange - 15))
                                                        locZ = math.sin(alpha)*(GetDistance(Target) - (qRange - 15))
                                                        CastSpell(_R, math.sign(Target.x-myHero.x)*locX+myHero.x, math.sign(Target.z-myHero.z)*locZ+myHero.z)
                                                end
                                        end
                                end    
                        end
                        if Menu.KSr then
                                if QREADY and RREADY and CountEnemyHeroInRange(GCRange) <= Menu.rCount then
                                        ComboMana = qMana + rMana
                                        if ComboMana <= myMana and (qDmg + rDmg) >= (Target.health - 50)  then
                                                if GetDistance(Target) < 650 then
                                                        Cast(SkillR, Target)
                                                end
                                        end
                                end    
                        end
						if Menu.KSr then
                                if RREADY and CountEnemyHeroInRange(GCRange) <= Menu.rCount and not QREADY then
                                        ComboMana = rMana
                                        if ComboMana <= myMana and (rDmg) >= (Target.health - 15)  then
                                                if GetDistance(Target) < rRange then
                                                        Cast(SkillR, Target)
                                                end
                                        end
                                end    
                        end
                end
                -- End of Kill Stealing Core --
       
        end
end
function PluginOnLoadMenu()
        Menu = AutoCarry.PluginMenu
        Menu2 = AutoCarry.MainMenu
        Menu:addParam("sep", "[Cast Options]", SCRIPT_PARAM_INFO, "")
        Menu:addParam("sep1", "[Combo Options]", SCRIPT_PARAM_INFO, "")
        Menu:addParam("AutoQ", "Auto Cast Q", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("AutoW", "Auto Cast W", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("AutoE", "Auto Cast E", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("AutoR", "Auto Cast R", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("GCR", "Use R As A Gap Closer           [A]", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("A"))
        Menu:permaShow("sep")
        Menu:permaShow("GCR")
		
        Menu:addParam("gap", "", SCRIPT_PARAM_INFO, "")
        Menu:addParam("sep2", "[Kill Steal Options]", SCRIPT_PARAM_INFO, "")
        Menu:addParam("KS", "Auto Kill Steal (w/ Q)              [T]", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("T"))
        Menu:addParam("KSr", "Use R (Extra DMG/Gap Closer)", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("A"))
        Menu:permaShow("sep2")
        Menu:permaShow("KS")
		
        Menu:addParam("gap1", "", SCRIPT_PARAM_INFO, "")
        Menu:addParam("sep3", "[Misc Options]", SCRIPT_PARAM_INFO, "")
        Menu:addParam("Cancelblitzgrabs", "Cancel Blitz Grabs", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("AutoLVL", "Auto Level Spells", SCRIPT_PARAM_ONOFF, false)
		Menu:addParam("rCount", "Cast R if enemies > This value", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		Menu:addParam("AutoSQ", "Auto Silence Channelled Spell", SCRIPT_PARAM_ONOFF, true) 
        Menu:addParam("MinMana", "Minimum Mana to Farm/harass", SCRIPT_PARAM_SLICE, 0.4, 0.1, 0.9, 1)
		
		Menu:addParam("gap2", "", SCRIPT_PARAM_INFO, "")
		Menu:addParam("sep4", "[Harras Options]", SCRIPT_PARAM_INFO, "")
        Menu:addParam("harassQ", "Auto harass w/ Q", SCRIPT_PARAM_ONOFF, true)
        Menu:addParam("harassQR", "Use R as a Gap Closer to harass", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("A"))
		
		Menu:addParam("gap3", "", SCRIPT_PARAM_INFO, "")
		Menu:addParam("sep4", "[Farm Options]", SCRIPT_PARAM_INFO, "")
        Menu:addParam("FarmQ", "Auto Farm w/ Q", SCRIPT_PARAM_ONOFF, false)
		Menu:addParam("FarmW", "Auto Cast W before farming", SCRIPT_PARAM_ONOFF, false)
		Menu:addParam("FarmE", "Auto Clear Lane w/ E", SCRIPT_PARAM_ONOFF, false)
		Menu:permaShow("sep3")
        Menu:permaShow("Cancelblitzgrabs")
end
function PluginOnLoad()
PluginOnLoadMenu()
ChatPrinting()
LastCast = nil
end
function SkillHandler()
Cast = AutoCarry.CastSkillshot
qRange = 650
wRange = getMyTrueRange()
eRange = 700
rRange = 700
GCRange = 700
SkillE = {spellKey = _R, range = 700, speed = 1.0, delay = 250, width = 100}
SkillR = {spellKey = _R, range = 700, speed = 1.0, delay = 250, width = 125}
QREADY = (myHero:GetSpellData(_Q).level > 0 and myHero:CanUseSpell(_Q) == READY )
WREADY = (myHero:GetSpellData(_W).level > 0 and myHero:CanUseSpell(_W) == READY )
EREADY = (myHero:GetSpellData(_E).level > 0 and myHero:CanUseSpell(_E) == READY )
RREADY = (myHero:GetSpellData(_R).level > 0 and myHero:CanUseSpell(_R) == READY )
myMana = (myHero.mana)
qMana = myHero:GetSpellData(_Q).mana
wMana = myHero:GetSpellData(_W).mana
eMana = myHero:GetSpellData(_E).mana
rMana = myHero:GetSpellData(_R).mana
end
function PluginOnCreateObj(object)
if object ~= nil and object.name == "Kassadin_Netherblade.troy" then wActive = true end
        if object.name:find("FistGrab") then
        grabbed = true
        grab = object
    end
end
function PluginOnDeleteObj(object)
if object ~= nil and object.name == "Kassadin_Netherblade.troy" then wActive = false end
    if object.name:find("FistGrab") then
        grabbed = false
        grab = nil
    end
end

function getMyTrueRange()
        return myHero.range + GetDistance(myHero, myHero.minBBox)
end
function math.sign(x)
 if x < 0 then
  return -1
 elseif x > 0 then
  return 1
 else
  return 0
 end
end
function AntiPull()
if Menu.Cancelblitzgrabs and grab ~= nil and grab:GetDistance(myHero) < 500 then
                -- "Jumping" twice the distance between blitz and you
                if myHero.charName == "" then --Leblanc
                        -- Compute the 90 degrees to better dodge with LB
                        destX = myHero.x * 4 - blitzChamp.x*3
                        destZ = myHero.z * 4  - blitzChamp.z*3
                        CastSpell(_W, destX, destZ)
                else
                        -- Check if the grab is actually going to hit or not (i.e if it is between you and blitz)
                        if math.abs((myHero.x-blitzChamp.x) * (grab.z - blitzChamp.z) - (myHero.z-blitzChamp.z) *                       (grab.x - blitzChamp.x)) < 39000 then
                                destX = myHero.x * 4 - blitzChamp.x*3
                                destZ = myHero.z * 4  - blitzChamp.z*3
                                if myHero.charName == "Kassadin" then
                                        CastSpell(_R, destX, destZ)
                                end
                        end
                end            
        end
end
function ChatPrinting()
PrintChat("<font color='#C80046'>K</font><font color='#C70027'>a</font><font color='#C80005'>s</font><font color='#C71C00'>s</font><font color='#C83900'>a</font><font color='#C75400'>d</font><font color='#C86D00'>i</font><font color='#C88800'>n</font><font color='#C7A400'> </font><font color='#C7C500'>P</font><font color='#A8C800'>l</font><font color='#88C800'>u</font><font color='#6AC700'>g</font><font color='#4BC800'>i</font><font color='#2AC800'>n</font><font color='#04C700'> </font><font color='#00C822'>-</font><font color='#00C744'> </font><font color='#00C863'>C</font><font color='#00C781'>r</font><font color='#00C8A0'>e</font><font color='#00C8C2'>a</font><font color='#00ABC8'>t</font><font color='#008EC8'>e</font><font color='#0073C8'>d</font><font color='#005AC7'> </font><font color='#003FC7'>b</font><font color='#0023C8'>y</font><font color='#0002C8'> </font><font color='#2000C8'>P</font><font color='#3F00C8'>a</font><font color='#5D00C8'>i</font><font color='#7C00C8'>n</font><font color='#9D00C8'>.</font>")
PrintChat("<font color='#C80046'>G</font><font color='#C8002D'>r</font><font color='#C80013'>e</font><font color='#C80900'>a</font><font color='#C82300'>t</font><font color='#C83A00'> </font><font color='#C75000'>C</font><font color='#C86500'>r</font><font color='#C87A00'>e</font><font color='#C79000'>d</font><font color='#C8A700'>i</font><font color='#C8C200'>t</font><font color='#B1C800'>s</font><font color='#97C800'> </font><font color='#7EC800'>t</font><font color='#66C800'>o</font><font color='#4DC800'> </font><font color='#33C800'>R</font><font color='#15C800'>a</font><font color='#00C70A'>v</font><font color='#00C829'>e</font><font color='#00C744'>n</font><font color='#00C75D'>/</font><font color='#00C776'>V</font><font color='#00C88E'>i</font><font color='#00C8A8'>k</font><font color='#00C8C3'>t</font><font color='#00B0C7'>o</font><font color='#0097C8'>r</font><font color='#0081C8'> </font><font color='#006CC7'>f</font><font color='#0057C7'>o</font><font color='#0042C8'>r</font><font color='#002BC8'> </font><font color='#0012C8'>t</font><font color='#0900C8'>e</font><font color='#2400C8'>s</font><font color='#3D00C8'>t</font><font color='#5600C8'>i</font><font color='#6E00C8'>n</font><font color='#8800C8'>g</font><font color='#A400C8'>.</font>")
end
function PluginBonusLastHitDamage(minion)
if wActive then
return (getDmg("W", minion, myHero) + myHero:CalcDamage(minion, myHero.addDamage+myHero.damage)) --myHero:CalcMagicDamage(minion, math.floor((myHero.ap * 0.3) * minion.maxHealth)) + myHero:CalcDamage(minion, myHero.addDamage+myHero.damage) and GetDistance(minion)
end
end
local ToStun = false
local charStun = false
 
local stunSpells = {}
local spellsToStun = {}
champsCanStun = {
{ charName = "Kassadin",        spellSlot = _Q, spellRange = 650,  interrupttype = 0, interrupt = 0}, }
champsToStun = {
                --Important, how lower the number, how important it is to interrupt
                { charName = "Katarina",        spellName = "KatarinaR" ,                  important = 0},
                { charName = "Galio",           spellName = "GalioIdolOfDurand" ,          important = 0},
                { charName = "FiddleSticks",    spellName = "Crowstorm" ,                  important = 1},
                { charName = "FiddleSticks",    spellName = "DrainChannel" ,               important = 1},
                { charName = "Nunu",            spellName = "AbsoluteZero" ,               important = 0},
                { charName = "Shen",            spellName = "ShenStandUnited" ,            important = 0},
                { charName = "Urgot",           spellName = "UrgotSwap2" ,                 important = 0},
                { charName = "Malzahar",        spellName = "AlZaharNetherGrasp" ,         important = 0},
                { charName = "Karthus",         spellName = "FallenOne" ,                  important = 0},
                { charName = "Pantheon",        spellName = "Pantheon_GrandSkyfall_Jump" , important = 0},
                { charName = "Varus",           spellName = "VarusQ" ,                     important = 1},
                { charName = "Caitlyn",         spellName = "CaitlynAceintheHole" ,        important = 1},
                { charName = "MissFortune",     spellName = "MissFortuneBulletTime" ,      important = 1},
                { charName = "Warwick",         spellName = "InfiniteDuress" ,             important = 0}
}
local k = 1;
for i,champCanStun in pairs(champsCanStun) do
  if (myHero.charName == champCanStun.charName) then
                charStun = true;
                stunSpells[k] = { spellSlot = champCanStun.spellSlot, spellRange = champCanStun.spellRange,  interrupttype = champCanStun.interrupttype, interrupt = champCanStun.interrupt}
                k= k+1
  end
end
if charStun == false then return end
local l = 1
for i,champToStun in pairs(champsToStun) do
    for i=1, heroManager.iCount do
        local enemy = heroManager:GetHero(i)
        if enemy.team ~= myHero.team and (enemy.charName == champToStun.charName) then
            spellsToStun[l] = { spell = champToStun.spellName, important = champToStun.important }
            l=l+1
            ToStun = true
        end
    end
end
if ToStun == false then return end
function PluginOnProcessSpell(unit, spell)
local spellName = spell.name
        if (unit and unit.team ~= myHero.team and unit.dead == false) then
            for i,spellToStun in pairs(spellsToStun) do
                if(spellName == spellToStun.spell) and Menu.AutoSQ then
                    for i,stunSpell in pairs(stunSpells) do
                        if (CanUseSpell(stunSpell.spellSlot) == READY and GetDistance(unit) < stunSpell.spellRange) then
                            if((stunSpell.interrupt == 0) or (stunSpell.interrupt == 1 and spellToStun.important == 0)) then
                                if (stunSpell.interrupttype == 0) then
                                    CastSpell(stunSpell.spellSlot, unit)
                                    return
                                elseif (stunSpell.interrupttype == 1) then
                                    CastSpell(stunSpell.spellSlot, unit.x, unit.z)
                                    return
                                elseif (stunSpell.interrupttype == 2) then
                                    CastSpell(stunSpell.spellSlot)
                                    return
                                elseif (stunSpell.interrupttype == 3) then
                                    CastSpell(stunSpell.spellSlot)
                                    player:Attack(unit)
                                    return
                                elseif (stunSpell.interrupttype == 4) then
                                    CastSpell(stunSpell.spellSlot, unit.x, unit.z)
                                    CastSpell(stunSpell.spellSlot)
                                    return
                                elseif (stunSpell.interrupttype == 5) then
                                    local stunLoc = getELoc(unit, stunSpell.spellRange)
                                    CastSpell(stunSpell.spellSlot, stunLoc.x, stunLoc.z)
                                end
                            end
                        end
                    end
                end
            end
        end
end
function getELoc(target, range)
    myLoc = Vector(myHero.x, myHero.y, myHero.z)
    targetLoc = Vector(target.x, target.y, target.z)
    stunLoc = Vector(targetLoc) + (Vector(targetLoc)-Vector(myLoc)):normalized()*375
    if GetDistance(stunLoc) < range then return stunLoc end
    stunLoc = Vector(targetLoc) - (Vector(targetLoc)-Vector(myLoc)):normalized()*375
    return stunLoc
end