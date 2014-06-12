_miniMapRatio = nil
function GetMinimapRatio()
    if _miniMapRatio then return _miniMapRatio end
    local windowWidth, windowHeight = 1
    local gameSettings = GetGameSettings()
    if gameSettings and gameSettings.General and gameSettings.General.Width and gameSettings.General.Height then
        windowWidth, windowHeight = gameSettings.General.Width, gameSettings.General.Height
        local hudSettings = ReadIni(GAME_PATH .. "DATA\\menu\\hud\\hud" .. windowWidth .. "x" .. windowHeight .. ".ini")
        if hudSettings and hudSettings.Globals and hudSettings.Globals.MinimapScale then
            _miniMapRatio = (windowHeight / 1080) * hudSettings.Globals.MinimapScale
        else
            _miniMapRatio = (windowHeight / 1080)
        end
    end
end

function DrawFilledCircleMinimap(x, z, radius, color)
    assert(type(radius) == "number" and type(x) == "number" and type(z) == "number" and type(color) == "table", "DrawFilledCircleMinimap: wrong argument types (<number>, <number>, <number>, <table> expected)")
    assert(string.len("•") == 1 and "•" ~= "?", "DrawFilledCircleMinimap: wrong encoding(Make sure to encode the function with ANSI and not with the BoL-Editor)")
    GetMinimapRatio()
    local size = radius/7.33*_miniMapRatio
    local x = GetMinimapX(x)-(radius/47.83)*_miniMapRatio
    local z = GetMinimapY(z)-(radius/14.86)*_miniMapRatio
    DrawText("•", size, x, z, ARGB(color[1], color[2], color[3], color[4]))
end
