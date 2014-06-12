--[ AutoCarry Plugin: Annie Hastur, the Dark Child by UglyOldGuy]--

if myHero.charName ~= "Annie" then return end -- Hero Check

require "AoE_Skillshot_Position" -- Library Required in Common Folder

--[ Plugin Loads] --
function PluginOnLoad()
	loadMain() -- Loads Global Variables
	menuMain() -- Loads AllClass Menu
end
--[/Loads]

--[Plugin OnTick]--
function PluginOnTick()
		Target = AutoCarry.GetAttackTarget(true)
		
		if Menu.dAttack then AutoCarry.CanAttack = false else AutoCarry.CanAttack = true end
		if Menu.qKS and qReady then qKS() end
		if Menu.qHarrass and qReady and Target then CastSpell(_Q, Target) end
		if Menu.qFarm and qReady and Menu.qMana <= MinMana and HaveStun and not Menu.cFarm and not Carry.AutoCarry then qFarm() end
		if Menu.qFarm and qReady and Menu.qMana <= MinMana and not HaveStun and not Carry.AutoCarry then qFarm() end
		if Menu.cStun and eReady and not HaveStun and not Backing then CastSpell(_E) end
		if Menu.bCombo and Carry.AutoCarry then smartCombo() end
end
--[/OnTick]--

function qKS()
		for i = 1, heroManager.iCount, 1 do
                        local qTarget = heroManager:getHero(i)
                        if ValidTarget(qTarget, qRange) then
                                if qTarget.health <=  getDmg("Q", qTarget, myHero) then CastSpell(_Q, qTarget) end
                        end
                end
end

function qFarm()
		for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
                        if ValidTarget(minion) and qReady and GetDistance(minion) <= qRange then
                                if minion.health < getDmg("Q", minion, myHero) then CastSpell(_Q, minion) end
                        end
                end
end

function castR(target)
        if Menu.rMEC then
                local ultPos = GetAoESpellPosition(250, target)
                if ultPos and GetDistance(ultPos) <= rRange     then
                        if CountEnemies(ultPos, 600) >= Menu.MinEnem then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        elseif GetDistance(target) <= rRange then
                CastSpell(_R, target.x, target.z)
        end
end

function PluginOnCreateObj(object)
        if object and object.name == "StunReady.troy" then HaveStun = true end
		if object and GetDistance(object) <= 150 and object.name == "TeleportHome.troy" then Backing = true end
		if object and object.name == "BearFire_foot.troy" then HaveTibbers = true end 
end
 
function PluginOnDeleteObj(object)
        if object and object.name == "StunReady.troy" then HaveStun = false end
		if object and GetDistance(object) <= 150 and object.name == "TeleportHome.troy" then Backing = false end
		if object and object.name == "BearFire_foot.troy" then HaveTibbers = false end
end

function smartCombo()
		if ValidTarget(Target) then
			local dfgDmg, hxgDmg, bwcDmg, iDmg, sheenDmg, triDmg, lichDmg  = 0, 0, 0, 0, 0, 0, 0
			local qDmg = getDmg("Q",Target,myHero)
            local wDmg = getDmg("W",Target,myHero)
            local rDmg = getDmg("R",Target,myHero)
			local myMana = (myHero.mana)
			local qMana = myHero:GetSpellData(_Q).mana
			local wMana = myHero:GetSpellData(_W).mana
			local rMana = myHero:GetSpellData(_R).mana
			local dfgDmg = (dfgSlot and getDmg("DFG",Target,myHero) or 0)
            local hxgDmg = (hxgSlot and getDmg("HXG",Target,myHero) or 0)
            local bwcDmg = (bwcSlot and getDmg("BWC",Target,myHero) or 0)
            local iDmg = (ignite and getDmg("IGNITE",Target,myHero) or 0)
            local onhitDmg = (sheenSlot and getDmg("SHEEN",Target,myHero) or 0)+(triSlot and getDmg("TRINITY",Target,myHero) or 0)+(lichSlot and getDmg("LICHBANE",Target,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)                                                 
            local onspellDmg = (liandrysSlot and getDmg("LIANDRYS",Target,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",Target,myHero) or 0)
            local dpsDmg = onspellDmg
            local itemsDmg = onhitDmg + qDmg + wDmg + rDmg + dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
						
			if Target and Target.health <= dpsDmg + qDmg and qReady then
					ComboDisplay = 1
					if qReady and qMana > myMana then ComboDisplay = 13 end
					if qReady and qMana <= myMana and GetDistance(Target) <= qRange then
					if qReady then CastSpell(_Q, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + itemsDmg + qDmg and qReady then
				ComboDisplay = 2
					if qReady and qMana > myMana then ComboDisplay = 14 end
					if qReady and qMana <= myMana and GetDistance(Target) <= qRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end		
						if qReady then CastSpell(_Q, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + wDmg and wReady then
				ComboDisplay = 3
					if wReady and wMana > myMana then ComboDisplay = 15 end
					if wReady and wMana <= myMana and GetDistance(Target) <= wRange then
						if wReady then CastSpell(_W, Target)  end
					end
			end
				if Target and Target.health <= dpsDmg + itemsDmg + wDmg and wReady then
				ComboDisplay = 4
					if wReady and wMana > myMana then ComboDisplay = 16 end
					if wReady and qMana <= myMana and GetDistance(Target) <= wRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + qDmg + wDmg and qReady and wReady then
				ComboDisplay = 5
				ComboMana = qMana + wMana
					if qReady and  wReady and ComboMana > myMana then ComboDisplay = 17 end
					if ComboMana <= myMana and GetDistance(Target) <= qRange then
						if qReady then CastSpell(_Q, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + itemsDmg + qDmg + wDmg and qReady and wReady then
				ComboDisplay = 6
				ComboMana = qMana + wMana
					if qReady and  wReady and ComboMana > myMana then ComboDisplay = 18 end
					if ComboMana <= myMana and GetDistance(Target) <= qRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end
						if qReady then CastSpell(_Q, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= rDmg and rReady then
				ComboDisplay = 7
					if rReady and  rMana > myMana then ComboDisplay = 19 end
					if rMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
					end
			end
			if Target and Target.health <= rDmg + qDmg and rReady and qReady then
				ComboDisplay = 8
				ComboMana = rMana + qMana
					if rReady and qReady and ComboMana > myMana then ComboDisplay = 20 end
					if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
						if qReady then CastSpell(_Q, Target) end
					end
			end
			if Target and Target.health <= rDmg + wDmg and rReady and wReady then
				ComboDisplay = 9
				ComboMana = rMana + wMana
					if rReady and wReady and ComboMana > myMana then ComboDisplay = 21 end
					if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= rDmg + qDmg + wDmg and rReady and qReady and wReady then
				ComboDisplay = 10
				ComboMana = rMana + qMana + wMana
					if rReady and qReady and wReady and ComboMana > myMana then ComboDisplay = 22 end
					if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
						if qReadt then CastSpell(_Q, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + itemsDmg + rDmg + qDmg + wDmg and rReady and qReady and wReady then
				ComboDisplay = 11
				ComboMana = rMana + qMana + wMana
					if rReady and qReady and wReady and ComboMana > myMana then ComboDisplay = 23 end
					if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end
						if rReady and not HaveTibbers then castR(Target) end
						if qReady and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
						if wReady and GetDistance(Target) <= wRange then CastSpell(_W, Target) end
				end
			end
			if Target and Target.health > dpsDmg + itemsDmg + rDmg + qDmg + wDmg then
				TargetKillable = false
				ComboDisplay = 12
					if dfgReady then CastSpell(dfgSlot, Target) end
					if hxgReady then CastSpell(hxgSlot, Target) end
					if bwcReady then CastSpell(bwcSlot, Target) end
					if rReady and not HaveTibbers and HaveStun and GetDistance(Target) <= rRange then castR(Target) end
					if qReady and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
					if wReady and GetDistance(Target) <= wRange then CastSpell(_W, Target) end
			end
		end
end
function PluginOnDraw()
	if not myHero.dead then
                if Menu.drawQ then
					DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
				end
				for i=1, heroManager.iCount do
					local dTarget = heroManager:GetHero(i)
					if ValidTarget(dTarget) and Menu.drawC then
						DrawCircle(dTarget.x, dTarget.y, dTarget.z, 100, 0xFFFFFF00)
						PrintFloatText(dTarget, 0, PrintList[ComboDisplay])
					end
				end
	end
end

function loadMain()
		Menu = AutoCarry.PluginMenu
		Carry = AutoCarry.MainMenu
        AutoCarry.SkillsCrosshair.range = 625
		MinMana = ((myHero.mana/myHero.maxMana)*100)
		HaveStun = false
		HaveTibbers = false
		KillableTarget = false
		ComboDisplay = 12
		HK1, HK2, HK3 = string.byte("Z"), string.byte("K"), string.byte("T")
        qRange, wRange, eRange, rRange = 625, 625, 600, 630
        qReady, wReady, eReady, rReady = false, false, false, false
		dfgSlot, hxgSlot, bcSlot, sheenSlot, triSlot, lichSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
        iceSlot, liandrysSlot, blackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)  
		qReady = (myHero:CanUseSpell(_Q) == READY)
		wReady = (myHero:CanUseSpell(_W) == READY)
		eReady = (myHero:CanUseSpell(_E) == READY)
		rReady = (myHero:CanUseSpell(_R) == READY)
		dfgReady = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
        hxgReady = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
        bwcReady = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
		waittxt = {}
        iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
		for i=1, heroManager.iCount do waittxt[i] = i*3 end
		PrintList = {"Kill with Q!", "Kill With Items+Q!", "Kill with W!", "Kill with Items+W!",
					 "Kill with Q+W!", "Kill With Items+Q+W", "Kill with R", "Kill with R+Q!", 
					 "Kill with R+W!", "Kill with R+Q+W!",  "Kill with Full Combo!", "Harrass!!", 
					 "Need Mana for Q!", "Need Mana for Q!", "Need Mana for W!", "Need Mana for W!", 
					 "Need Mana for Q+W!", "Need Mana for Q+W!", "Need Mana for R", "Need Mana for R+Q!",
					 "Need Mana for R+W", "Need Mana for R+Q+W!", "Need Mana for Full Combo!"}

end

 
function menuMain()
        Menu:addParam("sep", "-- Farm Options --", SCRIPT_PARAM_INFO, "")
       	Menu:addParam("qFarm", "Disintegrate(Q) - Farm ", SCRIPT_PARAM_ONKEYTOGGLE, false, HK1)
		Menu:addParam("cFarm", "Don't Q Farm if Stun Ready", SCRIPT_PARAM_ONKEYTOGGLE, false, HK2)
		Menu:addParam("qMana", "Minimum % of Mana to farm",  SCRIPT_PARAM_SLICE, 25, 0, 100, 2)
		Menu:addParam("sep1", "-- Combo Options --", SCRIPT_PARAM_INFO, "")
		Menu:addParam("qHarrass", "Disintegrate(Q) - Harrass", SCRIPT_PARAM_ONKEYTOGGLE, true, HK3)
		Menu:addParam("dAttack", "Disable Auto Attacks", SCRIPT_PARAM_ONOFF, false)
		Menu:addParam("cStun", "Charge Stun with E", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("bCombo", "Burst Combo while AutoCarry", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("rMec", "Tibbers Use MEC", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("MinEnem", "Tibbers - Min Enemies",SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
		Menu:addParam("sep2", "-- KS Options --", SCRIPT_PARAM_INFO, "")
		Menu:addParam("qKS", "Disintegrate(Q) - Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
		Menu:addParam("drawQ", "Draw Disintegrate (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("drawC", "Draw Enemy Circles", SCRIPT_PARAM_ONOFF, false)
		
end