require "AITimer"
require "AIMath"
--[[
AI lib version 3
by Ivan[RUSSIA]

GPL v1 license

description - screenPos are coefs from 0 to 1, for example 0.5 is midle of the screen. USE FUNCTIONS OUT OF OnDraw() CALLBACK

AI.draw - lib namespace. 
	handle circle({x,y,z} gamePos,float range = 350,float ARGB = GREEN)
		draw circle ingame around gamepos
	handle arrow({x,y,z} gamePos1,{x,y,z} gamePos2,float width)
		draw arrow ingame from pos1 to pos2
	void remove(void handle) 
		removing handle from screen
	void reset() 
		removes all handles from screen
	void test() 
		diagnosis of lib
--]]

if AI == nil then AI = {} end
AI.draw = {
	circle = function(unit,range,ARGB)
		ARGB = ARGB or 0xAA00FF00
		range = range or 350
		local key = #AI.draw.data + 1
		AI.draw.data[key] = function()
			DrawCircle(unit.x,unit.y,unit.z,range,ARGB)
		end
		return key
	end,
	arrow = function(pos1,pos2,width)
		local key = #AI.draw.data + 1
		AI.draw.data[key] = function()
			DrawArrow(D3DXVECTOR3(pos1.x,pos1.y,pos1.z),D3DXVECTOR3(pos2.x - pos1.x,pos1.y,pos2.z - pos1.z),AI.math.distance(pos1,pos2),width,10000000000000000000000, RGBA(255,255,255,0))
		end
		return key
	end,
	remove = function(handle)
		AI.draw.data[handle] = nil
	end,
	reset = function()
		for key, value in pairs(AI.draw.data) do 
			if value.remove ~= nil then value.remove() end
			AI.draw.data[key] = nil
		end
	end,
	test = function()
		PrintChat(">> AI.draw.test()")
		local handles = {AI.draw.circle(myHero),AI.draw.arrow(myHero,{x=0,y=0,z=0},150)}
		AI.timer.add(true,15,function() 
				for i=1,#handles,1 do AI.draw.remove(handles[i]) end
			end)
	end,
	data = {},
}
--draw processor
AddDrawCallback(function()
		--check requests
		for key, value in pairs(AI.draw.data) do value() end
	end)