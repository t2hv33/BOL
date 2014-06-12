--[[
 
        Auto Carry Plugin - Ashe Edition  --- DeniCevap
 
        Activates Q when attacking enemy hero and disables when attacking minions.
        Activates Muramana when attacking enemy hero.
        Press R to let the plugin auto aim the ultimate for you -- only works when the range is over 500 and under 2000. (Inspired from AesEzreal)
 
--]]
 
if myHero.charName ~= "Ashe" then return end


-- Skillshot table/constants "taken" from Ezreal plugin.

-- Constants
local RRange = 2000
local RSpeed = 1.6
local RDelay = 1000
local RWidth = 85

-- Prediction
local SkillR = {spellKey = _R, range = RRange, speed = RSpeed, delay = RDelay, width = RWidth}

 
local frostOn = false
AutoCarry.PluginMenu:addParam("AutoQ", "Activate Q Against Enemy", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("MMana", "Activate Muramana Against Enemy", SCRIPT_PARAM_ONOFF, true) 
AutoCarry.PluginMenu:addParam("ultimate", "Activate auto aim with R", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("useUlt", "Snipe the target with your ultimate", SCRIPT_PARAM_ONKEYDOWN, false, 82) -- R
AutoCarry.PluginMenu:addParam("draw", "Draw text when target is killable by ultimate", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("ManaCheck", "Do not activate Q if low on mana", SCRIPT_PARAM_ONOFF, true)


function PluginOnTick()
	Target = AutoCarry.GetTarget()

	if AutoCarry.PluginMenu.ultimate and AutoCarry.PluginMenu.useUlt and Target ~= nil and Target.type == "obj_AI_Hero" and GetDistance(Target) < RRange and GetDistance(Target) > 500 then
		if myHero:CanUseSpell(_R) == READY and GetDistance(Target) <= RRange then
			if not AutoCarry.GetCollision(SkillR, myHero, Target) then
				AutoCarry.CastSkillshot(SkillR, Target)
			end
		end
	end
end

function CustomAttackEnemy(enemy)
        if enemy.dead or not enemy.valid or not AutoCarry.CanAttack then return end

        if AutoCarry.PluginMenu.AutoQ then
                if ValidTarget(enemy) and enemy.type == "obj_AI_Hero" and not frostOn and ((AutoCarry.PluginMenu.ManaCheck and myHero.mana > 100) or not AutoCarry.PluginMenu.ManaCheck) then
                        CastSpell(_Q)
                elseif ValidTarget(enemy) and enemy.type ~= "obj_AI_Hero" and frostOn then
                        CastSpell(_Q)
                end
        end

        if AutoCarry.PluginMenu.MMana then
        	if ValidTarget(enemy) and enemy.type == "obj_AI_Hero" and ((AutoCarry.PluginMenu.ManaCheck and myHero.mana > 100) or not AutoCarry.PluginMenu.ManaCheck) and not MuramanaIsActive() then
        		MuramanaOn()
        	elseif ValidTarget(enemy) and enemy.type ~= "obj_AI_Hero" and MuramanaIsActive() then
        		MuramanaOff()
        	end
        end

        myHero:Attack(enemy)
        AutoCarry.shotFired = true
end

 
function PluginOnCreateObj(obj)
        if GetDistance(obj) < 100 and obj.name:lower():find("icesparkle") then
                frostOn = true
        end
end
 
function PluginOnDeleteObj(obj)
        if GetDistance(obj) < 100 and obj.name:lower():find("icesparkle") then
                frostOn = false
        end
end

--[[function PluginOnDraw()
	if AutoCarry.PluginMenu.draw then
		if Target ~= nil then
			RDmg = getDmg("R", Target, myHero)
		end

		if Target ~= nil and Target.type == "obj_AI_Hero" and myHero:CanUseSpell(_R) and GetDistance(Target) < RRange and GetDistance(Target) > 500 and Target.health < RDmg then
			DrawCircle(Target.x, Target.y, Target.z, 150, 0xFF0000)
			DrawText("Use R to ult!", 50,520,100,0xFFFF0000)
			PrintFloatText(Target,0,"Ult!")
		end
	end
end]]