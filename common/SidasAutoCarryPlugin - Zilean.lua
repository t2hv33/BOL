--[[

	Zilean The Evil Time Bomb by Lillgoalie [REWORKED]
	Version: 1.1
	
	Features:
	
		- Combo Mode:
			- Uses Q, W, Q , E (if E enabled in menu)
			- Checks if Q is not available before using W

	
	Instructions on saving the file:
	- Save the file in scripts folder
	
--]]
if myHero.charName ~= "Zilean" then return end

local ts

function OnLoad()
	-- Menu
	Config = scriptConfig("Zilean by Lillgoalie", "ZileanBL")
	Config:addParam("drawCircleAA", "Draw AA Range", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawCircleQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("drawCircleR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("FarmR", "Farm R with W", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("comboE", "Use E in combo", SCRIPT_PARAM_ONOFF, true)
	Config:addParam("combo", "Combo mode", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	
	-- Target Selector
	ts = TargetSelector(TARGET_LOW_HP_PRIORITY,700)
	
	-- Message
	PrintChat("Loaded Zilean By Lillgoalie")
end

function OnTick()
	-- Check for enemies repeatly
	ts:update()
	
	-- Enemy in range?
	if (ts.target ~= nil) then
		-- Combo key pressed?
		if (Config.combo) then
			-- Able to cast Q?
			if (myHero:CanUseSpell(_Q) == READY) then
				-- Cast spell on target
				CastSpell(_Q, ts.target)
			end
				-- Able to cast W?
			if (myHero:CanUseSpell(_W) == READY) then
				-- Not able to cast Q?
				if (myHero:CanUseSpell(_Q) ~= READY) then
					-- Cast spell on enemy
					CastSpell(_W)
				end
			end
			
			-- E in combo enabled?
			if (Config.comboE) then
				-- Able to cast E?
				if (myHero:CanUseSpell(_E) == READY) then
					-- Cast spell on target
					CastSpell(_E, ts.target)
				end
			end
		end
	end
			
end

function OnDraw()
	--Draw Range if activated in menu
		if (Config.drawCircleAA) then
			DrawCircle(myHero.x, myHero.y, myHero.z, 600, ARGB(255, 0, 255, 0))
		end
		if (Config.drawCircleQ) then
			DrawCircle(myHero.x, myHero.y, myHero.z, 700, 0x111111)
		end
		if (Config.drawCircleR) then
			DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0x111111)
		end
end
