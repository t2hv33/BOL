--[[

	Sida's Auto Carry, Sion Plugin.

	[[
	Features:
		- Mixed Mode:
			- Uses Q to harras.
			- Activates E if not activated.
		
		- Last Hit & Lane Clean:
			- Activates E if not activated.
			
		- Auto Carry Mode:
			- Uses Q to stun your target.
			- Uses W to shield and will reactivate again whilst the target is in range.
			- Activates E if not activated.
			- Uses R if your target is in rage.
			
		- Shift Menu:
			- Use W.
				- If toggled on, the script will include your shield in the combo for extra damage.
			- Use R.
				- If toggled on, the script will unclude your ultimate in the combo for attack speed and life steal.
	]]

	--[[Version 1.0
	- Public Release
	
	Instructions on saving the file:
	- Save the file as:
		- SidasAutoCarryPlugin - Sion.lua
	
]]



function PluginOnLoad()
eActive = false
Menu = AutoCarry.PluginMenu
AutoCarry.SkillsCrosshair.range = 600
MyMenu()
end

function PluginOnTick()
if (AutoCarry.MainMenu.MixedMode or AutoCarry.MainMenu.LastHit or AutoCarry.MainMenu.LaneClear) then
			if not eActive then
			CastSpell(_E)	
			end
		end
	Checks()	
	if Target then
		if (AutoCarry.MainMenu.AutoCarry) then
			if QREADY and GetDistance(Target) < 550 then
				CastSpell(_Q, Target)
			end			
			if WREADY and Menu.UseW and GetDistance(Target) < 525 then
				CastSpell(_W)
			end
			if RREADY and Menu.UseR and GetDistance(Target) < 400 then
				CastSpell(_R)
			end
			if not eActive then
			CastSpell(_E)	
			end
		end
		if (AutoCarry.MainMenu.MixedMode) then
			CastSpell(_Q, Target)
			if not eActive then
			CastSpell(_E)	
			end
		end
	end
end

function Checks()
        Target = AutoCarry.GetAttackTarget()
        QREADY = (myHero:CanUseSpell(_Q) == READY )
        WREADY = (myHero:CanUseSpell(_W) == READY )
        RREADY = (myHero:CanUseSpell(_R) == READY ) 
end


function MyMenu()
Menu:addParam("sep", "-- Skills --", SCRIPT_PARAM_INFO, "")
Menu:addParam("UseW", "Use Shield On Key Down", SCRIPT_PARAM_ONOFF, true)
Menu:addParam("UseR", "Use Ultimate On Key Down", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnCreateObj(object)
if object and object.name == "Enrageweapon_buf.troy" then eActive = true end
end

function PluginOnDeleteObj(object)
if object and object.name == "Enrageweapon_buf.troy" then eActive = false end
end