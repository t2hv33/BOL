--[[
AI lib version 3
by Ivan[RUSSIA]

GPL v1 license

AI.math - lib namespace
	{x,z} normalized({x,z} pos1,{x,z} pos2)
		return normalized pos1-pos2 vector
	float rad({x,z} pos1,{x,z} pos2)
		return degree between two points in radians, zero & 360 grad is NORTH
		float math.rad(float degree) - converter
		float math.deg(float rad) - converter
	{x,z} pos({x,z} pos, float rad, float range)
		return point moved by RANGE to RADIANS side
	float distance({x,z} pos1,{x,z} pos2)
		return distance between pos1 and pos2
	{x,z} project(linePos1,linePos2,dotPos)
		return dotPos, falled to line by 90 degree
	float greenToRed(float coef)
		return RGB color between RED and GREEN,
		coef == 0.5 is yellow
		coef == 1 is green
		coef == 0 is red
	void test()
		print AI.math library diagnosis
--]]

if AI == nil then AI = {} end
AI.math = {
	normalized = function(pos1,pos2)
		local rad = AI.math.rad(pos1,pos2)
		return {x = math.sin(rad),z = math.cos(rad)}
	end,
	rad = function(pos1,pos2)
		local a = AI.math.distance({x=pos1.x,z=pos2.z},{x=pos2.x,z=pos2.z})
		local b = AI.math.distance({x=pos1.x,z=pos1.z},{x=pos1.x,z=pos2.z})
		local c = AI.math.distance({x=pos1.x,z=pos1.z},{x=pos2.x,z=pos2.z})
		if pos2.z > pos1.z then
			if pos1.x < pos2.x then return math.acos(b/c)
			else return 6.283185307 - math.acos(b/c) end
		else 
			if pos1.x < pos2.x then return 1.570796327 + math.acos(a/c)
			else return 4.712388980 - math.acos(a/c) end
		end
	end,
	pos = function(pos,rad,range)
		return {x = pos.x + math.sin(rad) * range, z = pos.z + math.cos(rad) * range}
	end,
	distance = function(pos1,pos2)
		return math.sqrt((pos1.x-pos2.x)^2+(pos1.z-pos2.z)^2)
	end,
	greenToRed = function(coef)
		return RGB(255*(1-coef),255*coef,0)
	end,
	project = function(linePos1,linePos2,dotPos)
		local dotRad = AI.math.rad(linePos1,dotPos)
		local lineRad = AI.math.rad(linePos1,linePos2)
		local distance = math.cos(lineRad - dotRad) *  AI.math.distance(linePos1,dotPos)
		return AI.math.pos(linePos1,lineRad,distance)
	end,
	test = function()
		PrintChat(">> AI.math.test()")
		local norma = AI.math.normalized({x=0,z=0},{x=1000,z=0})
		if norma.x > 1.025  or norma.x < 0.975 or norma.z > 0.025 or norma.x < -0.025 then PrintChat("<< AI.math.test() failed at AI.math.normalized") return end
		local color = AI.math.greenToRed(0)
		if color ~= 0xFFFF0000 then PrintChat("<< AI.math.test() failed at AI.math.color") return end
		local degree = math.deg(AI.math.rad({x=0,z=0},{x=-1333,z=0}))
		if degree < 267.5 or degree > 272.5 then PrintChat("<< AI.math.test() failed at AI.math.rad") return end
		local distance = AI.math.distance({x=0,z=0},{x=1000000,z=0})
		if distance < 999999 or distance > 1000001 then PrintChat("<< AI.math.test() failed at AI.math.distance") return end
		local pos = AI.math.pos({x=0,z=0},math.rad(180),100)
		if pos.x < -0.025 or pos.x > 0.025 or pos.z < -100.25 or pos.z > -99.75 then PrintChat("<< AI.math.test() failed at AI.math.pos") return end
		local project = AI.math.project({x=-1000,z=0},{x = 1000,z = 0}, { x = 0, z = -9999}) 
		if project.x < -0.025 or project.x > 0.025 or project.z < -0.025 or project.z > 0.025 then PrintChat("<< AI.math.test() failed at AI.math.pos") return end
		PrintChat("<< AI.math.test() complete")
	end,
}