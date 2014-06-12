--[[

	Twisted Fate - by BomD
	

--]]

if myHero.charName ~= "TwistedFate" then return end

require 'SOW'
require 'VPrediction'

local VP = nil
local ts
local Menu
local Recalling
local DRAWGANKTEXT
local AdditionalTimeGank = 0
local CurrentTimeGank = 0

function OnLoad()
	ts = TargetSelector(TARGET_LESS_CAST, 1450)

	Menu = scriptConfig("Gã Cao Bô`i-TF", "TFBL")
	VP = VPrediction()
	Orbwalker = SOW(VP)
	Menu:addTS(ts)
    ts.name = "Focus"
	
	Menu:addSubMenu("["..myHero.charName.." - HitAndRun]", "SOWorb")
	Orbwalker:LoadToMenu(Menu.SOWorb)

	Menu:addSubMenu("["..myHero.charName.." - Combo]", "TFCombo")
	Menu.TFCombo:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.TFCombo:addSubMenu("Q Cài Ðat.", "Qset")
	Menu.TFCombo.Qset:addParam("comboQ", "Dùng Q khi combo", SCRIPT_PARAM_ONOFF, true)
	Menu.TFCombo.Qset:addParam("qRange", "Dùng Q nêu'muc.tiêu trong tâm`", SCRIPT_PARAM_SLICE, 1200, 1, 1450, 0)
	Menu.TFCombo.Qset:addParam("qHitChance", "Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 4, 0)
	Menu.TFCombo:addSubMenu("W Cài Ðat.", "Wset")
	Menu.TFCombo.Wset:addParam("autoW", "Auto W khi combo [BETA]", SCRIPT_PARAM_ONOFF, false)
	Menu.TFCombo.Wset:addParam("Wprio", "1=Vàng 2=Xanh 3=Ðo?", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
	Menu.TFCombo.Wset:addParam("WprioTwo", "1=Vàng 2=Xanh 3=Ðo?", SCRIPT_PARAM_SLICE, 3, 1, 3, 0)
	Menu.TFCombo.Wset:addParam("WprioThree", "1=Vàng 2=Xanh 3=Ðo?", SCRIPT_PARAM_SLICE, 1, 1, 3, 0)
	Menu.TFCombo.Wset:addParam("UseRed", "Dùng Bài Ðo? nêu'trúng ít nhâ't enemy", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Menu.TFCombo.Wset:addParam("UseBlue", "Dùng Bài Xanh nêu'mana < %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Pick Bài]", "Wsel")
	Menu.Wsel:addParam("selectgold", "Pick Vàng", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	Menu.Wsel:addParam("selectblue", "Pick Xanh", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
	Menu.Wsel:addParam("selectred", "Pick Ðo?", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))

	Menu:addSubMenu("["..myHero.charName.." - Quây'Rôi']", "Harass")
	Menu.Harass:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	Menu.Harass:addSubMenu("Quây'Rôi' Cài Ðat.", "Hset")
	Menu.Harass.Hset:addParam("harassrange", "Tâm`Quây'Rôi'", SCRIPT_PARAM_SLICE, 1200, 1, 1450, 0)
	Menu.Harass:addParam("autoharass", "Auto-Quây'Rôi'", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("A"))
	Menu.Harass:addSubMenu("Auto-Harass Settings", "AHset")
	Menu.Harass.AHset:addParam("autoharassmana", "Không Auto-Harass nê'u mana %", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	Menu.Harass.AHset:addParam("autoharassrange", "Auto-Harass Range", SCRIPT_PARAM_SLICE, 1200, 1, 1450, 0)
	Menu.Harass.AHset:addParam("QHitChance", "Auto-Harass Hitchance", SCRIPT_PARAM_SLICE, 4, 1, 4, 0)

	Menu:addSubMenu("["..myHero.charName.." - Clear-Creep]", "LaneClear")
	Menu.LaneClear:addParam("lclr", "Clear Creep = skill", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
	Menu.LaneClear:addParam("lclrMana", "Xanh thay vì Ðo? nêu' mana % <", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Tro*.Lý-BETA]", "Ads")
	Menu.Ads:addParam("notifyR", "Thông báo nêu'% HP Ðich. < trong tâm`", SCRIPT_PARAM_ONOFF, true)
	Menu.Ads:addParam("notifyRange", "Tâm`Thông Báo ", SCRIPT_PARAM_SLICE, 4500, 1, 5000, 0)
	Menu.Ads:addParam("notifyPercent", "% HP", SCRIPT_PARAM_SLICE, 25, 1, 100, 0)

	Menu:addSubMenu("["..myHero.charName.." - Ve~Tâm`Ðánh]", "drawings")
	Menu.drawings:addParam("drawCircleAA", "Ve~ AA Range", SCRIPT_PARAM_ONOFF, false)
	Menu.drawings:addParam("drawCircleQ", "Ve~ Q Range", SCRIPT_PARAM_ONOFF, false)
	Menu.drawings:addParam("drawCircleW", "Ve~ W Range", SCRIPT_PARAM_ONOFF, false)
	Menu.drawings:addParam("drawCircleR", "Ve~ R Range", SCRIPT_PARAM_ONOFF, false)

	Menu.Wsel:permaShow("selectgold")
	Menu.Wsel:permaShow("selectblue")
	Menu.Wsel:permaShow("selectred")

	DRAWGANKTEXT = false

	enemyMinions = minionManager(MINION_ENEMY, 600, myHero)

	PrintChat("<font color = \"#33CCCC\">Son Of Card Master Twisted Fate</font> <font color='#7fe8c2'>BETA by</font> <font color='#e97fa5'>BomD</font>")
	PrintChat ("<font color='#E97FA5'> Road to the Challenger Series BomD :)</font>")

end

function OnTick()
	if myHero.dead then return end
	ts:update()
	enemyMinions:update()
	CardSelect()
	NotifyGank()
	AdditionalTimeGank = os.clock()

	if Menu.TFCombo.combo then
		ComboTF()
	end

	if Menu.LaneClear.lclr then
		Laneclear()
	end

	if Menu.Harass.harass then
		Harass()
	end

	if Menu.Harass.autoharass then
		AutoHarass()
	end
end

function NotifyGank()
	if Menu.Ads.notifyR then
		for i, ultTarget in pairs(GetEnemyHeroes()) do
			if HealthCheck(ultTarget, Menu.Ads.notifyPercent) and Menu.Ads.notifyRange >= GetDistance(ultTarget) then
				DRAWGANKTEXT = true
				CurrentTimeGank = os.clock()
			else
				DRAWGANKTEXT = false
			end
		end
	end
end

function HealthCheck(unit, HealthValue)
	if unit.health < (unit.maxHealth * (HealthValue/100))
		then return true 
	else
		return false 
	end
end

function Harass()
	if ts.target ~= nil and ValidTarget(ts.target, 1450) then
    	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 80, Menu.Harass.Hset.harassrange, 1450, myHero, false)
    	if HitChance >= 2 and GetDistance(CastPosition) < Menu.Harass.Hset.harassrange then
        	CastSpell(_Q, CastPosition.x, CastPosition.z)
    	end
	end
end

function AutoHarass()
	if ts.target ~= nil and ValidTarget(ts.target, 1450) and not Recalling then
    	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 80, Menu.Harass.AHset.autoharassrange, 1450, myHero, false)
    	if HitChance >= Menu.Harass.AHset.QHitChance and GetDistance(CastPosition) < Menu.Harass.AHset.autoharassrange and (Menu.Harass.AHset.autoharassmana*0.01)*myHero.maxMana < myHero.mana then
        	CastSpell(_Q, CastPosition.x, CastPosition.z)
    	end
	end
end


function OnCreateObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			Recalling = true
		end 
	end
end

function OnDeleteObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			Recalling = false
		end
	end
end

function Laneclear()
	local Name = myHero:GetSpellData(_W).name
	for i, minion in pairs(enemyMinions.objects) do
  		if minion ~= nil and ValidTarget(minion, 600) and myHero:CanUseSpell(_W) == READY and (Menu.LaneClear.lclrMana*0.01)*myHero.maxMana < myHero.mana then
  			spellName = "redcardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
  		end
  	end

  	for i, minion in pairs(enemyMinions.objects) do
  		if minion ~= nil and ValidTarget(minion, 600) and myHero:CanUseSpell(_W) == READY and (Menu.LaneClear.lclrMana*0.01)*myHero.maxMana > myHero.mana then
  			spellName = "bluecardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
  		end
  	end
end

function ComboTF()
	if Menu.TFCombo.Qset.comboQ then
		CastQ()
	end

	if Menu.TFCombo.Wset.autoW then
		AutoW()
	end
end

function AutoW()
	if Menu.TFCombo.combo then
		FirstPrio()
		SecondPrio()
		ThirdPrio()
	end
end

function FirstPrio()
	local Name = myHero:GetSpellData(_W).name
	for i, Target in pairs(GetEnemyHeroes()) do
		if Menu.TFCombo.Wset.Wprio == 3 then
			if Target ~= nil and ValidTarget(Target, 900) then
				local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Target, 0, 80, 600, 2000, myHero)
				if nTargets >= Menu.TFCombo.Wset.UseRed then
					spellName = "redcardlock"
					if Name == "PickACard" then
						CastSpell(_W)
					end
				end
			end
		end
	end

	if Menu.TFCombo.Wset.Wprio == 2 then
		if (Menu.TFCombo.Wset.UseBlue*0.01)*myHero.maxMana < myHero.mana and CountEnemyHeroInRange(900) >= 1 then
			spellName = "bluecardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
		end
	end

	if Menu.TFCombo.Wset.Wprio == 1 and CountEnemyHeroInRange(900) >= 1 then
		spellName = "goldcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end
end

function SecondPrio()
	for i, Target in pairs(GetEnemyHeroes()) do
		if Menu.TFCombo.Wset.WprioTwo == 3 then
			if Target ~= nil and ValidTarget(Target, 900) then
				local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Target, 0, 80, 600, 2000, myHero)
				if nTargets >= Menu.TFCombo.Wset.UseRed then
					spellName = "redcardlock"
					if Name == "PickACard" then
						CastSpell(_W)
					end
				end
			end
		end
	end

	if Menu.TFCombo.Wset.WprioTwo == 2 then
		if (Menu.TFCombo.Wset.UseBlue*0.01)*myHero.maxMana < myHero.mana and CountEnemyHeroInRange(900) >= 1 then
			spellName = "bluecardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
		end
	end

	if Menu.TFCombo.Wset.WprioTwo == 1 and CountEnemyHeroInRange(900) >= 1 then
		spellName = "goldcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end
end

function ThirdPrio()
	for i, Target in pairs(GetEnemyHeroes()) do
		if Menu.TFCombo.Wset.WprioTwo == 3 then
			if Target ~= nil and ValidTarget(Target, 900) then
				local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Target, 0, 80, 600, 2000, myHero)
				if nTargets >= Menu.TFCombo.Wset.UseRed then
					spellName = "redcardlock"
					if Name == "PickACard" then
						CastSpell(_W)
					end
				end
			end
		end
	end

	if Menu.TFCombo.Wset.WprioThree == 2 then
		if (Menu.TFCombo.Wset.UseBlue*0.01)*myHero.maxMana < myHero.mana and CountEnemyHeroInRange(900) >= 1 then
			spellName = "bluecardlock"
			if Name == "PickACard" then
				CastSpell(_W)
			end
		end
	end

	if Menu.TFCombo.Wset.WprioThree == 1 and CountEnemyHeroInRange(900) >= 1 then
		spellName = "goldcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end
end

function CastQ()
	if ts.target ~= nil and ValidTarget(ts.target) then
    	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(ts.target, 0.5, 80, Menu.TFCombo.Qset.qRange, 1450, myHero, false)
    	if HitChance >= Menu.TFCombo.Qset.qHitChance and GetDistance(CastPosition) < Menu.TFCombo.Qset.qRange then
        	CastSpell(_Q, CastPosition.x, CastPosition.z)
    	end
	end
end

function CardSelect()
	local Name = myHero:GetSpellData(_W).name

	if Menu.Wsel.selectblue then
		SelectCard = "Blue"
	end

	if Menu.Wsel.selectred then
		SelectCard = "Red"
	end

	if Menu.Wsel.selectgold then
		SelectCard = "Gold"
	end

	if SelectCard == "Blue" then
		spellName = "bluecardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if SelectCard == "Red" then
		spellName = "redcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if SelectCard == "Gold" then
		spellName = "goldcardlock"
		if Name == "PickACard" then
			CastSpell(_W)
		end
	end

	if Name == spellName then
		CastSpell(_W)
		SelectCard = nil
	end
end

function OnDraw()
	if Menu.drawings.drawCircleW then
		--DrawText("2222", 24, 760, 910, 0xFFFF0000)
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x111111)
	end		
	
	if Menu.drawings.drawCircleQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, Menu.TFCombo.Qset.qRange, 0x111111)
	end
	
	if Menu.drawings.drawCircleAA then
		DrawCircle(myHero.x, myHero.y, myHero.z, 600, 0x111111)
	end

	if Menu.drawings.drawCircleR then
		DrawCircle(myHero.x, myHero.y, myHero.z, 5000, 0x111111)
	end

	if DRAWGANKTEXT or ((AdditionalTimeGank-CurrentTimeGank) <= 2) then
		DrawText("Có Tên Ít Máu Ra Kill Xác Nó!", 24, 760, 910, 0xFFFF0000)
	end	
	
		
	
end