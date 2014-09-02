-- Auto Ult function taken from Tux
-- lanten nearest ally taken from Hex
-- Auto Updater from Pain

if myHero.charName ~= "Thresh" then return end
require "SOW"
require "VPrediction"
        local VP = nil
require "Collision"
		local collision
local qRange, wRange, eRange, BoxRange, range = 1050, 950, 450, 450, 1050
local Assistant
local enemyTable = GetEnemyHeroes()
local informationTable = {}
local spellExpired = true
local spells = 
	{
		{name = "CaitlynAceintheHole", menuname = "Caitlyn (R)"},
		{name = "Crowstorm", menuname = "Fiddlesticks (R)"},
		{name = "DrainChannel", menuname = "Fiddlesticks (W)"},
		{name = "GalioIdolOfDurand", menuname = "Galio (R)"},
		{name = "KatarinaR", menuname = "Katarina (R)"},
		{name = "InfiniteDuress", menuname = "WarWick (R)"},
		{name = "AbsoluteZero", menuname = "Nunu (R)"},
		{name = "MissFortuneBulletTime", menuname = "Miss Fortune (R)"},
		{name = "AlZaharNetherGrasp", menuname = "Malzahar (R)"},	
	}
--local escapes = {"Ezreal","Corki","Vayne","Amumu","Caitlyn","Gragas","JarvinIV","Lucian","Renekton","Sejuani","Shen","Tryndamere","Vi","Aatrox","Kha'Zix", "Malphite","Tristana","Zac","Nidalee","Riven"}

function OnLoad()
VP = VPrediction()
SOW = SOW(VP)

Config = scriptConfig("BS Thresh","thresh")
Config:addSubMenu("Basic Settings", "Basic")
Config:addSubMenu("Flay Features", "Flay")
Config:addSubMenu("Box Settings", "Box")
Config:addSubMenu("Draw Settings", "Draw")
Config:addSubMenu("Orbwalker", "orbwalker")
--> Basic Settings
Config.Basic:addParam("doCombo", "Q > E combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config.Basic:addParam("harass", "harass", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("T"))
Config.Basic:addParam("usePull", "E Pull", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("E"))
Config.Basic:addParam("usePush", "E push", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G"))
Config.Basic:addParam("UseE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
Config.Basic:addParam("useLantern", "Use Lantern in Combo", SCRIPT_PARAM_ONOFF, true)
Config.Basic:addParam("lanterncc", "Lantern CC'd allys", SCRIPT_PARAM_ONOFF, true) 
Config.Basic:addParam("LanternSave", "Save Teammate with lantern", SCRIPT_PARAM_ONOFF, true)
Config.Basic:addParam("LanternCount", "Enemy # b4 EscapeLantern", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
-->More Flays
Config.Flay:addParam("PushAwayGapclosers", "PushAwayGapclosers", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("N"))
Config.Flay:addParam("antiLeona", "Anti Leona", SCRIPT_PARAM_ONOFF, false)
Config.Flay:addParam("xpecial", "The Xpecial Special", SCRIPT_PARAM_ONOFF, true) 
--Config.Flay:addSubMenu("Auto-Interrupt", "AutoInterrupt")
		--for i, spell in ipairs(spells) do
			--Config.Flay.AutoInterrupt:addParam(spell.name, spell.menuname, SCRIPT_PARAM_ONOFF, true)
		--end

--Config.Box:addParam("ultE", "Pull Enemy into Box", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("R"))
Config.Box:addParam("BoxCount", "Enemy Count before Using Ulti", SCRIPT_PARAM_SLICE, 3, 0, 5, 0)
Config.Box:addParam("BoxRange", "Use Auto Ult at this range", SCRIPT_PARAM_SLICE, 400, 0, 450, 0)

--> Draw Settings
Config.Draw:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("drawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("drawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("drawline", "Draw Q Target", SCRIPT_PARAM_ONOFF, true)

ts = TargetSelector(TARGET_NEAR_MOUSE, 1000, DAMAGE_PHYSICAL)
-- ts.name = "Thresh"
-- Config:addTS(ts)
	

SOW:LoadToMenu(Config.orbwalker)


ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, range, DAMAGE_MAGIC, true)
Config:addTS(ts)
if myHero:GetSpellData(SUMMONER_1).name:find("SummonerExhaust") then exhaust = SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerExhaust") then exhaust = SUMMONER_2
                else exhaust = nil
        end

player = GetMyHero()
Variables()
PriorityOnLoad()
PrintChat(" >> BS.Silent Thresh V1.8 Loaded mod by BomD")
--ignite = ((myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") and SUMMONER_2) or nil)
end

function Variables()	
	
	-- _G.oldDrawCircle = rawget(_G, 'DrawCircle')
	-- _G.DrawCircle = DrawCircle2	
	
	priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
			},
			
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
			},
			
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac"
			},
			
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
			},
			
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
			}
	}

	
end



function AutoBox()
        if Config.Box.BoxCount then
                if RREADY and CountEnemyHeroInRange(Config.Box.BoxRange) >= Config.Box.BoxCount then
                        CastSpell(_R)
                end
        end
end

function isFacing(source, target, lineLength)
local sourceVector = Vector(source.visionPos.x, source.visionPos.z)
local sourcePos = Vector(source.x, source.z)
sourceVector = (sourceVector-sourcePos):normalized()
sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end
function castQ(target)
	for i, target in pairs(GetEnemyHeroes()) do
	if ValidTarget(target) then
            CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.5, 80, qRange, 1900, myHero, true)
            if HitChance >= 2 and GetDistance(CastPosition) < 1050 then
						--local collision = Collision(1050, 1900, .500, 85)
                 ---   willCollide = collision:GetMinionCollision(CastPosition, myHero)
                    --if QREADY and GetDistance(CastPosition, myHero) < 1050 and minionCollisionWidth == 0 and not target.dead and myHero:GetSpellData(_Q).name == "ThreshQ" and ValidTarget(ts.target, qRange) then
					    if QREADY and GetDistance(CastPosition, myHero) < 1050 and not target.dead and myHero:GetSpellData(_Q).name == "ThreshQ" and ValidTarget(ts.target, qRange) then
                        CastSpell(_Q, CastPosition.x, CastPosition.z)
                    end
										if QREADY and GetDistance(CastPosition, myHero) < 1050 and 80 > 0 and not willCollide and not target.dead and myHero:GetSpellData(_Q).name == "ThreshQ" and ValidTarget(ts.target, qRange) then 
											CastSpell(_Q, CastPosition.x, CastPosition.z)
										end
						
			end
    end
	end
end

function qtwo()
if myHero:GetSpellData(_Q).name == "threshqleap" then
CastSpell(_Q)
end
end


function saveteam()
	if Config.Basic.LanternSave then
		if WREADY and CountEnemyHeroInRange(950) >= Config.Basic.LanternCount then
            for k, ally in pairs(GetAllyHeroes()) do
				if GetDistance(ally) < wRange then
					CastSpell(_W, GetLowestAlly().x, GetLowestAlly().z)
				end
			end
		end
	end
end

function lanterncc()
	if Config.Basic.lanterncc then
	      for k, ally in pairs(GetAllyHeroes()) do
            local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(ally, 0.250, 150, 950)
            if HitChance >= 4 and GetDistance(ally) < 950 then
                CastSpell(_W, ally.x, ally.z)
            end
        end
    end
end
 

function CountEnemyHeroInRange(range)
local enemyInRange = 0
	for i = 1, heroManager.iCount, 1 do
	local enemyheros = heroManager:getHero(i)
		if enemyheros.valid and enemyheros.visible and enemyheros.dead == false and enemyheros.team ~= myHero.team and GetDistance(enemyheros) <= range then
			enemyInRange = enemyInRange + 1
		end
	end
 return enemyInRange
end

function GetLowestAlly(range) --[[Tested function.. I love it! Always returns the lowest % ally in range.]]
	assert(range, "GetLowestAlly: Range returned nil. Cannot check valid ally in nil range")
	LowestAlly = nil
	for a = 1, heroManager.iCount do
		Ally = heroManager:GetHero(a)
		if Ally.team == myHero.team and not Ally.dead and GetDistance(myHero,Ally) <= range then
			if LowestAlly == nil then
				LowestAlly = Ally
			elseif not LowestAlly.dead and (Ally.health/Ally.maxHealth) < (LowestAlly.health/LowestAlly.maxHealth) then
				LowestAlly = Ally
			end
		end
	end
	return LowestAlly
end
 
           
function castW(target)
    if findClosestAlly() and GetDistance(findClosestAlly()) < wRange and WREADY and myHero:GetSpellData(_Q).name == "threshqleap" then
        CastSpell(_W, findClosestAlly().x, findClosestAlly().z)
    end
end

function findClosestAlly()
        local closestAlly = nil
        local currentAlly = nil
        for i=1, heroManager.iCount do
                currentAlly = heroManager:GetHero(i)
                if currentAlly.team == myHero.team and not currentAlly.dead and currentAlly.charName ~= myHero.charName then
                        if closestAlly == nil then
                                closestAlly = currentAlly
                        elseif GetDistance(currentAlly) < GetDistance(closestAlly) then
                                closestAlly = currentAlly
                        end
                end
        end
return closestAlly
end

function castE(target)
			xPos = myHero.x + (myHero.x - CastPosition.x)
			zPos = myHero.z + (myHero.z - CastPosition.z)
	for i, target in pairs(GetEnemyHeroes()) do
	if ValidTarget(target) then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.3, 200, eRange, 2000, myHero, true)
		if HitChance >= 2 or 3 and GetDistance(CastPosition) < 450 and not target.dead and ValidTarget(ts.target, eRange) then
			CastSpell(_E, xPos, zPos)
		end
	end
	end
end


function castE2(target)
	for i, target in pairs(GetEnemyHeroes()) do
	if ValidTarget(target) then
            CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.1, 200, eRange, 2000, myHero, true)
            if HitChance >= 2 or 3 and GetDistance(CastPosition) < 450 and not target.dead and ValidTarget(ts.target, eRange) then
                CastSpell(_E, CastPosition.x, CastPosition.z)
            end
    end
	end
end



function dontescape()
	for i, target in pairs(GetEnemyHeroes()) do
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.3, 200, eRange, 2000, myHero, true)
		if HitChance >= 3 and GetDistance(CastPosition) < 450 and not target.dead and ValidTarget(ts.target, eRange) and not isFacing(myHero, target) then
			xPos = myHero.x + (myHero.x - CastPosition.x)
			zPos = myHero.z + (myHero.z - CastPosition.z)
			CastSpell(_E, xPos, zPos)
		end
	end
	end


function stopDash()
        for i, target in pairs(GetEnemyHeroes()) do
            CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, 0.1, 210, eRange, 2000, myHero, true)
            if HitChance >= 5 and GetDistance(CastPosition) < 450 then
                CastSpell(_E, CastPosition.x, CastPosition.z)
            end
        end
    end

function ePush()
	if EREADY then
		castE2(ts.target)
	end
end

function harass()
	if ts.target then
		if QREADY then
			castQ(ts.target)
		end
	end
end

function doCombo()
	if ts.target then 
		if QREADY then
			castQ(ts.target)
        end
		if WREADY and Config.Basic.useLantern then
			castW(target)
		end
		if qtwo() then
			qtwo()
			end
		if EREADY and Config.Basic.UseE and GetDistance(ts.target) < 450 then
			castE(ts.target)
		end
	end
end


function Checks()
QREADY = ((myHero:CanUseSpell(_Q) == READY) or (myHero:GetSpellData(_Q).level > 0 and myHero:GetSpellData(_Q).currentCd <= 0.4)) WREADY = ((myHero:CanUseSpell(_W) == READY) or (myHero:GetSpellData(_W).level > 0 and myHero:GetSpellData(_W).currentCd <= 0.4))
EREADY = ((myHero:CanUseSpell(_E) == READY) or (myHero:GetSpellData(_E).level > 0 and myHero:GetSpellData(_E).currentCd <= 0.4))
RREADY = ((myHero:CanUseSpell(_R) == READY) or (myHero:GetSpellData(_R).level > 0 and myHero:GetSpellData(_R).currentCd <= 0.4))
IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
EREADY = (exasut ~= nil and myhero:CanuseSpell(exhaust) == READY)
ts:update()
end




function OnTick()
QNR = (myHero:CanUseSpell(_Q) == COOLDOWN)
QR = (myHero:CanUseSpell(_Q) == READY)
 
if QNR then
start = GetTickCount()
end
if myHero:GetSpellData(_Q).name == "threshqleap" then
elasped = GetTickCount() - start 
cd = 1500 - elasped
cooldown = ""..cd
PrintFloatText(myHero, 0, cooldown)
end
Checks()
	if ts.target then
		if Config.Basic.usePush then
			ePush()
		end
		if Config.Basic.doCombo then
			doCombo()
		end
		if Config.Flay.antiLeona then 
			stopDash()
		end
		if Config.Basic.usePull then
			castE()
		end
		if Config.Box.BoxCount then
			AutoBox()
		end
		if Config.Basic.LanternSave and CountEnemyHeroInRange(950) >= Config.Basic.LanternCount then
			saveteam()
		end
		if Config.Basic.lanterncc then
			lanterncc()
		end
		if Config.Basic.harass then
			harass()
		end
		if Config.Flay.xpecial then
			dontescape()
		end
	end
end


function OnDraw()
	if Config.Draw.drawQ and QREADY then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFFFF0000)
	end
	if Config.Draw.drawW and WREADY then
		DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0xFFFF0000)
	end
	if Config.Draw.drawE and EREADY then
		DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0xFFFF0000)
	end
	if Config.Draw.drawline and ValidTarget(ts.target, qRange) and QREADY then
                        local enemyPos = ts.nextPosition
                        if enemyPos ~= nil then
                                local x1, y1, OnScreen1 = get2DFrom3D(myHero.x, myHero.y, myHero.z)
                                local x2, y2, OnScreen2 = get2DFrom3D(enemyPos.x, enemyPos.y, enemyPos.z)
                                DrawLine(x1, y1, x2, y2, 3, 0xFFFF0000)
                        end
    end
end






function OnProcessSpell(unit, spell)
    if not Config.Flay.PushAwayGapclosers then return end
    local jarvanAddition = unit.charName == "JarvanIV" and unit:CanUseSpell(_Q) ~= READY and _R or _Q -- Did not want to break the table below.
    local isAGapcloserUnit = {
--        ['Ahri']        = {true, spell = _R, range = 450,   projSpeed = 2200},
        ['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
        ['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, }, -- Targeted ability
        ['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
        ['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, }, -- Targeted ability
        ['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
        ['Graves']      = {true, spell = _E,                  range = 425,   projSpeed = 2000, exeption = true },
        ['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
        ['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
        ['JarvanIV']    = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }, -- Skillshot/Targeted ability
        ['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, }, -- Targeted ability
        ['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, }, -- Targeted ability
        ['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
        ['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
        ['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
        ['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
        ['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms},
        ['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, }, -- Targeted ability
        ['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
        ['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, }, -- Targeted ability
        ['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, }, -- Targeted ability
        --['Quinn']       = {true, spell = _E,                  range = 725,   projSpeed = 2000, }, -- Targeted ability
        ['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
        ['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
        ['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
        ['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
        ['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
        ['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
    }
    if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and isAGapcloserUnit[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
        if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
            if spell.target ~= nil and spell.target.name == myHero.name or isAGapcloserUnit[unit.charName].spell == 'blindmonkqtwo' then
--                print('Gapcloser: ',unit.charName, ' Target: ', (spell.target ~= nil and spell.target.name or 'NONE'), " ", spell.name, " ", spell.projectileID)
        CastSpell(_E, unit.x, unit.z)
            else
                spellExpired = false
                informationTable = {
                    spellSource = unit,
                    spellCastedTick = GetTickCount(),
                    spellStartPos = Point(spell.startPos.x, spell.startPos.z),
                    spellEndPos = Point(spell.endPos.x, spell.endPos.z),
                    spellRange = isAGapcloserUnit[unit.charName].range,
                    spellSpeed = isAGapcloserUnit[unit.charName].projSpeed,
                    spellIsAnExpetion = isAGapcloserUnit[unit.charName].exeption or false,
                }
            end
        end
    end
    end
	
---MORE TARGET

function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end
 
function arrangePrioritys()
		for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,	   enemy, 2)
		SetPriority(priorityTable.Support,  enemy, 3)
		SetPriority(priorityTable.Bruiser,  enemy, 4)
		SetPriority(priorityTable.Tank,	 enemy, 5)
		end
end

function arrangePrioritysTT()
        for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,       enemy, 1)
		SetPriority(priorityTable.Support,  enemy, 2)
		SetPriority(priorityTable.Bruiser,  enemy, 2)
		SetPriority(priorityTable.Tank,     enemy, 3)
        end
end

function PriorityOnLoad()
	if heroManager.iCount < 10 or (TwistedTreeline and heroManager.iCount < 6) then
		print("<b><font color=\"#6699FF\">Corki - Daring Bombardier:</font></b> <font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end
	
	