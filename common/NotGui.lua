--[[
NotGui lib version 6
by Ivan[RUSSIA]

GPL v2 license
--]]

local guiCache = {}
AddDrawCallback(function()
		for key,handle in pairs(guiCache) do if handle.hide == false then
			handle.callback()
		end end
	end)
gui = function(key)
	if guiCache[key] == nil then
		guiCache[key] = {hide = false,x=0,y=0,w=0,h=0}
		guiCache[key].callback = function() end
		guiCache[key].remove = function() guiCache[key] = nil end
		guiCache[key].inside = function(x,y) return x >= guiCache[key].x and x <= guiCache[key].x + guiCache[key].w and y >= guiCache[key].y and y <= guiCache[key].y + guiCache[key].h end
		guiCache[key].transform = function(to,param)
			if to == "text" then
				guiCache[key].h = WINDOW_H/40
				guiCache[key].w = GetTextArea(param,guiCache[key].h).x
				guiCache[key].callback = function() DrawText(param,guiCache[key].h,guiCache[key].x,guiCache[key].y,0xAAFFFF00) end
			elseif to == "button" then
				guiCache[key].h = WINDOW_H/40
				guiCache[key].w = GetTextArea(param,guiCache[key].h).x + guiCache[key].h
				guiCache[key].callback = function() 
					DrawLine(guiCache[key].x,guiCache[key].y+guiCache[key].h/2,guiCache[key].x+guiCache[key].w,guiCache[key].y+guiCache[key].h/2,guiCache[key].h,0xBB964B00)
					DrawText(param,guiCache[key].h,guiCache[key].x+guiCache[key].h/2,guiCache[key].y,0xAAFFFF00)
				end
			end
		end
	end
	return guiCache[key]
end