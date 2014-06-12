--[[

	SAC Darius plugin
	Credits to Lux for his Hemo counter 

	Version 1.2 
	- Converted to iFoundation_v2

	LAST TESTED 8.12 WORKING MORE THEN PERFECT (INb4NERF)
--]]

require "iFoundation_v2"

local SkillQ = Caster(_Q, 425, SPELL_SELF)
local SkillW = Caster(_W, 145, SPELL_SELF)
local SkillE = Caster(_E, 540, SPELL_LINEAR_COL, math.huge, 0, 100, true)
local SkillR = Caster(_R, 460, SPELL_TARGETED)

local hemoTable = {
        [1] = "darius_hemo_counter_01.troy",
        [2] = "darius_hemo_counter_02.troy",
        [3] = "darius_hemo_counter_03.troy",
        [4] = "darius_hemo_counter_04.troy",
        [5] = "darius_hemo_counter_05.troy",
}
local enemyTable = {}

function PluginOnLoad()

	AutoCarry.SkillsCrosshair.range = 600

	MainMenu = AutoCarry.MainMenu
	PluginMenu = AutoCarry.PluginMenu
	PluginMenu:addParam("sep1", "-- Spell Cast Options --", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("wRequire", "Require hemo stacks for W", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("rMaxStack", "Cast R on enemy with full stacks", SCRIPT_PARAM_ONOFF, true)

	for i=0, heroManager.iCount, 1 do
        local playerObj = heroManager:GetHero(i)
        if playerObj and playerObj.team ~= myHero.team then
                playerObj.hemo = { tick = 0, count = 0, }
                table.insert(enemyTable,playerObj)
        end
	end
end

function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	enemy = GetEnemy(Target) 

	if Target and MainMenu.AutoCarry then
		if (GetTickCount() - enemy.hemo.tick > 5000) or (enemy and enemy.dead) then enemy.hemo.count = 0 end

		if SkillE:Ready() then SkillE:Cast(Target) end 
		if SkillQ:Ready() then SkillQ:Cast(Target) end
		-- count hemo
		if enemy.hemo.count >= 1 then
			if SkillR:Ready() then
				if getDmg("R", Target, myHero) * (enemy.hemo.count * 0.2) > Target.health then
					SkillR:Cast(Target) 
				elseif enemy.hemo.count == 5 and PluginMenu.rMaxStack then
					SkillR:Cast(Target)
				end 
			elseif SkillW:Ready() then
				SkillW:Cast(Target)
			end 
		end 
		if SkillW:Ready() and not PluginMenu.wRequire then
			SkillW:Cast(Target)
		end 
	end
end

function GetEnemy(target) 
	for i, enemy in pairs(enemyTable) do 
		if enemy and not enemy.dead and enemy.visible and enemy == target then
			return enemy
		end 
	end 
end 

function PluginOnCreateObj(obj)
	if obj then
		if string.find(string.lower(obj.name),"darius_hemo_counter") then
            for i, enemy in pairs(enemyTable) do
                if enemy and not enemy.dead and enemy.visible and GetDistance(enemy,obj) <= 50 then
                    for k, hemo in pairs(hemoTable) do
                        if obj.name == hemo then
                            enemy.hemo.tick = GetTickCount()
                            enemy.hemo.count = k
                            PrintFloatText(enemy,21,k .. " Bleedings")
                        end
                    end
                end
            end
        end
    end 
end 