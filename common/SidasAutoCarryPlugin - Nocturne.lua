--[[
	SAC Nocturne Plugin

	Features 
		- Smart combo
			- Q > W > E

	Version 1.0 
	- Initial release

	Version 1.2 
	- Converted to iFoundation_v2

--]]

require "iFoundation_v2"
local SkillQ = Caster(_Q, 1200, SPELL_LINEAR, 1398, 0.249, 50, true) 
local SkillW = Caster(_W, math.huge, SPELL_SELF)
local SkillE = Caster(_E, 425, SPELL_TARGETED)
-- ignore R... 
function PluginOnLoad()

	AutoCarry.SkillsCrosshair.range = 1200

	MainMenu = AutoCarry.MainMenu
	PluginMenu = AutoCarry.PluginMenu
    PluginMenu:addParam("sep1", "-- Spell Cast Options --", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("wDistance", "W distance", SCRIPT_PARAM_SLICE, 0, 0, 500, 0)
end

function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()

	if Target and MainMenu.AutoCarry then
		if SkillQ:Ready() then SkillQ:Cast(Target) end 
		if SkillW:Ready() and GetDistance(Target) < PluginMenu.wDistance then SkillW:Cast(Target) end 
		if SkillE:Ready() then SkillE:Cast(Target) end 
	end

	if MainMenu.LastHit then
		Combat.LastHit(SkillQ)
	end

end
