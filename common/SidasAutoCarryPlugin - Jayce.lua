class 'Plugin'

if myHero.charName ~= "Jayce" then return end

require "Prodiction"

local Skills, Keys, Items, Data, Jungle, Helper, MyHero, Minions, Crosshair, Orbwalker = AutoCarry.Helper:GetClasses()
local JayceType = 1 -- 1 = hammer, 2 = gun
local Passive = false

function Plugin:__init()
	AdvancedCallback:bind('OnGainBuff', function(unit, buff) self:OnGainBuff(unit, buff) end)
	AdvancedCallback:bind('OnLoseBuff', function(unit, buff) self:OnLoseBuff(unit, buff) end)
	if TargetHaveBuff("jaycestancehammer") then JayceType = 1 else JayceType = 2 end
	PrintChat("MFS: Jayce v1.0")
	ProdQ = ProdictManager.GetInstance():AddProdictionObject(_Q, 1800, 1600, 0.285, 50)   -- (spell, range, missilespeed, delay, width)
	QSkill = Skills:NewSkill(false, _Q, 1800, "JayceToTheSkies", AutoCarry.SPELL_LINEAR_COL, 0, false, false, 1600, 0.285, 50, true)
end
function Plugin:OnTick()
	Target = Crosshair:GetTarget()
	if ValidTarget(Target) then qPos = ProdQ:GetPrediction(Target) end
	
	if Keys.AutoCarry then self:Combo() end
	if Keys.MixedMode then self:Combo() end
	if Keys.LaneClear and AutoCarry.PluginMenu.uselc then self:Harass() end
end
function Plugin:Combo()
	if JayceType == 1 and Target then
		if GetDistance(Target) > (MyHero.TrueRange + 30) and GetDistance(Target) < 600 then
			if GetDistance(Target) < 600 and myHero:CanUseSpell(_Q) == READY  then
				CastSpell(_Q, Target)
			end
			if GetDistance(Target) < MyHero.TrueRange and myHero:CanUseSpell(_W) == READY then
				CastSpell(_W)
			end
			if AutoCarry.PluginMenu.useE and myHero:CanUseSpell(_E) == READY then
				CastSpell(_E, Target)
			end
		else
			if AutoCarry.PluginMenu.useE and myHero:CanUseSpell(_E) == READY then
				CastSpell(_E, Target)
			end
			if GetDistance(Target) < 600 and myHero:CanUseSpell(_Q) == READY  then
				CastSpell(_Q, Target)
			end
			if GetDistance(Target) < MyHero.TrueRange and myHero:CanUseSpell(_W) == READY then
				CastSpell(_W)
			end
		end
		if AutoCarry.PluginMenu.autoS and not Passive and myHero:CanUseSpell(_R) == READY and GetDistance(Target) > MyHero.TrueRange + 10 then CastSpell(_R) end
	
	elseif JayceType == 2 and Target then
		if not QSkill:GetCollision(qPos) and myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_E) == READY and GetDistance(Target) <= 1800 then
			
			GatePos = self:GetGatePos()
			CastSpell(_E, GatePos.x, GatePos.z) 
			CastSpell(_Q, qPos.x, qPos.z)
			if myHero:CanUseSpell(_W) == READY then CastSpell(_W) end
		else 
			if not QSkill:GetCollision(qPos) and myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_E) ~= READY and GetDistance(qPos) <= 850 and myHero:GetSpellData(_E).currentCd > 3 then
				CastSpell(_Q, qPos.x, qPos.z)
				if myHero:CanUseSpell(_W) == READY then CastSpell(_W) end
			end
		end
		if AutoCarry.PluginMenu.autoS and not Passive and myHero:CanUseSpell(_R) == READY and GetDistance(Target) <= 600 then CastSpell(_R) end
	end
end
function Plugin:Harass()
	if JayceType == 1 and Target then
		if GetDistance(Target) < 600 and myHero:CanUseSpell(_Q) == READY  then
			CastSpell(_Q, Target)
		end
		if GetDistance(Target) < MyHero.TrueRange and myHero:CanUseSpell(_W) == READY then
			CastSpell(_W)
		end
		if  AutoCarry.PluginMenu.useE and myHero:CanUseSpell(_E) == READY then
			CastSpell(_E, Target)
		end
	elseif JayceType == 2 and Target then
		if not QSkill:GetCollision(qPos) and myHero:CanUseSpell(_Q) == READY and myHero:CanUseSpell(_E) == READY and GetDistance(qPos) <= 1800 then
			GatePos = self:GetGatePos()
			CastSpell(_E, GatePos.x, GatePos.z) 
			CastSpell(_Q, qPos.x, qPos.z)
		end
	end
end

function Plugin:OnGainBuff(unit, buff)
	if unit.isMe then
		if buff.name == "jaycepassiverangedattack" or buff.name == "jaycepassivemeleeattack" then 
			Passive = true
		end
		if(buff.name == "jaycestancehammer") then 
			JayceType = 1 
			
		elseif(buff.name == "jaycestancegun") then
			JayceType = 2 
		end	
		
	end
end 
function Plugin:OnLoseBuff(unit, buff)
	if unit.isMe then
		if buff.name == "jaycepassiverangedattack" or buff.name == "jaycepassivemeleeattack" then 
			Passive = false
		end
	end
end 
function Plugin:GetGatePos()
	MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
	HeroPos = Vector(myHero.x, myHero.y, myHero.z)
	return HeroPos + ( HeroPos - MPos )*(-180/GetDistance(mousePos)) 
end 

AutoCarry.Plugins:RegisterPlugin(Plugin())
AutoCarry.PluginMenu:addParam("useE", "E in combo (Hammer)", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("autoS", "Auto switch in combo", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("uselc", "Auto harass in laneclear", SCRIPT_PARAM_ONOFF, false)