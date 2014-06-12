--[[

	SAC Sona plugin 

	Features:
		- Auto-Combo (Q poke - Prevents KS from Q for ultimate ADC feed)
		- PowerCord calculation
			- Cast's E when power cord is ready and a nearby teammate can kill them (slow)
			OR 
			- Cast's W when power cord is ready for damage output reduction 
			OR 
			- Cast's Q when teammates are not nearby and we need to defend ourselves (only when killable) 
			OR 
			- Cast's E on enemy when no teammates are near to get away from enemy 
		- Special R calculation to determine when the enemy can be killed by a nearby ally
		- Auto-Shield (W heal)
		- Cast's E when no enemies are nearby and we are not on fountain 
		- Maximizes aura usage for attack damage 


--]]

require "iFoundation_v2"
local SkillQ = Caster(_Q, 700, SPELL_SELF)
local SkillW = Caster(_W, 1000, SPELL_SELF)
local SkillE = Caster(_E, 1000, SPELL_SELF)
local SkillR = Caster(_R, 1000, SPELL_LINEAR)

local onPowerCord = false 
local powerCordProc = false

NONE = 0 -- DERP?
VALOR = 1 -- AD/AP BUFF
PERSEVERANCE = 2 -- RESISTANCE BUFF
CELERITY = 3 -- MOVEMENT SPEED BUFF

local AuraTable = {
	["valoraura"] = VALOR, 
	["perseveranceaura"] = PERSEVERANCE, 
	["discordaura"] = CELERITY
}

local currentAura = nil

function PluginOnLoad()

	AutoCarry.SkillsCrosshair.range = 600

	MainMenu = AutoCarry.MainMenu
	PluginMenu = AutoCarry.PluginMenu
	PluginMenu:addParam("sep1", "-- Spell Cast Options --", SCRIPT_PARAM_INFO, "")
	PluginMenu:addParam("qProc", "Q Proc", SCRIPT_PARAM_ONOFF, true)
	PluginMenu:addParam("wPercentage", "W percentage",SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	PluginMenu:addParam("pPercentage", "Panic percentage",SCRIPT_PARAM_SLICE, 60, 0, 100, 0)
	--PluginMenu:addParam("eSpam", "Spam E when no enemies are near (mana hungry)", SCRIPT_PARAM_ONOFF, true)
	AutoShield.Instance(SkillW.range, SkillW)
	AutoShield.selfOverride = true
end

function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()

	if Target and MainMenu.AutoCarry and not powerCordProc then

		local ally, damage = GetHighestDamageAlly()
		if onPowerCord and not powerCordProc then
			--> Check for ally
  			if ally then
  				--> Slow enemy when killable 
  				if SkillE:Ready() and (damage > Target.health) then
  					SkillE:Cast(Target) 
  					powerCordProc = true 
  					PrintChat("T1")
  				--> Otherwise decrease damage output 
  				elseif SkillW:Ready() then 
  					SkillW:Cast(Target)
  					powerCordProc = true
  					PrintChat("T2")
  				end  
  			else 
  				--> Finally, cast Q if any ally is not near and we can poke the enemy
  				if SkillQ:Ready() and PluginMenu.qProc then
  					SkillQ:Cast(Target)
  					powerCordProc = true
  					PrintChat("T3")
  				end 
  			end  
		end 

		if ally and not powerCordProc then
			if SkillR:Ready() and (damage > Target.health) then
				SkillR:Cast(Target) 
			elseif GetDistance(Target, ally) < 300 then
				if ally.health < ally.maxHealth * (PluginMenu.wPercentage / 100) and SkillW:Ready() and currentAura ~= PERSEVERANCE then
					SkillW:Cast(Target)
				elseif SkillQ:Ready() and currentAura ~= VALOR then
					SkillQ:Cast(Target) 
				end 
			elseif GetDistance(Target, ally) > 500 then
				if SkillQ:Ready() and currentAura ~= VALOR then
					SkillQ:Cast(Target) 
				end 
			end 
		elseif not powerCordProc then 
			if SkillQ:Ready() then SkillQ:Cast(Target) end 
			if currentAura ~= CELERITY and myHero.health < myHero.maxHealth * (PluginMenu.pPercentage / 100) and SkillE:Ready() then
				SkillE:Cast(Target) 
			end 
		end 
	end
		
end

function GetHighestDamageAlly() 
	local bestChamp = nil 
	local damage = math.huge
	for _, player in pairs(Heroes.GetObjects(1, 1000)) do 
		if not player.dead and not player.isMe then
			if bestChamp == nil then
				bestChamp = player
				damage = DamageCalculation.CalculateRealDamage(Target, player)
			elseif DamageCalculation.CalculateRealDamage(Target, player) > damage then
				bestChamp = player
				damage = DamageCalculation.CalculateRealDamage(Target, player) > Target
			end 
		end 
	end 
	return bestChamp, damage
end 

function OnGainBuff(unit, buff) 
	if unit == nil or buff == nil then return end 
	if unit.isMe and buff then
		--PrintChat("GAINED: " .. buff.name)
		if buff.name == "sonapowerchord" then
			PrintChat("TRUE")
			onPowerCord = true
		end 
		for aura, value in pairs(AuraTable) do
			if buff.name:find(aura) then
				currentAura = value
			end 
		end 
	end 
end 

function OnLoseBuff(unit, buff) 
	if unit == nil or buff == nil then return end 
	if unit.isMe and buff then
		--PrintChat("LOST: " .. buff.name)
		if buff.name == "sonapowerchord" then
			onPowerCord = false
			powerCordProc = false
		end 
	end 
end 