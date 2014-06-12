local SkillQ = {spellKey = _Q, range = 800, speed = 1.8, delay = 270, width = 80}
local SkillE = {spellKey = _E, range = 1000, speed = 1.6, delay = 270, width = 30}
local SkillR = {spellKey = _E, range = 375, speed = 2000, delay = 100}
--Menu--
AutoCarry.PluginMenu:addParam("Combo", "Auto Win", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
AutoCarry.PluginMenu:addParam("ComboMix", "Auto Win", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
AutoCarry.PluginMenu:addParam("AutoW", "Auto W", SCRIPT_PARAM_ONKEYDOWN, true, string.byte("W"))
AutoCarry.PluginMenu:permaShow("AutoW")
--EndOfMenu--
AutoCarry.SkillsCrosshair.range = 900
local minPercents = 0.35
local maxPercents = 0.75
local delay, raz = 0
local qp, qpe = nil, nil
raz = maxPercents - minPercents
function PluginOnTick()

	if AutoCarry.PluginMenu.AutoW then 
		local nameSpell = myHero:GetSpellData(_W).name
		if myHero.dead or myHero:CanUseSpell(_W) ~= READY or GetTickCount() < delay then
                return
        end
       
        local percentLevel = (myHero.level - 1) / 17
        local addedPerc = minPercents + (raz - (raz * percentLevel))
       
        local nameSpell = myHero:GetSpellData(_W).name
        if myHero:CanUseSpell(_W) == READY then
        if (myHero.health / myHero.maxHealth) < addedPerc then
                if nameSpell == "aatroxw2" then
                        CastSpell(_W)
                end
        elseif nameSpell == "AatroxW" then
                CastSpell(_W)
        end
				end
				end
		
	if AutoCarry.PluginMenu.Combo or AutoCarry.PluginMenu.ComboMix then
		QCast()
		ECast()
		RCast()
	end
end
function QCast()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy, QRange) and not enemy.dead and myHero:CanUseSpell(_Q) == READY then 
			AutoCarry.CastSkillshot(SkillQ, enemy)
		end
	end
end
function ECast()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy, ERange) and not enemy.dead and myHero:CanUseSpell(_E) == READY then 
			AutoCarry.CastSkillshot(SkillE, enemy)
		end
	end
end
function RCast()
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy) and GetDistance(enemy) <= 350 and not enemy.dead and myHero:CanUseSpell(_R) == READY then
			CastSpell(_R)
		end 
	end
end
