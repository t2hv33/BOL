--[[
1.0 DONE
--]]
require "iFoundation"
local SkillQ = Caster(_Q, 700, SPELL_LINEAR, 2250, 0.250, 100, true) 
local SkillW = Caster(_W, 450, SPELL_SELF)
local SkillE = Caster(_E, 1025, SPELL_LINEAR, 853, 0.250, 100, true) 
local SkillR = Caster(_R, 700, SPELL_TARGETED) 

local dmgCalc = DamageCalculation(true, {"Q", "W", "E", "R"}) 
local draw = Draw(dmgCalc) 

local monitor = nil

local eClaw = nil 
local eClawRemoved = nil 

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 600

	MainMenu = AutoCarry.MainMenu
	PluginMenu = AutoCarry.PluginMenu
	
	monitor = Monitor(PluginMenu)
end 

function PluginOnTick()
	monitor:MonitorTeam(700)
	monitor:MonitorLowTeamate()
	monitor:AutoPotion()

	Target = AutoCarry.GetAttackTarget()

	if eClaw ~= nil and not eClaw.valid then
		eClaw = nil 
	end 

	-- AutoCarry
	if Target and MainMenu.AutoCarry then

		if dmgCalc:CalculateRealDamage(true, Target) >= Target.health then
			if SkillE:Ready() then SkillE:Cast(Target) end -- First cast
			if SkillQ:Ready() then SkillQ:Cast(Target) end 
			if eClaw ~= nil and eClaw.valid then
				if GetDistance(eClaw, Target) < 50 then 
					if SkillE:Ready() and not UnderTurret(Target) then 
						CastSpell(_E) 
					end -- second cast
				end 
			end 
			if SkillW:Ready() then SkillW:Cast(Target) end 
		end 
		if eClaw == nil and SkillE:Ready() then SkillE:Cast(Target) end 
		if SkillR:Ready() and dmgCalc:CalculateRealDamage(true, Target) >= Target.health then SkillR:Cast(Target) end 
		if SkillQ:Ready() then SkillQ:Cast(Target) end 
		if GetDistance(Target) < SkillW.range and SkillW:Ready() then SkillW:Cast(Target) end 
	end  

	-- LastHit
	if MainMenu.LastHit then
		dmgCalc:LastHitMinion(SkillE, "E")
	end
end 

function PluginOnDraw()
	if Target == nil then return false end 
	draw:DrawTarget(Target)
end 

function PluginOnCreateObj(object)
	if object.name:find("Lissandra_E_Missile.troy") then
		eClaw = object
	end
end

function PluginOnDeleteObj(object)
	if object.name:find("Lissandra_E_Missile.troy") then
		eClaw = nil
		eClawRemoved = GetTickCount()
	end
end