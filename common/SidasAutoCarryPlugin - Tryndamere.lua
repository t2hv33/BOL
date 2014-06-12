--[[    Tryndamere The Barbarian King v2.0
		by Silent84
		Credits to: 
		botirk for auto mock
		Sida for items use and the way this script written
		
		
		Hot Keys:

		-Basic Combo: Space
	
		Features:

		-Basic Combo: E -> Item -> AA -> W(if enemy running away)
		-Item Support
		-Auto Ult On/Off
		-Auto W On/Off
		-Move to mouse On/Off
		-Target configuration, Press shift to configure.

		]]

if myHero.charName ~= "Tryndamere" then return end

--------[[Settings]]-----------
local healthpercentage = 20 	--Change this to the percent you would like it to activate the ULT.
-------------------------------

local tsrange = 900
local wRange = 860
local eRange = 700
local predictor = TargetPrediction(400,1,200)
local eSpeed, eDelay = 1.5, 234
local items =
	{
		BRK = {id=3153, range = 500, reqTarget = true, slot = nil },
		BWC = {id=3144, range = 400, reqTarget = true, slot = nil },
		DFG = {id=3128, range = 750, reqTarget = true, slot = nil },
		HGB = {id=3146, range = 400, reqTarget = true, slot = nil },
		RSH = {id=3074, range = 350, reqTarget = false, slot = nil},
		STD = {id=3131, range = 350, reqTarget = false, slot = nil},
		TMT = {id=3077, range = 350, reqTarget = false, slot = nil},
		YGB = {id=3142, range = 350, reqTarget = false, slot = nil}
	}
local ts = TargetSelector(TARGET_LOW_HP,tsrange,DAMAGE_PHYSICAL,true)	
Config = scriptConfig("Barbarian King Tryndamere v1.0", "tryndamere")
Config:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
Config:addParam("autoult", "Auto Ult", SCRIPT_PARAM_ONOFF, true)
Config:addParam("kill", "Kill steal", SCRIPT_PARAM_ONOFF, true)
Config:addParam("autouseW", "Auto use W", SCRIPT_PARAM_ONOFF, true)
Config:addParam("movement", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
Config:addParam("draw", "Draw range circles", SCRIPT_PARAM_ONOFF, true)
Config:permaShow("combo")
Config:permaShow("autoult")
Config:permaShow("kill")
Config:permaShow("autouseW")
ts.name = "Tryndamere"
Config:addTS(ts)

function OnTick()
	ts:update()
	if ts.target then
		if Config.combo then combo() end
		if Config.kill then kill() end
	end
	if ts.target == nil and Config.movement and Config.combo then myHero:MoveTo(mousePos.x, mousePos.z) end
	if Config.autoult then autoUlt() end
end

function combo()
	castE(ts.target)
	UseItems(ts.target)
	myHero:Attack(ts.target)
	if Config.autouseW then tryndMock(ts.target) end
end

function kill()
	if player:GetDistance(ts.target) <= tsrange then
		local eDmg = getDmg("E",ts.target,myHero)
		if	ts.target.health <= eDmg  then
			if CanCast(_E) then castE(ts.target) end	
		end
	end	
end

function autoUlt()
	if not myHero.dead and ((myHero.health * 100) / myHero.maxHealth) <= healthpercentage and CanCast(_R) then
		CastSpell(_R)
	end
end

function castE(target)
	if CanCast(_E) then
		local ePos = getPred(eSpeed, eDelay, target)
		if ePos and GetDistance(ePos) <= eRange then
			CastSpell(_E, ePos.x, ePos.z)
		end
	end
end

-- by botirk
function tryndMock(target)
	local prediction = predictor:GetPrediction(target)
	if prediction ~= nil and math.abs(AIMathRad(myHero,target) - AIMathRad(target,prediction)) < 1.5708 and CanCast(_W) then 
		CastSpell(_W) end
end

--AIMath library by ivan
function AIMathRad(pos1,pos2)
	local a = GetDistance({x=pos1.x,z=pos2.z},{x=pos2.x,z=pos2.z})
	local b = GetDistance({x=pos1.x,z=pos1.z},{x=pos1.x,z=pos2.z})
	local c = GetDistance({x=pos1.x,z=pos1.z},{x=pos2.x,z=pos2.z})
	if pos2.z > pos1.z then
		if pos1.x < pos2.x then 
			return math.acos(b/c)
		else 
			return 6.283185307 - math.acos(b/c) 
		end
	else 
		if pos1.x < pos2.x then 
			return 1.570796327 + math.acos(a/c)
		else 
			return 4.712388980 - math.acos(a/c) 
		end
	end
end

function CanCast(spell)
	return myHero:CanUseSpell(spell) == READY
end

function getHitBoxRadius(target)
    return GetDistance(ts.target.minBBox, ts.target.maxBBox)/2
end
--by Sida
function UseItems(target)
	if target == nil then return end
	for _,item in pairs(items) do
		item.slot = GetInventorySlotItem(item.id)
		if item.slot ~= nil then
			if item.reqTarget and GetDistance(target) < item.range then
				CastSpell(item.slot, target)
			elseif not item.reqTarget then
				if (GetDistance(target) - getHitBoxRadius(myHero) - getHitBoxRadius(target)) < 50 then
					CastSpell(item.slot)
				end
			end
		end
	end
end

function getPred(speed, delay, target)
	if target == nil then return nil end
	local travelDuration = (delay + GetDistance(myHero, target)/speed)
	travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
	travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
	travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed) 	
	return GetPredictionPos(target, travelDuration)
end

function OnDraw()
    if Config.draw and not myHero.dead then
        DrawCircle(myHero.x,myHero.y,myHero.z,wRange,0xFF0000)
        if CanCast(_E) then DrawCircle(myHero.x,myHero.y,myHero.z,eRange,0xFF0000) end
    end
end

PrintChat("<font color='#FFFFFF'>Tryndamere The Barbarian King v2.0</font>")