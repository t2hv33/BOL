local version = "1.0"

     
--[[
		Rengar - BomD
		Author: BomD
		Version: 1.00
		Copyright 2014
			
		Dependency: Standalone
--]]
---------------
if myHero.charName ~= "Rengar" then return end
_G.UseUpdater = false
local REQUIRED_LIBS = {
	["SOW"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua"
}
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#FF0000\">Rengar - The Pridestalker:</font></b> <font color=\"#FFFFFF\">Thư viện yêu cầu đã download xong, ấn F9 2 lần để áp dụng.</font>")
	end
end



for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

if DOWNLOADING_LIBS then return end

local UPDATE_NAME = "Rengar - The Pridestalker"
local UPDATE_HOST = "draconis.cuccfree.org"
local UPDATE_PATH = "/Ahri%20-%20the%20Nine-Tailed%20Fox.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH..UPDATE_NAME..".lua"
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<b><font color=\"#FF0000\">"..UPDATE_NAME..":</font></b> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.UseUpdater then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available"..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

------------------------------------------------------
--			 Callbacks				
------------------------------------------------------


function OnLoad()
	print("<b><font color=\"#FF0000\">Rengar - Thú Săn Mồi Kiêu Hãnh:</font></b> <font color=\"#FFFFFF\">To night we hunt!</font>")
	Variables()
	Menu()
	PriorityOnLoad()
end

function OnTick()
	ComboKey = Settings.combo.comboKey
	HarassKey = Settings.harass.harassKey
	JungleClearKey = Settings.jungle.jungleKey
	
	if ComboKey then
		Combo(Target)
	end
	
	if HarassKey then
		Harass(Target)
	end
	
	if JungleClearKey then
		JungleClear()
	end
	
	if Settings.ks.killSteal then
		KillSteal()
	end

	Checks()
end

function OnDraw()
	if not myHero.dead and not Settings.drawing.mDraw then
		if SkillQ.ready and Settings.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, 0xCE00FF)
		end
		if SkillW.ready and Settings.drawing.wDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, 0xCE00FF)
		end
		if SkillE.ready and Settings.drawing.eDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, 0xCE00FF)
		end
		
		if Settings.drawing.Target and Target ~= nil then
			DrawCircle(Target.x, Target.y, Target.z, 70, 0xCE00FF)
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, 550, 0xFF0000)
		end
	end
end
------------------------------------------------------
--			 Functions				
------------------------------------------------------

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if Settings.combo.comboItems then
			UseItems(unit)
		end
		
		if Settings.combo.useR then CastR(unit) end
		CastE(unit)
		CastQ(unit)
		CastW(unit)
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if Settings.harass.useQ then CastQ(unit) end
		if Settings.harass.useQ then CastW(unit) end
		if Settings.harass.useE then CastE(unit) end
	end
end

function JungleClear()
	if Settings.jungle.jungleKey then
		local JungleMob = GetJungleMob()
		
		if JungleMob ~= nil then
			if Settings.jungle.jungleQ and GetDistance(JungleMob) <= SkillQ.range then
				CastSpell(_Q)
			end
			if Settings.jungle.jungleW and GetDistance(JungleMob) <= SkillW.range then
				CastSpell(_W)
			end
			if Settings.jungle.jungleE and GetDistance(JungleMob) <= SkillE.range then
				CastSpell(_E)
			end
		end
	end
end


function CastQ(unit)
	if SkillW.ready and GetDistance(unit) <= SkillQ.range then
		CastSpell(_Q)
	end
end

function CastW(unit)
	if SkillW.ready and GetDistance(unit) <= SkillW.range then
		CastSpell(_W)
	end
end

function CastE(unit)
	if unit ~= nil and GetDistance(unit) <= SkillE.range and SkillE.ready then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillE.delay, SkillE.width, SkillE.range, SkillE.speed, myHero, true)
			
		if HitChance >= 2 then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

function KillSteal()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", enemy, myHero)
		wDmg = getDmg("W", enemy, myHero)
		eDmg = getDmg("E", enemy, myHero)
		
		if ValidTarget(enemy) and enemy.visible then
			if enemy.health <= qDmg then
				CastQ(enemy)
			elseif enemy.health <= qDmg + wDmg then
				CastW(enemy)
				CastQ(enemy)	
			elseif enemy.health <= wDmg then
				CastW(enemy)
			elseif enemy.health <= qDmg + eDmg then
				CastE(enemy)
				CastQ(enemy)
			elseif enemy.health <= eDmg then
				CastE(enemy)
			end

			if Settings.ks.autoIgnite then
				AutoIgnite(enemy)
			end
		end
	end
end



function AutoIgnite(unit)
	if ValidTarget(unit, Ignite.range) and unit.health <= 50 + (20 * myHero.level) then
		if Ignite.ready then
			CastSpell(Ignite.slot, unit)
		end
	end
end

------------------------------------------------------
--			 Checks, menu & stuff				
------------------------------------------------------
function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)
	
	if myHero:GetSpellData(SUMMONER_1).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_2
	end
	
	Ignite.ready = (Ignite.slot ~= nil and myHero:CanUseSpell(Ignite.slot) == READY)
	
	TargetSelector:update()
	Target = TargetSelector.target
	jSOW:ForceTarget(Target)
end

function Menu()
	Settings = scriptConfig("Rengar - The Pridestalker "..version.."", "DraconisAhri")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		--Settings.combo:addParam("useR", "Use "..SkillR.name.." (R) in Combo", SCRIPT_PARAM_LIST, 1, { "To mouse", "Toward enemy", "Don't use"})
		Settings.combo:addParam("comboItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
		--Settings.combo:addParam("requireE", "Require "..SkillE.name.." as first", SCRIPT_PARAM_ONOFF, false)
		Settings.combo:permaShow("comboKey")
	
	Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
		Settings.harass:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		Settings.harass:addParam("useQ", "Use "..SkillQ.name.." (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useE", "Use "..SkillE.name.." (E) in Harass", SCRIPT_PARAM_ONOFF, true)
		--Settings.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.harass:permaShow("harassKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
		Settings.jungle:addParam("jungleKey", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.jungle:addParam("jungleQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:permaShow("jungleKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks")
		Settings.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Settings.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		Settings.ks:permaShow("killSteal")
			
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("wDraw", "Draw "..SkillW.name.." (W) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("eDraw", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		jSOW:LoadToMenu(Settings.Orbwalking)
	
	TargetSelector = TargetSelector(TARGET_LESS_CAST, SkillE.range, DAMAGE_MAGIC, true)
	TargetSelector.name = "Rengar"
	Settings:addTS(TargetSelector)
	
end


------------
	 
    local target
     
    -- spells
    local qReady
    local qCooldown
     
    local wReady
    local wCooldown
    local wRange = 475
     
    local eReady
    local eCooldown
    local eRange = 1000
     
    local rReady
    local rCooldown
     
     
    local DoingTripleQ = false
    local qTime = 0
     
    -- items
    local BWCSlot, HXGSlot, BRKSlot, SheenSlot, TrinitySlot, LBSlot, RSHSlot, TMTSlot, STDSlot = nil, nil, nil, nil, nil, nil, nil, nil, nil
    local BWCREADY, HXGREADY, BRKREADY, RSHREADY, TMTREADY, STDREADY, IREADY = false, false, false, false, false, false, false
     
     
    --Damage calcs + draw
    local floattext = {"Hard Kill", "Medium Kill", "Easy Kill"}
    local killable = {}
    local waittxt = {}
     
     

--	 
	 
    function PluginOnLoad()
            AutoCarry.SkillsCrosshair.range = 525
            AutoCarry.PluginMenu:addParam("Combo", "Use Main Combo With Auto Carry", SCRIPT_PARAM_ONOFF, true)
            AutoCarry.PluginMenu:addParam("EmpPriority", "Empowered priority:1=Q 2=W 3=E", SCRIPT_PARAM_SLICE, 1, 1, 3, 0)
            AutoCarry.PluginMenu:addParam("TrowE", "Range to throw E in main combo", SCRIPT_PARAM_SLICE, 250, 1, 525, 0)
            AutoCarry.PluginMenu:addParam("ForceE", "Force E at 4 fury when cooldowns", SCRIPT_PARAM_ONOFF, true)
            AutoCarry.PluginMenu:addParam("TripleQ", "Use TrippleQ with Auto Carry", SCRIPT_PARAM_ONKEYTOGGLE, false, 219) -- '['
            AutoCarry.PluginMenu:addParam("Harass", "Use Harass With Mixed Mode", SCRIPT_PARAM_ONOFF, true)
            AutoCarry.PluginMenu:addParam("eHarass", "Use E in harass", SCRIPT_PARAM_ONOFF, true)  
            AutoCarry.PluginMenu:addParam("wHarass", "Use W in harass", SCRIPT_PARAM_ONOFF, false)
            AutoCarry.PluginMenu:addParam("KillSteal", "Killsteal with E or W", SCRIPT_PARAM_ONOFF, true)
            for i=1, heroManager.iCount do
            waittxt[i] = i*3
        end
    end
     
    function PluginOnTick()
     
            target = AutoCarry.GetAttackTarget()
            CheckCooldowns()
     
           
            if AutoCarry.PluginMenu.TripleQ and myHero.mana < 4 and DoingTripleQ == false then
                    --PrintChat("Not enough Fury, Triple Q DISABLED")
                    AutoCarry.PluginMenu.TripleQ = false
            end
           
            if AutoCarry.PluginMenu.TripleQ and rCooldown and DoingTripleQ == false then
                    --PrintChat("Your ult is on cooldown. Triple Q DISABLED")
                    AutoCarry.PluginMenu.TripleQ = false
            end    
           
            if AutoCarry.PluginMenu.TripleQ and qCooldown and DoingTripleQ == false then
                    --PrintChat("Your Q is on cooldown. Triple Q DISABLED")
                    AutoCarry.PluginMenu.TripleQ = false
            end    
                   
           
            if AutoCarry.PluginMenu.Combo and AutoCarry.MainMenu.AutoCarry and AutoCarry.PluginMenu.TripleQ == false then
                    Combo()
            end
           
            if AutoCarry.PluginMenu.TripleQ and AutoCarry.PluginMenu.Combo and AutoCarry.MainMenu.AutoCarry then
                    TripleQ()
            end    
     
            if AutoCarry.PluginMenu.Harass and AutoCarry.MainMenu.MixedMode then
                    Harass()
            end    
            if AutoCarry.PluginMenu.KillSteal then
                    KillStealEW()
            end
     
     
            if tick == nil or GetTickCount()-tick >= 100 then
                    tick = GetTickCount()
                    CalculateDamage()
            end
			if DoingTripleQ == false then
				AutoCarry.CanAttack = true
			end
    end
     
    function Combo()
     
            if target ~= nil then
           
            if myHero.mana <= 4 then
                            if qReady and pActive and GetDistance(target) <= 250 then
                                    CastSpell(_Q)
                            end
                            if qReady and not pActive and GetDistance(target) <= 250 then
                                    CastSpell(_Q)
                            end
                   
                            if wReady and qCooldown and GetDistance(target) <= wRange then
                                    CastSpell(_W)
                            end
                            if wReady and GetDistance(target) >= 150 and GetDistance(target) <= wRange then
                                    CastSpell(_W)
                            end
                           
                            if eReady and GetDistance(target) <= 1000 and GetDistance(target) >= AutoCarry.PluginMenu.TrowE then
                                    CastSpell(_E, target)
                            end
                            if myHero.mana == 4 and eReady and qCooldown and wCooldown and AutoCarry.PluginMenu.ForceE then
                                    CastSpell(_E, target)
                            end    
                           
                    end    
     
                    if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 1 and GetDistance(target) <= 300 then
                            CastSpell(_Q)
                    end
                    if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 2 and GetDistance(target) <= wRange then
                            CastSpell(_W)
                    end
                    if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 3 and GetDistance(target) <= eRange then
                            CastSpell(_E, target)
                    end
                   
                    if STDREADY then CastSpell(STDSlot, target) end
                    if BRKREADY then CastSpell(BRKSlot, target) end
                    if BWCREADY then CastSpell(BWCSlot, target) end
                    if GetDistance(target) <= 380 and TMTREADY then CastSpell(TMTSlot) end
                    if GetDistance(target) <= 380 and RSHREADY then CastSpell(RSHSlot) end 
                    if HXGREADY then CastSpell(HXGSlot, target) end        
                   
            end            
     
    end
     
     
    function TripleQ()
           
                    if myHero.mana == 4 and rReady then
                           
                            if qReady and rReady then
                                   
                                    AutoCarry.CanAttack = false
                                    CastSpell(_Q)
                                    CastSpell(_R)
                                   
                                    qTime = os.clock()
                                                                   
                                    DoingTripleQ = true
                                                                   
                            end    
                    end
           
           
                    if myHero.mana == 5 and rReady then
                           
                           
                            if qReady and rReady then
                                   
                                    AutoCarry.CanAttack = false
                                    CastSpell(_Q)
                                    CastSpell(_R)
     
                                    qTime = os.clock()
                                                                   
                                    DoingTripleQ = true
                            end    
                    end
           
                   
                    if rReady == false and os.clock() - qTime > 3.75 and DoingTripleQ == true then
                           
                            AutoCarry.CanAttack = true
								if ValidTarget(target) then
                                    if qReady and os.clock() - qTime > 4.25 then
                                            CastSpell(_Q)
                                    end
                                    if GetDistance(target) <= 350 then     
                                            if STDREADY then CastSpell(STDSlot, target) end
                                            if BRKREADY then CastSpell(BRKSlot, target) end
                                            if BWCREADY then CastSpell(BWCSlot, target) end
                                            if TMTREADY then CastSpell(TMTSlot) end
                                            if RSHREADY then CastSpell(RSHSlot) end
                                            if HXGREADY then CastSpell(HXGSlot, target) end
                                    end
								end
                    end
                   
                    if os.clock() - qTime > 5.6 then
                           
                            DoingTripleQ = false
                            AutoCarry.PluginMenu.TripleQ = false
                           
                            Combo()
                    end
           
    end
     
    function Harass()
           
            if target ~= nil then
                    if myHero.mana <= 4 then
                            if eReady and GetDistance(target) <= eRange and AutoCarry.PluginMenu.eHarass then
                                    CastSpell(_E, target)
                            end
                            if wReady and myHero.mana <= 4 and GetDistance(target) <= wRange and AutoCarry.PluginMenu.wHarass then
                                    CastSpell(_W, target)
                            end
                           
                    end
                   
                    if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 2 and GetDistance(target) <= wRange and AutoCarry.PluginMenu.wHarass then
                            CastSpell(_W, target)
                    end
                    if myHero.mana == 5 and AutoCarry.PluginMenu.EmpPriority == 3 and GetDistance(target) <= eRange then
                            CastSpell(_E, target)
                    end
            end            
    end
     
     
     
     
    function KillStealEW()
     
        for _, enemy in pairs(AutoCarry.EnemyTable) do
         
            if ValidTarget(enemy, eRange) and enemy.health < getDmg("E", enemy, myHero)and eReady then
         
                 CastSpell(_E, enemy)
         
            end
                    if ValidTarget(enemy, wRange) and enemy.health < getDmg("W", enemy, myHero) and wReady then
                           
                 CastSpell(_W, enemy)
         
                    end
         
                    if ValidTarget(enemy, wRange) and enemy.health < getDmg("E", enemy, myHero) + getDmg("W", enemy, myHero) and eReady and wReady then
                            CastSpell(_E, enemy)
                            CastSpell(_W, enemy)
     
                    end
         end       
             
    end
           
     --BomD, Ondraw
	 function OnDraw()
	if not myHero.dead and not Settings.drawing.mDraw then
		if SkillQ.ready and Settings.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, 0xCE00FF)
		end
		if SkillW.ready and Settings.drawing.wDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, 0xCE00FF)
		end
		if SkillE.ready and Settings.drawing.eDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, 0xCE00FF)
		end
		
		if Settings.drawing.Target and Target ~= nil then
			DrawCircle(Target.x, Target.y, Target.z, 70, 0xCE00FF)
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, 550, 0xFF0000)
		end
	end
	 --
	 
	 
	 
     
    function PluginOnDraw()
     
            if AutoCarry.PluginMenu.TripleQ == true and DoingTripleQ == false then
                    PrintFloatText(myHero, 0, "Triple Q Active")
            end
           
                   
            if DoingTripleQ == true then
                    PrintFloatText(myHero, 0, "Performing Tripple Q")
            end
            -- Damage calculations & drawing
            for i = 1, heroManager.iCount do
                    local enemyd = heroManager:GetHero(i)
                    if ValidTarget(enemyd) then
     
                            if killable[i] ~= 0 and waittxt[i] == 1 then
                                    if DoingTripleQ  then
                                            PrintFloatText(enemyd, 0, "Stay close enough")
                                    else
                                    PrintFloatText(enemyd, 0, floattext[killable[i]])
                                    end
                            end
                    end
                    if waittxt[i] == 1 then
                waittxt[i] = 30
            else
                waittxt[i] = waittxt[i]-1
            end
            end            
           
    end    
     
    function CalculateDamage()
        for i=1, heroManager.iCount do
                           
            local enemyc = heroManager:GetHero(i)
            if ValidTarget(enemyc) then
            --spells
                    local aa = getDmg("AD",enemyc,myHero)
                    local qDmg = getDmg("Q", enemyc, myHero)
                    local qDmgEmp = getDmg("Q", enemyc, myHero,2)
                    local wDmg = getDmg("W", enemyc, myHero)
                    local eDmg = getDmg("E", enemyc, myHero)
                           
            -- items
                    local bwcDamage = (BWCSlot and getDmg("BWC",enemyc,myHero) or 0)
                    local hxgDamage = (HXGSlot and getDmg("HXG", enemyc, myHero) or 0)
                    local brkDamage = (BRKSlot and getDmg("RUINEDKING",enemyc,myHero,2) or 0)
                    local igniteDamage = (ignite and getDmg("IGNITE",enemyc,myHero) or 0)
                    local onhitDmg = (SheenSlot and getDmg("SHEEN",enemyc,myHero) or 0)+(TrinitySlot and getDmg("TRINITY",enemyc,myHero) or 0)+(LBSlot and getDmg("LICHBANE",enemyc,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemyc,myHero) or 0)
                    local rshDamage = (RSHSlot and aa*0.8 or 0)
                    local tmtDamage = (TMTSlot and aa*0.8 or 0)
                    local stdDamage = (STDSlot and aa*6 or 0)
            -- extra damage for sword of divine with IE 250% crit damage
                    if GetInventorySlotItem(3031) ~= nil then
                            stdDamage = stdDamage*1.25
                    end
           
            -- calculations
                    local tripleQDmg = qDmg + qDmgEmp*2 + aa*3 + onhitDmg
                    local NormalCombo = qDmg + wDmg + eDmg + aa*2
                    local DoubleCombo = tripleQDmg + NormalCombo
           
                    if BRKREADY then
                    tripleQDmg = tripleQDmg + brkDamage
                    NormalCombo = NormalCombo + brkDamage
                    DoubleCombo = tripleQDmg + NormalCombo - brkDamage
                    end
                    if IREADY then
                    tripleQDmg = tripleQDmg + igniteDamage
                    NormalCombo = NormalCombo + igniteDamage
                    DoubleCombo = tripleQDmg + NormalCombo - igniteDamage
                    end
                    if HXGREADY then
                    tripleQDmg = tripleQDmg + hxgDamage
                    NormalCombo = NormalCombo + hxgDamage
                    DoubleCombo = tripleQDmg + NormalCombo - hxgDamage
                    end
                    if BWCREADY then
                    tripleQDmg = tripleQDmg + bwcDamage
                    NormalCombo = NormalCombo + bwcDamage
                    DoubleCombo = tripleQDmg + NormalCombo - bwcDamage
                    end
                    if TMTREADY then
                    tripleQDmg = tripleQDmg + tmtDamage
                    NormalCombo = NormalCombo + tmtDamage
                    DoubleCombo = tripleQDmg + NormalCombo - tmtDamage
                    end    
                    if RSHREADY then
                    tripleQDmg = tripleQDmg + rshDamage
                    NormalCombo = NormalCombo + rshDamage
                    DoubleCombo = tripleQDmg + NormalCombo - rshDamage
                    end
                    if STDREADY then
                    tripleQDmg = tripleQDmg + stdDamage
                    NormalCombo = NormalCombo + stdDamage
                    DoubleCombo = tripleQDmg + NormalCombo - stdDamage
                    end
                    if myHero.mana >= 3 then
                    NormalCombo = NormalCombo + qDmgEmp
                    end
            --
                    if NormalCombo >= enemyc.health then
                            killable[i] = 3
                           
                    elseif tripleQDmg >= enemyc.health then
                            if myHero.level >= 6 then
                                    killable[i] = 2
                            end
                    elseif DoubleCombo - qDmgEmp >= enemyc.health then
                            if myHero.level >= 6 then      
                                    killable[i] = 1
                            end    
                    else
                            killable[i] = 0
                    end
                           
            end
            end
           
     
     
    end
     
    function CheckCooldowns()
            --spells
            qReady = myHero:CanUseSpell(_Q) == READY
        wReady = myHero:CanUseSpell(_W) == READY
        eReady = myHero:CanUseSpell(_E)     == READY
        rReady = myHero:CanUseSpell(_R) == READY
            qCooldown = myHero:CanUseSpell(_Q) ~= READY
        wCooldown = myHero:CanUseSpell(_W) ~= READY
        eCooldown = myHero:CanUseSpell(_E)  ~= READY
        rCooldown = myHero:CanUseSpell(_R) ~= READY
           
     
           
           
            -- items
            BWCSlot = GetInventorySlotItem(3144)
            HXGSlot = GetInventorySlotItem(3146)
            BRKSlot = GetInventorySlotItem(3153)
            SheenSlot, TrinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
            RSHSlot = GetInventorySlotItem(3074)
            TMTSlot = GetInventorySlotItem(3077)
            STDSlot = GetInventorySlotItem(3131)
     
            BWCREADY = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
            HXGREADY = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
            BRKREADY = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
            RSHREADY = (RSHSlot ~= nil and myHero:CanUseSpell(RSHSlot) == READY)
            TMTREADY = (TMTSlot ~= nil and myHero:CanUseSpell(TMTSlot) == READY)
            STDREADY = (STDSlot ~= nil and myHero:CanUseSpell(STDSlot) == READY)
            IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
    end