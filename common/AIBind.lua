--[[
AI lib version 3
by Ivan[RUSSIA]

GPL v1 license

AIBind - lib namespace
	handle symbol(function callback(char letter,void handle))
		hook every letter/number/symbol and send it to callback
	handle number(function callback(float number,void handle))
		hook every number and send it to callback
	handle key(float vkey,function downCallback(void handle) = nil,function upCallback(void handle) = nil)
		hook keyboard key
	handle rmb(function downCallback(void handle) = nil,function upCallback(void handle) = nil)
		hook right mouse button
	handle lmb(function downCallback(void handle) = nil,function upCallback(void handle) = nil)
		hook left button
	handle mouseMove(function callback(void handle))
		hook mouse move
		callback called every mouse movement
	void remove(handle)
		remove hook from processing
	void test(function callback(string description)) 
		diagnosis of lib
		callback called after completion
--]]

AIBind = { }
local data = {}
local dataMove = {}


AIBind.symbol = function(callback)
	local key = #data + 1
	data[key] = function(msg,wParam)
		if msg == KEY_DOWN and (wParam >= 0x30 or wParam == 0x20) then 
			local candidate = ToAscii(wParam)
			if candidate ~= nil then callback(candidate,function() data[key] = nil end) end 
		end
	end
	return function() data[key] = nil end
end
	
AIBind.number = function(callback)
	local key = #data + 1
	data[key] = function(msg,wParam)
		if msg == KEY_DOWN and wParam >= 0x30 and wParam <= 0x39 then callback(wParam - 0x30,function() data[key] = nil end) 
		elseif msg == KEY_DOWN and wParam >= 0x60 and wParam <= 0x69 then callback(wParam - 0x60,function() data[key] = nil end) end
	end
	return function() data[key] = nil end
end

AIBind.key = function(vkey,downCallback,upCallback)
		local key = #data + 1
		data[key] = function(msg,wParam)
			if wParam == vkey then
				if msg == KEY_DOWN and downCallback ~= nil then downCallback(function() data[key] = nil end)
				elseif msg == KEY_UP and upCallback ~= nil then upCallback(function() data[key] = nil end) end
			end
		end
		return function() data[key] = nil end
end
	
AIBind.rmb = function(downCallback,upCallback)
		local key = #data + 1
		data[key] = function(msg,wParam)
			if msg == WM_RBUTTONDOWN and downCallback ~= nil then downCallback(function() data[key] = nil end)
			elseif msg == 0x0206 and downCallback ~= nil then downCallback(function() data[key] = nil end)
			elseif msg == WM_RBUTTONUP and upCallback ~= nil then upCallback(function() data[key] = nil end) end
		end
		return function() data[key] = nil end
end

AIBind.lmb = function(downCallback,upCallback)
		local key = #data + 1
		data[key] = function(msg,wParam)
			if msg == WM_LBUTTONDOWN and downCallback ~= nil then downCallback(function() data[key] = nil end)
			elseif msg == 0x203 and downCallback ~= nil then downCallback(function() data[key] = nil end)
			elseif msg == WM_LBUTTONUP and upCallback ~= nil then upCallback(function() data[key] = nil end) end
		end
		return function() data[key] = nil end
end
	
AIBind.mouseMove = function(callback)
	local key = #dataMove + 1
	dataMove[key] = function(msg,wParam)
		callback(function() dataMove[key] = nil end)
	end
	return function() dataMove[key] = nil end
end
	
AIBind.remove = function(handle)
	handle()
end
	
AIBind.test = function(callback)
	callback("press space")
	AIBind.key(0x20,function(handle)
			AIBind.remove(handle)
			callback("press any number")
			AIBind.number(function(num,handle)
					AIBind.remove(handle)
					callback("press right mouse button")
					AIBind.rmb(nil,function(handle)
							AIBind.remove(handle)
							callback("press any symbol")
							AIBind.symbol(function(symbol,handle)
									AIBind.remove(handle)
									callback("OK")
								end)
						end)
				end)
		end)
			
end

--window key processor
AddMsgCallback(function(msg, wParam)
		if msg ~= WM_MOUSEMOVE then
			for key, value in pairs(data) do
				value(msg,wParam) 
			end
		else
			for key, value in pairs(dataMove) do
				value() 
			end
		end
	end)