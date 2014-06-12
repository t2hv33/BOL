if VIP_USER then
	require 'VPrediction'
	require 'Collision'
end

FSLVersion = "1.3"
local latestVersion = nil
local updateCheck = false

function getDownloadVersion(response)
    latestVersion = response
end
function getVersion()
    GetAsyncWebResult("dl.dropboxusercontent.com","/s/y2mvdukzufccytw/FSL_Version.txt", a,getDownloadVersion)
end 
getVersion()
function update()
    if updateCheck == false then
        local PATH = BOL_PATH.."Scripts\\Common\\FSL.lua"
        local URL = "http://dl.dropboxusercontent.com/s/ocrro1tgfeoc1ta/FSL.lua"
        if latestVersion~=nil and latestVersion ~= FSLVersion then
            updateCheck = true
            PrintChat("UPDATING FSL.lua")
            DownloadFile(URL, PATH,function ()
                PrintChat("UPDATED - reload please (F9 twice)")
            end)            
        elseif latestVersion == FSLVersion then
            updateCheck = true
            PrintChat("<font color=\"#CC00FF\">FreezingShot Lib Version " .. FSLVersion .. "</font>")       
        end
    end
end
AddTickCallback(update)
--[[
                                                                                                            
                                             bbbbbbbb                                                       
        GGGGGGGGGGGGGlllllll                 b::::::b                              lllllll                  
     GGG::::::::::::Gl:::::l                 b::::::b                              l:::::l                  
   GG:::::::::::::::Gl:::::l                 b::::::b                              l:::::l                  
  G:::::GGGGGGGG::::Gl:::::l                  b:::::b                              l:::::l                  
 G:::::G       GGGGGG l::::l    ooooooooooo   b:::::bbbbbbbbb      aaaaaaaaaaaaa    l::::l     ssssssssss   
G:::::G               l::::l  oo:::::::::::oo b::::::::::::::bb    a::::::::::::a   l::::l   ss::::::::::s  
G:::::G               l::::l o:::::::::::::::ob::::::::::::::::b   aaaaaaaaa:::::a  l::::l ss:::::::::::::s 
G:::::G    GGGGGGGGGG l::::l o:::::ooooo:::::ob:::::bbbbb:::::::b           a::::a  l::::l s::::::ssss:::::s
G:::::G    G::::::::G l::::l o::::o     o::::ob:::::b    b::::::b    aaaaaaa:::::a  l::::l  s:::::s  ssssss 
G:::::G    GGGGG::::G l::::l o::::o     o::::ob:::::b     b:::::b  aa::::::::::::a  l::::l    s::::::s      
G:::::G        G::::G l::::l o::::o     o::::ob:::::b     b:::::b a::::aaaa::::::a  l::::l       s::::::s   
 G:::::G       G::::G l::::l o::::o     o::::ob:::::b     b:::::ba::::a    a:::::a  l::::l ssssss   s:::::s 
  G:::::GGGGGGGG::::Gl::::::lo:::::ooooo:::::ob:::::bbbbbb::::::ba::::a    a:::::a l::::::ls:::::ssss::::::s
   GG:::::::::::::::Gl::::::lo:::::::::::::::ob::::::::::::::::b a:::::aaaa::::::a l::::::ls::::::::::::::s 
     GGG::::::GGG:::Gl::::::l oo:::::::::::oo b:::::::::::::::b   a::::::::::aa:::al::::::l s:::::::::::ss  
        GGGGGG   GGGGllllllll   ooooooooooo   bbbbbbbbbbbbbbbb     aaaaaaaaaa  aaaallllllll  sssssssssss    
                                                                                                            
                                                                                                            
                                                                                                            
                                                                                                            
                                                                                                            
                                                                                                            
                                                                                                            
]]--
if VIP_USER then
	FSLVP = VPrediction()
end
SPELL_NORMAL = 0
SPELL_ON_POINT = 1
SPELL_ON_TARGET = 2
SPELL_SKILL_SHOT = 3

FSLEnemyTable = {}
FSLAllyTable = {}

FSLTurretsTable = {}
FSLAllyTurretsTable = {}
FSLEnemyTurretsTable = {}

FSLMinionsTable = {}

TEAM_RED = 200
TEAM_BLUE = 100


ColorTable = {
	Black = ARGB(0x00,0x00,0x00,0x00),
	Silver = ARGB(0x00,0xC0,0xC0,0xC0),
	Gray = ARGB(0x00,0x80,0x80,0x80),
	White = ARGB(0xFF,0xFF,0xFF,0xFF),
	Maroon = ARGB(0x00,0x80,0x00,0x00),
	Red = ARGB(0x00,0xFF,0x00,0x00),
	Purple = ARGB(0x00,0x80,0x00,0x80),
	Pink = ARGB(0x00,0xFF,0x00,0xFF),
	Green = ARGB(0x00,0x00,0x80,0x00),
	Lime = ARGB(0x00,0x00,0xFF,0x00),
	Olive = ARGB(0x00,0x80,0x80,0x00),
	Yellow = ARGB(0x00,0xFF,0xFF,0x00),
	Navy = ARGB(0x00,0x00,0x00,0x80),
	Blue = ARGB(0x00,0x00,0x00,0xFF),
	Teal = ARGB(0x00,0x00,0x80,0x80),
	Aqua = ARGB(0x00,0x00,0xFF,0xFF)
}

local HemorrhageArray ={
    [1] = "darius_hemo_counter_01.troy",
    [2] = "darius_hemo_counter_02.troy",
    [3] = "darius_hemo_counter_03.troy",
    [4] = "darius_hemo_counter_04.troy",
    [5] = "darius_hemo_counter_05.troy",
}

--[[
	Packets
MOVE = 2
ATTACK = 3
ATTACK_CLOSEST_TARGET = 7
	
]]--

FSL_MOVE = 2
FSL_ATTACK = 3
FSL_ATTACK_CLOSEST_TARGET = 7

function SendPacketCastSpell(SpellID, ToX, ToZ, Target)
	if ToX == 0 then
		ToX = Target.x
	end
	if ToZ == 0 then
		ToZ = Target.z
	end
	local TargetID = 0 
	if Target ~= nil then
		TargetID = Target.networkID
	end
	local Packet = CLoLPacket(153) 
	Packet.dwArg1 = 1
	Packet.dwArg2 = 0
	Packet:EncodeF(myHero.networkID) -- HeroID
	Packet:Encode1(SpellID) -- SpellID
	Packet:EncodeF(ToX) -- ToX
	Packet:EncodeF(ToZ) -- ToZ
	Packet:EncodeF(myHero.x) -- FromX
	Packet:EncodeF(myHero.z) -- FormZ
	Packet:EncodeF(TargetID) -- TargetID
	SendPacket(Packet)
end

function SendPacketMove(Type, PosX, PosY, TargetID)
	local Packet = CLoLPacket(113) -- 
	Packet.dwArg1 = 1
	Packet.dwArg2 = 0
	Packet:EncodeF(myHero.networkID)
	Packet:Encode1(Type) -- Move Type
	Packet:EncodeF(PosX) -- To X
	Packet:EncodeF(PosY) -- To Z
	Packet:EncodeF(TargetID or 0) -- Target network id
	Packet:EncodeF(0)
	Packet:EncodeF(0)
	Packet:EncodeF(0)
	Packet:Encode1(0)
	SendPacket(Packet)
end

--[[



]]--

Pos = function(x, y, z)
	return{
		x = x,
		y = y,
		z = z,
	}
end

function ReturnPosXYZ(Position)
	return Position.x, Position.y, Position.z
end

function Get2dDistance(P1, P2)
	if P1 ~= nil and P2 ~= nil then
		return math.sqrt( (P1.x-P2.x)*(P1.x-P2.x) + (P1.z-P2.z)*(P1.z-P2.z) )
	end
	return math.huge
end
function Get3dDistance(P1, P2)
	if P1 ~= nil and P2 ~= nil then
		return math.sqrt( (P1.x-P2.x)*(P1.x-P2.x) + (P1.y-P2.y)*(P1.y-P2.y) + (P1.z-P2.z)*(P1.z-P2.z) )
	end
	return math.huge
end
function DrawPolygon(Pos, Sides, Radius, Width, Color)
	if Pos ~= nil then
		local angle = 0.0
		local angle_increment = 2 * math.pi / Sides
		Points = {}
		
		for i=1, Sides do
			x = Pos.x + Radius * math.cos(angle)
			z = Pos.z + Radius * math.sin(angle)
			Points[i] = {x = x, y = Pos.y, z= z}
			angle = angle + angle_increment
		end
		Points[Sides+1] = Points[1]
		DrawLines3D(Points, Width, Color)
	end
end



function Draw3DBox(Object, Linesize, Linecolor)
	Linesize = Linesize or 1
	Linecolor = Linecolor or ARGB(255, 255, 255, 0)
	if Object and Object.minBBox then
	
		x1, y1, z1 = get2DFrom3D(Object.minBBox.x, Object.minBBox.y, Object.minBBox.z)
		x2, y2, z2 = get2DFrom3D(Object.maxBBox.x, Object.minBBox.y, Object.minBBox.z)
		x3, y3, z3 = get2DFrom3D(Object.minBBox.x, Object.maxBBox.y, Object.maxBBox.z)
		x4, y4, z4 = get2DFrom3D(Object.maxBBox.x, Object.maxBBox.y, Object.maxBBox.z)
		
		DrawLine(x1, y1, x2, y2, Linesize, Linecolor)
		DrawLine(x2, y2, x4, y4, Linesize, Linecolor)
		DrawLine(x3, y3, x1, y1, Linesize, Linecolor)
		DrawLine(x4, y4, x3, y3, Linesize, Linecolor)
	end
end

function Draw3DBox1(Object, Linesize, Linecolor, Height)
	Linesize = Linesize or 1
	Linecolor = Linecolor or ARGB(255, 255, 255, 0)
	if Object and Object.minBBox then
	
		x1, y1, z1 = get2DFrom3D(Object.minBBox.x, Height or Object.minBBox.y, Object.minBBox.z)
		x2, y2, z2 = get2DFrom3D(Object.maxBBox.x, Height or Object.minBBox.y, Object.minBBox.z)
		x3, y3, z3 = get2DFrom3D(Object.minBBox.x, Height or Object.minBBox.y, Object.maxBBox.z)
		x4, y4, z4 = get2DFrom3D(Object.maxBBox.x, Height or Object.minBBox.y, Object.maxBBox.z)
		
		DrawLine(x1, y1, x2, y2, Linesize, Linecolor)
		DrawLine(x2, y2, x4, y4, Linesize, Linecolor)
		DrawLine(x3, y3, x1, y1, Linesize, Linecolor)
		DrawLine(x4, y4, x3, y3, Linesize, Linecolor)
	end
end

function DrawTextNearObject(Object, Text, Size, Color, Height)
	Color = Color or ARGB(255, 255, 255, 0)
	if Object and Object.minBBox then
		x, y = GetObjectTopRighBoxCorner2D(Object)
		DrawText(Text, Size or 13, x+5, y, Color)
	end
end

function DrawTextAboveObject(Object, Text, Size, Color, Height)
	Color = Color or ARGB(255, 255, 255, 0)
	if Object and Object.minBBox then
		x, y, z = get2DFrom3D(Object.minBBox.x, Object.maxBBox.y+30, Object.maxBBox.z)
		DrawText(Text, Size or 13, x+5, y, Color)
	end
end


function GetObjectTopRighBoxCorner2D(Object)
	if Object and Object.minBBox then
		x, y, z = get2DFrom3D(Object.maxBBox.x, Object.maxBBox.y, Object.maxBBox.z)
		return x, y
	end
end

function GetObjectTopLeftBoxCorner2D(Object)
	if Object and Object.minBBox then
		x, y, z = get2DFrom3D(Object.minBBox.x, Object.maxBBox.y, Object.maxBBox.z)
		return x, y
	end
end

function SpellCdColor(Hero, SpellID)	
	if Hero:GetSpellData(SpellID).currentCd > 0 then
		R = 255
		G = 0
	else
		R = 0
		G = 255
	end
	Color =  ARGB(255, R or 255, G or 255, 0)
	return Color
end

function DrawSpellsCd(Hero)
	x, y = GetObjectTopRighBoxCorner2D(Hero)	
	DrawText("Q: ".. math.ceil(Hero:GetSpellData(_Q).currentCd), Size or 15, x+5, y, SpellCdColor(Hero, _Q))
	DrawText("W: ".. math.ceil(Hero:GetSpellData(_W).currentCd), Size or 15, x+5, y+15, SpellCdColor(Hero, _W))
	DrawText("E: ".. math.ceil(Hero:GetSpellData(_E).currentCd), Size or 15, x+5, y+30, SpellCdColor(Hero, _E))
	DrawText("R: ".. math.ceil(Hero:GetSpellData(_R).currentCd), Size or 15, x+5, y+45, SpellCdColor(Hero, _R))
	DrawText("S1: ".. math.ceil(Hero:GetSpellData(SUMMONER_1).currentCd), Size or 15, x+5, y+60, SpellCdColor(Hero, SUMMONER_1))
	DrawText("S2: ".. math.ceil(Hero:GetSpellData(SUMMONER_2).currentCd), Size or 15, x+5, y+75, SpellCdColor(Hero, SUMMONER_2))
end

function HpColor(Hero)
	if Hero.health/Hero.maxHealth >= 0.5 then
		R = 0 + (5.1 * ((1-Hero.health/Hero.maxHealth) * 100))
		G = 255
		B = 0
	else				
		R = 255
		G = 255 - (5.1 * ((1-Hero.health/Hero.maxHealth) * 100))
		B = 0
	end
	Color =  ARGB(255, R or 255, G or 255, 0)
	return Color
end

function DrawHpMP(Hero)
	x, y = GetObjectTopLeftBoxCorner2D(Hero)
	DrawText("HP: ".. math.ceil(Hero.health), Size or 20, x, y-50, HpColor(Hero))
	DrawText("MP: " .. math.ceil(Hero.mana), Size or 20, x, y-30, ARGB(255, 100, 255, 255))
end

function DrawCharName(Hero, Color)
	x, y = GetObjectTopLeftBoxCorner2D(Hero)
	DrawText(Hero.charName, Size or 20, x, y-70, Color or ARGB(255, 255, 255, 0))
end

-- Credits to Trees
_G.sTable = {}
function OverLoadPackets()
	for scriptName, environment in pairs(_G.environment) do
		if environment['OnSendPacket'] and type(environment['OnSendPacket']) == 'function' then
			table.insert(_G.sTable, environment['OnSendPacket'])
		end
	end

	_G.Packet.send = function(self, override)
		if self.blocked then return end
		local p = Packet.definition[self.values.name].encode(self)
		if override ~= nil then
			for i,v in ipairs(_G.sTable) do
				if v(p, true) == false then return end
			end
		end
		SendPacket(p)
		return self
	end
end

--[[

	MyHero

	
]]--

class 'FSLMyHero'

function FSLMyHero:__init()
end

function FSLMyHero:DrawHpMP(Size)
	if myHero ~= nil and not myHero.dead then
		DrawHpMP(myHero)
	end
end

function FSLMyHero:DrawBox()
	if myHero ~= nil and not myHero.dead then
		Draw3DBox(myHero, 1, ARGB(255, 0, 255, 0))
	end
end

function FSLMyHero:DrawSpells()
	if myHero ~= nil and not myHero.dead then
		DrawSpellsCd(myHero)
	end
end

function FSLMyHero:DrawInfo()
	if myHero ~= nil and not myHero.dead then
		DrawCharName(myHero)
		DrawHpMP(myHero)
		DrawSpellsCd(myHero)
	end
end

function FSLMyHero:MoveTo(Pos)
	if VIP_USER then
		Packet('S_MOVE', {type = 2, x = Pos.x, y = Pos.z}):send()
	else
		myHero:MoveTo(Pos.x, Pos.z)
	end
end

--[[
	Allies
]]--

class 'FSLAlly'
function FSLAlly:__init()
	self:Load()
end

function FSLAlly:Load()
	for i=0, heroManager.iCount, 1 do
		Ally = heroManager:GetHero(i)
		if Ally.team == myHero.team then
			Ally.MaxDmgToTarget = 0
			FSLAllyTable[Ally.charName] = Ally
		end
	end
end

function FSLAlly:DrawBox(Linesize, Linecolor, Height)
	for Name, Target in pairs(FSLAllyTable) do
		if Target ~= nil and Target ~= myHero and Target.visible and Target.health > 0 and not Target.dead then
			Draw3DBox(Target, Linesize, Linecolor or ARGB(255, 0, 0, 255), Height)
		end
	end
end

function FSLAlly:DrawCurentHP(Size)
	for Name, Target in pairs(FSLAllyTable) do
		if Target ~= nil and Target ~= myHero and Target.visible and Target.health > 0 and not Target.dead then
			DrawTextNearObject(Target, "HP: ".. math.ceil(Target.health), Size or 14, HpColor(Target) or ARGB(255, R or 255, G or 255, 0))
		end
	end
end


function FSLAlly:DrawInfo(Color, Size)
	for Name, Target in pairs(FSLAllyTable) do
		if Target ~= nil and Target ~= myHero and Target.visible and Target.health > 0 and not Target.dead then
			DrawHpMP(Target)
			DrawCharName(Target, ARGB(255, 0, 255, 0))
			DrawSpellsCd(Target)
		end
	end
end

--[[

	ENEMY TEAM

	
]]--

local function GetEnemysHemorrhage(obj)
	if string.find(string.lower(obj.name),"darius_hemo_counter") then
        for i, Target in pairs(FSLEnemyTable) do
            if Target and not Target.dead and Target.visible and  GetDistance(Target, obj) <= 80 then
				for j, Hemorrhage in pairs(HemorrhageArray) do
					if obj.name == Hemorrhage then
						Target.HemorrhageStacks = j
						Target.LastHemorrhageTmr = GetTickCount()
					end
				end
            end
        end
    end
end

class 'FSLEnemy'

function FSLEnemy:__init()
	if myHero.charName == "Darius" then
		self:LoadDarius()
		
		AddCreateObjCallback(GetEnemysHemorrhage)
		--AddDeleteObjCallback
		
		
		
	else
		self:Load()
	end
end

function FSLEnemy:Load()
	for i=0, heroManager.iCount, 1 do
		Target = heroManager:GetHero(i)
		if Target.team ~= myHero.team then
			Target.MaxDmgToTarget = 0
			FSLEnemyTable[Target.charName] = Target
		end
	end
end

function FSLEnemy:LoadDarius()
	for i=0, heroManager.iCount, 1 do
		Target = heroManager:GetHero(i)
		if Target.team ~= myHero.team then
			Target.MaxDmgToTarget = 0
			Target.HemorrhageStacks = 0
			Target.LastHemorrhageTmr = 0
			FSLEnemyTable[Target.charName] = Target
		end
	end
end

function FSLEnemy:DmgCalc(Spell1, Spell2, Spell3, Spell4, Items, Ignite)

	for Name, Target in pairs(FSLEnemyTable) do
		if Target ~= nil and Target.health > 0 and Target.visible and not Target.dead then
			DmgToTarget = 0
			if Spell1 ~= nil and Spell1:IsReady() then
				DmgToTarget = DmgToTarget + Spell1:ReturnDmgToTarget(Target)
			end
			if Spell2 ~= nil and Spell2:IsReady() then
				DmgToTarget = DmgToTarget + Spell2:ReturnDmgToTarget(Target)
			end
			if Spell3 ~= nil and Spell3:IsReady() then
				DmgToTarget = DmgToTarget + Spell3:ReturnDmgToTarget(Target)
			end
			if Spell4 ~= nil and Spell4:IsReady() then
				DmgToTarget = DmgToTarget + Spell4:ReturnDmgToTarget(Target)
			end
			if Items ~= nil then
				DmgToTarget = DmgToTarget
			end
			if Ignite ~= nil then
				DmgToTarget = DmgToTarget
			end
			Target.MaxDmgToTarget = DmgToTarget
		end
	end
end

function FSLEnemy:DrawBox(Linesize, Linecolor, Height)
	for Name, Target in pairs(FSLEnemyTable) do
		if Target ~= nil and Target.visible and Target.health > 0 and not Target.dead then
			Draw3DBox(Target, Linesize, Linecolor or ARGB(255, 255, 0, 0), Height)
		end
	end
end

function FSLEnemy:DrawHPAfterCombo(Color, Size)
	for Name, Target in pairs(FSLEnemyTable) do
		if Target ~= nil and Target.visible and Target.health > 0 and not Target.dead then
			DrawTextAboveObject(Target, "After Combo HP: ".. math.ceil(Target.health - Target.MaxDmgToTarget), Size or 14, Color or ARGB(255, 0, 255, 0))
		end
	end
end

function FSLEnemy:DrawCurentHP(Color, Size)
	for Name, Target in pairs(FSLEnemyTable) do
		if Target ~= nil and Target.visible and Target.health > 0 and not Target.dead then
			if Target.health/Target.maxHealth >= 0.5 then
				R = 0 + (5.1 * ((1-Target.health/Target.maxHealth) * 100))
				G = 255
				B = 0
			else				
				R = 255
				G = 255 - (5.1 * ((1-Target.health/Target.maxHealth) * 100))
				B = 0
			end
			DrawTextNearObject(Target, "HP: ".. math.ceil(Target.health), Size or 14, Color or ARGB(255, R or 255, G or 255, 0))
		end
	end
end


function FSLEnemy:DrawInfo(Color)
	for Name, Target in pairs(FSLEnemyTable) do
		if Target ~= nil and Target.visible and Target.health > 0 and not Target.dead then
			DrawHpMP(Target)
			DrawCharName(Target, ARGB(255, 255, 0, 0))
			DrawSpellsCd(Target)
		end
	end
end


function FSLEnemy:APGetBestTarget()

end

function FSLEnemy:ADGetBestTarget()

end

--[[
----------------------------------------------------------------------------------------------------------------------------------------------
	
                                                                                                                                            
TTTTTTTTTTTTTTTTTTTTTTT                                                                                      tttt                           
T:::::::::::::::::::::T                                                                                   ttt:::t                           
T:::::::::::::::::::::T                                                                                   t:::::t                           
T:::::TT:::::::TT:::::T                                                                                   t:::::t                           
TTTTTT  T:::::T  TTTTTTuuuuuu    uuuuuu rrrrr   rrrrrrrrr   rrrrr   rrrrrrrrr       eeeeeeeeeeee    ttttttt:::::ttttttt        ssssssssss   
        T:::::T        u::::u    u::::u r::::rrr:::::::::r  r::::rrr:::::::::r    ee::::::::::::ee  t:::::::::::::::::t      ss::::::::::s  
        T:::::T        u::::u    u::::u r:::::::::::::::::r r:::::::::::::::::r  e::::::eeeee:::::eet:::::::::::::::::t    ss:::::::::::::s 
        T:::::T        u::::u    u::::u rr::::::rrrrr::::::rrr::::::rrrrr::::::re::::::e     e:::::etttttt:::::::tttttt    s::::::ssss:::::s
        T:::::T        u::::u    u::::u  r:::::r     r:::::r r:::::r     r:::::re:::::::eeeee::::::e      t:::::t           s:::::s  ssssss 
        T:::::T        u::::u    u::::u  r:::::r     rrrrrrr r:::::r     rrrrrrre:::::::::::::::::e       t:::::t             s::::::s      
        T:::::T        u::::u    u::::u  r:::::r             r:::::r            e::::::eeeeeeeeeee        t:::::t                s::::::s   
        T:::::T        u:::::uuuu:::::u  r:::::r             r:::::r            e:::::::e                 t:::::t    ttttttssssss   s:::::s 
      TT:::::::TT      u:::::::::::::::uur:::::r             r:::::r            e::::::::e                t::::::tttt:::::ts:::::ssss::::::s
      T:::::::::T       u:::::::::::::::ur:::::r             r:::::r             e::::::::eeeeeeee        tt::::::::::::::ts::::::::::::::s 
      T:::::::::T        uu::::::::uu:::ur:::::r             r:::::r              ee:::::::::::::e          tt:::::::::::tt s:::::::::::ss  
      TTTTTTTTTTT          uuuuuuuu  uuuurrrrrrr             rrrrrrr                eeeeeeeeeeeeee            ttttttttttt    sssssssssss    
                                                                                                                                            
                                                                                                                                            
                                                                                                                                            
----------------------------------------------------------------------------------------------------------------------------------------------
	
	WARNING TO GET OR CHANGE TURRET RANGE use ".Range" instead of ".range"
	functions:
	FSLTurrets = Name()
	Name:Update() - Update Turrets Tables on evry tick
	Name:SlowUpdate() - Update Turrets Tables on evry 5 seconds
	Name:ReturnTurrets() - Returns AllTurrets, AllyTurrets, EnemyTurrets
	Name:ReturnAllyTurrets() - Returns AllyTurrets
	Name:ReturnEnemyTurrets() - Returns EnemyTurrets
	Name:DrawTurretsRange(ColorAllyTurrets, ColorEnemyTurrets) - Draw Circle Around Turrets Ranges Default Colors: AllyTurrets Blue, EnemyTurrets Red
	Name:DrawAllyTurrets(Color) Draw Circle Around Ally Turrets Ranges Default Color Blue
	Name:DrawEnemyTurrets(Color) Draw Circle Around Enemy Turrets Ranges Default Color Red
	Name:DrawTurretRange(Turret, Color) Draw Circle Around Turret Range Default Color Lime
	Name:DrawTurretsPolygons(Sides) - Draw Poligon around tower instead of Circle less FPS drop
	Name:DrawTurretsAllyPolygons(Sides) - Draw Poligon around tower instead of Circle less FPS drop
	Name:DrawTurretsEnemyPolygons(Sides) - Draw Poligon around tower instead of Circle less FPS drop
	Name:DrawDanger(Color) -- Draws Circle around Tower when our hero is its range
	Name:UnderTurret(Position, Team) return true/false if Position is in Turrets range | Team = nil check for all turrets, Team == myHero.Team for ally turrets, Team ~= myHero.Team for enemy turrets
	Name:UnderWhichTurret(Position) returns Turret object if the position is in Range 
	Name:GoToClosestAllyTurret() -- Goes to closet ally tower
	Name:GoToClosestEnemyTurret() -- Goes to closet enemy tower
	
	
]]--

class 'FSLTurrets'

function FSLTurrets:__init()
	self.Turrets = {}
	self.AllyTurrets = {}
	self.EnemyTurrets = {}
	self.LastUpDateTime = 0
	self:Load()
end


function FSLTurrets:Load()
	for i = 0, objManager.maxObjects do
		local obj = objManager:getObject(i)
		if obj ~= nil and (obj.type == "obj_AI_Turret") then
			obj.Range = 950
			self.Turrets[obj.name] = obj
			if obj.team == myHero.team then
				self.AllyTurrets[obj.name] = obj
			else
				self.EnemyTurrets[obj.name] = obj
			end
		end
	end
end


function FSLTurrets:Update()
	for Name, Turret in pairs(self.Turrets) do
        if Turret.valid == false or Turret.dead or Turret.health == 0 then
            self.Turrets[Name] = nil
			if Turret.team == myHero.team then
				self.AllyTurrets[Turret.name] = nil
			else
				self.EnemyTurrets[Turret.name] = nil
			end
		end
    end
end

function FSLTurrets:SlowUpdate()
	if GetGameTimer() > self.LastUpDateTime + 5 then 
		for Name, Turret in pairs(self.Turrets) do
			if Turret.valid == false or Turret.dead or Turret.health == 0 then
				self.Turrets[Name] = nil
				if Turret.team == myHero.team then
					self.AllyTurrets[Turret.name] = nil
				else
					self.EnemyTurrets[Turret.name] = nil
				end
			end
		end
		self.LastUpDateTime = GetGameTimer()
	end
end


function FSLTurrets:ReturnTurrets()
	self:Update()
	return self.Turrets, self.AllyTurrets, self.EnemyTurrets
end
function FSLTurrets:ReturnAllyTurrets()
	self:Update()
	return self.AllyTurrets
end
function FSLTurrets:ReturnEnemyTurrets()
	self:Update()
	return self.EnemyTurrets
end


function FSLTurrets:DrawTurretsRange(ColorAllyTurrets, ColorEnemyTurrets)
	for Name, Turret in pairs(self.Turrets) do
		if Turret ~= nil and Turret.health > 0 and Turret.team == myHero.team then
			DrawCircle(Turret.x, Turret.y, Turret.z, Turret.Range, ColorAllyTurrets or ColorTable.Blue)
		elseif Turret ~= nil and Turret.health > 0 and Turret.team ~= myHero.team then
			DrawCircle(Turret.x, Turret.y, Turret.z, Turret.Range, ColorEnemyTurrets or ColorAllyTurrets or ColorTable.Red)
		end
	end
end
function FSLTurrets:DrawAllyTurrets(Color)
	for Name, Turret in pairs(self.AllyTurrets) do
		if Turret ~= nil and Turret.health > 0 then
			DrawCircle(Turret.x, Turret.y, Turret.z, Turret.Range, Color or  ColorTable.Blue)
		end
	end
end
function FSLTurrets:DrawEnemyTurrets(Color)
	for Name, Turret in pairs(self.EnemyTurrets) do
		if Turret ~= nil and Turret.health > 0 then
			DrawCircle(Turret.x, Turret.y, Turret.z, Turret.Range, Color or ColorTable.Red)
		end
	end
end
function FSLTurrets:DrawTurretRange(Turret, Color)
	if Turret ~= nil and Turret.health > 0 then
		DrawCircle(Turret.x, Turret.y, Turret.z, Turret.Range, Color or ColorTable.Lime)
	end
end
function FSLTurrets:DrawTurretsPolygons(Sides)
	for Name, Turret in pairs(self.Turrets) do
		if Turret ~= nil and Turret.health > 0 then
			if Turret.team == myHero.team and GetDistanceFromMouse(Turret) < 3000 then
				DrawPolygon(Turret, Sides or 12, 900)
			elseif Turret.team ~= myHero.team and GetDistanceFromMouse(Turret) < 3000 then
				DrawPolygon(Turret, Sides or 12, 900)
			end
		end
	end
end
function FSLTurrets:DrawAllyTurretsPolygons(Sides)
	for Name, Turret in pairs(self.AllyTurrets) do
		if Turret ~= nil and Turret.health > 0 and GetDistanceFromMouse(Turret) < 3000 then
			DrawPolygon(Turret, Sides or 12, 900)
		end
	end
end
function FSLTurrets:DrawEnemyTurretsPolygons(Sides)
	for Name, Turret in pairs(self.EnemyTurrets) do
		if Turret ~= nil and Turret.health > 0 and GetDistanceFromMouse(Turret) < 3000 then
			DrawPolygon(Turret, Sides or 12, 900)
		end
	end
end

function FSLTurrets:DrawDanger(Color)
	for Name, Turret in pairs(self.EnemyTurrets) do
		if Turret ~= nil and Turret.health > 0 and Get2dDistance(myHero, Turret) <= Turret.Range then
			DrawCircle(Turret.x, Turret.y, Turret.z, Turret.Range, Color or ColorTable.Red)
		end
	end
end



function FSLTurrets:UnderTurret(Position, Team)
	if Position ~= nil then
		if Team == nil then
			for Name, Turret in pairs(self.Turrets) do
				if Turret ~= nil and Turret.health > 0 then
					if Get2dDistance(Position, Turret) <= Turret.Range then
						return true
					end
				end
			end
		elseif Team == myHero.team then
			for Name, Turret in pairs(self.AllyTurrets) do
				if Turret ~= nil and Turret.health > 0 then
					if Get2dDistance(Position, Turret) <= Turret.Range then
						return true
					end
				end
			end
		elseif Team ~= myHero.team then
			for Name, Turret in pairs(self.EnemyTurrets) do
				if Turret ~= nil and Turret.health > 0 then
					if Get2dDistance(Position, Turret) <= Turret.Range then
						return true
					end
				end
			end
		end
	end
	return false
end
function FSLTurrets:UnderWhichTurret(Position)
	if Position == nil then
		return nil
	else
		for Name, Turret in pairs(self.Turrets) do
			if Turret ~= nil and Turret.health > 0 then
				if Get2dDistance(Position, Turret) <= Turret.Range then
					return Turret
				end
			end
		end
	end
end

function FSLTurrets:ClosestTurret(Position, Team)
	local ClosestDistance = math.huge
	local Distance = ClosestDistance
	local TempTurret = nil
	if Position == nil then
		return nil
	else
		if Team == nil then
			for Name, Turret in pairs(self.Turrets) do
				if Turret ~= nil and Turret.health > 0 then
					Distance = Get2dDistance(Position, Turret)
					if Distance <= ClosestDistance then
						ClosestDistance = Distance
						TempTurret = Turret
					end
				end
			end
			return TempTurret
			
		elseif Team == myHero.team then
			for Name, Turret in pairs(self.AllyTurrets) do
				if Turret ~= nil and Turret.health > 0 then
					Distance = Get2dDistance(Position, Turret)
					if Distance <= ClosestDistance then
						ClosestDistance = Distance
						TempTurret = Turret
					end
				end
			end
			return TempTurret
		
		elseif Team ~= myHero.team then
			for Name, Turret in pairs(self.EnemyTurrets) do
				if Turret ~= nil and Turret.health > 0 then
					Distance = Get2dDistance(Position, Turret)
					if Distance <= ClosestDistance then
						ClosestDistance = Distance
						TempTurret = Turret
					end
				end
			end
			return TempTurret
			
		end
	end
	
	return nil
end

function FSLTurrets:GoToClosestAllyTurret()
	local ClosestDistance = math.huge
	local Distance = ClosestDistance
	local TempTurret = nil
	for Name, Turret in pairs(self.AllyTurrets) do
		if Turret ~= nil and Turret.health > 0 then
			Distance = Get2dDistance(myHero, Turret)
			if Distance <= ClosestDistance then
				ClosestDistance = Distance
				TempTurret = Turret
			end
		end
	end
	myHero:MoveTo(TempTurret.x, TempTurret.z)
end

function FSLTurrets:GoToClosestEnemyTurret()
	local ClosestDistance = math.huge
	local Distance = ClosestDistance
	local TempTurret = nil
	for Name, Turret in pairs(self.EnemyTurrets) do
		if Turret ~= nil and Turret.health > 0 then
			Distance = Get2dDistance(myHero, Turret)
			if Distance <= ClosestDistance then
				ClosestDistance = Distance
				TempTurret = Turret
			end
		end
	end
	myHero:MoveTo(TempTurret.x, TempTurret.z)
end

function FSLTurrets:AtackTurret(Range)
	for Name, Turret in pairs(self.EnemyTurrets) do
		if Turret ~= nil and Turret.health > 0 then
			if Get2dDistance(myHero, Turret) <= (Range or myHero.range )then
				myHero:Attack(Turret)
			end
		end
	end
end






--[[

		AI

]]--

class 'FSLAI'
function FSLAI:_init()

end

--[[

	FOLLOW

]]--
class 'FSLFollow'

function FSLFollow:_init() 
	self.Follow = true
	self.TargetToFollow = nil
	self.TempTargetToFollow = nil
end

function FSLFollow:GetTargetToFollow()
	if GetGameTimer() <= 300 then
		while self.TargetToFollow == nil do
			for i=0, heroManager.iCount, 1 do
				Target = heroManager:GetHero(i)
				if Target == myHero.team then
					if Get2dDistance(Target, BlueTeamBotLanePoints[8]) <= 300 then
						self.TargetToFollow = Target
					end
				end
			end
		end
	end
end

function FSLFollow:Update()
	if GetGameTimer() > 300 then
		if self.TargetToFollow == nil or self.TargetToFollow.dead then
			for i=0, heroManager.iCount, 1 do
				Target = heroManager:GetHero(i)
				if Target == myHero.team then
					if Get2dDistance(Target, myHero) <= 1000 and self.TempTargetToFollow == nil then
						self.TempTargetToFollow = Target
					end
				end
			end
		end	
	end
end

function FSLFollow:FollowTarget()

end



--[[
                                                                                          
                                                                                          
   SSSSSSSSSSSSSSS                                       lllllll lllllll                  
 SS:::::::::::::::S                                      l:::::l l:::::l                  
S:::::SSSSSS::::::S                                      l:::::l l:::::l                  
S:::::S     SSSSSSS                                      l:::::l l:::::l                  
S:::::S           ppppp   ppppppppp       eeeeeeeeeeee    l::::l  l::::l     ssssssssss   
S:::::S           p::::ppp:::::::::p    ee::::::::::::ee  l::::l  l::::l   ss::::::::::s  
 S::::SSSS        p:::::::::::::::::p  e::::::eeeee:::::eel::::l  l::::l ss:::::::::::::s 
  SS::::::SSSSS   pp::::::ppppp::::::pe::::::e     e:::::el::::l  l::::l s::::::ssss:::::s
    SSS::::::::SS  p:::::p     p:::::pe:::::::eeeee::::::el::::l  l::::l  s:::::s  ssssss 
       SSSSSS::::S p:::::p     p:::::pe:::::::::::::::::e l::::l  l::::l    s::::::s      
            S:::::Sp:::::p     p:::::pe::::::eeeeeeeeeee  l::::l  l::::l       s::::::s   
            S:::::Sp:::::p    p::::::pe:::::::e           l::::l  l::::l ssssss   s:::::s 
SSSSSSS     S:::::Sp:::::ppppp:::::::pe::::::::e         l::::::ll::::::ls:::::ssss::::::s
S::::::SSSSSS:::::Sp::::::::::::::::p  e::::::::eeeeeeee l::::::ll::::::ls::::::::::::::s 
S:::::::::::::::SS p::::::::::::::pp    ee:::::::::::::e l::::::ll::::::l s:::::::::::ss  
 SSSSSSSSSSSSSSS   p::::::pppppppp        eeeeeeeeeeeeee llllllllllllllll  sssssssssss    
                   p:::::p                                                                
                   p:::::p                                                                
                  p:::::::p                                                               
                  p:::::::p                                                               
                  p:::::::p                                                               
                  ppppppppp                                                               
                                

	SPELL_NORMAL = 0
	SPELL_ON_POINT = 1
	SPELL_ON_TARGET = 2
	SPELL_SKILL_SHOT = 3			
								
	Spell Structure Example						
								
	SpellQ = {
		SpellID = _Q,
		Range = 425,
		Type = SPELL_NORMAL,
		Predict = false,
		HitChance = 10,
		CheckCollision = true,
		Delay = 0,
		Width = 0,
		Speed = 0,
		DMGFormula = function(self, Target)
			return player:CalcDamage(Target, 70 + (player:GetSpellData(_Q).level-1)*35 + myHero.totalDamage*0.70)
		end
	},
								   
								   

FSLSpells:__init(SpellQ, SpellW, SpellE, SpellR) -- init spells with ready structures or nil
FSLSpells:Update() -- Update Spells Ready Status																					  
FSLSpells:CreateNewSpell(Spell) -- Creates FSLSpells.self.SpellQ|W|E|R depends of SpellID
FSLSpells:CreateNewSpell(Spell, Range, Predict, HitChance,Delay, Width, Speed, DMGFormula) -- Creates spell structure	

Spell - Structure or (SpellID ex _Q (only if FSLSpells.SpellQ is structure)) 												  
FSLSpells:CastSpell(Spell, Target) -- Cast Spell Like Darius W, Nunu R and etc																					  
FSLSpells:CastSpellOnTarget(Spell, Target) -- Cast Spell On target Hero, Ward, Monsters and etc	 like Ryze Q W E	 
FSLSpells:CastSpellOnPoint(Spell, Target, Predict) -- Cast Spell Like Malzahar E, Cassiopeia Q and etc
FSLSpells:CastSkillShot(Spell, Target, Predict) -- Cast Spell like Ez ult, Q,W 

for KS you have to pass target or "Auto" so it will look for target


]]--

class 'FSLSpells'
function FSLSpells:__init(Spell)
	self.Spell = Spell
end

function FSLSpells:Update()
	self.Spell.Ready = (myHero:CanUseSpell(self.Spell.SpellID) == READY)
end

function FSLSpells:Cast(Target, Predict, CheckCollision)
	if self.Spell.Type == SPELL_NORMAL then
		self:CastSpell(Target)
	elseif self.Spell.Type == SPELL_ON_POINT then
		self:CastSpellOnPoint(Target, Predict)
	elseif self.Spell.Type == SPELL_ON_TARGET then
		self:CastSpellOnTarget(Target)
	elseif self.Spell.Type == SPELL_SKILL_SHOT then
		self:CastSkillShot(Target, Predict, CheckCollision)
	end
end

function FSLSpells:CastSpell(Target)
	if Target ~= nil and Get2dDistance(myHero, Target) <= self.Spell.Range and self.Spell.Ready then
		if VIP_USER then
			--Packet("S_CAST", {spellId = self.Spell.SpellID, targetNetworkId = Target.networkID}):send()
			SendPacketCastSpell(self.Spell.SpellID, 0, 0, Target)
		else
			CastSpell(self.Spell.SpellID)
		end
	end
end

function FSLSpells:CastSpellOnTarget(Target)
	if Target ~= nil and Get2dDistance(myHero, Target) <= self.Spell.Range and self.Spell.Ready then
		if VIP_USER then
			--Packet("S_CAST", {spellId = self.Spell.SpellID, targetNetworkId = Target.networkID}):send()
			SendPacketCastSpell(self.Spell.SpellID, 0, 0, Target)
		else
			CastSpell(self.Spell.SpellID, Target)
		end
	end
end

function FSLSpells:CastSpellOnPoint(Target, Predict)
	if Predict == false then
		if VIP_USER then
			if Target ~= nil and Get2dDistance(myHero, Target) <= self.Spell.Range and self.Spell.Ready then
				SendPacketCastSpell(self.Spell.SpellID, Target.x, Target.z, nil)
			end
		else
			if Target ~= nil and Get2dDistance(myHero, Target) <= self.Spell.Range and self.Spell.Ready then
				CastSpell(self.Spell.SpellID, Target.x, Target.z)
			end
		end
	elseif self.Spell.Predict or Predict then
		if VIP_USER then							--(hero, delay, width, range, speed, from, collision)
			PredPos,  HitChance,  Position = FSLVP:GetCircularCastPosition(Target, self.Spell.Delay, self.Spell.Width, self.Spell.Range, self.Spell.Speed)
			if GetDistance(PredPos) < self.Spell.Range and HitChance >= self.Spell.HitChance then
				SendPacketCastSpell(self.Spell.SpellID, PredPos.x, PredPos.z, nil)
			end
		else
			Pred = TargetPrediction(self.Spell.Range, self.Spell.Speed, self.Spell.Delay, self.Spell.Width)
			PredPos = Pred:GetPrediction(Target)
			if GetDistance(PredPos) <= self.Spell.Range then
				CastSpell(self.Spell.SpellID, PredPos.x, PredPos.z)
			end
		end
	end
end


function FSLSpells:CastSkillShot(Target, Predict, CheckCollision)
	if Predict == false then
		if Target ~= nil and Get2dDistance(myHero, Target) <= self.Spell.Range and self.Spell.Ready then
			CastSpell(self.Spell.SpellID, Target.x, Target.z)
		end
	elseif self.Spell.Predict or Predict then
		if VIP_USER then
			PredPos,  HitChance,  Position = FSLVP:GetLineCastPosition(Target, self.Spell.Delay, self.Spell.Width, self.Spell.Range, self.Spell.Speed, myHero,  CheckCollision or false)
			if GetDistance(PredPos) < self.Spell.Range and HitChance >= self.Spell.HitChance then
				SendPacketCastSpell(self.Spell.SpellID, PredPos.x, PredPos.z, nil)
			end
		else
			Pred = TargetPrediction(self.Spell.Range, self.Spell.Speed, self.Spell.Delay, self.Spell.Width)
			PredPos = Pred:GetPrediction(Target)
			if GetDistance(PredPos) <= self.Spell.Range then
				CastSpell(self.Spell.SpellID, PredPos.x, PredPos.z)
			end
		end
	end
end

function FSLSpells:ReturnDmgToTarget(Target)
	return self.Spell.Dmg(Target)
end

function FSLSpells:IsReady()
	return myHero:CanUseSpell(self.Spell.SpellID) == READY
end

function FSLSpells:DrawRange(Color)
	if myHero.dead == false then
		DrawCircle(myHero.x, myHero.y, myHero.z, self.Spell.Range, Color or ColorTable.Lime)
	end
end

--[[
	
	
	AutoFArm

]]--

class 'FSLAutoFarm'

function FSLAutoFarm:__init(AADelay, Range)
	self.AADelay = AADelay or 20
	self.LastAtack = 0
	self.EnemyMinions = minionManager(MINION_ENEMY, Range or myHero.range, myHero, MINION_SORT_HEALTH_ASC)
	self.EnemyMinionsToDraw = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_HEALTH_ASC)
end

function FSLAutoFarm:Update()
	self.EnemyMinions:update()
	self.EnemyMinionsToDraw:update()
end

function FSLAutoFarm:AAFarm()
	if (self.EnemyMinions.objects[1] ~= nil) and myHero:CalcDamage(self.EnemyMinions.objects[1], myHero.totalDamage) > self.EnemyMinions.objects[1].health and GetTickCount() > self.LastAtack + self.AADelay then
		myHero:Attack(self.EnemyMinions.objects[1])
		self.LastAtack = GetTickCount()
	end
	if GetTickCount() > self.LastAtack + self.AADelay then
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
end

function FSLAutoFarm:SpellsFarm(Spell1, UseSpell1, Spell2, UseSpell2, Spell3, UseSpell3, Spell4, UseSpell4)
	if Spell1 ~= nil and UseSpell1 and Spell1:IsReady() and (self.EnemyMinions.objects[1] ~= nil) and (self.EnemyMinions.objects[1].health < Spell1:ReturnDmgToTarget(self.EnemyMinions.objects[1])) then
		Spell1:CastSpellOnTarget(self.EnemyMinions.objects[1])
	elseif Spell2 ~= nil and UseSpell2 and Spell2:IsReady() and  (self.EnemyMinions.objects[1] ~= nil) and (self.EnemyMinions.objects[1].health < Spell2:ReturnDmgToTarget(self.EnemyMinions.objects[1])) then
		Spell2:CastSpellOnTarget(self.EnemyMinions.objects[1])
	elseif Spell3 ~= nil and UseSpell3 and Spell3:IsReady() and (self.EnemyMinions.objects[1] ~= nil) and (self.EnemyMinions.objects[1].health < Spell3:ReturnDmgToTarget(self.EnemyMinions.objects[1])) then
		Spell3:CastSpellOnTarget(self.EnemyMinions.objects[1])
	elseif Spell4 ~= nil and UseSpell4 and Spell4:IsReady() and (self.EnemyMinions.objects[1] ~= nil) and (self.EnemyMinions.objects[1].health < Spell4:ReturnDmgToTarget(self.EnemyMinions.objects[1])) then
		Spell4:CastSpellOnTarget(self.EnemyMinions.objects[1])
	end
end

function FSLAutoFarm:AAFarmDraw(Color)
	if (self.EnemyMinions.objects[1] ~= nil) and myHero:CalcDamage(self.EnemyMinions.objects[1], myHero.totalDamage) > self.EnemyMinions.objects[1].health then
		DrawCircle(self.EnemyMinions.objects[1].x, self.EnemyMinions.objects[1].y, self.EnemyMinions.objects[1].z, 75, Color or ColorTable.Aqua)
	end
end

function FSLAutoFarm:Hp(Size, Color)
	for i in pairs(self.EnemyMinionsToDraw.objects) do
		x, y = GetObjectTopLeftBoxCorner2D(self.EnemyMinionsToDraw.objects[i])
		DrawText("HP: ".. math.ceil(self.EnemyMinionsToDraw.objects[i].health), Size or 15, x+15, y, Color or ARGB(255, 255, 255, 255))
	end
end



--[[

		SpellQ = {
			SpellID = _Q,
			Range = 425,
			Type = SPELL_NORMAL,
			Predict = false,
			HitChance = 4,
			Delay = 0,
			Width = 0,
			Speed = 0,
			DMGFormula = function(self, Target)
				return player:CalcDamage(Target, 70 + (player:GetSpellData(_Q).level-1)*35 + myHero.totalDamage*0.70)
			end
		},

]]--
FSLHeroSpellsTable = {
	Darius = {
		AA = {
			Speed = 0,
			DMG = 0
		},
		
		SpellQ = {
			SpellID = _Q,
			Range = 425,
			Type = SPELL_NORMAL,
			Predict = false,
			HitChance = 1,
			Delay = 0,
			Width = 0,
			Speed = 0,
			Dmg = function(self, Target)
				return player:CalcDamage(Target, 70 + (player:GetSpellData(_Q).level-1)*35 + myHero.totalDamage*0.70)
			end
		},
		
		SpellW = {
			SpellID = _W,
			Range = 145,
			Type = SPELL_NORMAL,
			Predict = false,
			HitChance = 1,
			Delay = 0,
			Width = 0,
			Speed = 0,
			Dmg = function(self, Target)
				return player:CalcDamage(Target, (player:GetSpellData(_W).level*0.20)*myHero.totalDamage)
			end
		},
		
		SpellE = {
			SpellID = _E,
			Range = 540,
			Type = SPELL_ON_POINT,
			Predict = true,
			HitChance = 1,
			Delay = 0.2,
			Width = 0,
			Speed = 0,
			Dmg = function(self, Target)
				return 0
			end
		},
		
		SpellR = {
			SpellID = _R,
			Range = 460,
			Type = SPELL_ON_TARGET,
			Predict = true,
			HitChance = 1,
			Delay = 0,
			Width = 0,
			Speed = 0,
			Dmg = function(self, Target)
				if Target.HemorrhageStacks ~= nil and Target.HemorrhageStacks > 0 then
					return (160 + (player:GetSpellData(_R).level-1)*90 + myHero.addDamage*0.75)*(Target.HemorrhageStacks*0.2)
				else
					return 160 + (player:GetSpellData(_R).level-1)*90 + myHero.addDamage*0.75
				end
			end
		}
	}, --Darius
	Ryze = {
		SpellQ = {
			SpellID = _Q,
			Range = 600,
			Type = SPELL_ON_TARGET,
			Dmg = function (Target) return player:CalcMagicDamage(Target, 60 + (player:GetSpellData(_Q).level-1)*25 + myHero.ap*0.40 + myHero.maxMana*0.065) end
		},
		SpellW = {
			SpellID = _W,
			Range = 600,
			Type = SPELL_ON_TARGET,
			Dmg = function (Target) return player:CalcMagicDamage(Target, 60 + (player:GetSpellData(_Q).level-1)*35 + myHero.ap*0.60 + myHero.maxMana*0.045) end
		},
		SpellE = {
			SpellID = _E,
			Range = 600,
			Type = SPELL_ON_TARGET,
			Dmg = function (Target) return player:CalcMagicDamage(Target, 50 + (player:GetSpellData(_Q).level-1)*20 + myHero.ap*0.35 + myHero.maxMana*0.01) end
		},
		SpellR = {
			SpellID = _R,
			Range = 600,
			Type = SPELL_NORMAL,
			Dmg = function (Target) return 0 end
		}
	} -- Ryze
	
	
}
