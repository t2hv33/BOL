if myHero.charName ~= "Nami" then return end

require "Prodiction"

local QRange = 850
local QSpeed = math.huge

local WRange = 725
local ERange = 800

local QAble, WAble, EAble = false, false, false

local ProdictQ

local stunned = false
local isslow = false

local slowarray = {}
local bubblearray = {}
function PluginOnLoad()

	for i=1, heroManager.iCount do slowarray[i] = 0 end
	for i=1, heroManager.iCount do bubblearray[i] = 0 end
	AdvancedCallback:bind('OnGainBuff', function(unit, buff) OnGainBuff(unit, buff) end)
	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		igniteslot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		igniteslot = SUMMONER_2
	end
	
	AutoCarry.SkillsCrosshair.range = 850
	
	Menu = AutoCarry.PluginMenu
	Menu:addParam("CanUseQ","Use Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wonenemy","W on bubble enemy", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("selfeonstun","Self E before Q for slow", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("autoig","Auto Ignite", SCRIPT_PARAM_ONOFF, true)
	--0.250
	ProdictQ = ProdictManager.GetInstance():AddProdictionObject(_Q, QRange, QSpeed, 0.8, 200, myHero, 
        function(unit, pos, spell) 
            if GetDistanceSqr(unit) < spell.RangeSqr and myHero:CanUseSpell(spell.Name) == READY then 
				CastSpell(spell.Name, pos.x, pos.z)
            end 
        end)
		
	for I = 1, heroManager.iCount do
			local hero = heroManager:GetHero(I)
			if hero.team ~= myHero.team then
					--ProdictQ:CanNotMissMode(true, hero)
			end
	end
	
	PrintChat(">> Nami bubble bubble 0.3 loaded")
end

function PluginOnTick()

	AutoIgnite()
	
	QAble = (myHero:CanUseSpell(_Q) == READY)
	WAble = (myHero:CanUseSpell(_W) == READY)
	EAble = (myHero:CanUseSpell(_E) == READY)
	Target = AutoCarry.GetAttackTarget()
	
	SlowTimer = 0
	BubbleTimer = 0
	if Target then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy == Target then
				SlowTimer = slowarray[i]
			end
		end
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy == Target then
				BubbleTimer = bubblearray[i]
			end
		end
		if Target and (AutoCarry.MainMenu.AutoCarry) then
			
			if QAble and Menu.CanUseQ then
				if GetGameTimer() < SlowTimer or Menu.selfeonstun == false then
					ProdictQ:EnableTarget(Target, true)
				end
			elseif QAble and not EAble and Menu.CanUseQ then
				ProdictQ:EnableTarget(Target, true)
			end
			if WAble and GetGameTimer() < BubbleTimer and Menu.wonenemy then
                if GetDistance(Target) <= WRange then
                    CastSpell(_W, Target)
                end
			end
			if EAble and QAble and GetGameTimer() > SlowTimer and Menu.selfeonstun then
				if GetDistance(Target) <= ERange then
                    CastSpell(_E)
                end
			end
		end
		if AutoCarry.PluginMenu.noAttack and AutoCarry.MainMenu.AutoCarry then AutoCarry.CanAttack = false else AutoCarry.CanAttack = true end
	end
end

function PluginOnDraw()
    if not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0xFFFFFF)
	end
end

function OnGainBuff(unit, buff)
	if not unit.isMe and buff.name == "namiqfakeknockup" then
		if buff.source ~= nil and buff.source.name == myHero.name then
			for i=1, heroManager.iCount do
				local enemy = heroManager:GetHero(i)
				if enemy == unit then
					bubblearray[i] = buff.endT
				end
			end
		end
	end
	
	if not unit.isMe and buff.name == "namieslow" then
		if buff.source ~= nil and buff.source.name == myHero.name then
			for i=1, heroManager.iCount do
				local enemy = heroManager:GetHero(i)
				if enemy == unit then
					slowarray[i] = buff.endT
				end
			end
		end
	end
end

local function getHitBoxRadius(target)
	return GetDistance(target, target.minBBox)
end

function CastQ(unit, pos, spell)
	if GetDistance(pos) - getHitBoxRadius(unit)/2 < QRange then
			CastSpell(_Q, pos.x, pos.z)
	end
end
	
function AutoIgnite( )
    for _, igtarget in pairs(GetEnemyHeroes()) do
		if ValidTarget(igtarget, 600) and autoig and igtarget.health <= 50 + (20 * player.level) then
        	CastSpell(igniteslot, igtarget)
        end
    end
end