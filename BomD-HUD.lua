-- ##############---------------------------ALL in ONE Scripts xkjtx---------------------############## --
-- #                         Credit for original scripts 100% to the original authors!!               # --
-- #                                  Most credit goes to Sida for making XT002                       # --
-- #################################################################################################### --



--[[LIST OF SCRIPTS IN THIS SCRIPT:

    Minion Marker
    Tower Range
    Low Awareness
    Player/Enemy Range
    Auto Level(Need to look in script to change sequence)
    Buy Me Items(xkjtx)
    Chat Spamm(YOLO,GLHF,GG)
    Smooth Move With Right Click
    Exp Range
    Mini Map Timers(WORKS ON ALL MAPS)
    Where Is He?
    Spin To Win
    Where Did He Go?
    Anti Ward.
    Auto Potion <-- Off by default
    Auto Ignite <-- Off by default
    Console <-- Always turned on (Hot-key = '/' =(key-191))
    AwesomeScript <-- Off by default
    
    ]]

-- ############################################# CONSOLE ##################################################
local function DrawRectangle(x, y, width, height, color)
    DrawLine(x, y + (height/2), x + width, y + (height/2), height, color)
end

-- Console Configuration
local console = {
    classic = false,
    bgcolor = ARGB( 170, 0, 0, 0 ),
    padding = 10,
    textSize = 16,
    linePadding = 2,
    brand = "Bot of Legends - S4 4.4",
    scrolling = {
        width    = 12
    },
    colors = {
        script = { R =     0, G = 255, B = 0 },
        console = { R = 255, G = 255, B = 0 },
        command = { R = 150, G = 255, B = 0 },
        prompt = { R =     0, G = 255, B = 0 },
        default = { R =     0, G = 255, B = 0 }
    },
    keys = {
        191
    },
    selection = {
        content = "",
        startLine = 1,
        endLine = 1,
        startPosition = 1,
        endPosition = 1
    }
}

-- Notifications Configuration
local notifications = {
    bgcolor = ARGB( 80, 0, 0, 0 ),
    max = 1,
    length = 5000,
    fadeTime = 500,
    slideTime = 200,
    perma = 0
}

-- Binds
local binds = {}

-- Command line structure
local command = {
    bullet = ">",
    history = {},
    offset = 1,
    buffer = "",
    methods = {
        -- DEFINED at end of script to allow access to all methods
    }
}

-- Spell mapping (for cast/level command, etc)
local spells = {
    q = _Q,
    w = _W,
    e = _E,
    r = _R,
    recall = RECALL,
    summoner1 = SUMMONER_1,
    summoner2 = SUMMONER_2,
    flash = function()
        if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then return SUMMONER_1
        elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then return SUMMONER_2
        else return nil end
    end
}

-- Cursor structure
local cursor = {
    blinkSpeed = 1200,
    offset = 0,
}

-- Is the console active or not
local active = false

-- The stack of console messages
local stack    = {}
local offset = 1

-- Last notification time
local closeTick = 0

-- Unorganized variables
local stayAtBottom = true

-- Calculated max console messages to display on a single screen
local maxMessages = math.floor(((WINDOW_H/2) - 2 * console.padding - 2 * console.textSize) / (console.textSize + console.linePadding)) + 1

-- Code ------------------------------------------------
local function LoadBinds()
    pcall(function() lines = io.lines(SCRIPT_PATH .. "binds.cfg") end)
    if lines ~= nil then
        for line in lines do
            local parts = string.split(line, " ", 3)
            binds[parts[2]] = parts[3]
        end
    end
end

local function SaveBinds()
    local file = assert(io.open(SCRIPT_PATH .. "binds.cfg", "w+"))
    if file then
        for key, cmd in pairs(binds) do
            file:write("bind " .. key .. " " .. cmd .. "\n")
        end
        file:close()
    end
end

local function IsConsoleKey(key)
    for i, k in ipairs(console.keys) do
        if k == key then
            return true
        end
    end

    return false
end

local function GetTextColor(type, opacity)
    local c = console.colors.default

    if console.colors[type] then
        c = console.colors[type]
    end

    return ARGB((opacity or 1) * 255, c.R, c.G, c.B)
end

function SplitMessage(messageToSplit, length)
    if GetTextWidth(messageToSplit) > length then
        local message1, message2 = SplitMessage(messageToSplit:sub(1, math.floor(#messageToSplit / 2)), length)
        return message1, message2 .. messageToSplit:sub(math.floor(#messageToSplit / 2))
    else
        return messageToSplit, ""
    end
end

function AddMessage(msg, type, insertionOffset)
    msg = msg:gsub("\t", "    "):gsub("<eof>","'eof'"):gsub('<[^>]+>', '')

    local lineNumber = 1
    local length = WINDOW_W - 2 * console.padding - console.scrolling.width - GetTextWidth("[" .. TimerText(GetInGameTimer()) .. "] ")
    for lineNo, line in ipairs(msg:split("\n")) do
        if GetTextWidth(msg) >= length then
            local currentString = ""
            for word in string.gmatch(line, "[^%s]+") do
                local newString = currentString .. (currentString ~= "" and (" " .. word) or word)
                if GetTextWidth(newString) >= length then
                    AddMessageToStack(currentString, type, insertionOffset and (insertionOffset - 1 + lineNumber) or insertionOffset, lineNumber == 1 and GetInGameTimer() or nil)
                    lineNumber = lineNumber + 1

                    currentString = word
                    length = WINDOW_W - 2 * console.padding - console.scrolling.width
                else
                    currentString = newString
                end
            end
            if currentString ~= "" then
                AddMessageToStack(currentString, type, insertionOffset and (insertionOffset - 1 + lineNumber) or insertionOffset, lineNumber == 1 and GetInGameTimer() or nil)
                lineNumber = lineNumber + 1
            end
        else
            AddMessageToStack(line, type, insertionOffset and (insertionOffset - 1 + lineNumber) or insertionOffset, lineNumber == 1 and GetInGameTimer() or nil)
            lineNumber = lineNumber + 1
        end
    end
end

function AddMessageToStack(msg, type, insertionOffset, gameTime)
    if insertionOffset then
        table.insert(stack, insertionOffset, {
            msg = tostring(msg),
            ticks = GetTickCount(),
            gameTime= gameTime,
            type = type
        })
    else
        table.insert(stack, {
            msg = tostring(msg),
            ticks = GetTickCount(),
            gameTime = gameTime,
            type = type
        })
    end

    if #stack - offset >= maxMessages and stayAtBottom then
        offset = offset + 1
    end

    if notifications.perma > 0 then
        for i = 1, notifications.perma do
            if #stack - i >= 1 then
                local item = stack[#stack - i]

                if item.ticks < GetTickCount() - notifications.length + notifications.fadeTime then
                    item.ticks = GetTickCount() - notifications.length + notifications.fadeTime
                    closeTick = GetTickCount() - notifications.length + notifications.fadeTime - 1
                end
            end
        end
    end
end

local function LazyProcess(cmd)
    local preExStack = #stack
    cmd = cmd:trim()
    if cmd:sub(1,1) == "=" then
        local successful, result = ExecuteLUA('return ' .. cmd:sub(2,#cmd))
        if successful then AddMessage(type(result) ~= "userdata" and tostring(result) or "userdata", "command")
        else AddMessage("Lua Error: " .. result:gsub("%[string \"\"%]:1: ", ""), "console") end
    else
        local successful, result = ExecuteLUA(cmd)
        if not successful then
            if not console.classic then
                local successful, result = ExecuteLUA('return ' .. cmd)
                if successful then
                    table.remove(stack, preExStack)
                    AddMessage(cmd .. " = " .. tostring(result), "command", preExStack)
                else AddMessage("Lua Error: " .. result:gsub("%[string \"\"%]:1: ", ""), "console") end
            else AddMessage("Lua Error: " .. result:gsub("%[string \"\"%]:1: ", ""), "console") end
        end
    end
end

function ExecuteLUA(cmd)
    local func, err = load(cmd, "", "t", _ENV)
    if func then
        return pcall(func)
    else
        return false, err
    end
end

local function ProcessCommand(cmd)
    local parts = string.split(cmd, " ", 2)
    if command.methods[parts[1]] == nil then return end
    return command.methods[parts[1]](#parts == 2 and parts[2] or nil)
end

local function ExecuteCommand(cmd)
    if cmd ~= "" then
        AddMessage(cmd, "command")

        if string.len(cmd) == 0 then return end

        -- Display command in console, and add to history stack
        table.insert(command.history, cmd)

        -- Parse the command
        local process = ProcessCommand(cmd)

        -- If no command was found, we will attempt to execute the command as LUA code
        if not process then
            LazyProcess(cmd)
        end
    end
end

function GetTextWidth(text, textSize)
    return GetTextArea("_" .. text .. "_", textSize or console.textSize).x - 2 * GetTextArea("_", textSize or console.textSize).x
end

function Console__WriteConsole(msg)
    AddMessage(msg, "script")
end

function Console__OnLoad()
    AddMessage("Game started", "console")
    AddMessage("Champion: " .. myHero.charName, "console")
    LoadBinds()
end

function Console__OnDraw()
    local messageBoxHeight = 2 * console.padding + (maxMessages - 1) * (console.textSize + console.linePadding) + console.textSize
    local promptHeight         = 2 * console.padding + console.textSize
    local consoleHeight        = messageBoxHeight + promptHeight
    local scrollbarHeight    = math.ceil(messageBoxHeight / math.max(#stack / maxMessages, 1))

    if active == true then
        local showRatio = math.min((GetTickCount() - closeTick) / notifications.slideTime, 1)
        local slideOffset = (1 - showRatio) * consoleHeight

        -- Draw console background
        DrawRectangle(0, 0 - slideOffset, WINDOW_W, consoleHeight, ARGB(showRatio * 170, 0, 0, 0))
        DrawLine(0, messageBoxHeight - slideOffset, WINDOW_W, messageBoxHeight - slideOffset, 1, GetTextColor("prompt", showRatio * 0.16))
        DrawLine(0, consoleHeight - slideOffset, WINDOW_W, consoleHeight - slideOffset, 1, GetTextColor("prompt", showRatio * 0.58))

        -- Display stack of messages
        console.selection.content = ""
        if #stack > 0 then
            for i = offset, offset + maxMessages - 1 do
                if i > #stack then break end

                local message = stack[i]

                local selectionStartLine, selectionEndLine, selectionStartPosition, selectionEndPosition
                if console.selection.startLine < console.selection.endLine or (console.selection.startLine == console.selection.endLine and console.selection.startPosition < console.selection.endPosition) then
                    selectionStartLine = console.selection.startLine
                    selectionEndLine = console.selection.endLine
                    selectionStartPosition = console.selection.startPosition
                    selectionEndPosition = console.selection.endPosition
                else
                    selectionStartLine = console.selection.endLine
                    selectionEndLine = console.selection.startLine
                    selectionStartPosition = console.selection.endPosition
                    selectionEndPosition = console.selection.startPosition
                end

                local timePrefix = message.gameTime and ("[" .. TimerText(message.gameTime) .. "] ") or ""

                if i >= selectionStartLine and i <= selectionEndLine then
                    local rightOffset

                    local leftOffset = (i == selectionStartLine) and (GetTextArea("_" .. (timePrefix .. message.msg):sub(1, selectionStartPosition - 1) .. "_", console.textSize).x - 2 * GetTextArea("_", console.textSize).x) or 0

                    if i == selectionEndLine then
                        local selectedText = (timePrefix .. message.msg):sub(selectionStartLine == selectionEndLine and selectionStartPosition or 1, selectionEndPosition - 1)
                        rightOffset = GetTextWidth(selectedText)

                        console.selection.content = console.selection.content .. (console.selection.content ~= "" and "\r\n" or "") .. selectedText
                    else
                        local selectedText = (timePrefix .. message.msg):sub(selectionStartLine == i and selectionStartPosition or 1)
                        rightOffset = WINDOW_W - 2 * console.padding - leftOffset - (scrollbarHeight == messageBoxHeight and 0 or console.scrolling.width)

                        console.selection.content = console.selection.content .. (console.selection.content ~= "" and "\r\n" or "") .. selectedText
                    end

                    DrawRectangle(console.padding + leftOffset, console.padding + (i - offset) * (console.textSize + console.linePadding) - slideOffset - console.linePadding / 2, rightOffset, console.textSize + console.linePadding, 1157627903)
                end

                if message ~= nil then
                    DrawText(timePrefix .. message.msg, console.textSize, console.padding, console.padding + (i - offset) * (console.textSize + console.linePadding) - slideOffset, GetTextColor(message.type, showRatio))
                end
            end
        end

        -- Show what user is currently typing
        DrawText(command.bullet .. " " .. command.buffer, console.textSize, console.padding, messageBoxHeight + console.padding - slideOffset, GetTextColor("prompt", showRatio))
        if GetTickCount() % cursor.blinkSpeed > cursor.blinkSpeed / 2 then
            DrawText("_", console.textSize, console.padding + GetTextArea(command.bullet .. " " .. command.buffer:sub(1, cursor.offset) .. "_", console.textSize).x - GetTextArea("_", console.textSize).x, messageBoxHeight + console.padding - slideOffset, GetTextColor("prompt", showRatio))
        end

        DrawText(console.brand, console.textSize, WINDOW_W - GetTextArea(console.brand, console.textSize).x - console.padding, messageBoxHeight + console.padding - slideOffset, GetTextColor("prompt", showRatio * 0.58))

        if scrollbarHeight ~= messageBoxHeight then
            DrawRectangle(WINDOW_W - console.scrolling.width, 0 - slideOffset + (offset - 1) / (#stack - maxMessages) * (messageBoxHeight - scrollbarHeight), console.scrolling.width, scrollbarHeight, GetTextColor("prompt", showRatio * 0.4))
        end
    elseif #stack > 0 then
        local filteredStack = {}

        local notificationsFound = 0
        local currentOffset = #stack
        while notificationsFound ~= notifications.max and currentOffset ~= 0 do
            if (GetTickCount() - stack[currentOffset].ticks > notifications.length or stack[currentOffset].ticks < closeTick) and notificationsFound >= notifications.perma then break end

            if stack[currentOffset].gameTime then
                table.insert(filteredStack, stack[currentOffset])
                notificationsFound = notificationsFound + 1
                currentOffset = currentOffset - 1
            else
                table.insert(filteredStack, stack[currentOffset])
                currentOffset = currentOffset - 1
            end
        end

        if #filteredStack > 0 then
            local slideOffset = 0
            local notificationsFound1 = 0
            for i = 1, #filteredStack do
                slideOffset = slideOffset - (console.textSize + (i == #filteredStack and console.padding * 2 or console.linePadding)) * ((notificationsFound - notificationsFound1 <= notifications.perma) and 0 or math.max((GetTickCount() - filteredStack[#filteredStack - i + 1].ticks - notifications.length + notifications.fadeTime) / notifications.fadeTime, 0))
                if stack[currentOffset].gameTime then
                    notificationsFound1 = notificationsFound1 + 1
                end
            end

            DrawRectangle(0, 0, WINDOW_W, (console.textSize * #filteredStack) + (console.padding * 2) + (#filteredStack - 1) * console.linePadding + slideOffset, notifications.bgcolor)
            DrawLine(0, (console.textSize * #filteredStack) + (console.padding * 2) + slideOffset + (#filteredStack - 1) * console.linePadding, WINDOW_W, (console.textSize * #filteredStack) + (console.padding * 2) + slideOffset + (#filteredStack - 1) * console.linePadding, 1, GetTextColor("prompt", 0.27))

            local notificationsFound1 = 0
            for i = 1, #filteredStack do
                local item = filteredStack[#filteredStack + 1 - i]

                local timePrefix = item.gameTime and ("[" .. TimerText(item.gameTime) .. "] ") or ""

                DrawText(timePrefix .. item.msg, console.textSize, console.padding, console.padding + (i - 1) * (console.linePadding + console.textSize) + slideOffset, GetTextColor(item.type, 1 - ((notificationsFound - notificationsFound1 <= notifications.perma) and 0 or math.max((GetTickCount() - item.ticks - notifications.length + notifications.fadeTime) / notifications.fadeTime, 0))) )

                if stack[currentOffset].gameTime then
                    notificationsFound1 = notificationsFound1 + 1
                end
            end
        end
    end
end

function getLineCoordinates(referencePoint)
    local yValue = math.max(math.ceil((referencePoint.y - console.padding - console.textSize) / (console.textSize + console.linePadding)) + 1, 1) + offset - 1
    local xValue = referencePoint.x - console.padding

    if yValue > #stack then
        return #stack + 1, math.huge
    else
        local timePrefix = stack[yValue].gameTime and ("[" .. TimerText(stack[yValue].gameTime) .. "] ") or ""
        local stringValue = timePrefix .. stack[yValue].msg
        local stringWidth = 0
        local charNumber = 0
        for i = 1, #stringValue do
            newStringWidth = stringWidth + GetTextArea("_" .. stringValue:sub(i,i) .. "_", console.textSize).x - 2 * GetTextArea("_", console.textSize).x
            if newStringWidth > xValue then break end
            stringWidth = newStringWidth
            charNumber = i
        end

        return yValue, charNumber + 1
    end
end

function Console__OnMsg(msg, key)
    local messageBoxHeight = 2 * console.padding + (maxMessages - 1) * (console.textSize + console.linePadding) + console.textSize
    local promptHeight         = 2 * console.padding + console.textSize
    local consoleHeight        = messageBoxHeight + promptHeight
    local scrollbarHeight    = math.ceil(messageBoxHeight / math.max(#stack / maxMessages, 1))

    if active and msg == WM_RBUTTONUP then
        SetClipboardText(console.selection.content)
        console.selection = {
            content = "",
            startLine = 1,
            endLine = 1,
            startPosition = 1,
            endPosition = 1
        }
    elseif active and msg == WM_LBUTTONDOWN then
        if GetCursorPos().x >= WINDOW_W - console.scrolling.width then
            dragConsole = true
            dragStart = {x = GetCursorPos().x, y = GetCursorPos().y}
            startOffset = offset
        else
            local line, char = getLineCoordinates(GetCursorPos())

            if line then
                console.selection.startLine = line
                console.selection.endLine = line
                console.selection.startPosition = char
                console.selection.endPosition = char

                selecting = true
            end
        end
    elseif active and msg == WM_LBUTTONUP then
        if selecting then
            local line, char = getLineCoordinates(GetCursorPos())

            if line then
                console.selection.endLine = line
                console.selection.endPosition = char
            end
        end

        dragConsole = false
        selecting = false
    elseif active and msg == WM_MOUSEMOVE then
        if selecting then
            local line, char = getLineCoordinates(GetCursorPos())

            if line then
                console.selection.endLine = line
                console.selection.endPosition = char
            end
        end

        if dragConsole then
            if #stack > maxMessages then
                stayAtBottom = false

                offset = startOffset + math.round(((GetCursorPos().y - dragStart.y) * (#stack - maxMessages) / (messageBoxHeight - scrollbarHeight)) + 1)
                if offset < 1 then
                    offset = 1
                elseif offset >= #stack - maxMessages + 1 then
                    offset = #stack - maxMessages + 1
                    stayAtBottom = true
                end
            end
        end
    end

    if active then
        BlockMsg()
    end
    if active and msg == KEY_DOWN then
        if key == 13 then --enter
            ExecuteCommand(command.buffer)
            if #stack > maxMessages then
                offset = #stack - maxMessages + 1
            end
            command.buffer = ""
            cursor.offset = 0
            stayAtBottom = true
        elseif key == 8 then --backspace
            if cursor.offset > 0 then
                command.buffer = command.buffer:sub(1, cursor.offset - 1) .. command.buffer:sub(cursor.offset + 1)
                cursor.offset = cursor.offset - 1
            end
        elseif key == 46 then -- delete
            command.buffer = command.buffer:sub(1, cursor.offset) .. command.buffer:sub(cursor.offset + 2)
        elseif key == 33 then --pgup
            offset = math.max(offset - maxMessages, 1)
            stayAtBottom = false
        elseif key == 34 then --pgdn
            offset = math.max(math.min(offset + maxMessages, #stack - maxMessages + 1), 1)
            if offset == #stack - maxMessages + 1 then
                stayAtBottom = true
            end
        elseif key == 38 and #command.history > 0 then --up arrow
            if command.offset < #command.history then
                command.offset = command.offset + 1
            end
            command.buffer = command.history[command.offset]
            cursor.offset = #command.buffer
        elseif key == 40 and #command.history > 0 then --down arrow
            if command.offset > 1 then
                command.offset = command.offset - 1
            end
            command.buffer = command.history[command.offset]
            cursor.offset = #command.buffer
        elseif key == 37 then --left arrow
            cursor.offset = math.max(cursor.offset - 1, 0)
        elseif key == 39 then --right arrow
            cursor.offset = math.min(cursor.offset + 1, #command.buffer)
        elseif key == 35 then
            cursor.offset = #command.buffer
        elseif key == 36 then
            cursor.offset = 0
        elseif ToAscii(key) == string.char(3) then
            SetClipboardText(console.selection.content)
            console.selection = {
                content = "",
                startLine = 1,
                endLine = 1,
                startPosition = 1,
                endPosition = 1
            }
        elseif ToAscii(key) == string.char(22) then
            local textToAdd = GetClipboardText():gsub("\r", ""):gsub("\n", " ")
            command.buffer = command.buffer:sub(1, cursor.offset) .. textToAdd .. command.buffer:sub(cursor.offset + 1)
            cursor.offset = cursor.offset + #textToAdd
        elseif key == 9 then
            for k,v in pairs(_G) do
                if k:sub(1, #command.buffer) == command.buffer then
                    command.buffer = k
                    cursor.offset = #k
                    break
                end
            end
        else
            local asciiChar = ToAscii(key)
            if asciiChar ~= nil then
                command.buffer = command.buffer:sub(1, cursor.offset) .. asciiChar .. command.buffer:sub(cursor.offset + 1)
                cursor.offset = cursor.offset + 1
            end
        end
    end

    if msg == KEY_DOWN and IsConsoleKey(key) then
        active = not active
        command.buffer = ""
        closeTick = GetTickCount()
    end

    if msg == KEY_DOWN and binds[ToAscii(key)] then
        local parts = string.split(binds[ToAscii(key)], ";")
        for p, cmd in ipairs(parts) do
            ProcessCommand(cmd)
        end
    end
end

-- Console Commands ---------------------------------
command.methods = {
    clear = function()
        stack = {}
        offset = 1
    end,

    dump = function(query)
        local t = ""
        for i, v in ipairs(stack) do
            t = t .. "[" .. TimerText(v.gameTime) .. "] " .. v.msg .. "\n"
        end
        return WriteFile(t, SCRIPT_PATH .. (query~="" and query or "console_dump.log"))
    end,

    say = function(query)
        SendChat(query)
        return true
    end,

    say_all = function(query)
        SendChat("/all " .. query)
        return true
    end,

    buy = function(query)
        BuyItem(tonumber(query))
        return true
    end,

    cast = function(query)
        local s = type(spells[query]) == "function" and spells[query]() or spells[query]
        if s then
            local target = GetTarget()
            if target ~= nil then
                CastSpell(s, target)
            else
                CastSpell(s, mousePos.x, mousePos.z)
            end
        else
            AddMessage("Attempted to cast invalid spell: \"" .. query .. "\"", "console")
        end

        return true
    end,

    flash = function() return command.methods.cast("flash") end,
    recall = function() return command.methods.cast("recall") end,

    level = function(query)
        local s = type(spells[query]) == "function" and spells[query]() or spells[query]
        if s then
            LevelSpell(s)
        end

        return true
    end,

    bind = function(query)
        local parts = string.split(query, " ", 2)
        binds[parts[1]] = parts[2]
        SaveBinds()
        return true
    end,

    unbind = function(query)
        binds[query] = nil
        SaveBinds()
        return true
    end,

    unbindall = function()
        binds = {}
        SaveBinds()
        return true
    end,

    reload = function()
        LoadBinds()
        return true
    end
}

AddLoadCallback(Console__OnLoad)
AddDrawCallback(Console__OnDraw)
AddMsgCallback(Console__OnMsg)
_G.WriteConsole = Console__WriteConsole
_G.PrintChat = _G.WriteConsole
_G.Console__IsOpen = active


-- ############################################# AUTO IGNITE ##############################################
local iSlot = nil

function useIgniteOnLoad()
  if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then iSlot = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then iSlot = SUMMONER_2
      else iSlot = nil
  end
end



function useIgniteOnTick()

  if KCConfig.useIgnite then
    local iDmg = 0    
    if iSlot ~= nil and myHero:CanUseSpell(iSlot) == READY then
      for i = 1, heroManager.iCount, 1 do
        local target = heroManager:getHero(i)
        if ValidTarget(target) then
          iDmg = 50 + 20 * myHero.level
          if target ~= nil and target.team ~= myHero.team and not target.dead and target.visible and GetDistance(target) < 600 and target.health < iDmg then
                CastSpell(iSlot, target)
          end
          end
        end
      end
    end
  end 

-- ############################################# AUTO POTION ################################################

--[[
Auto Potions, in case you forget.
by ikita
    Improved by Manciuszz(based on PedobearIGER's IgniteCounterer).
]]

--[[  Config   ]]
    EnableSmiteCheck = true -- self explanatory. Enable only when Jungling for auto hp pots in the jungle else leave it disabled since you won't be jungling to late game lol.
    hpLimit = 0.40  --/ if myHero health is lower than the hpLimit then activate a HP potion automatically.
  --hpLimitElixir = 0.25  --/ if myHero health is lower than the hpLimit then activate a Red Elixir automatically.
    manaLimit = 0.40 --/ if myHero mana is lower than the manaLimit then activate a MP potion automatically.
    FountainRange = 1550 -- The Fountain(Spawn-Pool) Range.
    DELAY = 100   --OnTick delay.
    --[[  Globals  ]]
    local nextTick = 0

    if myHero == nil then myHero = GetMyHero() end

    --[[   Code   ]]
    function inFountain()--distance from myHero to fountain < range
        local function getFountainCoordinates()  -- Locate the coordinates of the myHero's spawn-pool.
            for i = 1, objManager.iCount, 1 do
                local object = objManager:GetObject(i)
                if object ~= nil and object.name:lower() == ("Turret_ChaosTurretShrine"):lower() and myHero.team == TEAM_RED then return object.x, object.y, object.z, FountainRange
                elseif object ~= nil and object.name:lower() == ("Turret_OrderTurretShrine"):lower() and myHero.team == TEAM_BLUE then return object.x, object.y, object.z, FountainRange
                end
            end
        end
        if X == nil or Y == nil or Z == nil or FountainRange == nil then --check if was able to get fountainCoordinates.
            if getFountainCoordinates() ~= nil then
                X, Y, Z, FountainRange = getFountainCoordinates()
            else
                PrintChat("Can't do this Sir!")
                return
            end
        end

        if math.sqrt((X - myHero.x) ^ 2 + (Z - myHero.z) ^ 2) < FountainRange then  -- the math shit, calculating if in spawn-pool.
            return true, X, Y, Z, FountainRange
        end
        return false, X, Y, Z, FountainRange
    end

    function Buffed(target,buffName)
        if target ~= nil and not target.dead and target.visible then
            for i = 1, target.buffCount, 1 do
                local buff = target:getBuff(i)
                if buff.valid then
                    if buff.name ~= nil and buff.name:lower() == buffName:lower()then
                        return true
                    end
                end
            end
        end
        return false
    end

    function PotionOnTick()
        if myHero.dead then return end

        if nextTick > GetTickCount() then return end
        nextTick = GetTickCount() + DELAY

        local tick = GetTickCount()
      -- I just want the manaLimit scale a little lower, so flask gets used faster.
        if myHero ~= nil and myHero.mana <= myHero.maxMana* (manaLimit*0.9) and not inFountain() and not Buffed(myHero, "Recall") and not Buffed(myHero, "SummonerTeleport") and not Buffed(myHero, "RecallImproved") then
            if Buffed(myHero,"FlaskOfCrystalWater") == false then
                for i=1, 6, 1 do
                    if myHero:getInventorySlot(_G["ITEM_"..i]) == 2004 then
                        CastSpell(_G["ITEM_"..i])
                    end
                end
            end
        end

        if myHero ~= nil and myHero.health <= myHero.maxHealth* (hpLimit*0.9) and not inFountain() and not Buffed(myHero, "Recall") and not Buffed(myHero, "SummonerTeleport") and not Buffed(myHero, "RecallImproved") then
            if Buffed(myHero,"RegenerationPotion") == false or Buffed(myHero,"SummonerDot") or Buffed(myHero,"grievouswound") or Buffed(myHero,"MordekaiserChildrenOfTheGrave") then
                for i=1, 6, 1 do
                    if myHero:getInventorySlot(_G["ITEM_"..i]) == 2003 then
                        CastSpell(_G["ITEM_"..i])
                    end
                end
            end
        end

        if myHero ~= nil and (myHero.health <= myHero.maxHealth* hpLimit or myHero.mana <= myHero.maxMana* manaLimit) and not inFountain() and not Buffed(myHero, "Recall") and not Buffed(myHero, "SummonerTeleport") and not Buffed(myHero, "RecallImproved") then
            if Buffed(myHero,"ItemCrystalFlask") == false or Buffed(myHero,"SummonerDot") or Buffed(myHero,"grievouswound") or Buffed(myHero,"MordekaiserChildrenOfTheGrave") then
                for i=1, 6, 1 do
                    if myHero:getInventorySlot(_G["ITEM_"..i]) == 2041 then
                        CastSpell(_G["ITEM_"..i])
                    end
                end
            end
        end

        if myHero ~= nil and (myHero.health <= myHero.maxHealth* hpLimit or myHero.mana <= myHero.maxMana* manaLimit) and not inFountain() and not Buffed(myHero, "Recall") and not Buffed(myHero, "SummonerTeleport") and not Buffed(myHero, "RecallImproved") then
            if Buffed(myHero,"ItemMiniRegenPotion") == false or Buffed(myHero,"SummonerDot") or Buffed(myHero,"grievouswound") or Buffed(myHero,"MordekaiserChildrenOfTheGrave") then
                for i=1, 6, 1 do
                    if myHero:getInventorySlot(_G["ITEM_"..i]) == 2009 then
                        CastSpell(_G["ITEM_"..i])
                    end
                end
            end
        end
    --[[
    if myHero ~= nil and myHero.health <= myHero.maxHealth* hpLimitElixir and not inFountain() and not Buffed(myHero, "Recall") and not Buffed(myHero, "SummonerTeleport") and not Buffed(myHero, "RecallImproved") then
            if Buffed(myHero,"PotionOfGiantStrengt") == false or Buffed(myHero,"SummonerDot") or Buffed(myHero,"grievouswound") or Buffed(myHero,"MordekaiserChildrenOfTheGrave") then
                for i=1, 6, 1 do
                    if myHero:getInventorySlot(_G["ITEM_"..i]) == 2037 then
                        CastSpell(_G["ITEM_"..i])
                    end
                end
            end
        end
    --]]
    end
    
  
    function SmiteCheck()
        if myHero:GetSpellData(SUMMONER_1).name:find("Smite") ~= nil then --check if the myHero has Smite(that means he's jungling(or trolling))
            --PrintChat("Playing as a Jungler!")
            hpLimit = 0.65
        elseif myHero:GetSpellData(SUMMONER_2).name:find("Smite") ~= nil then
            --PrintChat("Playing as a Jungler!")
            hpLimit = 0.65
        end
    end

    function PotionOnLoad()
    if EnableSmiteCheck then SmiteCheck() end
    end

-- ##########################################   AntiWard    ##############################################
local blackColor  = 4278190080
local purpleColor = 4294902015
local greenColor  = 4278255360
local aquaColor = ARGB(255,102, 205, 170)

local whiteColor = ARGB(255,255, 255, 255)
local grayColor = ARGB(255, 200, 200, 200)

function AntiWardOnLoad()
  placedWards = {}

  Config = scriptConfig("AntiWard", "AntiWard")
  Config:addParam("OwnTeam", "show my own team wards", SCRIPT_PARAM_ONOFF, false)
  Config:addParam("ShowPinks", "show pink wards", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("ShowTraps", "show traps", SCRIPT_PARAM_ONOFF, true)

  Config:addParam("Manual", "manual ward editing (put/delete)", SCRIPT_PARAM_ONOFF, false)

  Config:addParam("DeleteWard", "delete ward", SCRIPT_PARAM_ONKEYDOWN, false, 0)

  Config:addParam("PutWard1", "put 1 minute ward", SCRIPT_PARAM_ONKEYDOWN, false, 0)
  Config:addParam("PutWard2", "put 2 minute ward", SCRIPT_PARAM_ONKEYDOWN, false, 0)
  Config:addParam("PutWard3", "put 3 minute ward", SCRIPT_PARAM_ONKEYDOWN, false, 0)

    --PrintChat(" >> AntiWard 3.15 (2014-02-03)")

  TriggerTrap()
end

local _allyHeroes
function GetAllyHeroes()
    if _allyHeroes then return _allyHeroes end
    _allyHeroes = {}
    for i = 1, heroManager.iCount do
        local hero = heroManager:GetHero(i)
        if hero.team == myHero.team then
            table.insert(_allyHeroes, hero)
        end
    end
    return setmetatable(_allyHeroes,{
        __newindex = function(self, key, value)
            error("Adding to AllyHeroes is not granted. Use table.copy.")
        end,
    })
end

function TriggerTrap()
  for ID, ward in pairs(placedWards) do
    for i = 1, heroManager.iCount do
      local hero = heroManager:GetHero(i)

      if ward.trap and ward.team ~= hero.team and GetDistance(ward, hero) <= ward.triggerRange then
        placedWards[ID] = nil
      end
    end
  end

  DelayAction(TriggerTrap, 0.2)
end

function AntiWardOnTick()
  if Config.Manual then
    if Config.DeleteWard then DeleteWard(mousePos.x, mousePos.y, mousePos.z) end

    if Config.PutWard1 then PutWard(mousePos.x, mousePos.y, mousePos.z, 1 * 60) end
    if Config.PutWard2 then PutWard(mousePos.x, mousePos.y, mousePos.z, 2 * 60) end
    if Config.PutWard3 then PutWard(mousePos.x, mousePos.y, mousePos.z, 3 * 60) end
  end
end

function AntiWardOnDraw()
    for ID, ward in pairs(placedWards) do
        if (GetTickCount() - ward.spawnTime) > ward.duration + 5000 or (ward.object and ward.object.health == 0) then
            placedWards[ID] = nil
        elseif (ward.team == TEAM_ENEMY or Config.OwnTeam) and (ward.duration < math.huge or Config.ShowPinks) and (not ward.trap or Config.ShowTraps) then
            local minimapPosition = GetMinimap(ward)
            DrawTextWithBorder('.', 60, minimapPosition.x - 3, minimapPosition.y - 43, ward.color, blackColor)

            local x, y, onScreen = get2DFrom3D(ward.x, ward.y, ward.z)
            DrawTextWithBorder(TimerText((ward.duration - (GetTickCount() - ward.spawnTime)) / 1000), 20, x - 15, y - 11, ward.color, blackColor)
      if ward["creator"] then DrawTextWithBorder(ward["creator"].charName, 16, x - 20, y + 10, whiteColor, blackColor) end

            DrawCircle2(ward.x, ward.y, ward.z, 90, ward.color)
            if IsKeyDown(16) then
                DrawCircle2(ward.x, ward.y, ward.z, ward.visionRange, ward.color)
            end
        end
    end
end

function DrawTextWithBorder(textToDraw, textSize, x, y, textColor, backgroundColor)
    DrawText(textToDraw, textSize, x + 1, y, backgroundColor)
    DrawText(textToDraw, textSize, x - 1, y, backgroundColor)
    DrawText(textToDraw, textSize, x, y - 1, backgroundColor)
    DrawText(textToDraw, textSize, x, y + 1, backgroundColor)
    DrawText(textToDraw, textSize, x , y, textColor)
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
    quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
    quality = 2 * math.pi / quality
    radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))

    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
        DrawCircleNextLvl(x, y, z, radius, 1, color, 75)    
    end
end

function get2DFrom3D(x, y, z)
    local pos = WorldToScreen(D3DXVECTOR3(x, y, z))
    return pos.x, pos.y, OnScreen(pos.x, pos.y)
end

function FindObjAt(x, y, z, distance, timediff, timestart)
  if not distance then distance = 1 end
  if not timediff then timediff = math.huge end
  if not timestart then timestart = GetTickCount() end

  for networkID, ward in pairs(placedWards) do
    if GetDistance(ward, Vector(x, y, z)) < distance and timestart - ward.spawnTime < timediff then return networkID end
  end

  return nil
end

function GetLandingPos(CastPoint)
    local wall = IsWall(D3DXVECTOR3(CastPoint.x, CastPoint.y, CastPoint.z))
    local Point = Vector(CastPoint)
    local StartPoint = Vector(Point)
        if not wall then return Point end
    for i = 0, 700, 10--[[Decrease for better precision, increase for less fps drops:]] do
        for theta = 0, 2 * math.pi + 0.2, 0.2 --[[Same :)]] do
            local c = Vector(StartPoint.x + i * math.cos(theta), StartPoint.y, StartPoint.z + i * math.sin(theta))
            if not IsWall(D3DXVECTOR3(c.x, c.y, c.z)) then
                return c
            end
        end
    end
    return Point
end

local types = {
  { duration=60 * 1000, sightRange=1350, triggerRange=70, charName="SightWard", name="YellowTrinket", spellName="RelicSmallLantern", color = aquaColor }, -- 1 minute trinket
  { duration=120 * 1000, sightRange=1350, triggerRange=70, charName="SightWard", name="YellowTrinketUpgrade", spellName="RelicLantern", color = aquaColor }, -- 2 minute trinket
  { duration=180 * 1000, sightRange=1350, triggerRange=70, charName="SightWard", name="SightWard", spellName="SightWard", color = greenColor }, -- 3 minute green ward
  { duration=180 * 1000, sightRange=1350, triggerRange=70, charName="SightWard", name="SightWard", spellName="wrigglelantern", color = greenColor }, -- 3 minute lantern ward
  { duration=180 * 1000, sightRange=1350, triggerRange=70, charName="VisionWard", name="SightWard", spellName="ItemGhostWard", color = greenColor }, -- 3 minute item ward
  { duration=math.huge, sightRange=1350, triggerRange=70, charName="VisionWard", name="VisionWard", spellName="VisionWard", color = purpleColor }, -- pink ward

  { duration=600 * 1000, sightRange=405, triggerRange=115, charName="Noxious Trap", name="TeemoMushroom", spellName="BantamTrap", color = whiteColor, trap = true }, -- teemo mushroom
  { duration=60 * 1000, sightRange=690, triggerRange=300, charName="Jack In The Box", name="ShacoBox", spellName="JackInTheBox", color = whiteColor, trap = true }, -- shaco trap
  { duration=240 * 1000, sightRange=150, triggerRange=150, charName="Cupcake Trap", name="CaitlynTrap", spellName="CaitlynYordleTrap", color = whiteColor, trap = true }, -- caitlyn trap
  { duration=240 * 1000, sightRange=0, triggerRange=150, charName="Noxious Trap", name="Nidalee_Spear", spellName="Bushwhack", color = whiteColor, trap = true } -- nidalee trap
}

function AntiWardOnDeleteObj(object)
    if object and object.name and object.valid and object.type == "obj_AI_Minion" then

    for _,type in ipairs(types) do

      if object.name == type.charName and object.charName == type.name then

        local ID = FindObjAt(object.x, object.y, object.z) 

        if ID and object.health == 0 then
          placedWards[ID] = nil
        end
      end

    end

  end
end

COOLDOWN = GetGameTimer()

function PutWard(x, y, z, time)
  if GetGameTimer() - COOLDOWN < 1 then return end

  local ID = FindObjAt(x, y, z, 150)

  if ID == nil then
    placedWards["user:" .. GetTickCount()] = { x = x, y = y, z = z, visionRange = 1350, color = grayColor, 
    spawnTime = GetTickCount(), duration = time*1000, creator = nil, team = nil }
  end

  COOLDOWN = GetGameTimer()
end

function DeleteWard(x, y, z)
  if GetGameTimer() - COOLDOWN < 1 then return end

  local ID = FindObjAt(x, y, z, 100)

  if ID then placedWards[ID] = nil end

  COOLDOWN = GetGameTimer()
end

function AntiWardOnCreateObj(object)

    if object and object.name and object.valid and object.type == "obj_AI_Minion" then

    DelayAction(function(object, timer, gtimer)

      for _,type in ipairs(types) do

        if object.name == type.charName and object.charName == type.name then

          local ID = FindObjAt(object.x, object.y, object.z, 1100, 500, timer)

          if object.health > 0 then
            if ID == nil then
              placedWards["create:" .. GetTickCount()] = { x = object.x, y = object.y, z = object.z, visionRange = type.sightRange, color = type.color, object = object, 
                triggerRange = type.triggerRange, spawnTime = timer, duration = type.duration, creator = nil, team = object.team, trap = type.trap }
            else
              placedWards[ID].x = object.x
              placedWards[ID].y = object.y
              placedWards[ID].z = object.z
            end
          end


        end

      end
    end, 1, { object, GetTickCount(), GetGameTimer() } )

  end
end

function AwardOnProcessSpell(unit, spell)

  if unit.type == "obj_AI_Hero" then
        for _,type in ipairs(types) do
            if type.spellName == spell.name then

        local wardPos = GetLandingPos(spell.endPos)

        if FindObjAt(wardPos.x, wardPos.y, wardPos.z) == nil then
                placedWards["spell:" .. GetTickCount()] = { x = wardPos.x, y = wardPos.y, z = wardPos.z, visionRange = type.sightRange, color = type.color, triggerRange = type.triggerRange,
                                                                              spawnTime = GetTickCount(), duration = type.duration, creator = unit, team = unit.team, trap = type.trap }
        end
            end

        end

  end

end

-- #######################################################################################################

-- ############################################ Where did he go? #########################################
--[[#####   Where did he go? v0.4 by ViceVersa   #####]]--
--[[Draws a line to the location where enemys blink or flash to.]]

--Vars
local blink = {} --Blink Ability Array
local vayneUltEndTick = 0
local shacoIndex = 0


--Functions
function FindNearestNonWall(x0, y0, z0, maxRadius, precision) --returns the nearest non-wall-position of the given position(Credits to gReY)
    
    --Convert to vector
    local vec = D3DXVECTOR3(x0, y0, z0)
    
    --If the given position it a non-wall-position return it
    if not IsWall(vec) then return vec end
    
    --Optional arguments
    precision = precision or 50
    maxRadius = maxRadius and math.floor(maxRadius / precision) or math.huge
    
    --Round x, z
    x0, z0 = math.round(x0 / precision) * precision, math.round(z0 / precision) * precision

    --Init vars
    local radius = 1
    
    --Check if the given position is a non-wall position
    local function checkP(x, y) 
        vec.x, vec.z = x0 + x * precision, z0 + y * precision 
        return not IsWall(vec) 
    end
    
    --Loop through incremented radius until a non-wall-position is found or maxRadius is reached
    while radius <= maxRadius do
        --A lot of crazy math (ask gReY if you don't understand it. I don't)
        if checkP(0, radius) or checkP(radius, 0) or checkP(0, -radius) or checkP(-radius, 0) then 
            return vec 
        end
        local f, x, y = 1 - radius, 0, radius
        while x < y - 1 do
            x = x + 1
            if f < 0 then 
                f = f + 1 + 2 * x
            else 
                y, f = y - 1, f + 1 + 2 * (x - y)
            end
            if checkP(x, y) or checkP(-x, y) or checkP(x, -y) or checkP(-x, -y) or 
               checkP(y, x) or checkP(-y, x) or checkP(y, -x) or checkP(-y, -x) then 
                return vec 
            end
        end
        --Increment radius every iteration
        radius = radius + 1
    end
end
    
    
--Callbacks
function WDHGOnLoad() --Called one time on load
    
    --Fill the Blink Ability Array
    for i, heroObj in pairs(GetEnemyHeroes()) do
        
        --If the object exists and the player is in the enemy team
        if heroObj and heroObj.valid then
            
            --Summoner Flash
            if heroObj:GetSpellData(SUMMONER_1).name:find("Flash") or heroObj:GetSpellData(SUMMONER_2).name:find("Flash") then
                table.insert(blink,{name = "SummonerFlash"..heroObj.charName, maxRange = 400, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Flash"})
            end
            
            --Ezreal E
            if heroObj.charName == "Ezreal" then
                table.insert(blink,{name = "EzrealArcaneShift", maxRange = 475, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Fiora R
            elseif heroObj.charName == "Fiora" then
                table.insert(blink,{name = "FioraDance", maxRange = 700, delay = 1, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "R", target = {}, targetDead = false})
            
            --Kassadin R
            elseif heroObj.charName == "Kassadin" then
                table.insert(blink,{name = "RiftWalk", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "R"})
            
            --Katarina E
            elseif heroObj.charName == "Katarina" then
                table.insert(blink,{name = "KatarinaE", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Leblanc W
            elseif heroObj.charName == "Leblanc" then
                table.insert(blink,{name = "LeblancSlide", maxRange = 600, delay = 0.5, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})
                table.insert(blink,{name = "leblancslidereturn", delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})
                table.insert(blink,{name = "LeblancSlideM", maxRange = 600, delay = 0.5, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})
                table.insert(blink,{name = "leblancslidereturnm", delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})
            
            --[[Lissandra E (wip)(ToDo: Draw where she blinks to only when she does)
            elseif heroObj.charName == "Lissandra" then
                table.insert(blink,{name= "LissandraE", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})]]
            
            --Master Yi Q
            elseif heroObj.charName == "MasterYi" then
                table.insert(blink,{name = "AlphaStrike", maxRange = 600, delay = 0.9, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Q", target = {}, targetDead = false})
            
            --Shaco Q
            elseif heroObj.charName == "Shaco" then
                table.insert(blink,{name = "Deceive", maxRange = 400, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Q", outOfBush = false})
                shacoIndex = #blink --Save the position of shacos Q

            --Talon E
            elseif heroObj.charName == "Talon" then
                table.insert(blink,{name = "TalonCutthroat", maxRange = 700, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "E"})
            
            --Vayne Q
            elseif heroObj.charName == "Vayne" then
                table.insert(blink,{name = "VayneTumble", maxRange = 250, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "Q"})
                vayneUltEndTick = 1 --Start to check for Vayne's ult
            
            --[[Zed W (wip)(ToDo: Draw where he blinks when he swaps place with shadow)
            elseif heroObj.charName == "Zed" then
                table.insert(blink,{name= "ZedShadowDash", maxRange = 999, delay = 0, casted = false, timeCasted = 0, startPos = {}, endPos = {}, castingHero = heroObj, shortName = "W"})]]
            
            end
            
        end
    end
    
    --If something was added to the array
    if #blink > 0 then

        --Shift-Menu
        WDHGConfig = scriptConfig("Where did he go?","whereDidHeGo")
        WDHGConfig:addParam("wallPrediction",     "Use Wall Prediction",      SCRIPT_PARAM_ONOFF, false)
        WDHGConfig:addParam("displayTime",        "Display time (No Vision)", SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
        WDHGConfig:addParam("displayTimeVisible", "Display time (Vision)",    SCRIPT_PARAM_SLICE, 1, 0.5, 3, 1)
        WDHGConfig:addParam("lineColor",          "Line Color",               SCRIPT_PARAM_COLOR, {255,255,255,0})
        WDHGConfig:addParam("lineWidth",          "Line Width",               SCRIPT_PARAM_SLICE, 3, 1, 5, 0)
        WDHGConfig:addParam("circleColor",        "Circle Color",             SCRIPT_PARAM_COLOR, {255,255,25,0})
        WDHGConfig:addParam("circleSize",         "Circle Size",              SCRIPT_PARAM_SLICE, 100, 50, 300, 0)
    
        --Print Load-Message
        --if #blink > 1 then
            --print('<font color="#A0FF00">Where did he go? >> v0.4 loaded! (Found '..#blink..' abilitys)</font>')
        --else
            --print('<font color="#A0FF00">Where did he go? >> v0.4 loaded! (Found 1 ability)</font>')
        --end
        
    --else
        --Print Notice
        --print('<font color="#FFFF55">Where did he go? >> No characters with blink abilitys or flash found!</font>')
    end
    
end

function WDHGOnProcessSpell(unit, spell)--When a spell is casted
    
    --If the casting unit is in the enemy team and if it is a champion-ability
    if unit and unit.valid and unit.team == TEAM_ENEMY and unit.type == "obj_AI_Hero" then
        
        --If the spell is Vayne's R
        if vayneUltEndTick > 0 and spell.name == "vayneinquisition" then
            vayneUltEndTick = os.clock() + 6 + 2*spell.level
            return --skip the array
        end
        
        --For each skillshot in the array
        for i=1, #blink, 1 do
            
            --If the casted spell is in the array
            if spell.name == blink[i].name or spell.name..unit.charName == blink[i].name then                
                
                --local function to set the normal end position
                local function SetNormalEndPosition(i, spell)
                    --If the position the enemy clicked is inside the range of the ability set the end position to that position
                    if GetDistance(spell.startPos, spell.endPos) <= blink[i].maxRange then
                        --Set the end position
                        blink[i].endPos = { x = spell.endPos.x, y = spell.endPos.y, z = spell.endPos.z }
                    
                    --Else Calculate the true position if the enemy clicked outside of the ability range
                    else
                        local vStartPos = Vector(spell.startPos.x, spell.startPos.y, spell.startPos.z)
                        local vEndPos = Vector(spell.endPos.x, spell.endPos.y, spell.endPos.z)
                        local tEndPos = vStartPos - (vStartPos - vEndPos):normalized() * blink[i].maxRange
                        
                        --If enabled, Check if the position is in a wall and return the position where the player was really flashed to
                        if WDHGConfig.wallPrediction then
                            tEndPos = FindNearestNonWall(tEndPos.x, tEndPos.y, tEndPos.z, 1000)
                        end
                        
                        --Set the end position
                        blink[i].endPos = { x = tEndPos.x, y = tEndPos.y, z = tEndPos.z }
                    
                    end
                end
                
                --##### Champion-Specific-Stuff #####--
                --#Vayne#
                --Exit if the spell is Vayne's Q and her ult isn't running
                if blink[i].name == "VayneTumble" and os.clock() >= vayneUltEndTick then return end
                
                --#Shaco#
                --Set outOfBush to false if the spell can be tracked
                if blink[i].name == "Deceive" then
                    blink[i].outOfBush = false
                end
                
                --#Leblanc#
                --If the spell is a mirrored W
                if blink[i].name == "LeblancSlideM" then
                    
                    --Cancel the normal W
                    blink[i-2].casted = false
                    
                    --Set the start position to the start position of the first W
                    blink[i].startPos = { x = blink[i-2].startPos.x, y = blink[i-2].startPos.y, z = blink[i-2].startPos.z }
                    
                    --Set the normal end position
                    SetNormalEndPosition(i, spell)
                
                --If the spell is one of Leblanc's returns
                elseif blink[i].name == "leblancslidereturn" or blink[i].name == "leblancslidereturnm" then
                    
                    --Cancel the other W-spells if she returns
                    if blink[i].name == "leblancslidereturn" then
                        blink[i-1].casted = false
                        blink[i+1].casted = false
                        blink[i+2].casted = false
                    else
                        blink[i-3].casted = false
                        blink[i-2].casted = false
                        blink[i-1].casted = false
                    end
                    
                    --Set the normal start position
                    blink[i].startPos = { x = spell.startPos.x, y = spell.startPos.y, z = spell.startPos.z }
                    
                    --Set the end position to the start position of her last slide
                    blink[i].endPos = { x = blink[i-1].startPos.x, y = blink[i-1].startPos.y, z = blink[i-1].startPos.z }
                
                --#Fiora# / #MasterYi#
                elseif blink[i].name == "FioraDance" or blink[i].name == "AlphaStrike" then
                    
                    --Set the target minion
                    blink[i].target = spell.target
                    
                    --Set targetDead to false
                    blink[i].targetDead = false
                    
                    --Set the normal start position
                    blink[i].startPos = { x = spell.startPos.x, y = spell.startPos.y, z = spell.startPos.z }
                    
                    --Set the end position to the position of the targeted unit
                    blink[i].endPos = { x = blink[i].target.x, y = blink[i].target.y, z = blink[i].target.z }
                    
                    
                --##### End of Champion-Specific-Stuff #####--
                                
                --Else set the normal positions
                else
                    
                    --Set the start position
                    blink[i].startPos = { x = spell.startPos.x, y = spell.startPos.y, z = spell.startPos.z }
                    
                    --Set the end position
                    SetNormalEndPosition(i, spell)

                end
                
                --Set casted to true
                blink[i].casted = true
                
                --Set the time when the ability is casted
                blink[i].timeCasted = os.clock()
                                
                --Exit loop
                break
                
            end
            
        end
    end
end

function WDHGOnCreateObj(obj)
    if shacoIndex ~= 0 and obj and obj.valid and obj.name == "JackintheboxPoof2.troy" and not blink[shacoIndex].casted then
        --Set the start and end position of shacos Q to the position of the obj
        blink[shacoIndex].startPos = { x = obj.x, y = obj.y, z = obj.z }
        blink[shacoIndex].endPos = { x = obj.x, y = obj.y, z = obj.z }
        
        --Set casted to true
        blink[shacoIndex].casted = true
        
        --Set the time when the ability is casted
        blink[shacoIndex].timeCasted = os.clock()
        
        --Set outOfBush to true to draw the circle instead the line
        blink[shacoIndex].outOfBush = true
    end
end

function WDHGOnTick()
    --Loop through all abilitys
    for i=1, #blink, 1 do
        
        --If the ability was casted
        if blink[i].casted then
            
            --If the enemy is Fiora or Master Yi and the target is not dead
            if blink[i].name == "FioraDance" or blink[i].name == "AlphaStrike" and not blink[i].targetDead then
                if os.clock() > (blink[i].timeCasted + blink[i].delay + 0.2) then
                    blink[i].casted = false
                elseif blink[i].target.dead then
                    --Save startPos in a temp var
                    local tempPos = { x = blink[i].endPos.x, y = blink[i].endPos.y, z = blink[i].endPos.z }
                    --Set the end position to the start position
                    blink[i].endPos = { x = blink[i].startPos.x, y = blink[i].startPos.y, z = blink[i].startPos.z }
                    --Set the start position to the enemy position
                    blink[i].startPos = { x = tempPos.x, y = tempPos.y, z = tempPos.z }
                    --Set targetDead to true
                    blink[i].targetDead = true
                else
                    --Set the end position the the target unit
                    blink[i].endPos = { x = blink[i].target.x, y = blink[i].target.y, z = blink[i].target.z }
                end
            
            --If the champ is dead or display time is over stop the drawing
            elseif blink[i].castingHero.dead or (not blink[i].castingHero.visible and os.clock() > (blink[i].timeCasted + WDHGConfig.displayTime + blink[i].delay)) or (blink[i].castingHero.visible and os.clock() > (blink[i].timeCasted + WDHGConfig.displayTimeVisible + blink[i].delay)) then
                blink[i].casted = false
                
            --If the enemy is visible after the delay set the target to his position
            elseif not blink[i].outOfBush and blink[i].castingHero.visible and os.clock() > blink[i].timeCasted + blink[i].delay then
                --Set the end position the the current position of the enemy
                blink[i].endPos = { x = blink[i].castingHero.x, y = blink[i].castingHero.y, z = blink[i].castingHero.z }
                
            end
        end
    end
end

function WDHGOnDraw()
    --For each ability in the array
    for i=1, #blink, 1 do
        
        --If the ability is casted
        if blink[i].casted then
            
            --Convert 3D-coordinates to 2D-coordinates for DrawLine and InfoText
            local lineStartPos = WorldToScreen(D3DXVECTOR3(blink[i].startPos.x, blink[i].startPos.y, blink[i].startPos.z))
            local lineEndPos = WorldToScreen(D3DXVECTOR3(blink[i].endPos.x, blink[i].endPos.y, blink[i].endPos.z))            
            
            --If the ability is shacos Q out of a bush draw only a circle
            if blink[i].outOfBush then
                --Draw a circle showing the possible target
                for j=0, 3, 1 do
                    DrawCircle(blink[i].endPos.x , blink[i].endPos.y , blink[i].endPos.z, blink[i].maxRange+j*2, ARGB(255, 255, 25, 0))
                end
            
            --Else draw the normal circle with a line
            else
                --Draw Circle at target position
                for j=0, 3, 1 do
                    DrawCircle(blink[i].endPos.x , blink[i].endPos.y , blink[i].endPos.z , WDHGConfig.circleSize+j*2, RGB(WDHGConfig.circleColor[2],WDHGConfig.circleColor[3],WDHGConfig.circleColor[4]))
                end
                                
                --Draw Line beetween the start and target position
                DrawLine(lineStartPos.x, lineStartPos.y, lineEndPos.x, lineEndPos.y, WDHGConfig.lineWidth, RGB(WDHGConfig.lineColor[2],WDHGConfig.lineColor[3],WDHGConfig.lineColor[4]))
            end
            
            --Draw the info text (Credits to Weee :3)
            local offset = 30
            local infoText = blink[i].castingHero.charName .. " " .. blink[i].shortName
            DrawLine(lineEndPos.x, lineEndPos.y, lineEndPos.x + offset, lineEndPos.y - offset, 1, ARGB(255,255,255,255))
            DrawLine(lineEndPos.x + offset, lineEndPos.y - offset, lineEndPos.x + offset + 6 * infoText:len(), lineEndPos.y - offset, 1, ARGB(255,255,255,255))
            DrawTextA(infoText, 12, lineEndPos.x + offset + 1, lineEndPos.y - offset, ARGB(255,255,255,255), "left", "bottom")

        end
    end
end

-- ######################################  Spin To Win  ##################################################
--[[
    ikita's Spin-To-Win
]]--

--Config:
local spinSpeed = 8 -- This is the (number of points it will face in a full circle)
local MyKeySpin = 192 -- English Tilt -- (~)

--Other stuff
local spin = false
local direction = 0
local lastSpined = 0

function SpinToWinOnWndMsg(msg,key)
    if key == MyKeySpin then
        if msg == KEY_DOWN then
            spin = true
        else
            spin = false
        end 
    end
end

function SpinToWinOnTick()
    if spin then
        spinX = 100*math.sin(math.pi*direction / spinSpeed)
        spinZ = 100*math.cos(math.pi*direction / spinSpeed)
        myHero:MoveTo(myHero.x + spinX,myHero.z + spinZ)
        direction = direction + 1
        directionCount = directionCount + 1
    else
        directionCount = spinSpeed + 1
        direction = (((math.pi/2) - math.atan2((mousePos.z - myHero.z),(mousePos.x - myHero.x)))*spinSpeed)/math.pi
    end
end
--PrintChat(" >> Spin To Win loaded!")


-- ######################################  Where Is He ??? ###############################################
--[[
    WhereIsHe v1.2 by eXtragoZ
        
    -Simple script that shows where the enemy can be
    -Thinner is the line is means that the enemy can be closer
    -Calculates the moving speed multiplied by the time that the enemy is miss
    -Circles have a minimum radius and maximum radius
]]

--[[        Code        ]]
local player = GetMyHero()
local unittraveled = 0
local MissTimer = {}
local MissSec = {}
local tick_heros = {}

function WhereIsHeOnTick()
    for i=1, heroManager.iCount do
        local heros = heroManager:GetHero(i)
        if heros.visible == false and heros.dead == false and heros.team ~= player.team then
            if tick_heros[i] == nil then
                tick_heros[i] = GetTickCount()
            end
            MissTimer[i] = GetTickCount() - tick_heros[i]           
            MissSec[i] =  MissTimer[i]/1000
        else
            tick_heros[i] = nil
            MissTimer[i] = nil
            MissSec[i] = 0
        end
    end
end
function WhereIsHeOnDraw()
    for i = 1, heroManager.iCount, 1 do
        local enemy = heroManager:getHero(i)
        if enemy ~= nil and enemy.team ~= player.team and enemy.dead == false and enemy.visible == false then
                if MissSec[i] == nil then
                    MissSec[i] = 0
                end
            unittraveled = enemy.ms*MissSec[i]
            if unittraveled > 50 and unittraveled < 10000 then
                DrawCircle(enemy.x, enemy.y, enemy.z, unittraveled, 0xFF0000)
            end
        end
    end
end
--PrintChat(" >> WhereIsHe 1.2 loaded!")
-- #############################################################################

-- ################################################### MiniMap Timers #########################################################
--[[
Script: minimapTimers v0.2 test try this

Author: SurfaceS 

In replacement of my Jungle Display v0.2

UPDATES :
v0.1          initial release
]]
do
  --[[      GLOBAL      ]]
  monsters = {
    summonerRift = {
      { -- baron
        name = "baron",
        spawn = 900,
        respawn = 420,
        advise = true,
        camps = {
          {
            pos = { x = 4600, y = 60, z = 10250 },
            name = "monsterCamp_12",
            creeps = { { { name = "Worm12.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
        },
      },
      { -- dragon
        name = "dragon",
        spawn = 150,
        respawn = 360,
        advise = true,
        camps = {
          {
            pos = { x = 9459, y = 60, z = 4193 },
            name = "monsterCamp_6",
            creeps = { { { name = "Dragon6.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
        },
      },
      { -- blue
        name = "blue",
        spawn = 115,
        respawn = 300,
        advise = true,
        camps = {
          {
            pos = { x = 3632, y = 60, z = 7600 },
            name = "monsterCamp_1",
            creeps = { { { name = "AncientGolem1.1.1" }, { name = "YoungLizard1.1.2" }, { name = "YoungLizard1.1.3" }, }, },
            team = TEAM_BLUE,
          },
          {
            pos = { x = 10386, y = 60, z = 6811 },
            name = "monsterCamp_7",
            creeps = { { { name = "AncientGolem7.1.1" }, { name = "YoungLizard7.1.2" }, { name = "YoungLizard7.1.3" }, }, },
            team = TEAM_RED,
          },
        },
      },
      { -- red
        name = "red",
        spawn = 115,
        respawn = 300,
        advise = true,
        camps = {
          {
            pos = { x = 7455, y = 60, z = 3890 },
            name = "monsterCamp_4",
            creeps = { { { name = "LizardElder4.1.1" }, { name = "YoungLizard4.1.2" }, { name = "YoungLizard4.1.3" }, }, },
            team = TEAM_BLUE,
          },
          {
            pos = { x = 6504, y = 60, z = 10584 },
            name = "monsterCamp_10",
            creeps = { { { name = "LizardElder10.1.1" }, { name = "YoungLizard10.1.2" }, { name = "YoungLizard10.1.3" }, }, },
            team = TEAM_RED,
          },
        },
      },
      { -- wolves
        name = "wolves",
        spawn = 115,
        respawn = 50,
        advise = false,
        camps = {
          {
            name = "monsterCamp_2",
            creeps = { { { name = "GiantWolf2.1.3" }, { name = "wolf2.1.1" }, { name = "wolf2.1.2" }, }, },
            team = TEAM_BLUE,
          },
          {
            name = "monsterCamp_8",
            creeps = { { { name = "GiantWolf8.1.3" }, { name = "wolf8.1.1" }, { name = "wolf8.1.2" }, }, },
            team = TEAM_RED,
          },
        },
      },
      { -- wraiths
        name = "wraiths",
        spawn = 115,
        respawn = 50,
        advise = false,
        camps = {
          {
            name = "monsterCamp_3",
            creeps = { { { name = "Wraith3.1.3" }, { name = "LesserWraith3.1.1" }, { name = "LesserWraith3.1.2" }, { name = "LesserWraith3.1.4" }, }, },
            team = TEAM_BLUE,
          },
          {
            name = "monsterCamp_9",
            creeps = { { { name = "Wraith9.1.3" }, { name = "LesserWraith9.1.1" }, { name = "LesserWraith9.1.2" }, { name = "LesserWraith9.1.4" }, }, },
            team = TEAM_RED,
          },
        },
      },
      { -- GreatWraiths
        name = "GreatWraiths",
        spawn = 115,
        respawn = 50,
        advise = false,
        camps = {
          {
            name = "monsterCamp_13",
            creeps = { { { name = "GreatWraith13.1.1" }, }, },
            team = TEAM_BLUE,
          },
          {
            name = "monsterCamp_14",
            creeps = { { { name = "GreatWraith14.1.1" }, }, },
            team = TEAM_RED,
          },
        },
      },
      { -- Golems
        name = "Golems",
        spawn = 115,
        respawn = 50,
        advise = false,
        camps = {
          {
            name = "monsterCamp_5",
            creeps = { { { name = "Golem5.1.2" }, { name = "SmallGolem5.1.1" }, }, },
            team = TEAM_BLUE,
          },
          {
            name = "monsterCamp_11",
            creeps = { { { name = "Golem11.1.2" }, { name = "SmallGolem11.1.1" }, }, },
            team = TEAM_RED,
          },
        },
      },
    },
    twistedTreeline = {
      { -- Wraith
        name = "Wraith",
        spawn = 100,
        respawn = 50,
        advise = false,
        camps = {
          {
            --pos = { x = 4414, y = 60, z = 5774 },
            name = "monsterCamp_1",
            creeps = {
              { { name = "TT_NWraith1.1.1" }, { name = "TT_NWraith21.1.2" }, { name = "TT_NWraith21.1.3" }, },
            },
            team = TEAM_BLUE,
          },
          {
            --pos = { x = 11008, y = 60, z = 5775 },
            name = "monsterCamp_4",
            creeps = {
              { { name = "TT_NWraith4.1.1" }, { name = "TT_NWraith24.1.2" }, { name = "TT_NWraith24.1.3" }, },
            },
            team = TEAM_RED,
          },
        },
      },
      { -- Golems
        name = "Golems",
        respawn = 50,
        spawn = 100,
        advise = false,
        camps = {
          {
            --pos = { x = 5088, y = 60, z = 8065 },
            name = "monsterCamp_2",
            creeps = {
              { { name = "TT_NGolem2.1.1" }, { name = "TT_NGolem22.1.2" } },
            },
            team = TEAM_BLUE,
          },
          {
            --pos = { x = 10341, y = 60, z = 8084 },
            name = "monsterCamp_5",
            creeps = {
              { { name = "TT_NGolem5.1.1" }, { name = "TT_NGolem25.1.2" } },
            },
            team = TEAM_RED,
          },
        },
      },
      { -- Wolves
        name = "Wolves",
        respawn = 50,
        spawn = 100,
        advise = false,
        camps = {
          {
            --pos = { x = 6148, y = 60, z = 5993 },
            name = "monsterCamp_3",
            creeps = { { { name = "TT_NWolf3.1.1" }, { name = "TT_NWolf23.1.2" }, { name = "TT_NWolf23.1.3" } }, },
            team = TEAM_BLUE,
          },
          {
            --pos = { x = 9239, y = 60, z = 6022 },
            name = "monsterCamp_6",
            creeps = { { { name = "TT_NWolf6.1.1" }, { name = "TT_NWolf26.1.2" }, { name = "TT_NWolf26.1.3" } }, },
            team = TEAM_RED,
          },
        },
      },
      { -- Heal
        name = "Heal",
        spawn = 115,
        respawn = 90,
        advise = true,
        camps = {
          {
            pos = { x = 7711, y = 60, z = 6722 },
            name = "monsterCamp_7",
            creeps = { { { name = "TT_Relic7.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
        },
      },
      { -- Vilemaw
        name = "Vilemaw",
        spawn = 600,
        respawn = 300,
        advise = true,
        camps = {
          {
            pos = { x = 7711, y = 60, z = 10080 },
            name = "monsterCamp_8",
            creeps = { { { name = "TT_Spiderboss8.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
        },
      },
    },
    crystalScar = {},
    provingGrounds = {
      { -- Heal
        name = "Heal",
        spawn = 190,
        respawn = 40,
        advise = false,
        camps = {
          {
            pos = { x = 8922, y = 60, z = 7868 },
            name = "monsterCamp_1",
            creeps = { { { name = "OdinShieldRelic1.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
          {
            pos = { x = 7473, y = 60, z = 6617 },
            name = "monsterCamp_2",
            creeps = { { { name = "OdinShieldRelic2.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
          {
            pos = { x = 5929, y = 60, z = 5190 },
            name = "monsterCamp_3",
            creeps = { { { name = "OdinShieldRelic3.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
          {
            pos = { x = 4751, y = 60, z = 3901 },
            name = "monsterCamp_4",
            creeps = { { { name = "OdinShieldRelic4.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
        },
      },
    },
    howlingAbyss = {
      { -- Heal
        name = "Heal",
        spawn = 190,
        respawn = 40,
        advise = false,
        camps = {
          {
            pos = { x = 8922, y = 60, z = 7868 },
            name = "monsterCamp_1",
            creeps = { { { name = "HA_AP_HealthRelic1.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
          {
            pos = { x = 7473, y = 60, z = 6617 },
            name = "monsterCamp_2",
            creeps = { { { name = "HA_AP_HealthRelic2.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
          {
            pos = { x = 5929, y = 60, z = 5190 },
            name = "monsterCamp_3",
            creeps = { { { name = "HA_AP_HealthRelic3.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
          {
            pos = { x = 4751, y = 60, z = 3901 },
            name = "monsterCamp_4",
            creeps = { { { name = "HA_AP_HealthRelic4.1.1" }, }, },
            team = TEAM_NEUTRAL,
          },
        },
      },
    },
  }

  altars = {
    summonerRift = {},
    twistedTreeline = {
      {
        name = "Left Altar",
        spawn = 180,
        respawn = 85,
        advise = true,
        objectName = "TT_Buffplat_L",
        locked = false,
        lockNames = {"TT_Lock_Blue_L.troy", "TT_Lock_Purple_L.troy", "TT_Lock_Neutral_L.troy", },
        unlockNames = {"TT_Unlock_Blue_L.troy", "TT_Unlock_purple_L.troy", "TT_Unlock_Neutral_L.troy", },
      },
      {
        name = "Right Altar",
        spawn = 180,
        respawn = 85,
        advise = true,
        objectName = "TT_Buffplat_R",
        locked = false,
        lockNames = {"TT_Lock_Blue_R.troy", "TT_Lock_Purple_R.troy", "TT_Lock_Neutral_R.troy", },
        unlockNames = {"TT_Unlock_Blue_R.troy", "TT_Unlock_purple_R.troy", "TT_Unlock_Neutral_R.troy", },
      },
    },
    crystalScar = {},
    provingGrounds = {},
    howlingAbyss = {},
  }

  relics = {
    summonerRift = {},
    twistedTreeline = {},
    crystalScar = {
      {
        pos = { x = 5500, y = 60, z = 6500 },
        name = "Relic",
        team = TEAM_BLUE,
        spawn = 180,
        respawn = 180,
        advise = true,
        locked = false,
        precenceObject = (player.team == TEAM_BLUE and "Odin_Prism_Green.troy" or "Odin_Prism_Red.troy"),
      },
      {
        pos = { x = 7550, y = 60, z = 6500 },
        name = "Relic",
        team = TEAM_RED,
        spawn = 180,
        respawn = 180,
        advise = true,
        locked = false,
        precenceObject = (player.team == TEAM_RED and "Odin_Prism_Green.troy" or "Odin_Prism_Red.troy"),
      },
    },
    provingGrounds = {},
    howlingAbyss = {},
  }

  heals = {
    summonerRift = {},
    twistedTreeline = {},
    provingGrounds = {},
    crystalScar = {
      {
        name = "Heal",
        objectName = "OdinShieldRelic",
        respawn = 30,
        objects = {},
      },
    },
    howlingAbyss = {},
  }

  inhibitors = {}

  function addCampCreepAltar(object)
    if object ~= nil and object.name ~= nil then
      if object.name == "Order_Inhibit_Gem.troy" or object.name == "Chaos_Inhibit_Gem.troy" then
        table.insert(inhibitors, { object = object, destroyed = false, lefttime = 0, x = object.x, y = object.y, z = object.z, minimap = GetMinimap(object), textTick = 0 })
        return
      elseif object.name == "Order_Inhibit_Crystal_Shatter.troy" or object.name == "Chaos_Inhibit_Crystal_Shatter.troy" then
        for i,inhibitor in pairs(inhibitors) do
          if GetDistance(inhibitor, object) < 200 then
            local tick = GetTickCount()
            inhibitor.dtime = tick
            inhibitor.rtime = tick + 240000
            inhibitor.ltime = 240000
            inhibitor.destroyed = true
          end
        end
        return
      end
      for i,monster in pairs(monsters[mapName]) do
        for j,camp in pairs(monster.camps) do
          if camp.name == object.name then
            camp.object = object
            return
          end
          if object.type == "obj_AI_Minion" then
            for k,creepPack in ipairs(camp.creeps) do
              for l,creep in ipairs(creepPack) do
                if object.name == creep.name then
                  creep.object = object
                  return
                end
              end
            end
          end
        end
      end
      for i,altar in pairs(altars[mapName]) do
        if altar.objectName == object.name then
          altar.object = object
          altar.textTick = 0
          altar.minimap = GetMinimap(object)
        end
        if altar.locked then
          for j,lockName in pairs(altar.unlockNames) do
            if lockName == object.name then
              altar.locked = false
              return
            end
          end
        else
          for j,lockName in pairs(altar.lockNames) do
            if lockName == object.name then
              altar.drawColor = 0
              altar.drawText = ""
              altar.locked = true
              altar.advised = false
              altar.advisedBefore = false
              return
            end
          end
        end
      end
      for i,relic in pairs(relics[mapName]) do
        if relic.precenceObject == object.name then
          relic.object = object
          relic.textTick = 0
          relic.locked = false
          return
        end
      end
      for i,heal in pairs(heals[mapName]) do
        if heal.objectName == object.name then
          for j,healObject in pairs(heal.objects) do
            if (GetDistance(healObject, object) < 50) then
              healObject.object = object
              healObject.found = true
              healObject.locked = false
              return
            end
          end
          local k = #heal.objects + 1
          heals[mapName][i].objects[k] = {found = true, locked = false, object = object, x = object.x, y = object.y, z = object.z, minimap = GetMinimap(object), textTick = 0,}
          return
        end
      end
    end
  end

  function removeCreep(object)
    if object ~= nil and object.type == "obj_AI_Minion" and object.name ~= nil then
      for i,monster in pairs(monsters[mapName]) do
        for j,camp in pairs(monster.camps) do
          for k,creepPack in ipairs(camp.creeps) do
            for l,creep in ipairs(creepPack) do
              if object.name == creep.name then
                creep.object = nil
                return
              end
            end
          end
        end
      end
    end
  end

  function MiniMapTimersOnLoad()
    mapName = GetGame().map.shortName
    if monsters[mapName] == nil then
      mapName = nil
      monsters = nil
      addCampCreepAltar = nil
      removeCreep = nil
      addAltarObject = nil
      return
    else
      startTick = GetGame().tick
      -- CONFIG
      MMTConfig = scriptConfig("Timers 0.2", "minimapTimers")
      MMTConfig:addParam("pingOnRespawn", "Ping on respawn", SCRIPT_PARAM_ONOFF, false) -- ping location on respawn
      MMTConfig:addParam("pingOnRespawnBefore", "Ping before respawn", SCRIPT_PARAM_ONOFF, false) -- ping location before respawn
      MMTConfig:addParam("textOnRespawn", "Chat on respawn", SCRIPT_PARAM_ONOFF, true) -- print chat text on respawn
      MMTConfig:addParam("textOnRespawnBefore", "Chat before respawn", SCRIPT_PARAM_ONOFF, true) -- print chat text before respawn
      MMTConfig:addParam("adviceTheirMonsters", "Advice enemy monster", SCRIPT_PARAM_ONOFF, true) -- advice enemy monster, or just our monsters
      MMTConfig:addParam("adviceBefore", "Advice Time", SCRIPT_PARAM_SLICE, 20, 1, 40, 0) -- time in second to advice before monster respawn
      MMTConfig:addParam("textOnMap", "Text on map", SCRIPT_PARAM_ONOFF, true) -- time in second on map
      for i,monster in pairs(monsters[mapName]) do
        monster.isSeen = false
        for j,camp in pairs(monster.camps) do
          camp.enemyTeam = (camp.team == TEAM_ENEMY)
          camp.textTick = 0
          camp.status = 0
          camp.drawText = ""
          camp.drawColor = 0xFF00FF00
        end
      end
      for i = 1, objManager.maxObjects do
        local object = objManager:getObject(i)
        if object ~= nil then
          addCampCreepAltar(object)
        end
      end
      AddCreateObjCallback(addCampCreepAltar)
      AddDeleteObjCallback(removeCreep)
    end
  end
  function MiniMapTimersOnTick()
    if GetGame().isOver then return end
    local GameTime = (GetTickCount()-startTick) / 1000
    local monsterCount = 0
    for i,monster in pairs(monsters[mapName]) do
      for j,camp in pairs(monster.camps) do
        local campStatus = 0
        for k,creepPack in ipairs(camp.creeps) do
          for l,creep in ipairs(creepPack) do
            if creep.object ~= nil and creep.object.valid and creep.object.dead == false then
              if l == 1 then
                campStatus = 1
              elseif campStatus ~= 1 then
                campStatus = 2
              end
            end
          end
        end
        --[[  Not used until camp.showOnMinimap work
        if (camp.object and camp.object.showOnMinimap == 1) then
        -- camp is here
        if campStatus == 0 then campStatus = 3 end
        elseif camp.status == 3 then            -- empty not seen when killed
        campStatus = 5
        elseif campStatus == 0 and (camp.status == 1 or camp.status == 2) then
        campStatus = 4
        camp.deathTick = tick
        end
        ]]
        -- temp fix until camp.showOnMinimap work
        -- not so good
        if camp.object ~= nil and camp.object.valid then
          camp.minimap = GetMinimap(camp.object)
          if campStatus == 0 then
            if (camp.status == 1 or camp.status == 2) then
              campStatus = 4
              camp.advisedBefore = false
              camp.advised = false
              camp.respawnTime = math.floor(GameTime) + monster.respawn
              if monster.name == "dragon" or monster.name == "baron" then
                camp.respawnText = TimerText(camp.respawnTime)..
                (monster.name == "baron" and " baron" or " d")
              elseif monster.name == "blue" or monster.name == "red" then
                camp.respawnText = TimerText(camp.respawnTime)..
                (camp.enemyTeam and " t" or " o")..(monster.name == "red" and "r" or "b")
              else
                camp.respawnText = (camp.enemyTeam and "Their " or "Our ")..
                monster.name.." respawn at "..TimerText(camp.respawnTime)
              end
            elseif (camp.status == 4) then
              campStatus = 4
            else
              campStatus = 3
            end
          end
        elseif camp.pos ~= nil then
          camp.minimap = GetMinimap(camp.pos)
          if (GameTime < monster.spawn) then
            campStatus = 4
            camp.advisedBefore = true
            camp.advised = true
            camp.respawnTime = monster.spawn
            camp.respawnText = (camp.enemyTeam and "Their " or "Our ")..monster.name.." spawn at "..TimerText(camp.respawnTime)
          end
        end
        if camp.status ~= campStatus or campStatus == 4 then
          if campStatus ~= 0 then
            if monster.isSeen == false then monster.isSeen = true end
            camp.status = campStatus
          end
          if camp.status == 1 then        -- ready
            camp.drawText = "ready"
            camp.drawColor = 0xFF00FF00
          elseif camp.status == 2 then      -- ready, master creeps dead
            camp.drawText = "stolen"
            camp.drawColor = 0xFFFF0000
          elseif camp.status == 3 then      -- ready, not creeps shown
            camp.drawText = "   ?"
            camp.drawColor = 0xFF00FF00
          elseif camp.status == 4 then      -- empty from creeps kill
            local secondLeft = math.ceil(math.max(0, camp.respawnTime - GameTime))
            if monster.advise == true and (MMTConfig.adviceTheirMonsters == true or camp.enemyTeam == false) then
              if secondLeft == 0 and camp.advised == false then
                camp.advised = true
                if MMTConfig.textOnRespawn then PrintChat("<font color='#00FFCC'>"..(camp.enemyTeam and "Their " or "Our ")..monster.name.."</font><font color='#FFAA00'> has respawned</font>") end
                if MMTConfig.pingOnRespawn then PingSignal(PING_FALLBACK,camp.object.x,camp.object.y,camp.object.z,2) end
              elseif secondLeft <= MMTConfig.adviceBefore and camp.advisedBefore == false then
                camp.advisedBefore = true
                if MMTConfig.textOnRespawnBefore then PrintChat("<font color='#00FFCC'>"..(camp.enemyTeam and "Their " or "Our ")..monster.name.."</font><font color='#FFAA00'> respawns in </font><font color='#00FFCC'>"..secondLeft.." sec</font>") end
                if MMTConfig.pingOnRespawnBefore then PingSignal(PING_FALLBACK,camp.object.x,camp.object.y,camp.object.z,2) end
              end
            end
            -- temp fix until camp.showOnMinimap work
            if secondLeft == 0 then
              camp.status = 0
            end
            camp.drawText = " "..TimerText(secondLeft)
            camp.drawColor = 0xFFFFFF00
          elseif camp.status == 5 then      -- camp found empty (not using yet)
            camp.drawText = "   -"
            camp.drawColor = 0xFFFF0000
          end
        end
        -- shift click
        if IsKeyDown(16) and camp.status == 4 then
          camp.drawText = " "..(camp.respawnTime ~= nil and TimerText(camp.respawnTime) or "")
          camp.textUnder = (CursorIsUnder(camp.minimap.x - 9, camp.minimap.y - 5, 20, 8))
        else
          camp.textUnder = false
        end
        if MMTConfig.textOnMap and camp.status == 4 and camp.object and camp.object.valid and camp.textTick < GetTickCount() and camp.floatText ~= camp.drawText then
          camp.floatText = camp.drawText
          camp.textTick = GetTickCount() + 1000
          PrintFloatText(camp.object,6,camp.floatText)
        end
      end
    end

    -- altars
    for i,altar in pairs(altars[mapName]) do
      if altar.object and altar.object.valid then
        if altar.locked then
          if GameTime < altar.spawn then
            altar.secondLeft = math.ceil(math.max(0, altar.spawn - GameTime))
          else
            local tmpTime = ((altar.object.mana > 39600) and (altar.object.mana - 39900) / 20100 or (39600 - altar.object.mana) / 20100)
            altar.secondLeft = math.ceil(math.max(0, tmpTime * altar.respawn))
          end
          altar.unlockTime = math.ceil(GameTime + altar.secondLeft)
          altar.unlockText = altar.name.." unlock at "..TimerText(altar.unlockTime)
          altar.drawColor = 0xFFFFFF00
          if altar.advise == true then
            if altar.secondLeft == 0 and altar.advised == false then
              altar.advised = true
              if MMTConfig.textOnRespawn then PrintChat("<font color='#00FFCC'>"..altar.name.."</font><font color='#FFAA00'> is unlocked</font>") end
              if MMTConfig.pingOnRespawn then PingSignal(PING_FALLBACK,altar.object.x,altar.object.y,altar.object.z,2) end
            elseif altar.secondLeft <= MMTConfig.adviceBefore and altar.advisedBefore == false then
              altar.advisedBefore = true
              if MMTConfig.textOnRespawnBefore then PrintChat("<font color='#00FFCC'>"..altar.name.."</font><font color='#FFAA00'> will unlock in </font><font color='#00FFCC'>"..altar.secondLeft.." sec</font>") end
              if MMTConfig.pingOnRespawnBefore then PingSignal(PING_FALLBACK,altar.object.x,altar.object.y,altar.object.z,2) end
            end
          end
          -- shift click
          if IsKeyDown(16) then
            altar.drawText = " "..(altar.unlockTime ~= nil and TimerText(altar.unlockTime) or "")
            altar.textUnder = (CursorIsUnder(altar.minimap.x - 9, altar.minimap.y - 5, 20, 8))
          else
            altar.drawText = " "..(altar.secondLeft ~= nil and TimerText(altar.secondLeft) or "")
            altar.textUnder = false
          end
          if MMTConfig.textOnMap and altar.object and altar.object.valid and altar.textTick < GetTickCount() and altar.floatText ~= altar.drawText then
            altar.floatText = altar.drawText
            altar.textTick = GetTickCount() + 1000
            PrintFloatText(altar.object,6,altar.floatText)
          end
        end
      end
    end

    -- relics
    for i,relic in pairs(relics[mapName]) do
      if (not relic.locked and (not relic.object or not relic.object.valid or relic.dead)) then
        if GameTime < relic.spawn then
          relic.unlockTime = relic.spawn - GameTime
        else
          relic.unlockTime = math.ceil(GameTime + relic.respawn)
        end
        relic.advised = false
        relic.advisedBefore = false
        relic.drawText = ""
        relic.unlockText = relic.name.." respawn at "..TimerText(relic.unlockTime)
        relic.drawColor = 4288610048
        --FF9EFF00
        relic.minimap = GetMinimap(relic.pos)
        relic.locked = true
      end
      if relic.locked then
        relic.secondLeft = math.ceil(math.max(0, relic.unlockTime - GameTime))
        if relic.advise == true then
          if relic.secondLeft == 0 and relic.advised == false then
            relic.advised = true
            if MMTConfig.textOnRespawn then PrintChat("<font color='#00FFCC'>"..relic.name.."</font><font color='#FFAA00'> has respawned</font>") end
            if MMTConfig.pingOnRespawn then PingSignal(PING_FALLBACK,relic.pos.x,relic.pos.y,relic.pos.z,2) end
          elseif relic.secondLeft <= MMTConfig.adviceBefore and relic.advisedBefore == false then
            relic.advisedBefore = true
            if MMTConfig.textOnRespawnBefore then PrintChat("<font color='#00FFCC'>"..relic.name.."</font><font color='#FFAA00'> respawns in </font><font color='#00FFCC'>"..relic.secondLeft.." sec</font>") end
            if MMTConfig.pingOnRespawnBefore then PingSignal(PING_FALLBACK,relic.pos.x,relic.pos.y,relic.pos.z,2) end
          end
        end
        -- shift click
        if IsKeyDown(16) then
          relic.drawText = " "..(relic.unlockTime ~= nil and TimerText(relic.unlockTime) or "")
          relic.textUnder = (CursorIsUnder(relic.minimap.x - 9, relic.minimap.y - 5, 20, 8))
        else
          relic.drawText = " "..(relic.secondLeft ~= nil and TimerText(relic.secondLeft) or "")
          relic.textUnder = false
        end
      end
    end

    for i,heal in pairs(heals[mapName]) do
      for j,healObject in pairs(heal.objects) do
        if (not healObject.locked and healObject.found and (not healObject.object or not healObject.object.valid or healObject.object.dead)) then
          healObject.drawColor = 0xFF00FF04
          healObject.unlockTime = math.ceil(GameTime + heal.respawn)
          healObject.drawText = ""
          healObject.found = false
          healObject.locked = true
        end
        if healObject.locked then
          -- shift click
          local secondLeft = math.ceil(math.max(0, healObject.unlockTime - GameTime))
          if IsKeyDown(16) then
            healObject.drawText = " "..(healObject.unlockTime ~= nil and TimerText(healObject.unlockTime) or "")
            healObject.textUnder = (CursorIsUnder(healObject.minimap.x - 9, healObject.minimap.y - 5, 20, 8))
          else
            healObject.drawText = " "..(secondLeft ~= nil and TimerText(secondLeft) or "")
            healObject.textUnder = false
          end
          if secondLeft == 0 then healObject.locked = false end
        end
      end
    end
    -- inhib
    for i,inhibitor in pairs(inhibitors) do
      if inhibitor.destroyed then
        local tick = GetTickCount()
        if inhibitor.rtime < tick then
          inhibitor.destroyed = false
        else
          inhibitor.ltime = (inhibitor.rtime - GetTickCount()) / 1000;
          inhibitor.drawText = TimerText(inhibitor.ltime)
          --inhibitor.drawText = (IsKeyDown(16) and TimerText(inhibitor.rtime) or TimerText(inhibitor.rtime))
          if MMTConfig.textOnMap and inhibitor.textTick < tick then
            inhibitor.textTick = tick + 1000
            PrintFloatText(inhibitor.object,6,inhibitor.drawText)
          end
        end
      end
    end
  end

  function MiniMapTimersOnDraw()
    if GetGame().isOver then return end
    for i,monster in pairs(monsters[mapName]) do
      if monster.isSeen == true then
        for j,camp in pairs(monster.camps) do
          if camp.status == 2 then
            DrawText("X",16,camp.minimap.x - 4, camp.minimap.y - 5, camp.drawColor)
          elseif camp.status == 4 then
            DrawText(camp.drawText,16,camp.minimap.x - 9, camp.minimap.y - 5, camp.drawColor)
          end
        end
      end
    end
    for i,altar in pairs(altars[mapName]) do
      if altar.locked then
        DrawText(altar.drawText,16,altar.minimap.x - 9, altar.minimap.y - 5, altar.drawColor)
      end
    end
    for i,relic in pairs(relics[mapName]) do
      if relic.locked then
        DrawText(relic.drawText,16,relic.minimap.x - 9, relic.minimap.y - 5, relic.drawColor)
      end
    end
    for i,heal in pairs(heals[mapName]) do
      for j,healObject in pairs(heal.objects) do
        if healObject.locked then
          DrawText(healObject.drawText,16,healObject.minimap.x - 9, healObject.minimap.y - 5, healObject.drawColor)
        end
      end
    end
    for i,inhibitor in pairs(inhibitors) do
      if inhibitor.destroyed == true then
        DrawText(inhibitor.drawText,16,inhibitor.minimap.x - 9, inhibitor.minimap.y - 5, 0xFFFFFF00)
      end
    end
  end

  function MiniMapTimersOnWndMsg(msg,key)
    if msg == WM_LBUTTONDOWN and IsKeyDown(16) then
      for i,monster in pairs(monsters[mapName]) do
        if monster.isSeen == true then
          if monster.iconUnder then
            monster.advise = not monster.advise
            break
          else
            for j,camp in pairs(monster.camps) do
              if camp.textUnder then
                if camp.respawnText ~= nil then SendChat(""..camp.respawnText) end
                break
              end
            end
          end
        end
      end
      for i,altar in pairs(altars[mapName]) do
        if altar.locked and altar.textUnder then
          if altar.unlockText ~= nil then SendChat(""..altar.unlockText) end
          break
        end
      end
    end
  end
end

-- ################################################## Move To Right Click #####################################################
--[[

Very simple script that smooths the movement when you hold right mouse butotn down.

    Modded by xkjtx, to fit his needs.. lol

]]


local del = os.clock()

local auto = false


function MyMoveToOnLoad()
    --PrintChat("SmoothMoves Loaded")

    co = scriptConfig("SmoothMove", "smooth")

    co:addParam("smooth", "Smooth RMB movement", SCRIPT_PARAM_ONOFF, true)

    co:addParam("toggle", "Toggle Delay: 3.0s", SCRIPT_PARAM_ONOFF, false)

end

--function moveToCursor()
    
   -- myHero:MoveTo(mousePos.x, mousePos.z)

--end

function MyMoveToOnWndMsg(msg,key)

        if msg == 516 and key == 2 then

            del = os.clock()

            auto = false

        end

        if (co.smooth and key == 2 and msg == 512) or (auto and co.smooth and co.toggle) then

            if ((co.smooth and auto == false and ((os.clock() - del) > 0.2)) or auto) then

                --moveToCursor()
                myHero:MoveTo(mousePos.x, mousePos.z)

            end

            if co.toggle and auto == false and ((os.clock() - del) > 3) then

                auto = true

                PrintFloatText(myHero,0,"Following Cursor")

            end

     end

end

-- ################################################## BUY ME ITEMS made by me xkjtx ##############################################

----------------------------------  --
--[ --- xkjtx's buy script  ]--  --
----------------------------------  --

----------- (num pad)
local HKB = 109 -- (-)-- 2 mana pots
local HKA = 107 -- (+)-- 2 sight wards and 2 health pots
local HK0 = 97 --   1 -- 2 Sight Wards
local HK1 = 98 --   2 -- 2 health pots
local HK2 = 99 --   3 -- Boot of Speed(1st boots) - 2 health pots
local HK3 = 100 --  4 -- Sapphire Crystal (+200 mana) - 2 health pots
local HK4 = 101 --  5 -- Tear of the Goddess
local HK5 = 102 --  6 -- Zeal
local HK6 = 103 --  7 -- Sorcerer's Boots
local HK7 = 104 --  8 -- Catalyst the Protector
local HK8 = 105 --  9 -- Glacial Shroud

function BuyMeItemsOnWndMsg(msg, key)
    if key == HKB and msg == KEY_DOWN then
        BuyItem(2004) -- 2 health pots
        BuyItem(2004)
    elseif key == HKA and msg == KEY_DOWN then
        BuyItem(2044) -- 2 Sight Wards
        BuyItem(2044)
        BuyItem(2003) -- 2 health pots
        BuyItem(2003)
    elseif key == HK0 and msg == KEY_DOWN then
        BuyItem(2044) -- 2 Sight Wards
        BuyItem(2044)
    elseif key == HK1 and msg == KEY_DOWN then
        BuyItem(2003) -- 2 health pots
        BuyItem(2003)
    elseif key == HK2 and msg == KEY_DOWN then
        BuyItem(1001) -- 1st boots
        BuyItem(2003) -- 2 health pots
        BuyItem(2003)
    elseif key == HK3 and msg == KEY_DOWN then
        BuyItem(1027) -- Sapphire Crystal (+200 mana)
        BuyItem(2003) -- 2 health pots
        BuyItem(2003)
    elseif key == HK4 and msg == KEY_DOWN then
        BuyItem(3070) -- Tear of the Goddess
    elseif key == HK5 and msg == KEY_DOWN then
        BuyItem(3086) -- Zeal
    elseif key == HK6 and msg == KEY_DOWN then
        BuyItem(3020) -- Sorcerer's Boots
    elseif key == HK7 and msg == KEY_DOWN then
        BuyItem(3010) -- Catalyst the Protector
    elseif key == HK8 and msg == KEY_DOWN then
        BuyItem(3024) -- Glacial Shroud
--PrintChat("Buy Me Items")
    end
end


-- ################################################## EMOTE SPAMMER ##############################################################
function EmoteJLTOnLoad()
    PreviousEmote = 0
    --PrintChat("<font color='#6e3c99'>Loaded Emote Spammer for, The Insane.</font>")
    --PrintChat("<font color='#6e3c99'>0 = Laugh, 1 = Taunt, 2 = Joke. These can be changed in the menu.</font>")
    EMenu = scriptConfig("Emote Spammer", "Emote Spam")
    EMenu:addParam("Spam", "Emote Spam", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("9"))
    EMenu:addParam("Emote", "Emote To Spam", SCRIPT_PARAM_SLICE, 0, 0, 2, 0) 
    EMenu:permaShow("Spam")
    EMenu:permaShow("Emote")
end
function EmoteJLTOnTick()
    if EMenu.Spam then
        local moveSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
        local moveX = myHero.x + 200*((mousePos.x - myHero.x)/moveSqr)
        local moveZ = myHero.z + 200*((mousePos.z - myHero.z)/moveSqr)
        myHero:MoveTo(moveX, moveZ)
        --player:MoveTo(mousePos.x,mousePos.z)
        if GetTickCount() - PreviousEmote > 1200 then
            if EMenu.Emote == 0 then SendChat("/l")
                PreviousEmote = GetTickCount()
            end
            if EMenu.Emote == 1 then SendChat("/t")
                PreviousEmote = GetTickCount() 
            end
            if EMenu.Emote == 2 then SendChat("/j")
                PreviousEmote = GetTickCount() 
            end
        end
    end
end

-- ################################################# EXP / MINION MARK ###########################################################
local expRange = 1200 -- 1400 seems good for the circle but 1200 seems proper for highlighting and actual range
local minionCircleSize = 75 -- 100 was nice as well
local displayMyCircle = true
local displayCircleMinions = false

local player = GetMyHero()


function notNil(obj)
    if obj ~= nil then
        return true
    else
        return false
    end
end

function isInDistance(minion)
    if player:GetDistance(minion) <= expRange then
        return true
    else
        return false
    end
end

function isEnemyMinion(minion)
    if string.find(minion.name,"Minion_") == 1 and 
            minion.team ~= player.team and 
            minion.dead == false then
        return true
    else
        return false
    end
end

function myCircle()
    DrawCircle(player.x, player.y, player.z, expRange, 0x333333)
end

function minionCircle(minion)
    DrawCircle(minion.x, minion.y, minion.z, minionCircleSize, 0xFFFFFF)
end

-- Wanted to try other ways to mark but WorldToScreen doesn't work currently : (
function myMark()
    myCircle()
end

function minionMark(minion)
    minionCircle(minion)
end

function circleMinions()
    for i = 1, objManager.maxObjects do
        local curObject = objManager:GetObject(i)
        if notNil(curObject) and isEnemyMinion(curObject) and isInDistance(curObject) then
            minionMark(curObject)
        end
    end
end

function ExpMinionMarkOnDraw()
    if displayMyCircle then
        myMark()
    end
    if displayCircleMinions then
        circleMinions()
    end
end


-- ################################################# CHAT SPAMM #################################################################
--GG Spam by The Saint. Special thanks to Broland
--YOLO! Spam by The Saint.
--GLHF by xkjtx
local HK1 = 37 -- Left Arrow (GG)
local HK2 = 39 --   Right Arrow (YOLO!)
local HK3 = 40 -- Down Arrow (Good Luck - Have Fun)

function EmoteSpammOnWndMsg(msg, key )
    if key == HK1 and msg == KEY_DOWN then
        SendChat("/all 聽聽")
        SendChat("/all 聽聽######聽聽聽聽聽聽聽聽######聽聽聽")
        SendChat("/all 聽##聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽 ##聽聽聽聽聽聽聽")
        SendChat("/all 聽##聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽聽##聽聽聽聽聽聽聽")
        SendChat("/all 聽##聽聽聽####聽聽聽聽聽##聽聽聽####")
        SendChat("/all 聽##聽聽聽聽聽聽聽 ##聽聽聽聽聽##聽聽聽聽聽聽聽##")
        SendChat("/all 聽##聽聽聽聽聽聽聽 ##聽聽聽聽聽##聽聽聽聽聽聽聽##")
        SendChat("/all 聽聽######聽聽聽聽聽聽聽聽######聽聽")
    end
    if key == HK2 and msg == KEY_DOWN then
        SendChat("/all 聽聽")
        SendChat("/all #聽聽聽聽##聽聽聽###聽聽聽聽#聽聽聽聽聽聽聽聽聽###聽聽聽聽聽聽##")
        SendChat("/all 聽#聽聽##聽聽#聽聽聽聽##聽聽#聽聽聽聽聽聽聽#聽聽聽聽##聽聽聽聽##")
        SendChat("/all 聽聽###聽聽聽#聽聽聽聽##聽聽#聽聽聽聽聽聽聽#聽聽聽聽##聽聽聽聽##")
        SendChat("/all 聽聽聽#聽聽聽聽聽聽#聽聽聽聽##聽聽#聽聽聽聽聽聽聽#聽聽聽聽##聽聽聽聽")
        SendChat("/all 聽聽聽#聽聽聽聽聽聽#聽聽聽聽##聽聽#聽聽聽聽聽聽聽#聽聽聽聽##聽聽聽聽##")
        SendChat("/all 聽聽聽#聽聽聽聽聽聽聽聽###聽聽聽聽####聽聽###聽聽聽聽聽聽##")
        SendChat("/all 聽聽")
    end
    if key == HK3 and msg == KEY_DOWN then
        SendChat("/all 聽聽")
        SendChat("/all    _     _      _     _     _ ")
        SendChat("/all   ().-.()   GL - HF   ().-.()  ")
        SendChat("/all    _     _      _     _     _ ")
        SendChat("/all 聽聽")
    end
end

-- ############################################# AutoLevel ##############################################
--[[
        Auto Level Spells
        v1.08
 
        Levels the abilities of every single Champion
        Written by grey
 
        Dont forget to check the abilitySequence of your champion
        Thanks to Zynox and PedobearIGER who gave me some ideas and tipps.
        Some of the default ability sequences are from mobafire, some from solomid (thx@crazy, Remus3 and phadeb) :)
]]

--[[ 		Globals		]]
local abilitySequence
local qOff, wOff, eOff, rOff = 0,0,0,0

--[[ 		Functions	]]
function AutoLevelOnTick()
    local qL, wL, eL, rL = player:GetSpellData(_Q).level + qOff, player:GetSpellData(_W).level + wOff, player:GetSpellData(_E).level + eOff, player:GetSpellData(_R).level + rOff
    if qL + wL + eL + rL < player.level then
        local spellSlot = { SPELL_1, SPELL_2, SPELL_3, SPELL_4, }
        local level = { 0, 0, 0, 0 }
        for i = 1, player.level, 1 do
            level[abilitySequence[i]] = level[abilitySequence[i]] + 1
        end
        for i, v in ipairs({ qL, wL, eL, rL }) do
            if v < level[i] then LevelSpell(spellSlot[i]) end
        end
    end
end

function AutoLevelOnLoad()
    local champ = player.charName
    --[[
     In this section you can adjust the ability sequence of champions.

     To turn off the script for a particular champion,
     you have to comment out this line with two dashes.
     ]]
    if champ == "Aatrox" then           abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Jinx" then         abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 2, 2, }
    elseif champ == "Ahri" then         abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 2, 2, }
    elseif champ == "Akali" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Alistar" then      abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Amumu" then        abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Anivia" then       abilitySequence = { 1, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 1, 1, 1, 2, 4, 2, 2, }
    elseif champ == "Annie" then        abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Ashe" then         abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Blitzcrank" then   abilitySequence = { 1, 3, 2, 3, 2, 4, 3, 2, 3, 2, 4, 3, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Brand" then        abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Caitlyn" then      abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Cassiopeia" then   abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Chogath" then      abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Corki" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
    elseif champ == "Darius" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Diana" then        abilitySequence = { 2, 1, 2, 3, 1, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "DrMundo" then      abilitySequence = { 2, 1, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Draven" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Elise" then        abilitySequence = { 2, 1, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, } rOff = -1
    elseif champ == "Evelynn" then      abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Ezreal" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 3, 1, 2, 4, 3, 2, 3, 2, 4, 3, 2, }
    elseif champ == "FiddleSticks" then abilitySequence = { 3, 2, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Fiora" then        abilitySequence = { 2, 1, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Fizz" then         abilitySequence = { 3, 1, 2, 1, 2, 4, 1, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Galio" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 3, 2, 2, 4, 3, 3, }
    elseif champ == "Gangplank" then    abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Garen" then        abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Gragas" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Graves" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
    elseif champ == "Hecarim" then      abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Heimerdinger" then abilitySequence = { 1, 2, 2, 1, 1, 4, 3, 2, 2, 2, 4, 1, 1, 3, 3, 4, 1, 1, }
    elseif champ == "Irelia" then       abilitySequence = { 3, 1, 2, 2, 2, 4, 2, 3, 2, 3, 4, 1, 1, 3, 1, 4, 3, 1, }
    elseif champ == "Janna" then        abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 2, 3, 2, 1, 2, 2, 1, 1, 1, 4, 4, }
    elseif champ == "JarvanIV" then     abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 2, 1, 4, 3, 3, 3, 2, 4, 2, 2, }
    elseif champ == "Jax" then          abilitySequence = { 3, 2, 1, 2, 2, 4, 2, 3, 2, 3, 4, 1, 3, 1, 1, 4, 3, 1, }
    elseif champ == "Jayce" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, } rOff = -1
    elseif champ == "Karma" then        abilitySequence = { 1, 3, 1, 2, 3, 1, 3, 1, 3, 1, 3, 1, 3, 2, 2, 2, 2, 2, }
    elseif champ == "Karthus" then      abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 1, 3, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Kassadin" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Katarina" then     abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
    elseif champ == "Kayle" then        abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Kennen" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Khazix" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "KogMaw" then       abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Leblanc" then      abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "LeeSin" then       abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Leona" then        abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Lissandra" then    abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Lucian" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Lulu" then         abilitySequence = { 3, 2, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Lux" then          abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Malphite" then     abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
    elseif champ == "Malzahar" then     abilitySequence = { 1, 3, 3, 2, 3, 4, 1, 3, 1, 3, 4, 2, 1, 2, 1, 4, 2, 2, }
    elseif champ == "Maokai" then       abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "MasterYi" then     abilitySequence = { 3, 1, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 2, 2, 2, 4, 2, 2, }
    elseif champ == "MissFortune" then  abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "MonkeyKing" then   abilitySequence = { 3, 1, 2, 1, 1, 4, 3, 1, 3, 1, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Mordekaiser" then  abilitySequence = { 3, 1, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Morgana" then      abilitySequence = { 1, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Nami" then         abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 2, 3, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Nasus" then        abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Nautilus" then     abilitySequence = { 2, 3, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Nidalee" then      abilitySequence = { 2, 3, 1, 3, 1, 4, 3, 2, 3, 1, 4, 3, 1, 1, 2, 4, 2, 2, }
    elseif champ == "Nocturne" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Nunu" then         abilitySequence = { 1, 3, 1, 2, 1, 4, 3, 1, 3, 1, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Olaf" then         abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Orianna" then      abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Pantheon" then     abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 2, 3, 2, 4, 2, 2, }
    elseif champ == "Poppy" then        abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 2, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, }
    elseif champ == "Quinn" then        abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Rammus" then       abilitySequence = { 1, 2, 3, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Renekton" then     abilitySequence = { 2, 1, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Rengar" then       abilitySequence = { 1, 3, 2, 1, 1, 4, 2, 1, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Riven" then        abilitySequence = { 1, 2, 3, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Rumble" then       abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Ryze" then         abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Sejuani" then      abilitySequence = { 2, 1, 3, 3, 2, 4, 3, 2, 3, 3, 4, 2, 1, 2, 1, 4, 1, 1, }
    elseif champ == "Shaco" then        abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 2, 4, 2, 2, 1, 1, 4, 1, 1, }
    elseif champ == "Shen" then         abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Shyvana" then      abilitySequence = { 2, 1, 2, 3, 2, 4, 2, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, }
    elseif champ == "Singed" then       abilitySequence = { 1, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 3, 2, 3, 2, 4, 2, 3, }
    elseif champ == "Sion" then         abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Sivir" then        abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 3, 2, 3, 4, 3, 3, }
    elseif champ == "Skarner" then      abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Sona" then         abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Soraka" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
    elseif champ == "Swain" then        abilitySequence = { 2, 3, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Syndra" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Talon" then        abilitySequence = { 2, 3, 1, 2, 2, 4, 2, 1, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Taric" then        abilitySequence = { 3, 2, 1, 2, 2, 4, 1, 2, 2, 1, 4, 1, 1, 3, 3, 4, 3, 3, }
    elseif champ == "Teemo" then        abilitySequence = { 1, 3, 2, 3, 3, 4, 1, 3, 1, 3, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Thresh" then       abilitySequence = { 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 4, 3, 3, 1, 1, 4, 1, 1, }
    elseif champ == "Tristana" then     abilitySequence = { 3, 2, 2, 3, 2, 4, 2, 1, 2, 1, 4, 1, 1, 1, 3, 4, 3, 3, }
    elseif champ == "Trundle" then      abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
    elseif champ == "Tryndamere" then   abilitySequence = { 3, 1, 2, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "TwistedFate" then  abilitySequence = { 2, 1, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Twitch" then       abilitySequence = { 1, 3, 3, 2, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 1, 2, 2, }
    elseif champ == "Udyr" then         abilitySequence = { 4, 2, 3, 4, 4, 2, 4, 2, 4, 2, 2, 1, 3, 3, 3, 3, 1, 1, }
    elseif champ == "Urgot" then        abilitySequence = { 3, 1, 1, 2, 1, 4, 1, 2, 1, 3, 4, 2, 3, 2, 3, 4, 2, 3, }
    elseif champ == "Varus" then        abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Vayne" then        abilitySequence = { 1, 3, 2, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Veigar" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 2, 2, 2, 2, 4, 3, 1, 1, 3, 4, 3, 3, }
    elseif champ == "Vi" then           abilitySequence = { 3, 1, 2, 3, 3, 4, 3, 1, 3, 1, 4, 1, 1, 2, 2, 4, 2, 2, }
    elseif champ == "Viktor" then       abilitySequence = { 3, 2, 3, 1, 3, 4, 3, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, }
    elseif champ == "Vladimir" then     abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Volibear" then     abilitySequence = { 2, 3, 2, 1, 2, 4, 3, 2, 1, 2, 4, 3, 1, 3, 1, 4, 3, 1, }
    elseif champ == "Warwick" then      abilitySequence = { 2, 1, 1, 2, 1, 4, 1, 3, 1, 3, 4, 3, 3, 3, 2, 4, 2, 2, }
    elseif champ == "Xerath" then       abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "XinZhao" then      abilitySequence = { 1, 3, 1, 2, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Yorick" then       abilitySequence = { 2, 3, 1, 3, 3, 4, 3, 2, 3, 1, 4, 2, 1, 2, 1, 4, 2, 1, }
    elseif champ == "Zac" then          abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Zed" then          abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Ziggs" then        abilitySequence = { 1, 2, 3, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    elseif champ == "Zilean" then       abilitySequence = { 1, 2, 1, 3, 1, 4, 1, 2, 1, 2, 4, 2, 2, 3, 3, 4, 3, 3, }
    elseif champ == "Zyra" then         abilitySequence = { 3, 2, 1, 1, 1, 4, 1, 3, 1, 3, 4, 3, 3, 2, 2, 4, 2, 2, }
    else PrintChat(string.format(" >> AutoLevelSpell Script disabled for %s", champ))
    end
    if abilitySequence and #abilitySequence == 18 then
        --PrintChat(" >> AutoLevelSpell Script loaded!")
    else
        PrintChat(" >> AutoLevelSpell Ability Sequence Error")
        AutoLevelExhOnTick = function() end
        return
    end
end

-- ############################################# LOW AWARENESS ##############################################

local alertActive = true
local championTable = {}
local playerTimer = {}
local playerDrawer = {}
local player = GetMyHero()
--showErrorsInChat = false
--showErrorTraceInChat = false

nextTick = 0 
function LowAwarenessOnTick()   
    if nextTick > GetTickCount() then return end   
    nextTick = GetTickCount() + 250 --(100 is the delay) 	
    local tick = GetTickCount()
    if alertActive == true then
        for i = 1, heroManager.iCount, 1 do
        local object = heroManager:getHero(i)
            if object.team ~= player.team and object.dead == false then
                if object.visible == true and player:GetDistance(object) < 2500 then
                    if playerTimer[i] == nil then
                        -- MASS PING ALERTS --
                        --PrintChat(string.format("<font color='#FF0000'> >> ALERT: %s</font>", object.charName))
                        --PingSignal(PING_FALLBACK,object.x,object.y,object.z,2)
                        --PingSignal(PING_FALLBACK,object.x,object.y,object.z,2)
                        --PingSignal(PING_FALLBACK,object.x,object.y,object.z,2)
                        table.insert(championTable, object )
                        playerDrawer[i] = tick
                    end
                    playerTimer[ i ] = tick
                    if (tick - playerDrawer[i]) > 5000 then
                        for ii, tableObject in ipairs(championTable) do
                            if tableObject.charName == object.charName then
                                table.remove(championTable, ii)
                            end
                        end
                    end
                else
                    if playerTimer[i] ~= nil and (tick - playerTimer[i]) > 10000 then
                        playerTimer[i] = nil
                        for ii, tableObject in ipairs(championTable) do
                            if tableObject.charName == object.charName then
                                table.remove(championTable, ii)
                            end
                        end
                    end
                end
            end
        end
    end
end



function LowAwarenessOnDraw()
    for i,tableObject in ipairs(championTable) do
       if tableObject.visible and tableObject.dead == false and tableObject.team ~= player.team then
			for t = 0, 1 do	
				DrawCircle(tableObject.x, tableObject.y, tableObject.z, 1250 + t*0.25, 0xFFFF0000)
			end
       end
    end
end

-- ############################################# TOWER RANGE ################################################

--[[
	Script: Tower Range v0.4
	Author: SurfaceS

	v0.1 	initial release -- thanks Shoot for idea
	V0.1b	added mode 4 -- thanks hellspan
	v0.1c	added gameOver to stop script at end
	v0.2	BoL Studio version
	v0.3	use the scriptConfig
	v0.4    Tower ranges now show ally and enemy tower range when you are in range
    v0.4a   Tower range changed in S3
]]

local towerRange = {
	turrets = {},
	typeText = {"OFF", "ON (enemy close)", "ON (enemy)", "ON (all)", "ON (all close)"},
	--[[         Config         ]]
	turretRange = 975,	 				-- 950-S3 updates to 975
	fountainRange = 1050,	 			-- 1050
	allyTurretColor = 0x003300, 		-- Green color
	enemyTurretColor = 0xFF0000, 		-- Red color
	activeType = 4,						-- 0 Off, 1 Close enemy towers, 2 All enemy towers, 3 Show all, 4 Show all close
	tickUpdate = 1000,
	nextUpdate = 0,
}

function towerRange.checkTurretState()
	if towerRange.activeType > 0 then
		for name, turret in pairs(towerRange.turrets) do
			turret.active = false
		end
		for i = 1, objManager.maxObjects do
			local object = objManager:getObject(i)
			if object ~= nil and object.type == "obj_AI_Turret" then
				local name = object.name
				if towerRange.turrets[name] ~= nil then towerRange.turrets[name].active = true end
			end
		end
		for name, turret in pairs(towerRange.turrets) do
			if turret.active == false then towerRange.turrets[name] = nil end
		end
	end
end

function TowerRangeOnDraw()
	if GetGame().isOver then return end
	if towerRange.activeType > 0 then
		for name, turret in pairs(towerRange.turrets) do
			if turret ~= nil then
				if (towerRange.activeType == 1 and turret.team ~= player.team and player.dead == false and GetDistance(turret) < 2000)
				or (towerRange.activeType == 2 and turret.team ~= player.team)
				or (towerRange.activeType == 3)
				or (towerRange.activeType == 4 and player.dead == false and GetDistance(turret) < 2000) then
					DrawCircle(turret.x, turret.y, turret.z, turret.range, turret.color)
				end
			end
		end
	end
end
function TowerRangeOnTick()
end
function TowerRangeOnDeleteObj(object)
	if object ~= nil and object.type == "obj_AI_Turret" then
		for name, turret in pairs(towerRange.turrets) do
			if name == object.name then
				towerRange.turrets[name] = nil
				return
			end
		end
	end
end
function TowerRangeOnLoad()
	gameState = GetGame()
	for i = 1, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object ~= nil and object.type == "obj_AI_Turret" then
			local turretName = object.name
			towerRange.turrets[turretName] = {
				object = object,
				team = object.team,
				color = (object.team == player.team and towerRange.allyTurretColor or towerRange.enemyTurretColor),
				range = towerRange.turretRange,
				x = object.x,
				y = object.y,
				z = object.z,
				active = false,
			}
			if turretName == "Turret_OrderTurretShrine_A" or turretName == "Turret_ChaosTurretShrine_A" then
				towerRange.turrets[turretName].range = towerRange.fountainRange
				for j = 1, objManager.maxObjects do
					local object2 = objManager:getObject(j)
					if object2 ~= nil and object2.type == "obj_SpawnPoint" and GetDistance(object, object2) < 1000 then
						towerRange.turrets[turretName].x = object2.x
						towerRange.turrets[turretName].z = object2.z
					elseif object2 ~= nil and object2.type == "obj_HQ" and object2.team == object.team then
						towerRange.turrets[turretName].y = object2.y
					end
				end
			end
		end
	end
end

-- ############################################# MINION MARKER ################################################

--[[function MinionMarkerOnLoad()
    enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC)

end

function MinionMarkerOnTick()
    enemyMinions:update()
end

function MinionMarkerOnDraw() 
    for index, minionObject in pairs(enemyMinions.objects) do
		if minionObject ~= nil and minionObject.valid and myHero:GetDistance(minionObject) ~= nil and myHero:GetDistance(minionObject) < 2000 and minionObject.health ~= nil and minionObject.health <= myHero:CalcDamage(minionObject, myHero.addDamage+myHero.damage) and minionObject.visible ~= nil and minionObject.visible == true then
			for g = 0, 6 do
				DrawCircle(minionObject.x, minionObject.y, minionObject.z, 80 + g,255255255)
			end
        end
    end
end]]

    --[[
            simpleMinionMarker
            v1.1
            Written by Kilua
    ]]
     
    function MinionMarkerOnLoad()
            minionTable = {}
            for i = 0, objManager.maxObjects do
                    local obj = objManager:GetObject(i)
                    if obj ~= nil and obj.type ~= nil and obj.type == "obj_AI_Minion" then
                            table.insert(minionTable, obj)
                    end
            end
            --PrintChat(" >> simple Minion Marker Loaded.")
    end
     
    function MinionMarkerOnDraw()
            for i,minionObject in ipairs(minionTable) do
                if minionObject.dead == true or minionObject.team == myHero.team then
                    table.remove(minionTable, i)
                    i = i - 1
                elseif minionObject ~= nil and myHero:GetDistance(minionObject) ~= nil and myHero:GetDistance(minionObject) < 1500 and minionObject.health ~= nil and minionObject.health <= myHero:CalcDamage(minionObject, myHero.addDamage+myHero.damage) and minionObject.visible ~= nil and minionObject.visible == true then
                for g = 0, 6 do
                        DrawCircle(minionObject.x, minionObject.y, minionObject.z,80 + g,255255255)
                end
            end
        end
    end
     
     
    function MinionMarkerOnCreateObj(object)
            if object ~= nil and object.type ~= nil and object.type == "obj_AI_Minion" then table.insert(minionTable, object) end
    end

-- ############################################# ENEMY RANGE ################################################

-- Simple Player and Enemy Range Circles
-- by heist
-- v1.0
-- Initial release
-- v1.0.1
-- Adjusted AA range to be more accurate
-- Adopted to studio by Mistal

champAux = {}
champ = {
	Ahri = { 975, 0 },
	Akali = { 800, 0 },
	Alistar = { 650, 0 },
	Amumu = { 600, 0 },
	Anivia = { 0, 1100 },
	Annie = { 625, 0 },
	Ashe = { 0, 0 },
	Blitzcrank = { 925, 0 },
	Brand = { 900, 625 },
	Caitlyn = { 0, 0 },
	Cassiopeia = { 700, 850 },
	Chogath = { 0, 700 },
	Corki = { 0, 0 },
	Darius = { 550, 475 }, -- his E and R
	Diana = { 830, 0 }, -- Q and R
	Draven = { 0, 0 }, -- his Ulti is global, his normal range is 550
	Elise = { 1075, 650 },
	DrMundo = { 1000, 0 },
	Evelynn = { 500, 0 },
	Ezreal = { 0, 1100 },
	Fiddlesticks = { 575, 750 },
	Fiora = { 600, 400 },
	Fizz = { 550, 1275 },
	Galio = { 940, 0 },
	Gangplank = { 625, 0 },
	Garen = { 400, 0 },
	Gragas = { 1100, 1050 },
	Graves = { 0, 750 },
	Hecarim = { 175, 0 }, -- Placeholder
	Heimerdinger = { 550, 1000 },
	Irelia = { 650, 425 },
	Janna = { 600, 1100 },
	JarvanIV = { 770, 650 },
	Jax = { 700, 0 },
	Jayce = { 1050, 0 }, -- normal range attack and ulti
	Karma = { 650, 800 },
	Karthus = { 875, 0 },
	Kassadin = { 700, 650 },
	Katarina = { 700, 0 },
	Kayle = { 650, 0 },
	KhaZix = { 900, 1000 },
	Kennen = { 1050, 0 },
	KogMaw = { 710, 0 },
	Leblanc = { 700, 950 },
	LeeSin = { 975, 0 },
	Leona = { 700, 0 },
	Lulu = { 925, 650 },
	Lux = { 1175, 0 },
	Malphite = { 700, 0 },
	Malzahar = { 700, 0 },
	Maokai = { 650, 0 },
	MasterYi = { 600, 0 },
	MissFortune = { 550, 0 },
	MonkeyKing = { 625, 325 },
	Mordekaiser = { 700, 0 },
	Morgana = { 1300, 0 },
	Nami = { 875, 0 },
	Nasus = { 700, 0 },
	Nautilus = { 950, 850 },
	Nidalee = { 525, 300 },
	Nocturne = { 2000, 425 },
	Nunu = { 550, 0 },
	Olaf = { 1000, 0 },
	Orianna = { 525, 825 },
	Pantheon = { 600, 0 },
	Poppy = { 525, 0 },
	Rammus = { 325, 0 },
	Renekton = { 450, 0 },
	Rengar = { 600, 0 },
	Riven = { 325, 0 },
	Rumble = { 600, 0 },
	Ryze = { 650, 0 },
	Sejuani = { 700, 1150 },
	Shaco = { 625, 0 },
	Shen = { 475, 575 },
	Shyvana = { 1000, 0 },
	Singed = { 125, 0 },
	Sion = { 550, 0 },
	Sivir = { 0, 1000 },
	Skarner = { 350, 0 },
	Sona = { 1000, 0 },
	Soraka = { 725, 0 },
	Swain = { 900, 0 },
	Syndra = { 650, 0 },
	Talon = { 600, 0 },
	Taric = { 625, 0 },
	Teemo = { 680, 0 },
	Tristana = { 900, 0 },
	Trundle = { 1000, 0 },
	Tryndamere = { 660, 0 },
	TwistedFate = { 525, 0 },
	Twitch = { 1200, 550 },
	Udyr = { 0, 0 },
	Urgot = { 1000, 0 },
	Varus = { 1075, 0 },
	Vayne = { 0, 0 },
	Veigar = { 650, 0 },
	Vi = { 700, 600 },
	Viktor = { 625, 0 },
	Vladimir = { 600, 0 },
	Volibear = { 0, 0 },
	Warwick = { 400, 700 },
	Wukong = { 625, 0},
	Xerath = { 1300, 900 },
	XinZhao = { 600, 0 },
	Yorick = { 600, 0 },
	Zed = { 900, 550},
	Ziggs = { 850, 0 },
	Zilean = { 700, 0 },
	Zyra = { 1100, 0 },
}
champAux = champ
heroindex, c = {}, 0
for i = 1, heroManager.iCount do
local h = heroManager:getHero(i)
if h.team ~= player.team then
heroindex[c+1] = i
c = c+1
end
end

function ERangesOnDraw()
for _,v in ipairs(heroindex) do
local h = heroManager:getHero(v)
local t = champAux[h.charName]

if h.visible and not h.dead then
         if h.range > 400 and (t == nil or (h.range + 100 ~= t[1] and h.range + 100 ~= t[2])) then
         DrawCircle(h.x, h.y, h.z,h.range + 100, 0xFF640000)
         end
         if t ~= nil then
         if t[1] > 0 then
                 DrawCircle(h.x, h.y, h.z,t[1], 0xFF006400)
         end
         if t[2] > 0 then
                 DrawCircle(h.x, h.y, h.z,t[2], 0xFF006400)
         end
         end
end
end
end

function PRangesOnDraw()
local h = GetMyHero()
local t = champAux[h.charName]

if h.visible and not h.dead then
         if h.range > 400 and (t == nil or (h.range + 100 ~= t[1] and h.range + 100 ~= t[2])) then
         DrawCircle(h.x, h.y, h.z,h.range + 100, 0xFF640000)
         end
         if t ~= nil then
         if t[1] > 0 then
                 DrawCircle(h.x, h.y, h.z,t[1], 0xFF006400)
         end
         if t[2] > 0 then
                 DrawCircle(h.x, h.y, h.z,t[2], 0xFF006400)
         end
         end
end
end

-- ###############################################################################
-- Awesome Script : Displays attack range colorful!
function AwesomeOnLoad()
    LoadProtectedScript('VjUzEzdFTURpN0NFYN50TGhvRUxAbTNLRXlNeENSZUVMRm1zS0I5DXkA8iVFykAtM8yFOUwkxnJkSAxAbXhLxXjGOUdy7wUNwufzCsbzDTvC+CUEycpt8M6OOUx5jDIkx4YALrCBBTvJswYz4I9Mg+g4CkR5RzgH8G/ED8NncgnBcww4w3hkhskkLbNK4HlNeU7y5cLpAG0zQ8V5xWZG8mVUTEBtN0xFeU0JKhMcID5AaTVLRXk/GCgVAEVITG0zSwIcOT0vAREkIiMIM09NeU15KxsLBw4vFTNPTXlNeSUHFzcpLhkzSEV5TXlGkgoFSEVtM0s2DSgJRnFlRUxAbTO7en1JeUZyCCwiQG4zS0V5TXlGcmFBTEBtXio9eUl8RnJlKCMkCDNIRXlNeUZylfpPQG0zS0V5TTlFcmVFTEBtOwtBc015Rh8MPQ8vAVw5NnlJfkZyZQoiBB9SPEV7TXlGemVFTFVtM0tFeUVlRnJlQ0wAbXZLxXlQeUdzckVJwCpyC0f+zDlEtaQFTs+sMkgI+Mx7TDPkxQsBLTHMRDhPYMbzZ1KMQO10SgR7RzjH8m8EDcF6s0rFPgw5RPXkBE5ZLTJIUvlN+QHzJEdGAeyzQYQ4zFvGcmXmTLoSLEvFeUV5RnJhQkxAbVo7JBA/CkZ2bUVMQA5GOTccIw1GdmBFTEAAXC8geUl8RnJlNjglHTNPQXlNeSsbC0VPQG0zS0V5vUZCdmVFTC0MS0tGeU15RnJltfNAbTNLR3lNeUZyZERMQG0zS0V5TXlGcmVFTEBtJEtFeVF5RnJlRUdWbTNLQ3kNeVsy5UVKAC0zDcU5TT6GsmXDzABttEsEeIv5BnKiBY1BaDLLRTjMeEb0pARMgWwxS0M7D3hB8CdBCsIsMgzHu0n/hDBkws4CaK5KxXtQOUZyekXMQGEzS0V9R3lGcggsNAMCXyQ3Ck19S3JlRQgyDEQILAsuFSNBIUVIR20zSzUVLAAjAGVBTkBtMzNFfU95RnIcRUhCbTNLP3lOeUZyZUVMQC03TkV5TTgUNSdFT0BtM0tFmSI5RXJlRUxAbcN0QXFNeUYREDc+JQNHS0Z5TXlGcmVNDEBtM0tGeU15RnJkRU1BbTNLRXlNeUZyZUVMQG0zS0R5TXlHcmVFTEBtM0tFeU15RnJlRUw=16B598D6671CE4783CEA6C71649C4025')
end


-- ###############################################################################

    function OnLoad()
    PrintChat("<font color='#CCCCCC'>>> ALLinONE <<</font>")
    KCConfig = scriptConfig("ALL in ONE (LIMITED)", "ALLinONE")
    KCConfig:addParam("MinionMarker", "Enable Minion Marker", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("TowerRange", "Enable Tower Range", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("LowAwareness", "Enable Low Awareness", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("PlayerRange", "Enable Player Range", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("EnemyRanges", "Enable Enemy Ranges", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("useLvl", "Auto Level", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("BuyMeItems", "BuyMeItems: Num keys on/off", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("EmoteSpamm", "ChatSpamm: Arrow Keys (Left/Right/Down)", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("EmoteJLT", "EmoteSpamm (Reload(F9) if get error)", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("MyMoveTo", "Smooth Move (Reload(F9) if error)", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("ExpMinionMark", "Exp Range", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("MiniMapTimers", "Mini Map Timers", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("WhereIsHe", "Where Is He? v1.2", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("WhereHeGo", "Where Did He Go", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("SpinToWin", "Spin To Win - Key '~' Tild", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("AntiWard", "AntiWard 3.15 (2014-02-03)", SCRIPT_PARAM_ONOFF, true)
    KCConfig:addParam("AutoPotion", "Enable Auto Potion", SCRIPT_PARAM_ONOFF, false) -- <-- Off by default
    KCConfig:addParam("useIgnite", "Ignite when killable", SCRIPT_PARAM_ONOFF, false) -- <-- Off by default
    KCConfig:addParam("AwesomeScript", "Awesome Script", SCRIPT_PARAM_ONOFF, false) -- <-- Off by default

    if KCConfig.AwesomeScript then
        AwesomeOnLoad()
    end
    if KCConfig.AntiWard then
        AntiWardOnLoad()
    end
    WDHGOnLoad()
    if KCConfig.EmoteJLT then
        EmoteJLTOnLoad()
    end
    if KCConfig.MyMoveTo then
        MyMoveToOnLoad()
    end
    if KCConfig.MiniMapTimers then
        MiniMapTimersOnLoad()
    end
    TowerRangeOnLoad()
    MinionMarkerOnLoad()
    if KCConfig.useLvl then
        AutoLevelOnLoad()
    end
    useIgniteOnLoad()
end

function OnTick()
    if KCConfig.useIgnite then
        useIgniteOnTick()
    end
    if KCConfig.AutoPotion then
      PotionOnTick()
    end
    if KCConfig.AntiWard then
        AntiWardOnTick()
    end
    if KCConfig.WhereHeGo then
        WDHGOnTick()
    end
    if KCConfig.SpinToWin then
        SpinToWinOnTick()
    end
    if KCConfig.WhereIsHe then
        WhereIsHeOnTick()
    end
    if KCConfig.TowerRange then
        TowerRangeOnTick()
    end
    if KCConfig.LowAwareness then
        LowAwarenessOnTick()
    end
    if KCConfig.useLvl then
        AutoLevelOnTick()
    end
    if KCConfig.EmoteJLT then
        EmoteJLTOnTick()
    end
    if KCConfig.MiniMapTimers then
        MiniMapTimersOnTick()
    end
end

function OnCreateObj(obj)
    if KCConfig.AntiWard then
        AntiWardOnCreateObj(obj)
    end
    if KCConfig.MinionMarker then
        MinionMarkerOnCreateObj(obj)
    end
    if KCConfig.WhereHeGo then
        WDHGOnCreateObj(obj)
    end
end

function OnDeleteObj(obj)
    if KCConfig.AntiWard then
        AntiWardOnDeleteObj(obj)
    end
    if KCConfig.TowerRange then
        TowerRangeOnDeleteObj(obj)
    end
end

function OnProcessSpell(obj,spell)
    if KCConfig.AntiWard then
        AwardOnProcessSpell(obj,spell)
    end
    if KCConfig.WhereHeGo then
        WDHGOnProcessSpell(obj,spell)
    end
end

function OnDraw() 
    if KCConfig.AntiWard then
        AntiWardOnDraw()
    end
    if KCConfig.WhereHeGo then
        WDHGOnDraw()
    end
    if KCConfig.WhereIsHe then
        WhereIsHeOnDraw()
    end
    if KCConfig.MinionMarker then
        MinionMarkerOnDraw()
    end
    if KCConfig.TowerRange then
        TowerRangeOnDraw()
    end
    if KCConfig.LowAwareness then
        LowAwarenessOnDraw()
    end
    if KCConfig.EnemyRanges then
        ERangesOnDraw()
    end
    if KCConfig.PlayerRange then
        PRangesOnDraw()
    end
    if KCConfig.ExpMinionMark then
        ExpMinionMarkOnDraw()
    end 
    if KCConfig.MiniMapTimers then
        MiniMapTimersOnDraw()
    end
end

function OnWndMsg(msg,key)
    if KCConfig.WardPrediction then
        WardPredictionOnWndMsg(msg, key)
    end
    if KCConfig.SpinToWin then
        SpinToWinOnWndMsg(msg, key)
    end
    if KCConfig.EmoteSpamm then
        EmoteSpammOnWndMsg(msg, key)
    end
    if KCConfig.BuyMeItems then
        BuyMeItemsOnWndMsg(msg, key)
    end
    if KCConfig.MyMoveTo then
        MyMoveToOnWndMsg(msg, key)
    end
end