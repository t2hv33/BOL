--[[
	SAC Poppy Plugin
--]]

-- Keys & Config
local KX = string.byte("X") -- Stun nearest possible enemy into wall/structure
local ER = 525 -- Heoric Charge Range
local RR = 900 -- Diplomatic Immunity Range
local killable = {} 
local floattext = {"-Harass-","-Fight/Trade-","-Kill-","-Murder-"} 
local waittxt = {} 
local QREADY, WREADY, EREADY, RREADY, DFGReady, HXGReady, SEReady, IGNITEReady = false, false, false, false, false, false, false, false -- item/ignite cooldown
local DFGSlot, HXGSlot, SESlot, SHEENSlot, TRINITYSlot, LICHBANESlot = nil, nil, nil, nil, nil, nil -- item slots
local enemyTable = GetEnemyHeroes()
local tp = TargetPredictionVIP(1000, 2200, 0.25)

function PluginOnLoad()
	AutoCarry.PluginMenu:addParam("autoStun", "Auto Stun", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("alwaysUlti", "Ulti in Combo", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("stunRandom", "Only use E when Stunable", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("alwaysKS", "Always try to KS", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("drawskillrange", "Draw Ranges", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("stunKey", "Fast Stun Key", SCRIPT_PARAM_ONKEYDOWN, false, KX) -- Hold down X to Fast Stun nearest possible enemy
	PrintChat("Poppy Plugin Loaded! Have fun..")
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
end

function PluginOnTick()
	CooldownHandler()
	DMGCalculation()
	if AutoCarry.MainMenu.AutoCarry then DmgCombo() end
	if AutoCarry.PluginMenu.alwaysKS then tryKS() end
end

function PluginOnDraw()
	if not myHero.dead and AutoCarry.PluginMenu.drawskillrange then
		if myHero:GetSpellData(_E).level > 0 then
		DrawCircle(myHero.x, myHero.y, myHero.z, ER, 0xc2743c)
		end
		for i=1, heroManager.iCount do
			local Unit = heroManager:GetHero(i)
			if ValidTarget(Unit) then 
				if killable[i] == 1 then
				 	DrawCircle(Unit.x, Unit.y, Unit.z, 100, 0xFFFFFF00)
				 end

				 if killable[i] == 2 then
				 	DrawCircle(Unit.x, Unit.y, Unit.z, 100, 0xFFFFFF00)
				 end

				 if killable[i] == 3 then
				 	for j=0, 10 do
				 		DrawCircle(Unit.x, Unit.y, Unit.z, 100+j*0.8, 0x099B2299)
				 	end
				 end

				 if killable[i] == 4 then
				 	for j=0, 10 do
				 		DrawCircle(Unit.x, Unit.y, Unit.z, 100+j*0.8, 0x099B2299)
				 	end
				 end

				 if waittxt[i] == 1 and killable[i] ~= 0 then
				 	PrintFloatText(Unit,0,floattext[killable[i]])
				 end
			end

			if waittxt[i] == 1 then
				waittxt[i] = 30
			else
				waittxt[i] = waittxt[i]-1
			end

		end
		if myHero:GetSpellData(_R).level > 0 then
		DrawCircle(myHero.x, myHero.y, myHero.z, RR, 0xFF6600)
		end
		if AutoCarry.PluginMenu.autoStun or AutoCarry.PluginMenu.stunKey or AutoCarry.MainMenu.AutoCarry then
            local casted = false
            for i, enemyHero in ipairs(enemyTable) do
				if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 520 and GetDistance(enemyHero) > 0 then
                local enemyPosition = AutoCarry.PluginMenu.autoStun and VIP_USER and tp:GetPrediction(enemyHero) or enemyHero
                local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*300

                if enemyHero.x > 0 and enemyHero.z > 0 and PushPos.x > 0 and PushPos.z > 0 then
                local checks = math.ceil((300+65)/65)
                local checkDistance = (300+65)/checks
                local InsideTheWall = false
                for k=1, checks, 1 do
                local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
					if IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z)) then
                         InsideTheWall = true
                         break
                        end
                  end

               if AutoCarry.PluginMenu.autoStun or AutoCarry.PluginMenu.stunKey or AutoCarry.MainMenu.AutoCarry then
					DrawArrows(enemyHero, PushPos, 80, 0xFFFFFF, 0)
					else
                    DrawCircle(PushPos.x, PushPos.y, PushPos.z, 50, 0xFFFF00)
               end

				if not casted and InsideTheWall then
                  CastSpell(_E, enemyHero)
                   casted = true
                            end
                        end
                    end
                end
            end
        end	
end

function tryKS()
	for i=1, heroManager.iCount do
		local killableEnemy = heroManager:GetHero(i)
		if ValidTarget(killableEnemy,SpellRangeQ) and QREADY and (getDmg("Q", killableEnemy, myHero) >= killableEnemy.health) then CastSpell(_Q, killableEnemy) end
		if ValidTarget(killableEnemy, SpellRangeE) and EREADY and (getDmg("E", killableEnemy, myHero) >= killableEnemy.health) then CastSpell(_E, killableEnemy) end
	end
end

function DmgCombo()
	local cdr = math.abs(myHero.cdr*100)
	local target = AutoCarry.GetAttackTarget(true)
	local calcenemy = 1
	local cast = 0
	

	if not ValidTarget(target) then return true end

	for i=1, heroManager.iCount do
    	local Unit = heroManager:GetHero(i)
    	if Unit.charName == target.charName then
    		calcenemy = i
    	end
   	end

    if (killable[calcenemy] == 2 or killable[calcenemy] == 3) and DFGReady then
    	CastSpell(DFGSlot, target)
    end

    if (killable[calcenemy] == 2 or killable[calcenemy] == 3) and HXGReady then
    	CastSpell(HXGSlot, target)
    end

    if killable[calcenemy] == 2 and AutoCarry.PluginMenu.aIGN and IGNITEReady then
    	CastSpell(IGNITESlot, target)
    end

    if cdr <= 20 then
    	if ValidTarget(target, SpellRangeQ) and QREADY then CastSpell(_Q, target) cast = cast + 1 end
    	if ValidTarget(target, SpellRangeW) and WREADY then CastSpell(_W, target) cast = cast + 1 end
    	if ValidTarget(target, SpellRangeE) and EREADY and AutoCarry.PluginMenu.stunRandom == false or (target.health / target.maxHealth) < 0.1 then CastSpell(_E, target) cast = cast + 1 end
		if AutoCarry.PluginMenu.alwaysUlti then
		if ValidTarget(target, SpellRangeR) and RREADY then CastSpell(_R, target) cast = cast + 1 end
		end
    elseif cdr > 20 and cdr < 30 then
    	if ValidTarget(target, SpellRangeQ) and QREADY then CastSpell(_Q, target) cast = cast + 1 end
    	if ValidTarget(target, SpellRangeE) and EREADY and AutoCarry.PluginMenu.stunRandom == false or (target.health / target.maxHealth) < 0.1 then CastSpell(_E, target) cast = cast + 1 end
    	if ValidTarget(target, SpellRangeW) and WREADY then CastSpell(_W, target) cast = cast + 1 end
    	if AutoCarry.PluginMenu.alwaysUlti then
		if ValidTarget(target, SpellRangeR) and RREADY then CastSpell(_R, target) cast = cast + 1 end
		end
    else
    	if ValidTarget(target, SpellRangeQ) and QREADY then CastSpell(_Q, target) cast = cast + 1 end
    	UseUlti(target)
		if ValidTarget(target, SpellRangeW) and WREADY then CastSpell(_W, target) cast = cast + 1 end
		if ValidTarget(target, SpellRangeE) and EREADY and AutoCarry.PluginMenu.stunRandom == false or (target.health / target.maxHealth) < 0.1 then CastSpell(_E, target) cast = cast + 1 end
		if AutoCarry.PluginMenu.alwaysUlti then
		if ValidTarget(target, SpellRangeR) and RREADY then CastSpell(_R, target) cast = cast + 1 end
		end
	end
end


function CooldownHandler()
	DFGSlot, HXGSlot, SESlot, SHEENSlot, TRINITYSlot, LICHBANESlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3040), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGReady = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	SEReady = (SESlot ~= nil and myHero:CanUseSpell(SESlot) == READY)
	IGNITEReady = (IGNITESlot ~= nil and myHero:CanUseSpell(IGNITESlot) == READY)
end

function DMGCalculation()
	for i=1, heroManager.iCount do
        local Unit = heroManager:GetHero(i)
        if ValidTarget(Unit) then
        	local DFGDamage, HXGDamage, LIANDRYSDamage, IGNITEDamage, SHEENDamage, TRINITYDamage, LICHBANEDamage = 0, 0, 0, 0, 0, 0, 0
        	local QDamage = getDmg("Q",Unit,myHero)
			local WDamage = getDmg("W",Unit,myHero)
			local EDamage = getDmg("E",Unit,myHero)
			local HITDamage = getDmg("AD",Unit,myHero)
			local ONHITDamage = (SHEENSlot and getDmg("SHEEN",Unit,myHero) or 0)+(TRINITYSlot and getDmg("TRINITY",Unit,myHero) or 0)+(LICHBANESlot and getDmg("LICHBANE",Unit,myHero) or 0)
			local ONSPELLDamage = (LIANDRYSSlot and getDmg("LIANDRYS",Unit,myHero) or 0)+(BLACKFIRESlot and getDmg("BLACKFIRE",Unit,myHero) or 0)
			local IGNITEDamage = (IGNITESlot and getDmg("IGNITE",Unit,myHero) or 0)
			local DFGDamage = (DFGSlot and getDmg("DFG",Unit,myHero) or 0)
			local HXGDamage = (HXGSlot and getDmg("HXG",Unit,myHero) or 0)
			local LIANDRYSDamage = (LIANDRYSSlot and getDmg("LIANDRYS",Unit,myHero) or 0)
			local combo1 = HITDamage + ONHITDamage + ONSPELLDamage
			local combo2 = HITDamage + ONHITDamage + ONSPELLDamage
			local combo3 = HITDamage + ONHITDamage + ONSPELLDamage
			local mana = 0

			if QREADY then
				combo1 = combo1 + QDamage
				combo2 = combo2 + QDamage
				combo3 = combo3 + QDamage
				mana = mana + myHero:GetSpellData(_Q).mana
			end

			if WREADY then
				combo1 = combo1 + WDamage
				combo2 = combo2 + WDamage
				combo3 = combo3 + WDamage
				mana = mana + myHero:GetSpellData(_W).mana
			end

			if EREADY then
				combo1 = combo1 + EDamage
				combo2 = combo2 + EDamage
				combo3 = combo3 + EDamage
				mana = mana + myHero:GetSpellData(_E).mana
			end
			
			if RREADY then
				if myHero:GetSpellData(_R).level == 1 then
					combo1 = combo1 * 1.2
					combo2 = combo2 * 1.2
					combo3 = combo3 * 1.2
					elseif myHero:GetSpellData(_R).level == 2 then
					combo1 = combo1 * 1.3
					combo2 = combo2 * 1.3
					combo3 = combo3 * 1.3
					else
					combo1 = combo1 * 1.4
					combo2 = combo2 * 1.4
					combo3 = combo3 * 1.4
				end
				mana = mana + myHero:GetSpellData(_E).mana
			end

			if DFGReady then
				combo2 = combo2 + DFGDamage
				combo3 = combo3 + DFGDamage
			end

			if HXGReady then
				combo2 = combo2 + HXGDamage
				combo3 = combo3 + HXGDamage
			end

			if IGNITEReady then
				combo3 = combo3 + IGNITEDamage
			end

			killable[i] = 1

			if (combo3 >= Unit.health) and (myHero.mana >= mana) then
				killable[i] = 2
			end

			if (combo2 >= Unit.health) and (myHero.mana >= mana) then
				killable[i] = 3
			end

			if (combo1 >= Unit.health) and (myHero.mana >= mana) then
				killable[i] = 4
			end
		end
	end
end

