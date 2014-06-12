--[[

	Sida's Auto Carry, Singed Plugin.

	
	Features:
		- Mixed Mode:
			- N/A.
		
		- Last Hit:
			- N/A.
		
		- Lane Clean:
			- Uses Q automatically when in range of a enemy minion.
			
		- Auto Carry Mode:
			- Uses Q automatically when in range of an enemy champion (will deactivate too)
			- Uses W automatically when in range (1000) of the enemy.
			- Uses E automatically when in range of the enemy (Flipping tables and what not).
			- Uses R automatically when in range of the enemy.
			
		- Shift Menu:
			- Use Q
			- Use W
			- Use E
			- Use R
				- If any of the Use "KEY" is toggled on then it will use the desired spell in the combo (Auto Carry mode).
	

	Version 1.0
	- Public Release
	
	Instructions on saving the file:
	- Save the file as:
		- SidasAutoCarryPlugin - Singed.lua

--]]

function PluginOnLoad()
QBuff = false
SkillW = {spellKey = _W, range = 1000, speed = 1.1, delay = 0.250, width = 150}
Menu = AutoCarry.PluginMenu
AutoCarry.SkillsCrosshair.range = 1000
SingedMenu()
end
function PluginOnTick()
	ReadyChecks()
	if AutoCarry.MainMenu.LaneClear then
			for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
				if ValidTarget(minion) and GetDistance(minion) <= 350 and QBuff == false then
					CastSpell(_Q)
				end
				
				if ValidTarget(minion) and GetDistance(minion) >= 350 and QBuff == false then
					CastSpell(_Q)
				end
			end
		end
	if Target then
		if (AutoCarry.MainMenu.AutoCarry) then
			SingedCombo()
		end
		
	end
end
function SingedCombo()
			if QREADY then
				if QBuff == false and GetDistance(Target) < 400 and Menu.UseQ then
					CastSpell(_Q)
				end
				
				if QBuff == true and GetDistance(Target) > 400 and Menu.UseQ then
					CastSpell(_Q)
				end
			end
			if WREADY and Menu.UseW then
				AutoCarry.CastSkillshot(SkillW, Target)
			end
			if EREADY and GetDistance(Target) < 205 and Menu.UseE then
				CastSpell(_E, Target)
			end
			if RREADY and GetDistance(Target) < 500 and Menu.UseR then
				CastSpell(_R)
			end
end
function SingedMenu()
Menu:addParam("sep", "-- Skills --", SCRIPT_PARAM_INFO, "")
Menu:addParam("UseQ", "Use Q in Combo", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("UseW", "Use W in Combo", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("UseE", "Use E in Combo", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("UseR", "Use R in Combo", SCRIPT_PARAM_ONOFF, true)
end
function ReadyChecks()
    Target = AutoCarry.GetAttackTarget()
    QREADY = (myHero:CanUseSpell(_Q) == READY )
    WREADY = (myHero:CanUseSpell(_W) == READY )
	EREADY = (myHero:CanUseSpell(_E) == READY )
    RREADY = (myHero:CanUseSpell(_R) == READY ) 
end
function PluginOnCreateObj(object)
	if object and object.name == "Acidtrail_buf.troy" then QBuff = true end
end
function PluginOnDeleteObj(object)
	if object and object.name == "Acidtrail_buf.troy" then QBuff = false end
end