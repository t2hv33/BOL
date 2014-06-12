wardItems = {3340, 3361, 3362, 2045, 2049, 3154, 3160, 2044, 2043}
function ready(spell)
	if spell == "Q" and myHero:CanUseSpell(_Q) == READY then
		return true
	elseif spell == "W" and myHero:CanUseSpell(_W) == READY then
		return true
	elseif spell == "E" and myHero:CanUseSpell(_E) == READY then
		return true
	elseif spell == "R" and myHero:CanUseSpell(_R) == READY then
		return true
	else 
		return false
	end
end


function name(spell)
	if spell == "Q" then
		return myHero:GetSpellData(_Q).name
	elseif spell == "W" then
		return myHero:GetSpellData(_W).name
	elseif spell == "E" then
		return myHero:GetSpellData(_E).name
	elseif spell == "R" then
		return myHero:GetSpellData(_R).name
	else 
		return false
	end
end

function cast(spell,target)
	if spell == "Q" then
		CastSpell(_Q,target)
	elseif spell == "W" then
		CastSpell(_W,target)
	elseif spell == "E" then
		CastSpell(_E,target) 
	elseif spell == "R" then
		CastSpell(_R,target)
	end
end

function cast2(spell,x,z)
	if spell == "Q" then
		CastSpell(_Q,x,z)
	elseif spell == "W" then
		CastSpell(_W,x,z)
	elseif spell == "E" then
		CastSpell(_E,x,z) 
	elseif spell == "R" then
		CastSpell(_R,x,z)
	end
end


function KSSpell(spell,range) 
	local ready = ready(spell)
		
	for i = 1, heroManager.iCount do
	    local target = heroManager:GetHero(i)
	    if target ~= nil and target.team ~= player.team and target.visible == true and target.dead == false and GetDistanceBetween(myHero,target) <= range then
			local damage = getDmg(spell,myHero,target)
			if damage > target.health and ready then 
				cast(spell)
			end
	    end
	end
end


function haveWard()
	for _, item in pairs(wardItems) do
		slot = GetInventorySlotItem(item)
		if slot ~= nil and CanUseSpell(slot) == READY then
			return true
		end
	end
	return false
end

function isWard(object)
    return object and object.valid and (string.find(object.name, "Ward") ~= nil or string.find(object.name, "Wriggle") ~= nil)
end





	
-- From ImLib
class 'ColorARGB' -- {

    function ColorARGB:__init(red, green, blue, alpha)
        self._R = red or 255
        self._G = green or 255
        self._B = blue or 255
        self._A = alpha or 255
    end

    function ColorARGB.FromArgb(red, green, blue, alpha)
        return ColorARGB(red,green,blue, alpha)
    end

    function ColorARGB:ToTable()
        return {self._A, self._R, self._G, self._B}
    end 

    function ColorARGB.FromTable(table)
        return ARGB(table[1], table[2], table[3], table[4])
    end 

    function ColorARGB:A(number)
        self._A = number or 255
        return self
    end 

    function ColorARGB:R(number)
        self._R = number or 255
        return self
    end

    function ColorARGB:B(number)
        self._B = number or 255
        return self
    end

    function ColorARGB:G(number)
        self._G = number or 255
        return self
    end

    function ColorARGB:ToARGB()
        return ARGB(self._A, self._R, self._G, self._B)
    end

    ColorARGB.AliceBlue = ColorARGB(240, 248, 255, 255)
    ColorARGB.AntiqueWhite = ColorARGB(250, 235, 215, 255)
    ColorARGB.Aqua = ColorARGB(0, 255, 255, 255)
    ColorARGB.AquaMarine = ColorARGB(127, 255, 212, 255)
    ColorARGB.Azure = ColorARGB(240, 255, 255, 255)
    ColorARGB.Beige = ColorARGB(245, 245, 196, 255)
    ColorARGB.Bisque = ColorARGB(255, 228, 196, 255)
    ColorARGB.Black = ColorARGB(0, 0, 0, 255)
    ColorARGB.BlancheDalmond = ColorARGB(255, 235, 205, 255)
    ColorARGB.Blue = ColorARGB(0, 0, 255, 255)
    ColorARGB.BlueViolet = ColorARGB(138, 43, 226, 255)
    ColorARGB.Brown = ColorARGB(165, 42, 42, 255)
    ColorARGB.BurlyWood = ColorARGB(222, 184, 135, 255)
    ColorARGB.CadetBlue = ColorARGB(92, 158, 160, 255)
    ColorARGB.ChartReuse = ColorARGB(127, 255, 0, 255)
    ColorARGB.Chocolate = ColorARGB(210, 105, 30, 255)
    ColorARGB.Coral = ColorARGB(255, 127, 80, 255)
    ColorARGB.CornFlowerBlue = ColorARGB(100, 149, 237, 255)
    ColorARGB.CornSilk = ColorARGB(255, 248, 220, 255)
    ColorARGB.Crimson = ColorARGB(220, 20, 60, 255)
    ColorARGB.Cyan = ColorARGB(0, 255, 255, 255)
    ColorARGB.DarkBlue = ColorARGB(0, 0, 139, 255)
    ColorARGB.DarkCyan = ColorARGB(0, 139, 139, 255)
    ColorARGB.DarkGoldenRod = ColorARGB(184, 134, 11, 255)
    ColorARGB.DarkGray = ColorARGB(169, 169, 169, 255)
    ColorARGB.DarkGreen = ColorARGB(0, 100, 0, 255)
    ColorARGB.DarkKhaki = ColorARGB(189, 183, 107, 255)
    ColorARGB.DarkMagenta = ColorARGB(139, 0, 139, 255)
    ColorARGB.DarkOliveGreen = ColorARGB(85, 107, 47, 255)
    ColorARGB.DarkOrange = ColorARGB(255, 140, 0, 255)
    ColorARGB.DarkOrchid = ColorARGB(153, 50, 204, 255)
    ColorARGB.DarkRed = ColorARGB(139, 0, 0, 255)
    ColorARGB.darkSalmon = ColorARGB(233, 150, 122, 255)
    ColorARGB.DarkSeaGreen = ColorARGB(143, 188, 143, 255)
    ColorARGB.DarkSlateBlue = ColorARGB(72, 61, 139, 255)
    ColorARGB.DarkSlateGray = ColorARGB(47, 79, 79, 255)
    ColorARGB.DarkTurquoise = ColorARGB(0, 206, 209, 255)
    ColorARGB.DarkViolet = ColorARGB(148, 0, 211, 255)
    ColorARGB.DeepPink = ColorARGB(255, 20, 147, 255)
    ColorARGB.DeepSkyBlue = ColorARGB(0, 191, 255, 255)
    ColorARGB.DimGray = ColorARGB(105, 105, 105, 255)
    ColorARGB.DodgerBlue = ColorARGB(30, 144, 255, 255)
    ColorARGB.FireBrick = ColorARGB(178, 34, 34, 255)
    ColorARGB.FloralWhite = ColorARGB(255, 250, 240, 255)
    ColorARGB.ForestGreen  = ColorARGB(34, 139, 34, 255)
    ColorARGB.Fuchsia = ColorARGB(255, 0, 255, 255)
    ColorARGB.GainsBoro = ColorARGB(220, 220, 220, 255)
    ColorARGB.GhostWhite = ColorARGB(255, 250, 240, 255)
    ColorARGB.Gold = ColorARGB(255, 215, 0, 255)
    ColorARGB.GoldenRod = ColorARGB(218, 165, 32, 255)
    ColorARGB.Gray = ColorARGB(128, 128, 128, 255)
    ColorARGB.Green = ColorARGB(0, 255, 0, 255)
    ColorARGB.GreenYellow = ColorARGB(173, 255, 47, 255)
    ColorARGB.HoneyDew = ColorARGB(240, 255, 240, 255)
    ColorARGB.HotPink = ColorARGB(255, 105, 180, 255)
    ColorARGB.IndianRed = ColorARGB(205, 92, 92, 255)
    ColorARGB.Indigo = ColorARGB(75, 0, 130, 255)
    ColorARGB.Ivory  = ColorARGB(255, 255, 240, 255)
    ColorARGB.Khaki = ColorARGB(240, 230, 140, 255)
    ColorARGB.Lavender = ColorARGB(230, 230, 250, 255)
    ColorARGB.LavenderBlush = ColorARGB(255, 240, 245)
    ColorARGB.LawnGreen = ColorARGB(124, 252, 0, 255)
    ColorARGB.LemonChiffon = ColorARGB(255, 250, 205, 255)
    ColorARGB.LightBlue = ColorARGB(173, 216, 230, 255)
    ColorARGB.LightCoral = ColorARGB(240, 128, 128, 255)
    ColorARGB.LightCyan = ColorARGB(240, 128, 128, 255)
    ColorARGB.LightGoldenRodYellow = ColorARGB(250, 250, 210, 255)
    ColorARGB.LightGray = ColorARGB(211, 211, 211, 255)
    ColorARGB.LightGreen = ColorARGB(144, 238, 144, 255)
    ColorARGB.LightPink = ColorARGB(255, 182, 193, 255)
    ColorARGB.LightSalmon = ColorARGB(255, 160, 122, 255)
    ColorARGB.LightSeaGreen = ColorARGB(32, 178, 170, 255)
    ColorARGB.LightSkyBlue = ColorARGB(135, 206, 250, 255)
    ColorARGB.LightSlateGray = ColorARGB(119, 136, 153, 255)
    ColorARGB.LightSteelBlue = ColorARGB(176, 196, 222, 255)
    ColorARGB.LightYellow = ColorARGB(255, 255, 224, 255)
    ColorARGB.Lime = ColorARGB(0, 255, 0, 255)
    ColorARGB.LimeGreen = ColorARGB(50, 205, 50, 255)
    ColorARGB.Linen = ColorARGB(250, 240, 230, 255)
    ColorARGB.Magenta = ColorARGB(255, 0, 255, 255)
    ColorARGB.Maroon = ColorARGB(128, 0, 0, 255)
    ColorARGB.MediumAquaMarine  = ColorARGB(102, 205, 170, 255)
    ColorARGB.MediumBlue = ColorARGB(0, 0, 205, 255)
    ColorARGB.MediumOrchid = ColorARGB(186, 85, 211, 255)
    ColorARGB.MediumPurple = ColorARGB(147, 112, 219, 255)
    ColorARGB.MediumSeaGreen = ColorARGB(60, 179, 113, 255)
    ColorARGB.MediumSlateBlue = ColorARGB(123, 104, 238, 255)
    ColorARGB.MediumSpringGreen = ColorARGB( 0, 250, 154, 255)
    ColorARGB.MediumTurquoise = ColorARGB(72, 209, 204, 255)
    ColorARGB.MediumVioletred = ColorARGB(199, 21, 133, 255)
    ColorARGB.Midnightblue = ColorARGB(25, 25, 112, 255)
    ColorARGB.MintCream = ColorARGB(245, 255, 250, 255)
    ColorARGB.MistyRose = ColorARGB(255, 228, 225, 255)
    ColorARGB.Red = ColorARGB(255, 0, 0, 255)
    ColorARGB.Yellow = ColorARGB(255, 255, 0, 255)
    ColorARGB.Green = ColorARGB(0, 255, 0, 255)
    ColorARGB.Fuchsia = ColorARGB(255, 0, 255, 255)
    ColorARGB.White = ColorARGB(255, 255, 255, 255)
-- }
--Notification class
class 'Message' -- {

    Message.instance = ""

    function Message:__init()
        self.notifys = {} 

        AddDrawCallback(function(obj) self:OnDraw() end)
    end

    function Message.Instance()
        if Message.instance == "" then Message.instance = Message() end return Message.instance 
    end

    function Message.AddMassage(text, color, target)
        return Message.Instance():PAddMassage(text, color, target)
    end

    function Message:PAddMassage(text, color, target)
        local x = 0
        local y = 200 
        local tempName = "Screen" 
        local tempcolor = color or ColorARGB.Red

        if target then  
            tempName = target.networkID
        end

        self.notifys[tempName] = { text = text, color = tempcolor, duration = GetGameTimer() + 2, object = target}
    end

    function Message:OnDraw()
        for i, notify in pairs(self.notifys) do
            if notify.duration < GetGameTimer() then notify = nil 
            else
                notify.color.A = math.floor((255/2)*(notify.duration - GetGameTimer()))

                if i == "Screen" then  
                    local x = 0
                    local y = 200
                    local gameSettings = GetGameSettings()
                    if gameSettings and gameSettings.General then 
                        if gameSettings.General.Width then x = gameSettings.General.Width/2 end 
                        if gameSettings.General.Height then y = gameSettings.General.Height/4 - 100 end
                    end  
                    --PrintChat(tostring(notify.color))
                    local p = GetTextArea(notify.text, 40).x 
                    Message.DrawTextWithBorder(notify.text, 40, x - p/2, y, notify.color:ToARGB(), ARGB(notify.color.A, 0, 0, 0))
                else    
                    local pos = WorldToScreen(D3DXVECTOR3(notify.object.x, notify.object.y, notify.object.z))
                    local x = pos.x
                    local y = pos.y - 25
                    local p = GetTextArea(notify.text, 40).x 

                     Message.DrawTextWithBorder(notify.text, 30, x- p/2, y, notify.color:ToARGB(), ARGB(notify.color.A, 0, 0, 0))
                end
            end
        end
    end 

    function Message.DrawTextWithBorder(textToDraw, textSize, x, y, textColor, backgroundColor)
        DrawText(textToDraw, textSize, x + 1, y, backgroundColor)
        DrawText(textToDraw, textSize, x - 1, y, backgroundColor)
        DrawText(textToDraw, textSize, x, y - 1, backgroundColor)
        DrawText(textToDraw, textSize, x, y + 1, backgroundColor)
        DrawText(textToDraw, textSize, x , y, textColor)
    end
-- }

function DspMsg(string)
	Message.AddMassage(string, ColorARGB(255, 0, 0, 255))
end
		
