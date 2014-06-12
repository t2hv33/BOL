--[[
NotClass lib version 6
by Ivan[RUSSIA]

GPL v2 license

table engine - lib namespace
	string map = dom/tt/pg/classic/unknown
	string type(unit)
		string = return game-slang unit type
		unit = investigation object
	unit find(bool condition(unit))
		unit = found object or nil
		bool(unit) = should return true if you need this unit gathered
	table,float gather(bool condition(unit),bool manage)
		table = hash unit table
		float = table size
		bool(unit) = should return true if you need this unit gathered
		bool = library refresh table with actual data
table timer(* key)
	function callback = set your callback here
	float cooldown = set timer cooldown here 
	float lastcall = see last timer proc here
	void start()
	void pause(float cooldown) = pause your timer for passed amount of time
	void stop()
table bind(* key)
	void callback(bool isDown) = set your callback here
	float key = set your key here
	void unbind() = disable bind
D3DXVECTOR3 VEC(float x,float z)
	D3DXVECTOR3 = 3d engine vector
	float = 3d engine coord
table math - lib expansion
	float dist2d(float x1,float y1,float x2,float y2)
		float = return distance between points
	float rad2d(D3DXVECTOR3 pos1,D3DXVECTOR3 pos2)
		float = return radians between two points, 0 = north
	D3DXVECTOR3 pos2d(D3DXVECTOR3 pos, float rad, float range)
		D3DXVECTOR3 = return displaced position
	D3DXVECTOR3 proj2d(D3DXVECTOR3 dotPos,D3DXVECTOR3 linePos1,D3DXVECTOR3 linePos2)
		D3DXVECTOR3 = return dot dot projection on line
	D3DXVECTOR3 normal2d(D3DXVECTOR3 pos1,D3DXVECTOR3 pos2)
		D3DXVECTOR3 = return [0-1] normalized dot
--]]

VEC = function(x,z) return D3DXVECTOR3(x,0,z) end

engine = {}

engine.type = function(unit)
	local type = unit.type
	if type ==  "obj_Turret" or type ==  "LevelPropSpawnerPoint" or type ==  "LevelPropGameObject" or type ==  "obj_Lake" or type ==  "obj_LampBulb" then return "useless"
	elseif type ==  "obj_GeneralParticleEmmiter" or type ==  "DrawFX" then return "visual"
	elseif type ==  "obj_AI_Minion" then
		local name = unit.name:lower()
		if name:find("minion") then return "minion"
		elseif name:find("ward") then return "ward"
		elseif name:find("wolf") or name:find("wraith") or name:find("golem") or name:find("lizard") then return "creep"
		elseif name:find("dragon") then return "dragon"
		elseif name:find("worm") or name:find("spider") then return "nashor"
		elseif name:find("shrine") then return "shrine"
		elseif name:find("buffplat") or name == "odinneutralguardian" then return "point"	
		elseif name == "odinshieldrelic" then return "heal"
		elseif name == "odincenterrelic" then return "shield"
		elseif unit.bTargetableToTeam == false or unit.bTargetable == false then return "trap" 
		else return "pet" end
	elseif type ==  "obj_AI_Turret" then return "tower"
	elseif type ==  "obj_SpawnPoint" then return "playerSpawn"
	elseif type ==  "obj_AI_Hero" then return "player"
	elseif type ==  "obj_Shop" then return "shop"
	elseif type ==  "obj_HQ" then return "nexus"
	elseif type ==  "obj_BarracksDampener" then return "inhibitor"
	elseif type ==  "obj_Barracks" then return "minionSpawn"
	elseif type ==  "obj_InfoPoint" or type ==  "NeutralMinionCamp" then return "info" 
	elseif type:sub(#type - 6) == "Missile" then return "spell" end
	return "error"
end

engine.find = function(condition)
	for i=1,objManager.maxObjects,1 do
		local unit = objManager:getObject(i)
		if unit ~= nil and unit.valid == true and condition(unit) == true then return unit end
	end
end

engine.gather = function(condition,manage)
	local result,size = {},0
	if manage == true then
		AddCreateObjCallback(function(unit) if condition(unit) == true then result[unit.hash] = unit end end)
		AddDeleteObjCallback(function(unit) result[unit.hash] = nil end)
	end
	for i=1,objManager.maxObjects,1 do
		local unit = objManager:getObject(i)
		if unit ~= nil and unit.valid == true and condition(unit) == true then result[unit.hash],size = unit,size+1 end
	end
	return result,size
end

engine.map = engine.find(function(unit) return unit.type=="obj_SpawnPoint" and unit.x<9000 end):GetDistance(engine.find(function(unit) return unit.type=="obj_SpawnPoint" and unit.x>9000 end))
if engine.map<12810 then engine.map="dom" elseif engine.map<13270 then engine.map="tt" elseif engine.map<15185 then engine.map="pg" 
elseif engine.map<19680 then engine.map="classic" else engine.map="unknown" end

local timerCache = {}
AddTickCallback(function()
		local clock = os.clock()
		for key,handle in pairs(timerCache) do if handle.lastcall + handle.cooldown <= clock then
				handle.lastcall = handle.lastcall + handle.cooldown
				handle.callback()
		end end
	end)
timer = function(key)
	if timerCache[key] == nil then
		timerCache[key] = {lastcall = math.huge,cooldown = 0,callback = function() end}
		timerCache[key].callback = function() end
		timerCache[key].stop = function() timerCache[key].lastcall = math.huge end
		timerCache[key].pause = function(timeline) timerCache[key].lastcall = timerCache[key].lastcall + timeline end
		timerCache[key].start = function() timerCache[key].lastcall = os.clock() end
	end
	return timerCache[key]
end

local bindCache = {}
AddMsgCallback(function(msg,wParam)
		if msg == 0x0200 then return elseif msg == 0x0202 then wParam,msg = 0x1,KEY_UP elseif msg == 0x0205 then wParam,msg = 0x2,KEY_UP elseif msg == 0x0208 then wParam,msg = 0x4,KEY_UP end
		for key,handle in pairs(bindCache) do if handle.key == wParam then handle.callback(msg ~= KEY_UP) end end
	end)
bind = function(key)
	if bindCache[key] == nil then
		bindCache[key] = {key = math.huge}
		bindCache[key].callback = function() end
		bindCache[key].unbind = function() bindCache[key] = nil end
	end
	return bindCache[key]
end

math.dist2d = function(x1,y1,x2,y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

math.rad2d = function(pos1,pos2)
	if pos2.z > pos1.z then
		if pos1.x < pos2.x then return math.acos(math.dist2d(pos1.x,pos1.z,pos1.x,pos2.z)/(pos1:GetDistance(pos2)))
		else return 6.283185307 - math.acos(math.dist2d(pos1.x,pos1.z,pos1.x,pos2.z)/(pos1:GetDistance(pos2))) end
	else 
		if pos1.x < pos2.x then return 1.570796327 + math.acos(math.dist2d(pos1.x,pos2.z,pos2.x,pos2.z)/(pos1:GetDistance(pos2)))
		else return 4.712388980 - math.acos(math.dist2d(pos1.x,pos2.z,pos2.x,pos2.z)/(pos1:GetDistance(pos2))) end
	end
end

math.pos2d = function(pos,rad,range)
	return VEC(pos.x + math.sin(rad) * range,pos.z + math.cos(rad) * range)
end

math.normal2d = function(pos1,pos2)
	local rad = math.rad2d(pos1,pos2)
	return VEC(math.sin(rad),math.cos(rad))
end

math.proj2d = function(dotPos,linePos1,linePos2)
	dotPos = VEC(dotPos.x,dotPos.z)
	local dotRad = math.rad2d(linePos1,dotPos)
	local lineRad = math.rad2d(linePos1,linePos2)
	return math.pos2d(linePos1,lineRad,math.cos(lineRad - dotRad) *  dotPos:GetDistance(linePos1))
end

math.center2d = function()
	return D3DXVECTOR3(cameraPos.x,-161.1643,cameraPos.z + (cameraPos.y + 161.1643) * math.sin(0.6545))
end