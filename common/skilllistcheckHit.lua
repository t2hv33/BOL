--[[
	skilllist + checkHit Library 1.1 by eXtragoZ
	checkSkillHit taken from AntiSkillshot
]]

function checkhitaoe(pos1, pos2, radius, target, playerradius)
    local distancePos2 = GetDistance(target, pos2)
	return (distancePos2 < radius+playerradius)
end
function checkhitlinepoint(pos1, pos2, radius, target, playerradius)
	local distancePos1 = GetDistance(target, pos1)
    local distancePos2 = GetDistance(target, pos2)
    local distancePos1Pos2 = GetDistance(pos1, pos2)
    local perpendicular = (math.floor((math.abs((pos2.x-pos1.x)*(pos1.z-target.z)-(pos1.x-target.x)*(pos2.z-pos1.z)))/distancePos1Pos2))
	return (perpendicular < radius+playerradius and distancePos2 < distancePos1Pos2 and distancePos1 < distancePos1Pos2)
end
function checkhitlinepass(pos1, pos2, radius, maxDist, target, playerradius)
	local distancePos1 = GetDistance(target, pos1)
	local distancePos1Pos2 = GetDistance(pos1, pos2)
	local pos3 = {}
	pos3.x = pos1.x + (maxDist)/distancePos1Pos2*(pos2.x-pos1.x)
    pos3.z = pos1.z + (maxDist)/distancePos1Pos2*(pos2.z-pos1.z)
    local distancePos3 = GetDistance(target, pos3)
    local distancePos1Pos3 = GetDistance(pos1, pos3)
    local perpendicular = (math.floor((math.abs((pos3.x-pos1.x)*(pos1.z-target.z)-(pos1.x-target.x)*(pos3.z-pos1.z)))/distancePos1Pos3))
	return (perpendicular < radius+playerradius and distancePos3 < distancePos1Pos3 and distancePos1 < distancePos1Pos3)
end
function checkhitcone(pos1, pos2, angle, maxDist, target, playerradius)
	local distancePos1 = GetDistance(target, pos1)
	local distancePos1Pos2 = GetDistance(pos1, pos2)
	local pos3 = {}
	pos3.x = pos1.x + (maxDist)/distancePos1Pos2*(pos2.x-pos1.x)
    pos3.z = pos1.z + (maxDist)/distancePos1Pos2*(pos2.z-pos1.z)
    local distancePos3 = GetDistance(target, pos3)
    local distancePos1Pos3 = GetDistance(pos1, pos3)
    local perpendicular = (math.floor((math.abs((pos3.x-pos1.x)*(pos1.z-target.z)-(pos1.x-target.x)*(pos3.z-pos1.z)))/distancePos1Pos3))
	local radius = (math.tan(math.rad(angle/2)))*distancePos1
	return (perpendicular < radius+playerradius and distancePos3 < distancePos1Pos3 and distancePos1 < distancePos1Pos3)
end
function checkhitwall(pos1, pos2, radius, maxDist, target, playerradius)
	local distancePos2 = GetDistance(target, pos2)
	return (distancePos2 < radius+playerradius)
end

skillShield = {
	Ahri = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Akali = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = "Slow"},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Alistar = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Amumu = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Anivia = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = false, Shield = true, CC = "Slow"}
	},
	Annie = {
		P = {BShield = false, SShield = false, Shield = false, CC = true},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Ashe = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = false, Shield = true, CC = "Slow"},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Blitzcrank = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Brand = {
		P = {BShield = true, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Caitlyn = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Cassiopeia = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Chogath = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Corki = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Darius = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = false, CC = true},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Diana = {
		P = {BShield = true, SShield = true, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = false, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},	
	DrMundo = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Draven = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = false, SShield = false, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Evelynn = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = "Slow"}
	},
	Ezreal = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	FiddleSticks = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = false, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = false, Shield = true, CC = false}
	},
	Fiora = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = true, CC = false},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Fizz = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Galio = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Gangplank = {
		P = {BShield = true, SShield = false, Shield = true, CC = "Slow"},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = "Slow"}
	},
	Garen = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Gragas = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Graves = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Hecarim = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Heimerdinger = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = false, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Irelia = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Janna = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Jarvan = {
		P = {BShield = false, SShield = true, Shield = true, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = false, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Jax = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = false, Shield = true, CC = false}
	},
	Jayce = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		QM = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		WM = {BShield = true, SShield = false, Shield = true, CC = false},
		EM = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = true, CC = false}
	},
	Karma = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = false, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Karthus = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = false, CC = "Slow"},
		E = {BShield = true, SShield = false, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Kassadin = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Katarina = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Kayle = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = false, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Kennen = {
		P = {BShield = false, SShield = false, Shield = false, CC = true},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Khazix = {
		P = {BShield = true, SShield = false, Shield = true, CC = "Slow"},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = true, Shield = true, CC = false},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	KogMaw = {
		P = {BShield = false, SShield = true, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Leblanc = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	LeeSin = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Leona = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Lulu = {
		P = {BShield = true, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = false, CC = true}
	},
	Lux = {
		P = {BShield = true, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Malphite = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = false, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Malzahar = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = false, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Maokai = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	MasterYi = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	MissFortune = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = false, Shield = true, CC = "Slow"},
		R = {BShield = false, SShield = false, Shield = true, CC = false}
	},
	Mordekaiser = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Morgana = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Nasus = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = false, CC = "Slow"},
		E = {BShield = true, SShield = false, Shield = true, CC = false},
		R = {BShield = true, SShield = false, Shield = true, CC = false}
	},
	Nautilus = {
		P = {BShield = true, SShield = true, Shield = true, CC = true},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Nidalee = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		QM = {BShield = false, SShield = true, Shield = true, CC = false},
		WM = {BShield = true, SShield = true, Shield = true, CC = false},
		EM = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Nocturne = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Nunu = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = false, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = "Slow"}
	},
	Olaf  = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = false, SShield = false, Shield = true, CC = false},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Orianna = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Pantheon = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = "Slow"}
	},
	Poppy = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Rammus = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = false, CC = true},
		R = {BShield = true, SShield = false, Shield = true, CC = false}
	},
	Renekton = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = false, Shield = true, CC = false}
	},
	Rengar = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Riven = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Rumble = {
		P = {BShield = true, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = false, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = "Slow"}
	},
	Ryze = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = true},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Sejuani = {
		P = {BShield = true, SShield = false, Shield = true, CC = "Slow"},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Shaco = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = false, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Shen = {
		P = {BShield = true, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Shyvana = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Singed = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = false, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = false, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Sion = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Sivir = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = true, Shield = true, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Skarner = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Sona = {
		P = {BShield = true, SShield = true, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Soraka = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Swain = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Syndra = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Talon = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = true, Shield = true, CC = false}
	},
	Taric = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = false, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Teemo = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = false, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = "Slow"}
	},
	Tristana = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = false, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Trundle = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = false, Shield = false, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Tryndamere = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = false, CC = false},
		W = {BShield = false, SShield = true, Shield = false, CC = "Slow"},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	TwistedFate = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = true, SShield = false, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Twitch = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = false, SShield = false, Shield = false, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = true, CC = false}
	},
	Udyr = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = false, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = false, Shield = true, CC = false}
	},
	Urgot = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Varus = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Vayne = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = false, SShield = false, Shield = true, CC = false}
	},
	Veigar = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = false, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Viktor = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = false, CC = true},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Vladimir = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = false, Shield = true, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Volibear = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = true},
		W = {BShield = false, SShield = true, Shield = true, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = false, Shield = true, CC = false}
	},
	Warwick = {
		P = {BShield = true, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = false, SShield = false, Shield = false, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	MonkeyKing = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = true, Shield = true, CC = false},
		E = {BShield = false, SShield = true, Shield = true, CC = false},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Xerath = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	XinZhao = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = false, Shield = true, CC = true},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
	Yorick = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = false, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		E = {BShield = true, SShield = true, Shield = true, CC = false},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Ziggs = {
		P = {BShield = true, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = true, SShield = true, Shield = true, CC = true},
		E = {BShield = true, SShield = true, Shield = true, CC = "Slow"},
		R = {BShield = true, SShield = true, Shield = true, CC = false}
	},
	Zilean = {
		P = {BShield = false, SShield = false, Shield = false, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = false, CC = "Slow"},
		R = {BShield = false, SShield = false, Shield = false, CC = false}
	},
	Zyra = {
		P = {BShield = false, SShield = false, Shield = true, CC = false},
		Q = {BShield = true, SShield = true, Shield = true, CC = false},
		W = {BShield = false, SShield = false, Shield = false, CC = false},
		E = {BShield = true, SShield = true, Shield = true, CC = true},
		R = {BShield = true, SShield = true, Shield = true, CC = true}
	},
}

skillData = {
	Ahri = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 880, type = 1, radius = 80},
		W = {maxdistance = 0, type = 3, radius = 800},
		E = {maxdistance = 975, type = 1, radius = 80},
		R = {maxdistance = 0, type = 3, radius = 550}
	},
	Akali = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 400},
		E = {maxdistance = 0, type = 3, radius = 163},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Alistar = {
		P = {maxdistance = 0, type = 3, radius = 200},
		Q = {maxdistance = 0, type = 3, radius = 183},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 288},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Amumu = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1100, type = 1, radius = 80},
		W = {maxdistance = 0, type = 3, radius = 150},
		E = {maxdistance = 0, type = 3, radius = 200},
		R = {maxdistance = 0, type = 3, radius = 600}
	},
	Anivia = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1100, type = 1, radius = 90},
		W = {maxdistance = 0, type = 5, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 400}
	},
	Annie = {
		P = {maxdistance = 0, type = 0, radius = 80},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 625, type = 4, radius = 53},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 280}
	},
	Ashe = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 1200, type = 4, radius = 52},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 500, type = 1, radius = 120}
	},
	Blitzcrank = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 925, type = 1, radius = 80},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 600}
	},
	Brand = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1050, type = 1, radius = 50},
		W = {maxdistance = 0, type = 3, radius = 250},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Caitlyn = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1300, type = 1, radius = 80},
		W = {maxdistance = 0, type = 3, radius = 150},
		E = {maxdistance = 800, type = 1, radius = 50},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Cassiopeia = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 75},
		W = {maxdistance = 0, type = 3, radius = 175},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 850, type = 4, radius = 85}
	},
	Chogath = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 275},
		W = {maxdistance = 700, type = 4, radius = 60},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Corki = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 280},
		W = {maxdistance = 0, type = 2, radius = 150},
		E = {maxdistance = 600, type = 4, radius = 40},
		R = {maxdistance = 1225, type = 1, radius = 150}
	},
	Darius = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 425},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 550, type = 4, radius = 54},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Diana = {
		P = {maxdistance = 0, type = 3, radius = 100},
		Q = {maxdistance = 0, type = 3, radius = 205},
		W = {maxdistance = 0, type = 3, radius = 240},
		E = {maxdistance = 0, type = 3, radius = 440},
		R = {maxdistance = 0, type = 0, radius = 0}
	},	
	DrMundo = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 10, type = 1, radius = 80},
		W = {maxdistance = 0, type = 3, radius = 163},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Draven = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 1050, type = 1, radius = 125},
		R = {maxdistance = 200, type = 1, radius = 100}
	},
	Evelynn = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 500},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 250}
	},
	Ezreal = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1100, type = 1, radius = 80},
		W = {maxdistance = 900, type = 1, radius = 100},
		E = {maxdistance = 0, type = 3, radius = 100},
		R = {maxdistance = 50000, type = 1, radius = 150}
	},
	FiddleSticks = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 600}
	},
	Fiora = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Fizz = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 290},
		R = {maxdistance = 0, type = 2, radius = 290}
	},
	Galio = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 200},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 1000, type = 1, radius = 120},
		R = {maxdistance = 0, type = 3, radius = 560}
	},
	Gangplank = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 700},
		R = {maxdistance = 0, type = 3, radius = 600}
	},
	Garen = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 165},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Gragas = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 320},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 2, radius = 60},
		R = {maxdistance = 0, type = 3, radius = 400}
	},
	Graves = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 750, type = 4, radius = 33},
		W = {maxdistance = 0, type = 3, radius = 275},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 1000, type = 1, radius = 110}
	},
	Hecarim = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 350},
		W = {maxdistance = 0, type = 3, radius = 525},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 1000, type = 1, radius = 280}
	},
	Heimerdinger = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 525},
		W = {maxdistance = 0, type = 3, radius = 1000},
		E = {maxdistance = 0, type = 3, radius = 225},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Irelia = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 1200, type = 1, radius = 80}
	},
	Janna = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1700, type = 1, radius = 100},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 362}
	},
	Jarvan = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 770, type = 1, radius = 70},
		W = {maxdistance = 0, type = 3, radius = 300},
		E = {maxdistance = 0, type = 3, radius = 150},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Jax = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 188},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Jayce = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1050, type = 1, radius = 100},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 5, radius = 0},
		QM = {maxdistance = 0, type = 3, radius = 100},
		WM = {maxdistance = 0, type = 3, radius = 285},
		EM = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Karma = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 600, type = 4, radius = 70},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 300},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Karthus = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 120},
		W = {maxdistance = 0, type = 5, radius = 800},
		E = {maxdistance = 0, type = 3, radius = 425},
		R = {maxdistance = 0, type = 3, radius = 500000}
	},
	Kassadin = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 400, type = 4, radius = 82},
		R = {maxdistance = 0, type = 3, radius = 150}
	},
	Katarina = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 375},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 275}
	},
	Kayle = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Kennen = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1050, type = 1, radius = 75},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 275}
	},
	Khazix = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 1000, type = 1, radius = 50},
		E = {maxdistance = 0, type = 3, radius = 325},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	KogMaw = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 1115, type = 1, radius = 100},
		R = {maxdistance = 0, type = 3, radius = 200}
	},
	Leblanc = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 250},
		E = {maxdistance = 1000, type = 1, radius = 80},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	LeeSin = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 975, type = 1, radius = 80},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 175},
		R = {maxdistance = 1200, type = 1, radius = 100}
	},
	Leona = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 275},
		E = {maxdistance = 700, type = 1, radius = 80},
		R = {maxdistance = 0, type = 3, radius = 250}
	},
	Lulu = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 925, type = 1, radius = 50},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 150}
	},
	Lux = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1175, type = 1, radius = 80},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 300},
		R = {maxdistance = 3000, type = 1, radius = 80}
	},
	Malphite = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 200},
		E = {maxdistance = 0, type = 3, radius = 200},
		R = {maxdistance = 0, type = 3, radius = 300}
	},
	Malzahar = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 5, radius = 400},
		W = {maxdistance = 0, type = 3, radius = 250},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Maokai = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 600, type = 1, radius = 100},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 350},
		R = {maxdistance = 0, type = 3, radius = 575}
	},
	MasterYi = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	MissFortune = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 400},
		R = {maxdistance = 1400 , type = 4, radius = 38}
	},
	Mordekaiser = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 250 },
		E = {maxdistance = 700, type = 4, radius = 54},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Morgana = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1300, type = 1, radius = 100},
		W = {maxdistance = 0, type = 3, radius = 350},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 600}
	},
	Nasus = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 400},
		R = {maxdistance = 0, type = 3, radius = 175}
	},
	Nautilus = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 950, type = 1, radius = 80},
		W = {maxdistance = 0, type = 3, radius = 350},
		E = {maxdistance = 0, type = 3, radius = 600},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Nidalee = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1500, type = 1, radius = 80},
		W = {maxdistance = 0, type = 3, radius = 75},
		E = {maxdistance = 0, type = 0, radius = 0},
		QM = {maxdistance = 0, type = 0, radius = 0},
		WM = {maxdistance = 0, type = 3, radius = 375},
		EM = {maxdistance = 300, type = 4, radius = 80},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Nocturne = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1200, type = 1, radius = 80},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Nunu = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 1300}
	},
	Olaf  = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1000, type = 2, radius = 100},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Orianna = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 150},
		W = {maxdistance = 0, type = 3, radius = 250},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 400}
	},
	Pantheon = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 600, type = 4, radius = 70},
		R = {maxdistance = 0, type = 3, radius = 700}
	},
	Poppy = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Rammus = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 200},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 150}
	},
	Renekton = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 225},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 450, type = 1, radius = 80},
		R = {maxdistance = 0, type = 3, radius = 175}
	},
	Rengar = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 500},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Riven = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 112.5},
		W = {maxdistance = 0, type = 3, radius = 125},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 900, type = 4, radius = 48}
	},
	Rumble = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 600, type = 4, radius = 70},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 1000, type = 1, radius = 100},
		R = {maxdistance = 1700, type = 1, radius = 100}
	},
	Ryze = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Sejuani = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 700, type = 2, radius = 80},
		W = {maxdistance = 0, type = 3, radius = 350},
		E = {maxdistance = 0, type = 3, radius = 1000},
		R = {maxdistance = 1150, type = 1, radius = 80}
	},
	Shaco = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 300},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Shen = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 600, type = 2, radius = 80},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Shyvana = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 163},
		E = {maxdistance = 1000, type = 1, radius = 80},
		R = {maxdistance = 925, type = 2, radius = 80}
	},
	Singed = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 175},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Sion = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 275},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Sivir = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1100, type = 1, radius = 100},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Skarner = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 350},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 600, type = 1, radius = 100},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Sona = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 650},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 1000, type = 1, radius = 150}
	},
	Soraka = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 530},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Swain = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 275},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 700}
	},
	Syndra = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 225},
		E = {maxdistance = 650, type = 4, radius = 43},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Talon = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 600, type = 4, radius = 56},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 500}
	},
	Taric = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 200},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 200}
	},
	Teemo = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 200}
	},
	Tristana = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 290},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 200}
	},
	Trundle = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 188},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Tryndamere = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 400},
		E = {maxdistance = 600, type = 2, radius = 100},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	TwistedFate = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1450, type = 1, radius = 80},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Twitch = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 290},
		E = {maxdistance = 0, type = 3, radius = 600},
		R = {maxdistance = 850, type = 1, radius = 80}
	},
	Udyr = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 250}
	},
	Urgot = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 150},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Varus = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 1475, type = 1, radius = 50},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},--
		R = {maxdistance = 1075, type = 1, radius = 80}
	},
	Vayne = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Veigar = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 245},
		E = {maxdistance = 0, type = 3, radius = 400},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Viktor = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 320},
		E = {maxdistance = 700, type = 1, radius = 80},
		R = {maxdistance = 0, type = 3, radius = 270}
	},
	Vladimir = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 150},
		E = {maxdistance = 0, type = 3, radius = 610},
		R = {maxdistance = 0, type = 3, radius = 450}
	},
	Volibear = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 425},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Warwick = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	MonkeyKing = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 175},
		E = {maxdistance = 0, type = 3, radius = 163},
		R = {maxdistance = 0, type = 3, radius = 163}
	},
	Xerath = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 900, type = 1, radius = 80},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 3, radius = 250}
	},
	XinZhao = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 3, radius = 113},
		R = {maxdistance = 0, type = 3, radius = 188}
	},
	Yorick = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 3, radius = 100},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Ziggs = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 160},
		W = {maxdistance = 0, type = 3, radius = 225},
		E = {maxdistance = 0, type = 3, radius = 250},
		R = {maxdistance = 0, type = 3, radius = 550}
	},
	Zilean = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 0, radius = 0},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 0, type = 0, radius = 0},
		R = {maxdistance = 0, type = 0, radius = 0}
	},
	Zyra = {
		P = {maxdistance = 0, type = 0, radius = 0},
		Q = {maxdistance = 0, type = 3, radius = 275},
		W = {maxdistance = 0, type = 0, radius = 0},
		E = {maxdistance = 1100, type = 1, radius = 90},
		R = {maxdistance = 0, type = 3, radius = 530}
	},
}
