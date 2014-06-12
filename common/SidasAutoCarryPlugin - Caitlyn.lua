--Caitlyn SAC
if myHero.charName ~= "Caitlyn" then return end

function PluginOnLoad()
  mainLoad()
	mainMenu()
end

function mainLoad()
	qRange, wRange, rRange = 1250, 950, 2000
	QREADY, WREADY, EREADY, RREADY, FREADY = false, false, false, false, false
	SkillQ = {spellKey = _Q, range = qRange, speed = 2.10, delay = 625}
	CastQ = AutoCarry.CastSkillshot
	Menu = AutoCarry.PluginMenu
  flashEscape = false
  
  
  if (myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") == nil) and (myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") == nil) then Flash = nil
  elseif myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then Flash = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then Flash = SUMMONER_2 end
  
end

--> Main Menu
function mainMenu()
  Menu:addParam("alt", "Alternate", SCRIPT_PARAM_ONKEYDOWN, false, 17)  
  Menu:addParam("Dash", "Dash", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
  Menu:addParam("rKill", "Killshot with R", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
	Menu:addParam("sep", "-- Cast Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("qKill", "Killshot with Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep1", "-- Weapon Options --", SCRIPT_PARAM_INFO, "")
  Menu:addParam("toggleQ", "Toggle Q Cast", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("castQ", "Fire Q", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("castW", "Drop Trap", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")  
	Menu:addParam("drawMaster", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawQ", "Draw - Peacemaker", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("drawR", "Draw - Ace in the Hole", SCRIPT_PARAM_ONOFF, true)  
end

function getMyRange()
  return myHero.range + GetDistance(myHero.minBBox) + 100
end

function PluginOnTick()
  Checks()
  if RREADY then rKill() end
  if Menu.qKill and QREADY then qKill() end
  
  if not Menu.toggleQ then
    if Menu.alt then
      Menu.castQ = true
      flashEscape = true
    elseif Menu.alt == false then
      Menu.castQ = false
      flashEscape = false
    end
  elseif Menu.toggleQ then
    Menu.castQ = true
  end
  
  
  if Menu.Dash then    
    myHero:MoveTo(mousePos.x,mousePos.z)
    if not flashEscape then
      if WREADY and Menu.castW then 
        for i, enemy in ipairs(GetEnemyHeroes()) do
          if enemy and GetDistance(enemy) < 400 then
            CastSpell(_W,myHero.x,myHero.z)
          end
        end
      end
      if EREADY then
        MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
        HeroPos = Vector(myHero.x, myHero.y, myHero.z)
        DashPos = HeroPos + ( HeroPos - MPos )*(500/GetDistance(mousePos))
        myHero:MoveTo(mousePos.x,mousePos.z)
        CastSpell(_E,DashPos.x,DashPos.z)
        myHero:MoveTo(mousePos.x,mousePos.z)
      end
    end
    if flashEscape then
      if WREADY and Menu.castW then  
        for i, enemy in ipairs(GetEnemyHeroes()) do
          if enemy and GetDistance(enemy) < 400 then
            CastSpell(_W,myHero.x,myHero.z)
          end
        end
      end
      if FREADY then
        myHero:MoveTo(mousePos.x,mousePos.z)
        CastSpell(Flash,mousePos.x,mousePos.z)
        myHero:MoveTo(mousePos.x,mousePos.z)
      end
    end
  end
  
  if Menu.castQ and QREADY then
    AutoCarry.SkillsCrosshair.range = 1300
  else
    AutoCarry.SkillsCrosshair.range = getMyRange()
  end  

	if Target then
    if AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode then
      if QREADY and GetDistance(Target) > getMyRange() then
        if Menu.castQ then
          if GetDistance(Target) < qRange then CastQ(SkillQ, Target) myHero:Attack(Target) end
        end
      end
    end    
	end
end

function OnAttacked()
  if Target then
    if AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode then
      if QREADY then
        if Menu.castQ then
          if GetDistance(Target) < qRange then CastQ(SkillQ, Target) myHero:Attack(Target) end
        end
      end
    end    
	end
end

function PluginOnDraw()
	if not myHero.dead then
		if QREADY and Menu.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FFFF)
		end
		if RREADY and Menu.drawR then
			DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x00FF00)
		end
	end
end

function rKill()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local rDmg = getDmg("R", enemy, myHero)
    local qDmg = getDmg("Q", enemy, myHero)
    local aaDmg = getDmg("AD", enemy, myHero)
		if enemy and not enemy.dead and enemy.health < rDmg and GetDistance(enemy) < rRange then     
      if enemy.health > aaDmg or (enemy.health < aaDmg and GetDistance(enemy) > getMyRange()) and (enemy.health > qDmg or (enemy.health < qDmg and GetDistance(enemy) > qRange)) then
        PrintFloatText(myHero, 0, "Press R For Killshot")
        if Menu.rKill then
          CastSpell(_R,enemy)
        end
      end
    end    
	end
end

function qKill()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local qDmg = getDmg("Q", enemy, myHero)
    local aaDmg = getDmg("AD", enemy, myHero)
    if enemy and not enemy.dead and enemy.health < qDmg and GetDistance(enemy) < qRange then
      if enemy.health > aaDmg or (enemy.health < aaDmg and GetDistance(enemy) > getMyRange()) then    
        CastQ(SkillQ, enemy)
      end
    end
	end
end

function Checks()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
  FREADY = (Flash ~= nil and myHero:CanUseSpell(Flash) == READY)
  if player:GetSpellData(_R).level < 1 then rRange = 1300
  elseif player:GetSpellData(_R).level == 1 then rRange = 2000
  elseif player:GetSpellData(_R).level == 3 then rRange = 2500
  elseif player:GetSpellData(_R).level == 3 then rRange = 3000
  end
end