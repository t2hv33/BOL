--[[ 
	Current_Cooldowns 1.1 by monogato - Edited by Wursti for his HUD
	
	GetCurrentCd(iIndex, iSpellString) returns the current cooldown of any champion spell.
	
	Note: Call CurrentCooldowns__OnLoad() in your script´s OnLoad().
]]

-- Spell data
ChampNames = {"", "", "", "", "", "", "", "", "", ""}
QNames = {"", "", "", "", "", "", "", "", "", ""}
WNames = {"", "", "", "", "", "", "", "", "", ""}
ENames =  {"", "", "", "", "", "", "", "", "", ""}
RNames =  {"", "", "", "", "", "", "", "", "", ""}
Summoner1Names =  {"", "", "", "", "", "", "", "", "", ""}
Summoner2Names =  {"", "", "", "", "", "", "", "", "", ""}
-- Cast track
lastQs = {-300, -300, -300, -300, -300, -300, -300, -300, -300, -300}
lastWs = {-300, -300, -300, -300, -300, -300, -300, -300, -300, -300}
lastEs = {-300, -300, -300, -300, -300, -300, -300, -300, -300, -300}
lastRs = {-300, -300, -300, -300, -300, -300, -300, -300, -300, -300}
lastSummoner1s = {-300, -300, -300, -300, -300, -300, -300, -300, -300, -300}
lastSummoner2s = {-300, -300, -300, -300, -300, -300, -300, -300, -300, -300}

function FillChampNames()
	for i=1, heroManager.iCount do
		ChampNames[i] = heroManager:GetHero(i).name
	end
end

function FillSpellNames()
	local champion
	
	for i=1, heroManager.iCount do
		champion = heroManager:GetHero(i)
		QNames[i] = champion:GetSpellData(_Q).name
		WNames[i] = champion:GetSpellData(_W).name
		ENames[i] = champion:GetSpellData(_E).name
		RNames[i] = champion:GetSpellData(_R).name
		Summoner1Names[i] = champion:GetSpellData(SUMMONER_1).name
		Summoner2Names[i] = champion:GetSpellData(SUMMONER_2).name
	end
end

function CurrentCooldowns__OnLoad()
	FillChampNames()
	FillSpellNames()
end

function GetiIndex(champion)
	local champion_name = champion.name
	local i = 1
	local iIndex
	local found = false
	
	while not found do
		if ChampNames[i] == champion_name then
			iIndex = i
			found = true
		end
		
		i = i + 1
	end
	
	return iIndex
end

function GetiSpellString(iIndex, spell)
	local spell_name = spell.name
	local iSpellString
	
	if spell_name == QNames[iIndex] then iSpellString = "_Q"
	elseif spell_name == WNames[iIndex] then iSpellString = "_W"
	elseif spell_name == ENames[iIndex] then iSpellString = "_E"
	elseif spell_name == RNames[iIndex] then iSpellString = "_R"
	elseif spell_name == Summoner1Names[iIndex] then iSpellString = "SUMMONER_1"
	elseif spell_name == Summoner2Names[iIndex] then iSpellString = "SUMMONER_2"
	end
	
	return iSpellString
end

function OnProcessSpell(unit, spell)
	if unit.type == "obj_AI_Hero" and string.find(spell.name, "Basic") == nil then
		local iIndex = GetiIndex(unit)
		local iSpellString = GetiSpellString(iIndex, spell)
		
		if iSpellString == "_Q" then lastQs[iIndex] = GetTickCount() / 1000
		elseif iSpellString == "_W" then lastWs[iIndex] = GetTickCount() / 1000
		elseif iSpellString == "_E" then lastEs[iIndex] = GetTickCount() / 1000
		elseif iSpellString == "_R" then lastRs[iIndex] = GetTickCount() / 1000
		elseif iSpellString == "SUMMONER_1" then lastSummoner1s[iIndex] = GetTickCount() / 1000
		elseif iSpellString == "SUMMONER_2" then lastSummoner2s[iIndex] = GetTickCount() / 1000
		end
	end
end

function GetCurrentCd(iIndex, iSpellString)
	local lastCast
	local spellCd
	local currentCd
	
	if iSpellString == "_Q" then
		lastCast = lastQs[iIndex]
		spellCd = heroManager:GetHero(iIndex):GetSpellData(_Q).cd
	elseif iSpellString == "_W" then
		lastCast = lastWs[iIndex]
		spellCd = heroManager:GetHero(iIndex):GetSpellData(_W).cd
	elseif iSpellString == "_E" then
		lastCast = lastEs[iIndex]
		spellCd = heroManager:GetHero(iIndex):GetSpellData(_E).cd
	elseif iSpellString == "_R" then
		lastCast = lastRs[iIndex]
		spellCd = heroManager:GetHero(iIndex):GetSpellData(_R).cd
	elseif iSpellString == "SUMMONER_1" then
		lastCast = lastSummoner1s[iIndex]
		spellCd = heroManager:GetHero(iIndex):GetSpellData(SUMMONER_1).cd
	elseif iSpellString == "SUMMONER_2" then
		lastCast = lastSummoner2s[iIndex]
		spellCd = heroManager:GetHero(iIndex):GetSpellData(SUMMONER_2).cd
	end
	
	currentCd = spellCd - (GetTickCount() / 1000 - lastCast)
	if lastCast == -300 then 
		check = false
	else 
		check = true
	end
	if currentCd < 0 then currentCd = 0 end
	
	return {currentCD = math.floor(currentCd, 0), checked = check}
end