--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

table AIData - data gatherer
table AICondition - functions for detecting conditions
table AITimer - timer with callbacks management
table AIRoutine - usefull lua+math functions
table AISpell - spell/items abstraction
table AIGui - user interface + AIDraw inside
table AIFind - searching abstraction
table AIStat - analytic abstraction
table AIBind - easy key bindings
--]]

require "AIData"
require "AICondition" --too hard implement auto test
require "AITimer"
require "AIRoutine"
require "AISpell" --too hard implement auto test
require "AIGui" 
require "AIFind"
require "AIStat"
require "AIBind"

--you should call this function, to test library
function AITest()
	AIGui.test(function(result)
			if result ~= "OK" then PrintChat("AITest failed at AIGui:"..result)
			else
				local isFinished = false
				local tGui = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.3,"AIGui: OK")
				local tData = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.333,"AIData: "..AIData.test())
				local tTimer = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.366,"AITimer: ...")
				AITimer.test(3,function(timerResult)
						if isFinished == false then
							AIGui.remove(tTimer)
							tTimer = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.366,"AITimer: "..timerResult)
						end
					end)
				local tMath = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.4,"AIRoutine: "..AIRoutine.test())
				local tFind = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.433,"AIFind: "..AIFind.test())
				local tState = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.466,"AIStat: "..AIStat.test())
				local tBind = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.5,"AIBind: ...")
				AIBind.test(function(bindResult)
						if isFinished == false then
							AIGui.remove(tBind)
							tBind = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.5,"AIBind: "..bindResult)
						end
					end)
				local tEvent = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.533,"AIEvent: ...")
				AIEvent.test(function(eventResult)
						if isFinished == false then
							AIGui.remove(tEvent)
							tEvent = AIGui.text(WINDOW_W * 0.45,WINDOW_H * 0.533,"AIEvent: "..eventResult)
						end
					end)
				local button = nil
				button = AIGui.button(WINDOW_W * 0.45,WINDOW_H * 0.566,"Close",function() 
						isFinished = true
						AIGui.remove(tGui)
						AIGui.remove(tData)
						AIGui.remove(tTimer)
						AIGui.remove(tMath)
						AIGui.remove(tFind)
						AIGui.remove(tState)
						AIGui.remove(tBind)
						AIGui.remove(tEvent)
						AIGui.remove(button)
					end) 
			end
		end)
	
end

