--[[
 
        Auto Carry Plugin - Ahri Free Edition
                Author: Chancity & Kain
                Version: See version variable below.
                Copyright 2013

                Dependency: Sida's Auto Carry
 
                How to install:
                        Make sure you already have AutoCarry installed.
                        Name the script EXACTLY "SidasAutoCarryPlugin - Ahri.lua" without the quotes.
                        Place the plugin in BoL/Scripts/Common folder.

                Features:
					Smart Combos (Checks for mana, ability damage, and cool downs), can be disabled
					Draw text for smart combo is shown on target
					Fully customizable ability options in Mixed Mode (Q, W, E)
					Mixed Mode Harass with mana management
					Optional use Q return while using Mixed Mode
					Draws Skill Ranges based on what skills are ready
				
                
                Download: 

                Version History:
						Version: 1.14
							Added options to adjust Q and E width
						Version: 1.13
							Added automatic updates
							Added ability to change ranges for all skills
						Version: 1.12
							Added require charm toggle
							Added permaShow for ult toggle and require charm
							Cleaned up code and logic
						Version: 1.11
							Removed KS
						Version: 1.1
							Added ult toggle
						Version: 1.09
							Fixed a small bug with damage calculations
							Added KSing feature
							Use Ult has can be toggled on and off with "Z", can be changed
						Version: 1.08
							Added new draw text messages
							Fixed a bug when checking current mana for Smart Combos
						Version: 1.07
							PROdiction 2.0
						Version: 1.06
							Added Back: Smart Combos (Checks for mana, ability damage, and cool downs), can be disabled
							Added Back: Draw text for smart combo is shown on target
						Version: 1.05
							Smart Combos (Checks for mana, ability damage, and cool downs), can be disabled
							Draw text for smart combo is shown on target
							Slider to change format of draw text
							Slider to adjust "Q Return"
                        Version: 1.04
                            Release         
--]]

if myHero.charName ~= "Ahri" then return end

local GetVersionURL, hasUpdated = "http://bit.ly/17GTqzC", true
local PLUGIN_PATH = BOL_PATH.."Scripts\\Common\\SidasAutoCarryPlugin - "..myHero.charName..".lua"
local VERSION_PATH = os.getenv("APPDATA").."\\"..myHero.charName.."Version.ini"
DownloadFile(GetVersionURL, VERSION_PATH, function() end)


function DefaultRanges()
	QRange, QSpeed, QDelay, QWidth = 895, 1.67, 240, 50
	WRange, WSpeed, WDelay, WWidth = 605, nil, nil, 225
	ERange, ESpeed, EDelay, EWidth = 920, 1.55, 240, 80
	RRange, RSpeed, RDelay, RWidth = 700, math.huge, 100, 100
	setRange = false
end

function Variables()
	curVersion = 1.2
	UpdateChat = {}
	
	AhriTumbleActive = false
	
	if VIP_USER then
		AdvancedCallback:bind('OnGainBuff', function(unit, buff) OnGainBuff(unit, buff) end)
		AdvancedCallback:bind('OnLoseBuff', function(unit, buff) OnLoseBuff(unit, buff) end)
	end
	
    if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end

    if IsSACReborn then
		AutoCarry.Skills:DisableAll()
    end
	
	QReady, WReady, EReady, RReady, DFGReady, IReady = false, false, false, false, false, false
	DFGSlot = nil

	SkillQ = {spellKey = _Q, range = QRange, speed = QSpeed, delay = QDelay, width = QWidth, configName = "orbofdeception", displayName = "Q (Orb of Deception)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
	SkillW = {spellKey = _W, range = WRange, speed = WSpeed, delay = WDelay, width = WWidth, configName = "foxfire", displayName = "W (Fox-Fire)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = false }
	SkillE = {spellKey = _E, range = ERange, speed = ESpeed, delay = EDelay, width = EWidth, configName = "charm", displayName = "E (Charm)", enabled = true, skillShot = true, minions = true, reset = false, reqTarget = false }
	SkillR = {spellKey = _R, range = RRange, speed = RSpeed, delay = RDelay, width = RWidth, configName = "spiritrush", displayName = "R (Spirit Rush)", enabled = true, skillShot = false, minions = false, reset = false, reqTarget = false }
		
	ignite = nil
	useIgnite = true
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
	end
	
	enemyHeros = {}
	enemyHerosCount = 0
	for i = 1, heroManager.iCount do
		local hero = heroManager:GetHero(i)
		if hero.team ~= player.team then
			local enemyCount = enemyHerosCount + 1
			enemyHeros[enemyCount] = {object = hero, q = 0, w = 0, e = 0, r = 0, dfg = 0, ig = 0, myDamage = 0, manaCombo = 0}
			enemyHerosCount = enemyCount
		end
	end
	
	KeyQ = string.byte("Q")
    KeyE = string.byte("E")
end

function AhriMenu()
	Menu = AutoCarry.PluginMenu
		Menu:addSubMenu(""..myHero.charName.." Auto Carry: Auto Carry", "autocarry")
			Menu.autocarry:addParam("SmartCombo","Use Smart Combo", SCRIPT_PARAM_ONOFF, true)
			Menu.autocarry:addParam("CastR","Use Spirit Rush (Z)", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("Z"))
			Menu.autocarry:permaShow("CastR")
			
		Menu:addSubMenu(""..myHero.charName.." Auto Carry: Mixed Mode", "mixedmode")
			Menu.mixedmode:addSubMenu("Q Return", "qreturn")
					Menu.mixedmode.qreturn:addParam("MixedQdoubleProc","Use Q Return", SCRIPT_PARAM_ONOFF, false)
					Menu.mixedmode.qreturn:addParam("bottomQ","Minimum Range %", SCRIPT_PARAM_SLICE, 75, 65, 85, 0)
					Menu.mixedmode.qreturn:addParam("topQ","Maximum Range %", SCRIPT_PARAM_SLICE, 95, 75, 95, 0)	
			Menu.mixedmode:addParam("MixedUseQ","Use Orb Of Deception", SCRIPT_PARAM_ONOFF, true)
			Menu.mixedmode:addParam("MixedUseW","Use Fox Fire", SCRIPT_PARAM_ONOFF, false)
			Menu.mixedmode:addParam("MixedUseE","Use Charm", SCRIPT_PARAM_ONOFF, true)
			Menu.mixedmode:addParam("MixedMinMana","Mana Manager %", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
					
		Menu:addSubMenu(""..myHero.charName.." Auto Carry: Skill Settings", "skills")
			Menu.skills:addParam("UseAdjustedSkills","Adjusted Skills", SCRIPT_PARAM_ONOFF, false)
				Menu.skills:addSubMenu("Q Settings", "Qskill")
					Menu.skills.Qskill:addParam("QskillRange","Q Range", SCRIPT_PARAM_SLICE, 895, 800, 1000, 0)
					Menu.skills.Qskill:addParam("QskillWidth","Q Width", SCRIPT_PARAM_SLICE, 25, 50, 120, 0)
				Menu.skills:addSubMenu("E Settings", "Eskill")
					Menu.skills.Eskill:addParam("EskillRange","E Range", SCRIPT_PARAM_SLICE, 920, 800, 1000, 0)
					Menu.skills.Eskill:addParam("EskillWidth","E Width", SCRIPT_PARAM_SLICE, 25, 80, 100, 0)
				Menu.skills:addSubMenu("W Settings", "Wskill")
					Menu.skills.Wskill:addParam("WskillRange","W Range", SCRIPT_PARAM_SLICE, 600, 450, 700, 0)
				Menu.skills:addSubMenu("R Settings", "Rskill")
					Menu.skills.Rskill:addParam("RskillRange","R Range", SCRIPT_PARAM_SLICE, 700, 450, 900, 0)
		
		Menu:addSubMenu(""..myHero.charName.." Auto Carry: Draw", "draw")
			Menu.draw:addParam("DrawKillable","Draw Killable", SCRIPT_PARAM_ONOFF, true)
			Menu.draw:addParam("DrawKillableTextSize","Draw Killable Text Size", SCRIPT_PARAM_SLICE, 15, 0, 40, 0)
			Menu.draw:addParam("DrawTextTargetColor","Target Color", SCRIPT_PARAM_COLOR, {255,0,238,0})
			Menu.draw:addParam("DrawTextUnitColor","Unit Color", SCRIPT_PARAM_COLOR, { 255, 255, 50, 50 })
			Menu.draw:addParam("DrawRange","Draw Skill Range", SCRIPT_PARAM_ONOFF, true)
			
		Menu:addSubMenu(""..myHero.charName.." Auto Carry: Extras", "extras")
			Menu.extras:addParam("RequireCharm","Require Charm (X)", SCRIPT_PARAM_ONKEYTOGGLE, true, string.byte("X"))
			Menu.extras:permaShow("RequireCharm")
			Menu.extras:addParam("ProMode","Use Auto Q & E Keys", SCRIPT_PARAM_ONOFF, false)
			Menu.extras:addParam("Ignite","Use Ignite", SCRIPT_PARAM_ONOFF, true)	
end

function PluginOnLoad()
	DefaultRanges()
	Variables()
	AhriMenu()
	AutoCarry.SkillsCrosshair.range = ERange
end

function PluginOnTick()	
	if hasUpdated then 
		if FileExist(VERSION_PATH) then
			AutoUpdate() 
		end 
	end
	
	CheckSpells()
	damageCalculation()
	
	if Menu.skills.UseAdjustedSkills then 
		AdjustRanges() 
	elseif setRange then
		DefaultRanges()
	end
	
	if Target ~= nil and  AutoCarry.MainMenu.AutoCarry then
		FullCombo()
	end
	
	if Target ~= nil and AutoCarry.MainMenu.MixedMode and CheckMana() then
		HarassCombo()
	end
	
	if Menu.extras.Ignite and ignite and IReady then doIgnite() end
end

function PluginOnDraw()
	if Menu.draw.DrawRange and EReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0xe066a3)
	elseif Menu.draw.DrawRange and QReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0xe066a3)
	elseif Menu.draw.DrawRange and WReady then
		DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0xe066a3)
	end
	
	if Menu.draw.DrawKillable then
		for i = 1, enemyHerosCount do
			local Unit = enemyHeros[i].object
			local q = enemyHeros[i].q
			local w = enemyHeros[i].w
			local e = enemyHeros[i].e
			local r = enemyHeros[i].r
			local dfg = enemyHeros[i].dfg
			local ig = enemyHeros[i].ig
			local myDamage = enemyHeros[i].myDamage
			local manaCombo = enemyHeros[i].manaCombo
			local comboMessage = ""
			local a = Menu.draw.DrawTextTargetColor
			local b = Menu.draw.DrawTextUnitColor
			if ValidTarget(Unit) then
				if myDamage >= Unit.health and manaCombo <= myHero.mana and not myHero.dead then
					if e == 1 then
						comboMessage = comboMessage.." E"
					end
					if q == 1 then
						comboMessage = comboMessage.." Q"
					end
					if w == 1 then
						comboMessage = comboMessage.." W"
					end
					if r >= 1 then
						comboMessage = comboMessage.." R"..tostring(r)
					end
					if dfg == 1 then
						comboMessage = comboMessage.." DFG"
					end
					if ig == 1 then
						comboMessage = comboMessage.." IG"
					end
					if Unit == Target then
						DrawText3D("Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.draw.DrawKillableTextSize,ARGB(a[1],a[2],a[3],a[4]), true)
					else
						DrawText3D("Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.draw.DrawKillableTextSize,ARGB(b[1],b[2],b[3],b[4]), true)
					end
				elseif myDamage < Unit.health and QReady or WReady or EReady then
					if Unit == Target then
						DrawText3D("Harass"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.draw.DrawKillableTextSize,ARGB(a[1],a[2],a[3],a[4]), true)
					else
						DrawText3D("Harass"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.draw.DrawKillableTextSize,ARGB(b[1],b[2],b[3],b[4]), true)
					end
				elseif not myHero.dead then
					if Unit == Target then
						DrawText3D("Not Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.draw.DrawKillableTextSize,ARGB(a[1],a[2],a[3],a[4]), true)
					else
						DrawText3D("Not Killable"..comboMessage,Unit.x,Unit.y, Unit.z,Menu.draw.DrawKillableTextSize,ARGB(b[1],b[2],b[3],b[4]), true)
					end
				end
			end
		end 
	end
end

function FullCombo()
	if Menu.autocarry.SmartCombo then
		for i = 1, enemyHerosCount do
			local Unit = enemyHeros[i].object
			local q = enemyHeros[i].q
			local w = enemyHeros[i].w
			local e = enemyHeros[i].e
			local r = enemyHeros[i].r
			local dfg = enemyHeros[i].dfg
			local myDamage = enemyHeros[i].myDamage
			if Unit.name == Target.name and myDamage >= Target.health then
				
				if ig == 0 then 
					useIgnite = false 
				else
					useIgnite = true
				end
				
				if e == 1 then CastE() end
				if charmCheck() then return end
				
				if dfg == 1 then
					if DFGReady then CastSpell(DFGSlot, Target) end
				end
				
				if r >= 1 and Menu.autocarry.CastR then CastR() end
				if q == 1 then CastQ() end
				if w == 1 then CastW() end
				
			elseif myDamage < Target.health then
				if AhriTumbleActive and Menu.autocarry.CastR then CastR() end
				CastE()
				if charmCheck() then return end
				CastQ()
				CastW()
			end
		end
	else
		CastE()
		if charmCheck() then return end
		CastQ()
		CastW()
	end
end

function HarassCombo()
	if Menu.mixedmode.MixedUseE and EReady and CheckMana() and ValidTarget(Target, ERange) then 
		CastE()
	end
	
	if charmCheck() then return end
	
	if Menu.mixedmode.MixedUseQ and QReady and CheckMana() and ValidTarget(Target, QRange) then
		if Menu.mixedmode.MixedQdoubleProc then
			if HarassQ() then 
				CastQ()
			end
		else
			CastQ()
		end
	end
	
	if Menu.mixedmode.MixedUseW and WReady and CheckMana() and GetDistance(Target) <= WRange then CastSpell(_W) end 
end

function CastE()
	if EReady and ValidTarget(Target, ERange) then 
		AutoCarry.CastSkillshot(SkillE, Target)
	end
end

function CastQ()
	if QReady and ValidTarget(Target, QRange) then 
		AutoCarry.CastSkillshot(SkillQ, Target)
	end
end

function CastW()	
	if WReady and GetDistance(Target) <= WRange then CastSpell(_W) end 
end

function CastR()
	if RReady and ValidTarget(Target, RRange) then 
		AutoCarry.CastSkillshot(SkillR, Target)
	end
end

function doIgnite()
    for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, 600) and useIgnite and enemy.health <= 50 + (20 * player.level) and not IsIgnited(enemy) then
        	CastSpell(ignite, enemy)
        end
    end
end

function IsIgnited(target)
	if TargetHaveBuff("SummonerDot", target) then
		igniteTick = GetTickCount()
		return true
	elseif igniteTick == nil or GetTickCount()-igniteTick>500 then
		return false
	end
end

function CheckMana()
	if myHero.mana >= myHero.maxMana*(Menu.mixedmode.MixedMinMana/100) then
		return true
	else
		return false
	end	
end

function HarassQ()
	if GetDistance(Target) >= (QRange * Menu.mixedmode.qreturn.bottomQ/100) and GetDistance(Target) <= (QRange * Menu.mixedmode.qreturn.topQ/100) then
		return true
	else
		return false
	end
end

function charmCheck()
	CheckSpells()
	if EReady and Menu.extras.RequireCharm then 
		return true
	else
		return false
	end
end

function CheckSpells()
	Target = AutoCarry.GetAttackTarget()
	DFGSlot = GetInventorySlotItem(3128)

	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	EReady = (myHero:CanUseSpell(_E) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)

	DFGReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	IReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function OnGainBuff(unit, buff)
	if unit.isMe then
		if buff.name == "AhriTumble" then
			AhriTumbleActive = true
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe then
		if buff.name == "AhriTumble" then
			AhriTumbleActive = false
		end
	end
end

function  AdjustRanges()
	if QRange > Menu.skills.Qskill.QskillRange or QRange < Menu.skills.Qskill.QskillRange then QRange = Menu.skills.Qskill.QskillRange end
	if QWidth > Menu.skills.Qskill.QskillWidth or QRange < Menu.skills.Qskill.QskillWidth then QWidth = Menu.skills.Qskill.QskillWidth end
	
	if WRange > Menu.skills.Wskill.WskillRange or WRange < Menu.skills.Wskill.WskillRange then WRange = Menu.skills.Wskill.WskillRange end
	
	if ERange > Menu.skills.Eskill.EskillRange or ERange < Menu.skills.Eskill.EskillRange then ERange = Menu.skills.Eskill.EskillRange end
	if EWidth > Menu.skills.Eskill.EskillWidth or EWidth < Menu.skills.Eskill.EskillWidth then EWidth = Menu.skills.Eskill.EskillWidth end
	
	if RRange > Menu.skills.Rskill.RskillRange or RRange < Menu.skills.Rskill.RskillRange then RRange = Menu.skills.Rskill.RskillRange end
	setRange = true
end

function damageCalculation()
	for i = 1, enemyHerosCount do
		local Unit = enemyHeros[i].object
		if ValidTarget(Unit) then
			dfgdamage, ignitedamage = 0, 0
			manaCombo, myDamage, QDamage, EDamage, WDamage, RDamage = 0, 0, getDmg("Q", Unit, myHero), getDmg("E", Unit, myHero), getDmg("W", Unit, myHero), getDmg("R", Unit, myHero)
			dfgdamage = (DFGSlot and getDmg("DFG",Unit,myHero) or 0)
			ignitedamage = (ignite and getDmg("IGNITE",Unit,myHero) or 0)
			
			if EReady then
				if myHero.mana >= myHero:GetSpellData(_E).mana and myHero.mana >= manaCombo then
					manaCombo = manaCombo + myHero:GetSpellData(_E).mana
					myDamage = myDamage + EDamage
					enemyHeros[i].e = 1
				else
					enemyHeros[i].e = 0
				end
			else
				enemyHeros[i].e = 0
			end
			
			if QReady then
				if myHero.mana >= myHero:GetSpellData(_Q).mana and myHero.mana >= manaCombo and myDamage < Unit.health then
					manaCombo = manaCombo + myHero:GetSpellData(_Q).mana
					myDamage = myDamage + QDamage
					enemyHeros[i].q = 1
				else
					enemyHeros[i].q = 0
				end
			else
				enemyHeros[i].q = 0
			end
			
			if WReady then
				if myHero.mana >= myHero:GetSpellData(_W).mana and myHero.mana >= manaCombo and myDamage < Unit.health then
					manaCombo = manaCombo + myHero:GetSpellData(_W).mana
					myDamage = myDamage + (WDamage + WDamage)
					enemyHeros[i].w = 1
				else
					enemyHeros[i].w = 0
				end
			else
				enemyHeros[i].w = 0
			end
			
			if RReady then
				if myHero.mana >= myHero:GetSpellData(_R).mana and myHero.mana >= manaCombo and myDamage < Unit.health then
					manaCombo = manaCombo + myHero:GetSpellData(_R).mana
					myDamage = myDamage + RDamage
					enemyHeros[i].r = 1
					if myDamage < Unit.health then
						myDamage = myDamage + RDamage
						enemyHeros[i].r = 2
					end
					if myDamage < Unit.health then
						myDamage = myDamage + RDamage
						enemyHeros[i].r = 3
					end
				else
					enemyHeros[i].r = 0
				end
			else
				enemyHeros[i].r = 0
			end
			
			if DFGReady and myDamage < Unit.health then
				myDamage = myDamage * 1.2
				myDamage = myDamage + dfgdamage
				enemyHeros[i].dfg = 1
			else
				enemyHeros[i].dfg = 0
			end
			
			if IReady and myDamage < Unit.health then
				myDamage = myDamage + ignitedamage
				enemyHeros[i].ig = 1
			else
				enemyHeros[i].ig = 0
			end
			
			enemyHeros[i].manaCombo = manaCombo
			enemyHeros[i].myDamage = myDamage
		end
	end
end

function PluginOnWndMsg(msg, key)
        if Target ~= nil and Menu.extras.ProMode then
                if msg == KEY_DOWN and key == KeyQ then CastQ() end
                if msg == KEY_DOWN and key == KeyE then CastE() end
        end
end

function NewIniReader()
	local reader = {};
	function reader:Read(fName)
		self.root = {};
		self.reading_section = "";
		for line in io.lines(fName) do
			if startsWith(line, "[") then
				local section = string.sub(line,2,-2);
				self.root[section] = {};
				self.reading_section = section;
			elseif not startsWith(line, ";") then
				if self.reading_section then
					local var,val = line:usplit("=");
					local var,val = var:utrim(), val:utrim();
					if string.find(val, ";") then
						val,comment = val:usplit(";");
						val = val:utrim();
					end
					self.root[self.reading_section] = self.root[self.reading_section] or {};
					self.root[self.reading_section][var] = val;
				else
					return error("No element set for setting");
				end
			end
		end
	end
	function reader:GetValue(Section, Key)
		return self.root[Section][Key];
	end
	function reader:GetKeys(Section)
		return self.root[Section];
	end
	return reader;
end

function startsWith(text,prefix)
	return string.sub(text, 1, string.len(prefix)) == prefix
end

function string:usplit(sep)
	return self:match("([^" .. sep .. "]+)[" .. sep .. "]+(.+)")
end

function string:utrim()
	return self:match("^%s*(.-)%s*$")
end

function AutoUpdate()
	reader = NewIniReader();
	
	if FileExist(VERSION_PATH) then 
		reader:Read(VERSION_PATH);
	
		newDownloadURL = reader:GetValue("Version", "Download")
		newVersion = reader:GetValue("Version", "Version")
		newMessage = reader:GetValue("Version", "Message")
		
		UpdateChat = {
			"<font color='#e066a3'> >> "..myHero.charName.." Auto Carry Plugin:</font> <font color='#f4cce0'> Checking for update... </font>",
			"<font color='#e066a3'> >> "..myHero.charName.." Auto Carry Plugin:</font> <font color='#f4cce0'> Running Version "..curVersion.."</font>",
			"<font color='#e066a3'> >> "..myHero.charName.." Auto Carry Plugin:</font> <font color='#f4cce0'> New Version Released "..newVersion.."</font>",
			"<font color='#e066a3'> >> "..myHero.charName.." Auto Carry Plugin:</font> <font color='#f4cce0'> Updated to version "..newVersion.." press F9 two times to use updated script. </font>",
			"<font color='#e066a3'> >> "..myHero.charName.." Auto Carry Plugin:</font> <font color='#f4cce0'> Script is Up-To-Date </font>",
			"<font color='#e066a3'> >> "..myHero.charName.." Auto Carry Plugin:</font> <font color='#f4cce0'> Update Message ("..newVersion.."): "..newMessage.."</font>",
			"<font color='#e066a3'> >> "..myHero.charName.." Auto Carry Plugin:</font> <font color='#f4cce0'> Failed to check for update, press F9 two times if first run </font>"
					}
					
		os.remove(VERSION_PATH)
		
		if tonumber(newVersion) > tonumber(curVersion) then
			DownloadFile(newDownloadURL, PLUGIN_PATH, function()
				if FileExist(PLUGIN_PATH) then
					ChatUpdate("update")
				end
			end)
		else
			ChatUpdate("uptodate")
		end	
	else 
		ChatUpdate("failed")
	end 
	hasUpdated = false
end

function ChatUpdate(stats)
		PrintChat(UpdateChat[1])
		PrintChat(UpdateChat[2])
	if stats == "update" then
		PrintChat(UpdateChat[3])
		PrintChat(UpdateChat[4])
		PrintChat(UpdateChat[6])
	elseif stats == "uptodate" then
		PrintChat(UpdateChat[5])
		PrintChat(UpdateChat[6])
	else
		PrintChat(UpdateChat[7])
	end
end