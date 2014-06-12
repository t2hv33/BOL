--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

comment - timer works in seconds, precision is starting to fail at 0.1 seconds

AITimer - lib namespace
	handle add(float cooldown,function callback(handle)) 
		library will call callback, every time cooldown elapse,
		You can stop timer inside callback, example: function callback(handle) AITimer.remove(handle) end
	void pause(void handle,float cooldown)
		timer will be continued, after cooldown elapse
		missed timeouts callbacked 
	handle remove(void handle) 
		library remove timer, and stop call it
		handle is returned by AI.timer.add
	float performance(string code,iters = 1000)
		start performance test of your code string
		as default it makes 1000 iterations
		return time per iteration in mseconds
	void test(float testTime,function callback(string description))
		tests precision, return callback after completition
--]]

AITimer = { }
local data = {}
	
AITimer.add = function(cooldown,callback)
	local key = #data + 1
	local lastcall = os.clock()
	data[key] = function(time)
		if time >= lastcall + cooldown then
			callback(key)
			lastcall = lastcall + cooldown
		end
	end
	return key
end

AITimer.pause = function(handle,pause)
	--calc end of pause
	pause = os.clock() + pause
	--remove timer from processing
	local saved = data[handle]
	--place pause placeholder
	data[handle] = function(time)
		--check pause ended
		if time >= pause then
			--remove placeholder
			data[handle] = saved
		end
	end
end

AITimer.remove = function(handle)
	data[handle] = nil
end

AITimer.performance = function(str,iters)
	iters = iters or 1000
	str = assert(load(str))
	local start = os.clock()
	for i=1,iters,1 do str() end
	return (os.clock() - start) * 1000 / iters
end

AITimer.test = function(time,callback)
	local start = os.clock()
	local timerID = AITimer.add(time,function(handle) 
			local error = math.abs(os.clock() - start - time)
			if error/time < 0.05 then callback("OK") else callback("precision error: "..tostring(math.floor(error/time * 100 + 0.5)).."%") end
			AITimer.remove(handle)
		end)
	AITimer.pause(timerID,time * 0.95)
end


--timers processor
AddTickCallback(function()
		--check timers
		local time = os.clock()
		for key, value in pairs(data) do
			value(time)
		end
	end)