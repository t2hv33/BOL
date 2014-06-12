require "AIBind"
--[[
AI lib version 4
by Ivan[RUSSIA]

GPL v1 license

AIGui - lib namespace 
	handle text(float x,float y,string text) 
		draw text onscreen
	handle button(float x,float y,string name,function callback())
		draw button onscreen
		callback called everytime button pressed
	handle tick(float x,float y,bool default,function callback(bool state))
		draw tick onscreen
		after user edited variable, callback called
	handle slider(float x,float y,float defaultNumber,float min,float max,function callback(float number))
		draw number onscreen
		callback called everytime user edited number
	handle,function bar(float x,float y,float startValue,float endValue)
		draw progress bar onscreen
		this function return handle & setter 
		you should use setter to change progress of bar 
		example:
			handle,setter = AIGui.bar(100,100,0,100)
			setter(50)
		this example creates progress bar, and set progress to 50%
		
	handle line(float x,float y,table handles)
		draw horizontal union of handles
		handles become the list property and handled by union
	handle list(float x,float y,table handles)
		draw vertical union of handles
		handles become the list property and handled by union
	handle anchor(float x,float y,void handle)
		user can move handle's item through anchor
		handle become the anchor property and handled by anchor
	handle question(float x,float y,string question,function callback(bool answer))
		user asked for question
		callback called with answer (true = yes,false = no)
	
	float,float pos(handle)
		return x,y pos of handle
	void init(void handle,...)
		this function reinit selected handle
		... are same params as been handle's function creator has
		example:
			local handle = AIGui.text(100,100,"Yep")
			AIGui.init(handle,50,50,"Nope")
		if params are niled then they are not changed
		example:
			local handle = AIGui.text(100,100,"Yep")
			AIGui.init(handle,nil,nil,"Nope")
	void remove(void handle) 
		removing handle from screen
	void reset() 
		removes all handles from screen
	void test(function callback(string description)) 
		starts diagnosis of lib
		sends callback with description upon completion
	
	void save(float line,string toSave) 
		this function works with lua file
		replace your line with string
		
AIDraw - lib namespace. 
	handle circle({x,y,z} gamePos,float range,float ARGB = GREEN)
		draw circle ingame around gamepos
	handle arrow({x,y,z} gamePos1,{x,y,z} gamePos2,float width)
		draw arrow ingame from pos1 to pos2
	void remove(void handle) 
		removing handle from screen
	void reset() 
		removes all handles from screen
--]]

AIGui = {}
--begin private data structure
local data = {}
--save colors
local font,back = 0xAAFFFF00,0xBB964B00 
--save text size
local tSize = math.max(WINDOW_H,768)/40
--save line size
local lSize = math.max(WINDOW_H,768)/225
--save double size line
local lSize2 = lSize * 2
--save trible size line
local lSize3 = lSize * 3

AIGui.text = function(x,y,text)
	local self = {height = tSize}
	--init
	self.init = function(reX,reY,reText)
		x,y,text = reX or x,reY or y,reText or text
		self.width = GetTextArea(text,tSize).x
	end
	--draw text
	self.draw = function()
		DrawText(text,tSize,x,y,font)
	end
	--retrieve pos
	self.pos = function() return x,y end
	--move to processor 
	self.init()
	local key = #data + 1
	data[key] = self
	return key
end

AIGui.button = function(x,y,name,callback)
	local self = {height = tSize}
	--save size
	local finish,textStart,textFinish,mid = nil,nil,nil,nil
	--init
	self.init = function(reX,reY,reName,reCallback)
		x,y,name,callback = reX or x,reY or y,reName or name,reCallback or callback
		finish = x + GetTextArea(name,tSize).x + tSize
		textStart,textFinish = x + tSize/2,finish - tSize/2
		mid = y + tSize/2
		self.width = finish - x
	end
	--draw
	self.draw = function()
		--draw box
		DrawLine(x,mid,finish,mid,tSize,back)
		--draw name
		DrawText(name,tSize,textStart,y,font)
	end
	--button init
	local mouseBind = AIBind.lmb(nil,function()
			local clickPos = GetCursorPos()
			--check clicked inside button
			if clickPos.x >= x and clickPos.x <= finish
			and clickPos.y >= y and clickPos.y <= y + tSize then
				callback()
			end
		end)
	--retrieve pos
	self.pos = function() return x,y end
	--remove binding
	self.unbind = function()
		AIBind.remove(mouseBind)
	end
	--move to processor 
	self.init()
	local key = #data + 1
	data[key] = self
	return key
end

AIGui.tick = function(x,y,default,callback)
	local self = {height = tSize,width = tSize}
	--save size
	local finishX,tick1X,finishX,finishY,tick1X,tick1Y,tick2X,tick2Y,tick3X,tick3Y = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	--init
	self.init = function(reX,reY,reDefault,reCallback)
		x,y,default,callback = reX or x,reY or y,reDefault or default,reCallback or callback
		finishX,finishY = x + tSize,y + tSize
		tick1X,tick1Y = x + tSize/6,y + tSize/2.3
		tick2X,tick2Y = x + tSize/2,y + tSize/1.3
		tick3X,tick3Y = x + tSize/1.3,y + tSize/7
	end
	--draw
	self.draw = function()
		--box
		DrawLine(x,y,finishX,y,2,back)
		DrawLine(x,y,x,finishY,2,back)
		DrawLine(x,finishY,finishX,finishY,2,back)
		DrawLine(finishX,y,finishX,finishY,2,back)
		--tick
		if default == true then
			DrawLine(tick1X,tick1Y,tick2X,tick2Y,lSize,font)
			DrawLine(tick2X,tick2Y,tick3X,tick3Y,lSize,font)
		end
	end
	--button init
	local mouseBind = AIBind.lmb(function()
			local clickPos = GetCursorPos()
			--check clicked inside tick area
			if clickPos.x >= x and clickPos.x <= finishX
			and clickPos.y >= y and clickPos.y <= finishY then
				default = not default
				callback(default)
			end
		end)
	--retrieve pos
	self.pos = function() return x,y end
	--remove binding
	self.unbind = function()
		AIBind.remove(mouseBind)
	end
	--move to processor 
	self.init()
	local key = #data + 1
	data[key] = self
	return key
end

AIGui.slider = function(x,y,default,min,max,callback)
	local self = {height = tSize}
	--save size
	local lineStart,lineFinish,sliderX,sliderY,textStart,mid,defaultStr = nil,nil,nil,nil,nil,nil,nil
	--init
	self.init = function(reX,reY,reDefault,reMin,reMax,reCallback)
		x,y,default,min,max,callback = reX or x,reY or y,reDefault or default,reMin or min,reMax or max,reCallback or callback
		lineStart = x + tSize/2
		lineFinish = lineStart + 5 * tSize
		sliderX,sliderY = x + tSize/2 + (lineFinish - lineStart )/(max  - min) * (default - min),y + tSize
		textStart = x + tSize * 6
		mid = y + tSize/2
		defaultStr = tostring(default)
		self.width = tSize * 6 + math.max(GetTextArea(tostring(min),tSize).x,GetTextArea(tostring(max),tSize).x) 
	end
	--draw init
	self.draw = function()
		--draw line
		DrawLine(lineStart,mid,lineFinish,mid,lSize,back)
		--draw slider
		DrawLine(sliderX,y,sliderX,sliderY,lSize2,font)
		--draw number
		DrawText(defaultStr,tSize,textStart,y,font)
	end
	--button init
	local mouseBind = AIBind.lmb(function()
			local clickPos = GetCursorPos()
			--check clicked inside move area
			if clickPos.x >= lineStart - lSize and clickPos.x <= lineFinish + lSize
			and clickPos.y >= y and clickPos.y <= sliderY
			then
				--move number
				default = math.floor(min + (clickPos.x - lineStart)*(max  - min)/(lineFinish - lineStart) + 0.5) 
				--filter max min
				default = math.min(math.max(default,min),max)
				sliderX = x + tSize/2 + (lineFinish - lineStart )/(max  - min) * (default - min)
				defaultStr = tostring(default)
				--send callback
				callback(default)
				--move number bind
				local mouseMoveBind = AIBind.mouseMove(function()
						local clickPos = GetCursorPos()
						--move number
						default = math.floor(min + (clickPos.x - lineStart)*(max  - min)/(lineFinish - lineStart) + 0.5) 
						--filter max min
						default = math.min(math.max(default,min),max)
						sliderX = x + tSize/2 + (tSize * 5)/(max  - min) * (default - min)
						defaultStr = tostring(default)
						--send callback
						callback(default)
					end)
				--after move dropped
				AIBind.lmb(nil,function(handle) 
						--stop movement
						AIBind.remove(mouseMoveBind)
						--self remove
						AIBind.remove(handle)
					end)
			end
		end)
	--retrieve pos
	self.pos = function() return x,y end
	--remove init
	self.unbind = function()
		AIBind.remove(mouseBind)
	end
	--move to processor 
	self.init()
	local key = #data + 1
	data[key] = self
	return key
end

AIGui.bar = function(x,y,startValue,endValue)
	local self = {height = tSize}
	--save size
	local default,text,mid,barStart,barPos,barFinish,textStart = startValue,nil,nil,nil,nil,nil,nil
	--init 
	self.init = function(reX,reY,reStartValue,reEndValue)
		barPos = (barPos or x + tSize/2) + ((reX or x) - x)
		x,y,startValue,endValue = reX or x,reY or y,reStartValue or startValue,reEndValue or endValue
		text = tostring(math.floor(default / (endValue - startValue) * 100+0.5)).."%"
		mid = y + tSize/2
		barStart = x + tSize/2
		barFinish = barStart + tSize * 5
		textStart = barFinish + tSize/2
		self.width = tSize * 6 + GetTextArea("100%",tSize).x
	end
	--draw init
	self.draw = function()		
		--draw line
		DrawLine(barStart,mid,barFinish,mid,tSize,back)
		--draw bar
		DrawLine(barStart,mid,barPos,mid,tSize,font)
		--draw number
		DrawText(text,tSize,textStart,y,font)
	end
	--retrieve pos
	self.pos = function() return x,y end
	--move to processor 
	self.init()
	local key = #data + 1
	data[key] = self
	return key,function(default)
			barPos = x + tSize/2 + (tSize * 5)/(endValue - startValue) * (default - startValue)
			text = tostring(math.floor(default / (endValue - startValue) * 100+0.5)).."%"
		end
end

AIGui.line = function(x,y,INhandles)
	local self = {}
	--save size/handles
	local handles = {}
	--init 
	self.init = function(reX,reY,INhandles)
		x,y = reX or x,reY or y
		if INhandles ~= nil then
			--remove previous handles
			self.unbind()
			--get new handles
			self.height,self.width = 0,0
			for i = 1,#INhandles,1 do
				--copying object to parent location
				handles[i] = data[INhandles[i]]
				--owning object
				data[INhandles[i]] = nil
				--moving object to its parent position
				handles[i].init(x + self.width,y) 
				--plusing width
				self.width = self.width + handles[i].width + lSize2
				--find maximum height element
				self.height = math.max(self.height,handles[i].height)
			end
			--fix
			self.width = self.width - lSize2
		end
		--move them together
		local width = 0
		for i = 1,#handles,1 do 
			handles[i].init(x + width,y)
			--move next object bellow this object
			width = width + handles[i].width + lSize2
		end
	end
	--draw init
	self.draw = function()
		for i=1,#handles,1 do handles[i].draw() end
	end
	--retrieve pos
	self.pos = function() return x,y end
	--remove 
	self.unbind = function() 
		for i=1,#handles,1 do if handles[i].unbind ~= nil then handles[i].unbind() end end
	end
	--move to processor
	self.init(x,y,INhandles)
	local key = #data + 1
	data[key] = self
	return key
end

AIGui.list  = function(x,y,INhandles)
	local self = {}
	--save size/handles
	local handles = {}
	--init
	self.init = function(reX,reY,INhandles)
		x,y = reX or x,reY or y
		if INhandles ~= nil then
			--remove previous handles
			self.unbind()
			--get new handles
			self.height,self.width = 0,0
			for i = 1,#INhandles,1 do
				--copying object to parent location
				handles[i] = data[INhandles[i]]
				--owning object
				data[INhandles[i]] = nil
				--moving object to its parent position
				handles[i].init(x,y + self.height) 
				--plusing height
				self.height = self.height + handles[i].height + lSize2
				--find maximum width element
				self.width = math.max(self.width,handles[i].width)
			end
			--fix 
			self.height = self.height - lSize2
		end
		--move them together
		local height = 0
		for i = 1,#handles,1 do 
			handles[i].init(x,y + height)
			--move next object bellow this object
			height = height + handles[i].height + lSize2
		end
	end
	--draw init
	self.draw = function()
		for i=1,#handles,1 do handles[i].draw() end
	end
	--retrieve pos
	self.pos = function() return x,y end
	--remove 
	self.unbind = function() 
		for i=1,#handles,1 do if handles[i].unbind ~= nil then handles[i].unbind() end end
	end
	--move to processor 
	self.init(x,y,INhandles)
	local key = #data + 1
	data[key] = self
	return key
end

AIGui.anchor = function(x,y,INhandle)
	local self = {}
	--save size
	local lineX,lineY = nil,nil
	local handle = {}
	--init
	self.init = function(reX,reY,INhandle)
		x,y = reX or x,reY or y
		if INhandle ~= nil then
			--remove previous handle
			if handle.unbind ~= nil then handle.unbind() end
			--copying object to parent location
			handle = data[INhandle]
			--owning object
			data[INhandle] = nil
			--set size
			self.height,self.width = handle.height,handle.width + lSize3
		end
		--save size
		lineX,lineY = x + lSize,y + handle.height 
		--move object to parent location
		handle.init(x + lSize3,y)
	end
	--draw init
	self.draw = function()
		--draw line
		DrawLine(lineX,y,lineX,lineY,lSize2,font)
		--draw object
		handle.draw()
	end
	--move button init
	local mouseBind = AIBind.lmb(function()
			local clickPos = GetCursorPos()
			--check clicked inside move area
			if clickPos.x >= x and clickPos.x <= x + lSize2
			and clickPos.y >= y and clickPos.y <= lineY
			then
				--calc anchor
				local anchor = clickPos.y - y 
				--move
				local mouseMoveBind = AIBind.mouseMove(function() 
						local toPos = GetCursorPos()
						self.init(toPos.x,toPos.y - anchor)
					end) 
				--after anchor droped
				AIBind.lmb(nil,function(handle)
						--stop movement
						AIBind.remove(mouseMoveBind)
						--self remove
						AIBind.remove(handle)
					end)
			end
		end)
	--retrieve pos
	self.pos = function() return x,y end
	--remove
	self.unbind = function()
		if handle.unbind ~= nil then handle.unbind() end
		AIBind.remove(mouseBind)
	end
	--move to processor 
	self.init(x,y,INhandle)
	local key = #data + 1
	data[key] = self
	return key
end

AIGui.question = function(x,y,name,callback)
	local handle = AIGui.text(0,0,name)
	local yes = AIGui.button(0,0,"yes",function() AIGui.remove(handle) callback(true) end)
	local no = AIGui.button(0,0,"no",function() AIGui.remove(handle) callback(false) end)
	handle = AIGui.list(x,y,{handle,AIGui.line(0,0,{yes,no})})
	return handle
end

AIGui.init = function(handle,...)
	data[handle].init(...)
end

AIGui.pos = function(handle)
	return data[handle].pos()
end

AIGui.remove = function(handle)
	if data[handle].unbind ~= nil then data[handle].unbind() end
	data[handle] = nil
end

AIGui.reset = function()
	for key, value in pairs(data) do 
		if value.unbind ~= nil then value.unbind() end
		data[key] = nil
	end
end

AIGui.save = function(line,variable)
	--open file
	local file = io.open(SCRIPT_PATH..FILE_NAME,"r")
	local str = file:read("*all")
	io.close(file)
	--iterate through file searching for string
	local newline = {0,str:find("\n"),1}		
	while newline[2] ~= nil and newline[3] ~= line do newline = {newline[2],str:find("\n",newline[2] + 1),newline[3] + 1} end
	--save to existing string
	if newline[2] ~= nil then str = str:sub(0,newline[1])..variable.."\n"..str:sub(newline[2] + 1)
	--save to last string
	elseif newline[3] == line then str = str:sub(0,newline[1])..variable
	--save to unexisting string
	else str = str..string.rep("\n",line-newline[3])..variable end
	--create new temporary file
	file = io.open(SCRIPT_PATH.."AIGui.save","w")
	--write to this file
	file:write(str)
	--close
	file:flush()
	io.close(file)
	--remove previous file 
	os.remove(SCRIPT_PATH..FILE_NAME)
	--rename temporary file
	os.rename(SCRIPT_PATH.."AIGui.save",SCRIPT_PATH..FILE_NAME)
end

--local map = {x = 0.7085 + WINDOW_W/WINDOW_H * 0.1, y = 0.79}

AIGui.test = function(callback)
	local text = AIGui.text(0,0,"AIGui.test()")
	local progressState = 0
	local progress,setProgress = AIGui.bar(0,0,0,2)
	progress = AIGui.line(0,0,{AIGui.text(0,0,"AIGui.bar() check your progress"),progress})
	local tickState = false
	local tick = AIGui.line(0,0,{})
	AIGui.init(tick,nil,nil,{AIGui.text(0,0,"AIGui.tick() please check this box"),AIGui.tick(0,0,false,function(state) 
			if state == true then progressState = progressState + 1
			else progressState = progressState - 1 end
			tickState = state 
			setProgress(progressState)
		end)})
	local numberState = 0
	local number = AIGui.line(0,0,{})
	AIGui.init(number,nil,nil,{AIGui.text(0,0,"AIGui.number() please enter 25"),AIGui.slider(0,0,0,-20,40,function(number) 
			if numberState ~= 25 and number == 25 then progressState = progressState + 1
			elseif number ~= 25 and numberState == 25 then progressState = progressState - 1 end
			numberState = number 
			setProgress(progressState)
		end)})
	local button = AIGui.button(0,0,"",function()
			AIGui.reset()
			if numberState ~= 25 then callback("Slider error")
			elseif tickState ~= true then callback("Tick error")
			elseif #data ~= 0 then callback("Overflow error")
			else callback("OK") end 
		end)
	AIGui.init(button,nil,nil,"Press to continue")
	AIGui.anchor(WINDOW_W/2,WINDOW_H/2,AIGui.list(0,0,{text,tick,number,progress,button}))
end

--init processing
AddLoadCallback(function()
		tSize = math.max(WINDOW_H,1024)/40
		--save line size
		lSize = math.max(WINDOW_H,1024)/225
		--save double size line
		lSize2 = lSize * 2
		--save trible size line
		lSize3 = lSize * 3
		--draw processor
		AddDrawCallback(function()
				--check requests
				for key, value in pairs(data) do value.draw() end
			end)
	end)

	
--------- AIDraw Part -----------


	
AIDraw = {}
local dataLite = {}

AIDraw.circle = function(unit,range,ARGB)
	ARGB = ARGB or 0xAA00FF00
	local key = #dataLite + 1
	dataLite[key] = function()
		DrawCircle(unit.x,unit.y,unit.z,range,ARGB)
	end
	return key
end

AIDraw.arrow = function(pos1,pos2,width)
	local key = #dataLite + 1
	local color = RGBA(255,255,255,0)
	dataLite[key] = function()
		DrawArrow(D3DXVECTOR3(pos1.x,pos1.y,pos1.z),D3DXVECTOR3(pos2.x - pos1.x,pos1.y,pos2.z - pos1.z),math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x)+(pos1.z-pos2.z)*(pos1.z-pos2.z)),width,10000000000000000000000,color)
	end
	return key
end

AIDraw.remove = function(handle)
	dataLite[handle] = nil
end

AIDraw.reset = function()
	for key, value in pairs(dataLite) do 
		dataLite[key] = nil
	end
end

--draw processor
AddDrawCallback(function()
		--check requests
		for key, value in pairs(dataLite) do value() end
	end)
