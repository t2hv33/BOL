local version = 1.0
--[[Version 1.0
    Contents:
        Bolscript.com   -- A basic but powerful library downloader
        Orbwakler       -- Implement from SOWi
		Using Spell     -- Using spell like a SAC:Auto Carry
        Skillshoots     -- Using skillshoot for all of champ
        LagFreeCycle    -- Easy drawing of all kind of things, comes along with some other classes such as Circle - SourceLib
        TurnAround      -- TurnAround to against Tryn,Shaco,Cass
        Awareness       -- Simple awareness for pure free user
        HiddenObject    -- Easy menu creation with only a few lines
--TODO: 
		Implement all spell and using like an Auto Carry

--BUG: 
		Fix Bug all of script

  _______ ___  _    ___      ______ ____  
 |__   __|__ \| |  | \ \    / /___ \___ \ 
    | |     ) | |__| |\ \  / /  __) |__) |
    | |    / /|  __  | \ \/ /  |__ <|__ < 
    | |   / /_| |  | |  \  /   ___) |__) |
    |_|  |____|_|  |_|   \/   |____/____/ 
	
	  ____   ____  _       _____  _____ _____  _____ _____ _______ _____ ____  __  __ 
 |  _ \ / __ \| |     / ____|/ ____|  __ \|_   _|  __ \__   __/ ____/ __ \|  \/  |
 | |_) | |  | | |    | (___ | |    | |__) | | | | |__) | | | | |   | |  | | \  / |
 |  _ <| |  | | |     \___ \| |    |  _  /  | | |  ___/  | | | |   | |  | | |\/| |
 | |_) | |__| | |____ ____) | |____| | \ \ _| |_| |      | |_| |___| |__| | |  | |
 |____/ \____/|______|_____/ \_____|_|  \_\_____|_|      |_(_)\_____\____/|_|  |_|
                                                                                  
                                                                                  
	
	
	
                                          
]]
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--AD check HWID
HWID = Base64Encode(tostring(os.getenv("PROCESSOR_IDENTIFIER")..os.getenv("USERNAME")..os.getenv("COMPUTERNAME")..os.getenv("PROCESSOR_LEVEL")..os.getenv("PROCESSOR_REVISION")))
-- DO NOT CHANGE. This is set to your proper ID.
id = 12
ScriptName = "BSAIO"

-- Thank to Roach and Bilbao for the support!
assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIDAAAAJQAAAAgAAIAfAIAAAQAAAAQKAAAAVXBkYXRlV2ViAAEAAAACAAAADAAAAAQAETUAAAAGAUAAQUEAAB2BAAFGgUAAh8FAAp0BgABdgQAAjAHBAgFCAQBBggEAnUEAAhsAAAAXwAOAjMHBAgECAgBAAgABgUICAMACgAEBgwIARsNCAEcDwwaAA4AAwUMDAAGEAwBdgwACgcMDABaCAwSdQYABF4ADgIzBwQIBAgQAQAIAAYFCAgDAAoABAYMCAEbDQgBHA8MGgAOAAMFDAwABhAMAXYMAAoHDAwAWggMEnUGAAYwBxQIBQgUAnQGBAQgAgokIwAGJCICBiIyBxQKdQQABHwCAABcAAAAECAAAAHJlcXVpcmUABAcAAABzb2NrZXQABAcAAABhc3NlcnQABAQAAAB0Y3AABAgAAABjb25uZWN0AAQQAAAAYm9sLXRyYWNrZXIuY29tAAMAAAAAAABUQAQFAAAAc2VuZAAEGAAAAEdFVCAvcmVzdC9uZXdwbGF5ZXI/aWQ9AAQHAAAAJmh3aWQ9AAQNAAAAJnNjcmlwdE5hbWU9AAQHAAAAc3RyaW5nAAQFAAAAZ3N1YgAEDQAAAFteMC05QS1aYS16XQAEAQAAAAAEJQAAACBIVFRQLzEuMA0KSG9zdDogYm9sLXRyYWNrZXIuY29tDQoNCgAEGwAAAEdFVCAvcmVzdC9kZWxldGVwbGF5ZXI/aWQ9AAQCAAAAcwAEBwAAAHN0YXR1cwAECAAAAHBhcnRpYWwABAgAAAByZWNlaXZlAAQDAAAAKmEABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQA1AAAAAgAAAAIAAAACAAAAAgAAAAIAAAACAAAAAgAAAAMAAAADAAAAAwAAAAMAAAAEAAAABAAAAAUAAAAFAAAABQAAAAYAAAAGAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAgAAAAHAAAABQAAAAgAAAAJAAAACQAAAAkAAAAKAAAACgAAAAsAAAALAAAACwAAAAsAAAALAAAACwAAAAsAAAAMAAAACwAAAAkAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAMAAAADAAAAAwAAAAGAAAAAgAAAGEAAAAAADUAAAACAAAAYgAAAAAANQAAAAIAAABjAAAAAAA1AAAAAgAAAGQAAAAAADUAAAADAAAAX2EAAwAAADUAAAADAAAAYWEABwAAADUAAAABAAAABQAAAF9FTlYAAQAAAAEAEAAAAEBvYmZ1c2NhdGVkLmx1YQADAAAADAAAAAIAAAAMAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))()


local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
    require("SourceLib")
else
    DOWNLOADING_SOURCELIB = true
    DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Thu vien yeu cau` da download thanh cong, vui long` reload F9 2 lan`") end)
end
--require "old2dgeo"
local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/t2hv33/bomd/master/common/SOW.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Init Alert
local LastPinged = 0
local CL = ChampionLane()
local blackColor  = 4278190080
local purpleColor = 4294902015
local greenColor  = 4278255360
local yellowColor = 4294967040
local vangaColor = 4294967295
local aquaColor = ARGB(255,102, 205, 170)
local dangerousobjects = {      
        { name = "Jack In The Box", objectType = "boxes", spellName = "JackInTheBox", charName = "ShacoBox", color = 0x00FF0000, range = 300, duration = 60000},
        { name = "Cupcake Trap", objectType = "traps", spellName = "CaitlynYordleTrap", charName = "CaitlynTrap", color = 0x00FF0000, range = 300, duration = 240000},
        { name = "Noxious Trap", objectType = "traps", spellName = "Bushwhack", charName = "Nidalee_Spear", color = 0x00FF0000, range = 300, duration = 240000},
        { name = "Noxious Trap", objectType = "traps", spellName = "BantamTrap", charName = "TeemoMushroom", color = 0x00FF0000, range = 300, duration = 600000}}
local drawobjects = {}
local drawtraps = {}
local pinkwards = {}
--end Alert

--skillshot init
_G.Champs = {
    ["Aatrox"] = {
        [_Q] = { speed = 450, delay = 0.27, range = 650, minionCollisionWidth = 280},
        [_E] = { speed = 1200, delay = 0.27, range = 1000, minionCollisionWidth = 80}
    },
        ["Ahri"] = {
        [_Q] = { speed = 1670, delay = 0.24, range = 895, minionCollisionWidth = 50},
        [_E] = { speed = 1550, delay = 0.24, range = 920, minionCollisionWidth = 80}
    },
        ["Amumu"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1100, minionCollisionWidth = 80}
    },
        ["Anivia"] = {
        [_Q] = { speed = 860.05, delay = 0.250, range = 1100, minionCollisionWidth = 110},
        [_R] = { speed = math.huge, delay = 0.100, range = 615, minionCollisionWidth = 350}
    },
        ["Annie"] = {
        [_W] = { speed = math.huge, delay = 0.25, range = 625, minionCollisionWidth = 0},
        [_R] = { speed = math.huge, delay = 0.2, range = 600, minionCollisionWidth = 0}
    },
        ["Ashe"] = {
        [_W] = { speed = 2000, delay = 0.120, range = 1200, minionCollisionWidth = 85},
        [_R] = { speed = 1600, delay = 0.5, range = 1200, minionCollisionWidth = 0}
    },
        ["Blitzcrank"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 1050, minionCollisionWidth =  90}
    },
        ["Brand"] = {
        [_Q] = { speed = 1600, delay = 0.625, range = 1100, minionCollisionWidth = 90},
        [_W] = { speed = 900, delay = 0.25, range = 1100, minionCollisionWidth = 0},
        },
        ["Caitlyn"] = {
        [_Q] = { speed = 2200, delay = 0.625, range = 1300, minionCollisionWidth = 0},
        [_E] = { speed = 2000, delay = 0.400, range = 1000, minionCollisionWidth = 80},
    },
        ["Cassiopeia"] = {
        [_Q] = { speed = math.huge, delay = 0.535, range = 850, minionCollisionWidth = 0},
        [_W] = { speed = math.huge, delay = 0.350, range = 850, minionCollisionWidth = 80},
        [_R] = { speed = math.huge, delay = 0.535, range = 850, minionCollisionWidth = 350}
    },
        ["Chogath"] = {
        [_Q] = { speed = 950, delay = 0, range = 950, minionCollisionWidth = 0},
        [_W] = { speed = math.huge, delay = 0.25, range = 700, minionCollisionWidth = 0},
        },
        ["Corki"] = {
        [_Q] = { speed = 1500, delay = 0.350, range = 840, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.200, range = 1225, minionCollisionWidth = 60},
    },
        ["Darius"] = {
        [_E] = { speed = 1500, delay = 0.550, range = 530, minionCollisionWidth = 0}
    },
        ["Diana"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 830, minionCollisionWidth = 0}
    },
        ["DrMundo"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1050, minionCollisionWidth = 80}
    },
        ["Draven"] = {
        [_E] = { speed = 1400, delay = 0.250, range = 1100, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.5, range = 2500, minionCollisionWidth = 0}
    },
        ["Elise"] = {
        [_E] = { speed = 1450, delay = 0.250, range = 975, minionCollisionWidth = 80}
    },
        ["Ezreal"] = {
        [_Q] = { speed = 2000, delay = 0.251, range = 1200, minionCollisionWidth = 80},
        [_W] = { speed = 1600, delay = 0.25, range = 1050, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 1, range = 20000, minionCollisionWidth = 150}
    },
        ["Fizz"] = {
        [_R] = { speed = 1350, delay = 0.250, range = 1150, minionCollisionWidth = 0}
    },
        ["Galio"] = {
        [_Q] = { speed = 850, delay = 0.25, range = 940, minionCollisionWidth = 0},
        --[_E] = { speed = 2000, delay = 0.400, range = 1180, minionCollisionWidth = 0},
    },
        ["Gragas"] = {
        [_Q] = { speed = 1000, delay = 0.250, range = 1100, minionCollisionWidth = 0}
    },
        ["Graves"] = {
        [_Q] = { speed = 1950, delay = 0.265, range = 950, minionCollisionWidth = 85},
        [_W] = { speed = 1650, delay = 0.300, range = 950, minionCollisionWidth = 0},
        [_R] = { speed = 2100, delay = 0.219, range = 1000, minionCollisionWidth = 30}
    },
        ["Heimerdinger"] = {
                [_W] = { speed = 1200, delay = 0.200, range = 1100, minionCollisionWidth = 70},
                [_E] = { speed = 1000, delay = 0.1, range = 925, minionCollisionWidth = 0},
        },
        ["Irelia"] = {
        [_R] = { speed = 1700, delay = 0.250, range = 1000, minionCollisionWidth = 0}
    },
        ["JarvanIV"] = {
                [_Q] = { speed = 1400, delay = 0.2, range = 800, minionCollisionWidth = 0},
                [_E] = { speed = 200, delay = 0.2, range = 850, minionCollisionWidth = 0},
        },
        ["Jinx"] = {
                [_W] = { speed = 3300, delay = 0.600, range = 1500, minionCollisionWidth = 70},
                [_E] = { speed = 887, delay = 0.500, range = 950, minionCollisionWidth = 0},
                [_R] = { speed = 2500, delay = 0.600, range = 2000 , minionCollisionWidth = 0}
        },
        ["Karma"] = {
        [_Q] = { speed = 1700, delay = 0.250, range = 1050, minionCollisionWidth = 80}
    },
        ["Karthus"] = {
        [_Q] = { speed = 1750, delay = 0.25, range = 875, minionCollisionWidth = 0},
    },
        ["Kennen"] = {
        [_Q] = { speed = 1700, delay = 0.180, range = 1050, minionCollisionWidth = 70}
    },
        ["Khazix"] = {
        [_W] = { speed = 828.5, delay = 0.225, range = 1000, minionCollisionWidth = 100}
    },
        ["KogMaw"] = {
        [_R] = { speed = 1050, delay = 0.250, range = 2200, minionCollisionWidth = 0}
    },
        ["Leblanc"] = {
        [_E] = { speed = 1600, delay = 0.250, range = 960, minionCollisionWidth = 0},
        [_R] = { speed = 1600, delay = 0.250, range = 960, minionCollisionWidth = 0},
    },
        ["LeeSin"] = {
        [_Q] = { speed = 1800, delay = 0.250, range = 1100, minionCollisionWidth = 100}
    },
        ["Leona"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 900, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.250, range = 1200, minionCollisionWidth = 0},
    },
        ["Lucian"] = {
        [_W] = { speed = 1470, delay = 0.288, range = 1000, minionCollisionWidth = 25}
    },
        ["Lulu"] = {
        [_Q] = { speed = 1530, delay = 0.250, range = 945, minionCollisionWidth = 80}
    },
        ["Lux"] = {
        [_Q] = { speed = 1200, delay = 0.245, range = 1300, minionCollisionWidth = 50},
        [_E] = { speed = 1400, delay = 0.245, range = 1100, minionCollisionWidth = 0},
        [_R] = { speed = math.huge, delay = 0.245, range = 3500, minionCollisionWidth = 0}
    },
        ["Malzahar"] = {
        [_Q] = { speed = 1170, delay = 0.600, range = 900, minionCollisionWidth = 50}
    },
        ["Mordekaiser"] = {
        [_E] = { speed = math.huge, delay = 0.25, range = 700, minionCollisionWidth = 0},
        },
        ["Morgana"] = {
        [_Q] = { speed = 1200, delay = 0.250, range = 1300, minionCollisionWidth = 80}
    },
        ["Nami"] = {
        [_Q] = { speed = math.huge, delay = 0.8, range = 850, minionCollisionWidth = 0}
    },
        ["Nautilus"] = {
        [_Q] = { speed = 2000, delay = 0.250, range = 1080, minionCollisionWidth = 100}
    },
        ["Nidalee"] = {
        [_Q] = { speed = 1300, delay = 0.125, range = 1500, minionCollisionWidth = 60},
    },
        ["Nocturne"] = {
        [_Q] = { speed = 1600, delay = 0.250, range = 1200, minionCollisionWidth = 0}
    },
    ["Olaf"] = {
        [_Q] = { speed = 1600, delay = 0.25, range = 1000, minionCollisionWidth = 0}
    },
        ["Quinn"] = {
        [_Q] = { speed = 1600, delay = 0.25, range = 1050, minionCollisionWidth = 100}
    },
        ["Rumble"] = {
        [_E] = { speed = 2000, delay = 0.250, range = 950, minionCollisionWidth = 80}
    },
        ["Sejuani"] = {
        [_R] = { speed = 1300, delay = 0.200, range = 1175, minionCollisionWidth = 0}
    },
        ["Sivir"] = {
        [_Q] = { speed = 1330, delay = 0.250, range = 1075, minionCollisionWidth = 0}
    },
        ["Skarner"] = {
        [_E] = { speed = 1200, delay = 0.250, range = 760, minionCollisionWidth = 0}
    },
        ["Swain"] = {
        [_Q] = { speed = math.huge, delay = 0.500, range = 900, minionCollisionWidth = 0}
    },
        ["Syndra"] = {
        [_Q] = { speed = math.huge, delay = 0.400, range = 800, minionCollisionWidth = 0}
    },
        ["Thresh"] = {
        [_Q] = { speed = 1900, delay = 0.500, range = 1075, minionCollisionWidth = 80}
    },
        ["Twitch"] = {
        [_W] = {speed = 1750, delay = 0.283, range = 900, minionCollisionWidth = 0}
    },
        ["TwistedFate"] = {
        [_Q] = { speed = 1450, delay = 0.200, range = 1450, minionCollisionWidth = 0}
    },
        ["Urgot"] = {
        [_Q] = { speed = 1600, delay = 0.175, range = 1000, minionCollisionWidth = 100},
        [_E] = { speed = 1750, delay = 0.25, range = 900, minionCollisionWidth = 0}
    },
        ["Varus"] = {
       --[_Q] = { speed = 1850, delay = 0.1, range = 1475, minionCollisionWidth = 0},
        [_E] = { speed = 1500, delay = 0.245, range = 925, minionCollisionWidth = 0},
        [_R] = { speed = 1950, delay = 0.5, range = 1075, minionCollisionWidth = 0}
    },
        ["Veigar"] = {
        [_W] = { speed = 900, delay = 0.25, range = 900, minionCollisionWidth = 0}
    },
        ["Viktor"] = {
                [_W] = { speed = math.huge, delay = 0.25, range = 625, minionCollisionWidth = 0},
                [_E] = { speed = 1200, delay = 0.25, range = 1225, minionCollisionWidth = 0},
                [_R] = { speed = 1000, delay = 0.25, range = 700, minionCollisionWidth = 0},
    },
        ["Velkoz"] = {
                [_Q] = { speed = 1300, delay = 0.066, range = 1100, minionCollisionWidth = 50},
                [_W] = { speed = 1700, delay = 0.064, range = 1050, minionCollisionWidth = 0},
                [_E] = { speed = 1500, delay = 0.333, range = 1100, minionCollisionWidth = 0},
    },    
        ["Xerath"] = {
        [_Q] = { speed = 3000, delay = 0.6, range = 1100, minionCollisionWidth = 0},
        [_R] = { speed = 2000, delay = 0.25, range = 1100, minionCollisionWidth = 0}
    },
        ["Zed"] = {
        [_Q] = { speed = 1700, delay = 0.2, range = 925, minionCollisionWidth = 0},
    },
        ["Ziggs"] = {
        [_Q] = { speed = 1722, delay = 0.218, range = 850, minionCollisionWidth = 0},
                [_W] = { speed = 1727, delay = 0.249, range = 1000, minionCollisionWidth = 0},
                [_E] = { speed = 2694, delay = 0.125, range = 900, minionCollisionWidth = 0},
                [_R] = { speed = 1856, delay = 0.1014, range = 2500, minionCollisionWidth = 0},
    },
        ["Zyra"] = {
                 [_Q] = { speed = math.huge, delay = 0.7, range = 800, minionCollisionWidth = 0},
         [_E] = { speed = 1150, delay = 0.16, range = 1100, minionCollisionWidth = 0}
    },
        ["Lissandra"] = {
                 [_Q] = { speed = 725, delay = 0.5, range = 775, minionCollisionWidth = 0},
    }
}
--Skillshoot init 0.1

--if not Champs[myHero.charName] then return end -- put other declarations after this check
--this line give an error for BS_0.3
local data = Champs[myHero.charName]
local VP -- it is nil by default :D
local Target 
local ts2 = TargetSelector(TARGET_LOW_HP, 1500, DAMAGE_MAGIC, true) -- make these local
local Menu -- make these local
local predictions = {} -- make these local
local str = { [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R" }
local keybindings = { [_Q] = "Z", [_W] = "X", [_E] = "C", [_R] = "R" }
local ConfigType = SCRIPT_PARAM_ONKEYDOWN
local initDone = false
--End Skillshoot

--Start Orbwalker
local _TOMOUSE, _TOTARGET, _EMPOWER = 100, 101, 201
local MySpells = {}
local Spells =
{
    ["MissFortune"] = {
        [_Q] = {name = "Double Up", spellType = _TOTARGET, range = 650},
        [_W] = {name = "Impure shots", spellType = _EMPOWER, range = -1}
    },

    ["Sivir"] = {
        [_Q] = {name = "Boomerang blade", skillshot = true, spellType = SKILLSHOT_LINEAR, range = 1175, width = 90, speed = 1350, delay = 0.25, collision = false},
        [_W] = {name = "Ricochet", spellType = _EMPOWER, range = -1}
    },

    ["Jax"] = {
        [_Q] = {name = "Leap Strike", spellType = _TOTARGET, range = 700},
        [_W] = {name = "Empower", spellType = _EMPOWER, range = -1},
        [_E] = {name = "Counter Strike", spellType = _EMPOWER, range = -1},
        [_R] = {name = "Grandmaster's Might", spellType = _EMPOWER, range = -1},
    },

    ["Tristana"] = {
        [_Q] = {name = "Rapid Fire", spellType = _EMPOWER, range = -1},
        [_E] = {name = "Explosive Shot", spellType = _TOTARGET, range = -1},
    },

    ["Teemo"] = {
        [_Q] = {name = "Blinding dart", spellType = _TOTARGET, range = 680}
    },

    ["Taric"] = {
        [_E] = {name = "Dazzle", spellType = _TOTARGET, range = 625}
    },

    ["Lucian"] = {
        [_Q] = {name = "Piercing Light", spellType = _TOTARGET, range = 550},
        [_W] = {name = "Mistic Shot", skillshot = true, spellType = SKILLSHOT_LINEAR, range = 1000, width = 55, speed = 1600, delay = 0.25, collision = false},
    },

    ["Khazix"] = {
        [_Q] = {name = "Taste Their Fear", spellType = _TOTARGET, range = -1},
        [_W] = {name = "Void Spikes", skillshot = true, spellType = SKILLSHOT_LINEAR, range = 1025, width = 70, speed = 1700, delay = 0.25, collision = true},
        [_E] = {name = "Leap", skillshot = true, spellType = SKILLSHOT_CIRCULAR, range = function() return myHero:GetSpellData(_E).range end, width = 100, speed = 1000, delay = 0.25, AOE = true},
    },

    ["Vayne"] = {
        [_Q] = {name = "Tumble", spellType = _TOMOUSE, range = -1}
    },

    ["Zed"] = {
        [_Q] = {name = "Razor Shuriken", skillshot = true, spellType = SKILLSHOT_CONE, range = 925, width = 50, speed = 1700, delay = 0.25, AOE = true, collision = false},
        [_E] = {name = "Shadow Slash", spellType = SKILLSHOT_CIRCULAR, range = 290, width = 1, speed = math.huge, delay = 0.25, AOE = false, collision = false},
    },

    ["Graves"] = {
        [_Q] = {name = "Buckshot", skillshot = true, spellType = SKILLSHOT_CONE, range = 700, width = 15.32 * math.pi / 180, speed = 902, delay = 0.25, AOE = true, collision = false},
        [_W] = {name = "Smoke screen", spellType = SKILLSHOT_CIRCULAR, range = 900, width = 250, speed = 1650, delay = 0.25, AOE = true, collision = false},
        [_E] = {name = "Quckdraw", spellType = _TOMOUSE, range = -1},
    },

    ["Ezreal"] = {
        [_Q] = {name = "Mistic Shot", skillshot = true, spellType = SKILLSHOT_LINEAR, range = 1200, width = 60, speed = 2000, delay = 0.25, collision = true},
        [_W] = {name = "Essence Flux", skillshot = true, spellType = SKILLSHOT_LINEAR, range = 1050, width = 80, speed = 1600, delay = 0.25, AOE = true},
    },

    ["Ashe"] = {
        [_W] = {name = "Volley", skillshot = true, spellType = SKILLSHOT_CONE, range = 1050, width = 57.5 * math.pi / 180, speed = 1600, delay = 0.25, AOE = true, collision = false},
    },
	 ["Yasuo"] = {
        [_Q] = {name = "YasuoQW", skillshot = true, spellType = SKILLSHOT_CONE, range = 475, width = 55, speed = 1500, delay = 0.25, AOE = true, collision = false},
    },
}
--End OrbWalker

function OnLoad()
	PrintChat ("<font color='#14C4DB'>Skillshoot and Olbwalker</font> <font color='#7fe8c2'>of</font> <font color='#DB32D0'>BolScript.com</font> <font color='#7fe8c2'>cho free user by</font> <font color='#e97fa5'>BomD</font></font>")
     --start Alert
    lastvanga = 0
    local loadedTable, error = Serialization.loadTable(SCRIPT_PATH .. 'Common/IHateWards_cache.lua')
    if not error and loadedTable.saveTime <= GetInGameTimer() then
        placedWards = loadedTable.placedWards
    else
        placedWards = {}
    end
    WardsHater = scriptConfig("BolScript-Canh?Bao'", "CanhBao")
    WardsHater:addParam("drawpath", "Hiên.Ðuong`Team Ðich.", SCRIPT_PARAM_ONOFF, true)
    WardsHater:addParam("drawallypath", "Hiên.Ðuong`Team Mình", SCRIPT_PARAM_ONOFF, false)
    WardsHater:addParam("drawpathtime", "Hiên.time", SCRIPT_PARAM_ONOFF, true)
    WardsHater:addParam("drawobj", "Hiên.Nâ'm+Bây~", SCRIPT_PARAM_ONOFF, true)
    WardsHater:addParam("drawwards", "Hiên.Mät' WARD", SCRIPT_PARAM_ONOFF, true)
    WardsHater:addParam("ownteam", "Hiên.Hàng Team Mình(Ðang TEST)", SCRIPT_PARAM_ONOFF, false)
    --WardsHater:addParam("ping11", "Ping Jungler Ðich.(Ðang TEST-VIP)", SCRIPT_PARAM_ONOFF, false)
   -- WardsHater:addParam("ping", "Ping Jungler Ðich.(Ðang TEST-FREE)", SCRIPT_PARAM_ONOFF, false)
    WardsHater:addParam("pingdistance", "Khoang?Cach' < Ping Jungler Ðich.", SCRIPT_PARAM_SLICE, 1500, 100, 4000, 0)
    WardsHater:addParam("pinginterval", "Time < Ping Jungler Ðich.(s)", SCRIPT_PARAM_SLICE, 1, 69, 180, 0)
    WardsHater:addParam("vangamode", "Chô~Này Có WARD! (I)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("I"))
    WardsHater:addParam("showvision", "Lây'Tâm`Nhin`  (U)", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("U"))
    WardsHater:addParam("drawcross", "Hiên.Mui~Tên", SCRIPT_PARAM_ONOFF, true)
    WardsHater:addParam("crosssize", "adj cross_size", SCRIPT_PARAM_SLICE, 30, 10, 100, 0)
    WardsHater:addParam("crosswidth", "adj cross_width", SCRIPT_PARAM_SLICE, 8, 5, 50, 0)
    WardsHater:addParam("txtsize", "adj Champ Text size", SCRIPT_PARAM_SLICE, 15, 5, 50, 0)
    WardsHater:addParam("txtxpos", "adj Champ Text x pos", SCRIPT_PARAM_SLICE, 0, -300, 300, 0)
    WardsHater:addParam("txtypos", "adj Champ Text y pos", SCRIPT_PARAM_SLICE, -60, -300, 300, 0)
    WardsHater:addParam("timertxtsize", "adj Timer Text Size", SCRIPT_PARAM_SLICE, 20, 5, 50, 0)
    --end Arlet

    --New Aiming
	if Champs[myHero.charName] then
      VP = VPrediction()
    Config = scriptConfig("BolScript-Skillshoot: Cài Ðät.", "BolScript")
    if Champs[myHero.charName] ~= nil then -- this line give a fucking bug in BS 0.3
    for i, spell in pairs(data) do
        Config:addParam(str[i], "Xài'-" .. str[i], ConfigType, false, GetKey(keybindings[i]))
        predictions[str[i]] = {spell.range, spell.speed, spell.delay, spell.minionCollisionWidth, i}
    end 
	end
    Config:addParam("accuracy", "Ðoán Chính Xác", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
    Config:addParam("rangeoffset", "Giäm? Range Xài Chiêu", SCRIPT_PARAM_SLICE, 0, 0, 200, 0)
    Config:addParam("autocast", "Auto Xài khi 100% trung' (L)", SCRIPT_PARAM_ONKEYTOGGLE, false, 76)
	Config:permaShow("autocast")
	ts2.name = "Skillshoot"
    Config:addTS(ts2)
    initDone = true
	end
    --PrintChat ("<font color='#14C4DB'>Skillshoot and Olbwalker</font> <font color='#7fe8c2'>of</font> <font color='#DB32D0'>BolScript.com</font> <font color='#7fe8c2'>cho free user by</font> <font color='#e97fa5'>BomD</font></font>")

    --Advance Turn Around
    TurnAroundTable = {
        lastTargetedPos = { x = nil, z = nil },
        lastMove = 0,
        champions = {
            { charName = "Cassiopeia", key = "CassiopeiaPetrifyingGaze",                range = 750 * 750, spellName = "Hóa Ðá(R)",   var = -100 },
            { charName = "Shaco",      key = "ShacoBasicAttack" or "ShacoCritAttack",   range = 125 * 125, spellName = "Ðánh Thuong`(AA)",          var =  100 },
            { charName = "Shaco",      key = "TwoShivPoison",                           range = 625 * 625, spellName = "Dao Ðôc. (E)",   var =  100 },
            { charName = "Tryndamere", key = "MockingShout",                            range = 850 * 850, spellName = "Tiêng'Thet'Uy Hiêp' (W)",     var =  100 }
        }
    }

    oldMoveTo = myHero.MoveTo
    myHero.MoveTo = function(unit, x, z)
                        if TurnAroundTable.lastMove ~= 0 then return end

                        TurnAroundTable.lastTargetedPos.x, TurnAroundTable.lastTargetedPos.z = x, z

                        return oldMoveTo(unit, x, z)
                    end

    TurnAroundMenu = scriptConfig("BolScript-Quay Lüng Lai.", "TA")
        TurnAroundMenu:addParam("Enable", "Bât.Script", SCRIPT_PARAM_ONOFF, true)

        TurnAroundMenu:addSubMenu("Cài Ðat.Nâng Cao", "cas")
        for i = 1, #TurnAroundTable.champions, 1 do
            if i ~= 3 then
                TurnAroundMenu.cas:addSubMenu("Né -"..TurnAroundTable.champions[i].charName, TurnAroundTable.champions[i].charName)
            end
            TurnAroundMenu.cas[TurnAroundTable.champions[i].charName]:addParam(TurnAroundTable.champions[i].key, TurnAroundTable.champions[i].spellName, SCRIPT_PARAM_ONOFF, true)
    end
    --End Turn Around

    --Load Orbwalker
    DelayAction(DelayedLoad, 1)
    --End Orbwalker
    --BolTracker
    UpdateWeb(true, ScriptName, id, HWID)





end --end onload


--start orbwalker
function CastSpells(target, mode)
	  for id, spell in pairs(Spells[myHero.charName]) do
        if Menu["Spells"..myHero.charName]["id"..id].Enabled and Menu["Spells"..myHero.charName]["id"..id]["Mode"..mode] and Menu["Spells"..myHero.charName]["id"..id][tostring(string.gsub(target.type, "_", ""))] then
            local range = spell.range == -1 and SOWi:MyRange() or spell.range
            if type(range) == "function" then
                range = range(target)
            end
            MySpells[id]:SetRange(range)

            if spell.spellType == _TOMOUSE and GetDistanceSqr(target) < MySpells[id].rangeSqr then
                CastSpell(id, mousePos.x, mousePos.z)
            elseif spell.spellType == _TOTARGET and GetDistanceSqr(target) < MySpells[id].rangeSqr then
                CastSpell(id, target)
            elseif spell.spellType == _EMPOWER and GetDistanceSqr(target) < MySpells[id].rangeSqr then
                CastSpell(id)
            elseif GetDistanceSqr(target) < MySpells[id].rangeSqr then
                MySpells[id]:Cast(target)
            end
        end
    end
end

function AfterAttack(target, mode)
    if target and target.type and Spells[myHero.charName] and ValidTarget(target) then
        CastSpells(target, mode)
    end
end

function DelayedLoad()
    if not _G.SOWLoaded then
        DManager = DrawManager()
        VP = VPrediction(true)
        STS = SimpleTS(STS_LESS_CAST_PHYSICAL)
        SOWi = SOW(VP, STS)

        --Load the spells:
        if Spells[myHero.charName]  then
            for id, spell in pairs(Spells[myHero.charName]) do
                local range = spell.range == -1 and SOWi:MyRange() or spell.range
                if type(range) == "function" then
                    range = range(target)
                end
                MySpells[id] = Spell(id, range)

                if spell.skillshot then
                    MySpells[id]:SetSkillshot(VP, spell.spellType, spell.width, spell.delay, spell.speed, spell.collision)
                end

                if spell.AOE then
                    MySpells[id]:SetAOE(true)
                end
            end
        end
        Menu = scriptConfig("BolScript-Olbwalker: Cài Ðät.", "Olbwalker")
        Menu:addSubMenu("Chon.Muc.Tiêu", "STS")
        STS:AddToMenu(Menu.STS)
        
        if Spells[myHero.charName] then
            Menu:addSubMenu("Dùng Skills", "Spells"..myHero.charName)
            for id, spell in pairs(Spells[myHero.charName]) do
                Menu["Spells"..myHero.charName]:addSubMenu(SpellToString(id).." - "..spell.name, "id"..id)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Enabled", "Enabled", SCRIPT_PARAM_ONOFF, false)

                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode3", "Bât. khi Last Hit mode", SCRIPT_PARAM_ONOFF, false)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode2", "Bât. khi Lane Clear mode", SCRIPT_PARAM_ONOFF, false)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode1", "Bât. khi Mixed mode", SCRIPT_PARAM_ONOFF, false)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode0", "Bât. khi AutoCarry mode", SCRIPT_PARAM_ONOFF, true)

                Menu["Spells"..myHero.charName]["id"..id]:addParam(tostring(string.gsub(myHero.type, "_", "")), "Dùng vs Ðich.", SCRIPT_PARAM_ONOFF, true)
                Menu["Spells"..myHero.charName]["id"..id]:addParam(tostring(string.gsub("obj_AI_Minion", "_", "")), "Dùng vs Lính", SCRIPT_PARAM_ONOFF, false)
            end
        end
        Menu:addSubMenu("Drawing", "Drawing")

        AArangeCircle = DManager:CreateCircle(myHero, SOWi:MyRange()+50, 1, {255, 255, 255, 255})
        AArangeCircle:AddToMenu(Menu.Drawing, "Tâm`Ðánh AA", false, true, true)

        SOWi:LoadToMenu(Menu)
        SOWi:RegisterAfterAttackCallback(AfterAttack)
        Menu:permaShow("Mode0")
    end
end
--end orbwalker

--Aiming Skillshoot
--Credit Trees
function GetCustomTarget()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    ts2:update()
    --print('tstarget called')
    return ts2.target
end
--End Credit Trees

--End Aiming Skillshoot
function IsLeeThresh()
    if myHero.charName == 'LeeSin' then
        if myHero:GetSpellData(_Q).name == 'BlindMonkQOne' then
            return true
        else
            return false
        end
    elseif myHero.charName == 'Thresh' then
        if myHero:GetSpellData(_Q).name == 'ThreshQ' then
            return true
        else
            return false
        end 
    else 
        return true
    end
end



function OnTick()
--start orbwalker
    if SOWi and AArangeCircle then
        AArangeCircle.radius = SOWi:MyRange() + 50
    end

    if SOWi and not SOWi:GetTarget() and Spells[myHero.charName] then
        for id, spell in pairs(Spells[myHero.charName]) do
            local range = spell.range == -1 and SOWi:MyRange() or spell.range
            if type(range) == "function" then
                range = range(target)
            end
            local target = STS:GetTarget(range)
            if target then
                CastSpells(target, SOWi.mode)
            end
        end
    end
	--end orbwalker
    --Aiming
    if initDone then
        Target = GetCustomTarget() --Tmrees
        if Target == nil then return end
        for i, spell in pairs(data) do
            local collision = spell.minionCollisionWidth == 0 and false or true
            local CastPosition, HitChance, Position = VP:GetLineCastPosition(Target, spell.delay, spell.minionCollisionWidth, spell.range, spell.speed, myHero, collision)
            if Config[str[i]] and myHero:CanUseSpell(i) and IsLeeThresh() then -- move spell ready check to top
                if CastPosition and HitChance and HitChance >= Config.accuracy and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CastSpell(i, CastPosition.x, CastPosition.z) end   
            elseif Config.autocast then
                if CastPosition and HitChance and HitChance > 2 and GetDistance(CastPosition, myHero) < spell.range - Config.rangeoffset then CastSpell(i, CastPosition.x, CastPosition.z) end
            end
        end 
    end
    --End Aiming
    --Turn around
    if not TurnAroundMenu.Enable or TurnAroundTable.lastMove == 0 then return end

    if os.clock() - TurnAroundTable.lastMove >= .7 and (TurnAroundTable.lastTargetedPos.x ~= myHero.x and TurnAroundTable.lastTargetedPos.z ~= myHero.z) and (TurnAroundTable.lastTargetedPos.x ~= nil and TurnAroundTable.lastTargetedPos.z ~= nil) then
        oldMoveTo(myHero, TurnAroundTable.lastTargetedPos.x, TurnAroundTable.lastTargetedPos.z)

        TurnAroundTable.lastMove = 0
    end

    --End Turnaround

    --BolTrack
    if GetGame().isOver then
	UpdateWeb(false, ScriptName, id, HWID)
	-- This is a var where I stop executing what is in my OnTick()
	startUp = false;
	end
    --end bol track

end --end ontick
--Turn around
function OnProcessSpell(unit, spell)
    if not TurnAroundMenu.Enable or (myHero.charName == "Teemo" and myHero.isStealthed) then return end

    if unit ~= nil and unit.team ~= myHero.team then
        for i = 1, #TurnAroundTable.champions, 1 do
            if TurnAroundMenu.cas[TurnAroundTable.champions[i].charName][TurnAroundTable.champions[i].key] then
                if spell.name:find(TurnAroundTable.champions[i].key) and (GetDistanceSqr(unit, myHero) <= TurnAroundTable.champions[i].range and unit.charName ~= "Shaco" or spell.target == myHero) then
                    oldMoveTo(myHero, myHero.x + ((unit.x - myHero.x) * (TurnAroundTable.champions[i].var) / GetDistance(unit)), myHero.z + ((unit.z - myHero.z) * (TurnAroundTable.champions[i].var) / GetDistance(unit)))

                    TurnAroundTable.lastMove = os.clock()
                end
            end
        end
    end
end 
function OnWndMsg(msg, key)
    if not TurnAroundMenu.Enable then return end

    if msg == WM_RBUTTONDOWN then
        TurnAroundTable.lastTargetedPos.x, TurnAroundTable.lastTargetedPos.z = mousePos.x, mousePos.z
    end

    --start awa
        if WardsHater.vangamode and lastvanga < GetTickCount() then
        for networkID, ward in pairs(placedWards) do
            if ward and GetDistance(ward,mousePos)<100 and ward.vanga == 3 then
                placedWards[networkID] = nil
                return
            end
        end
        placedWards[GetTickCount()] = {x = mousePos.x, y = myHero.y, z = mousePos.z, visionRange = 1100, color = vangaColor, spawnTime = GetTickCount(), duration = 180000, vanga = 3}
        lastvanga = GetTickCount() + 1000
    end

    --end awa


end

--Off

--======================================================NEW 0.3 CANH BAO

function OnBugSplat()
    Serialization.saveTable({wards = placedWards}, SCRIPT_PATH .. 'Common/HiddenWards_BugSplat.lua')
    UpdateWeb(false, ScriptName, id, HWID)

end

function OnCreateObj(object)
    if object ~= nil and object.type == "obj_AI_Minion" then
        for idx, table1 in ipairs(dangerousobjects) do
            if object.name == table1.name then
                local current_tick = GetTickCount()
                local temp_table = {object = object, name = table1.name, duration = table1.duration, start_tick = current_tick, end_tick = current_tick+table1.duration, range = table1.range, color = table1.color}
                --rint(temp_table)
                table.insert(drawobjects, temp_table)
            end
        end
    end
end

function OnDeleteObj(object)

    if object.name == 'Ward_Vision_Idle.troy' then
        for idx, ward in pairs(pinkwards) do
            if GetDistance(ward, object) < 400 then
                pinkwards[idx].alive = 0
            end
        end
    end

    if object ~= nil and object.name ~= nil and object.type == "obj_AI_Minion" then
        for idx, table1 in ipairs(drawobjects) do
            if object.valid and table1.object.valid and table1.object.networkID == object.networkID then
                drawobjects[idx] = nil
                
            end
        end
        for idx, table1 in ipairs(drawtraps) do
            if object.networkID == table1.obnid then
                drawtraps[idx] = nil
            end
        end
        if object.name == 'Ward_Vision_Idle.troy' then
            for idx, table1 in ipairs(pinkwards) do
                if object.x == table1.x and object.y == table1.y and object.z == wable1.z then
                    pinkwards[idx] = nil
                end
            end
        end
    end
end

function CheckTimer()
    for idx, table in ipairs(drawobjects) do
        if table.object.valid and table.end_tick < GetTickCount() then
            drawobjects[idx] = nil
        end
    end
end



function CheckLane()
    local enemy_jungler = CL:GetJungler()
    --local my_lane = CL:GetMyLane()
    --local champs_in_lane = CL:GetHeroArray(my_lane)
    --for idx, champ in ipairs(champs_in_lane) do
        --if champ.networkID == enemy_jungler.networkID then
        if enemy_jungler ~= nil then
            local bool = false
            for i = enemy_jungler.pathIndex, enemy_jungler.pathCount do
                path = enemy_jungler:GetPath(i)
                if path ~= nil and path.x then
                    if GetDistance(path,myHero) < WardsHater.pingdistance then
                        bool = true
                    end
                end
            end
            if bool and GetTickCount() - LastPinged > WardsHater.pinginterval*1000 then
                RecPing(enemy_jungler.x, enemy_jungler.z)
                LastPinged = GetTickCount()
            end
        --end
    end

end


--Honda7
-- function RecPing(X, Y)
--     Packet("R_PING", {x = X, y = Y, type = PING_FALLBACK}):receive()
-- end

-- function OnRecvPacket(p)
--     if p.header == 50 then
--         p.pos = 1
--         local deaddid = p:DecodeF()
--         local killerid = p:DecodeF()
--         for networkID, ward in pairs(placedWards) do
--             if ward and deaddid and networkID == deaddid and ward.vanga == 1 and (GetTickCount() - ward.spawnTime) > 200 then
--                 placedWards[networkID] = nil
--             elseif ward and deaddid and networkID == deaddid and ward.vanga == 2 and killerid == 0 then
--                 placedWards[networkID] = nil
--             end
--         end
--     end
    
--     if p.header == 0xB5 then
        
--         p.pos = 12

--         local wardtype2 = p:Decode1()
--         p.pos = 1
--         local creatorID = p:DecodeF()
--         p.pos = p.pos + 20
--         local creatorID2 = p:DecodeF()
--         p.pos = 37
--         local objectID = p:DecodeF()
--         local objectX = p:DecodeF()
--         local objectY = p:DecodeF()
--         local objectZ = p:DecodeF()
--         local objectX2 = p:DecodeF()
--         local objectY2 = p:DecodeF()
--         local objectZ2 = p:DecodeF()
--         p:DecodeF()
--         local warddet = p:Decode1()
--         p.pos = p.pos + 4
--         local warddet2 = p:Decode1()
--         p.pos = 13
--         local wardtype = p:Decode1()
--         --[[ 
--             8 - Vision ward
--             229 - Sight Stone 
--             161 - normal wards
--             56 trinket1
--             56 - trinket1 green upgrade
--             137 = trink1 pink
--             48 - teemo shroom
--             ]]
--         local visionColor

--         --if wardtype==8 or wardtype2==0x7E then return end -- Dont show pinks

--         local objectID = DwordToFloat(AddNum(FloatToDword(objectID), 2))
--         local creatorchamp = objManager:GetObjectByNetworkId(creatorID)
--         local duration
--         local range

--         if creatorchamp and creatorchamp.team == myHero.team and not WardsHater.ownteam then return end
        
--         visionColor = (wardtype == 229 and yellowColor or greenColor)
        
--         if (warddet == 0x3E or (warddet == 0x3F and wardtype == 0x3F)) then ---objects
--             if wardtype == 0x30 and wardtype2 == 0xD0 and creatorchamp.charName == "Teemo" then
--                 duration = 600000 range = 200 -- shroom
--             elseif (wardtype == 0x09 and wardtype2 == 0x5B  and creatorchamp.charName == "Nidalee" ) or (wardtype == 62 and wardtype2 == 0xB0  and creatorchamp.charName == "Caitlyn" ) then
--                 duration = 240000 range = 100 -- Nidalee trap / cait
--             elseif (wardtype == 0x02 and wardtype2 == 0x68  and creatorchamp.charName == "Shaco" ) then

--                 duration = 60000 range = 100 -- Shaco
--             else return
--             end
            
--             --placedWards[objectID] = {x = objectX2, y = objectY2, z = objectZ2, visionRange = range, color = yellowColor, spawnTime = GetTickCount(), duration = duration, vanga = 2}
--             tmpdrawtraps = {x = objectX2, y = objectY2, z = objectZ2, visionRange = range, color = yellowColor, spawnTime = GetTickCount(), duration = duration, vanga = 2, obnid = objectID }
--             table.insert(drawtraps, tmpdrawtraps)

--         end
        
--         if warddet == 0x3F and warddet2 == 0x33 and wardtype ~= 12 and wardtype ~= 48 then --wards 116 | wardtype 48 -> riven E
--             if wardtype2 == 0x6E then
--                 placedWards[objectID] = {x = objectX2, y = objectY2, z = objectZ2, visionRange = 1100, color = aquaColor, spawnTime = GetTickCount(), duration = 60000, vanga = 1 } -- WARDING TOTEM
--             elseif wardtype2 == 0x2E then
--                 placedWards[objectID] = {x = objectX2, y = objectY2, z = objectZ2, visionRange = 1100, color = aquaColor, spawnTime = GetTickCount(), duration = 120000, vanga = 1 }    -- GREATER TOTEM
--             elseif wardtype == 8 then
--                 tmppnk = {x = objectX2, y = objectY2, z = objectZ2, visionRange = 1100, color = purpleColor, vanga = 2, alive = 1, owner = creatorchamp.name } --Pink ward
--                 table.insert(pinkwards, tmppnk)
--             elseif wardtype == 137 then
--                 tmppnk = {x = objectX2, y = objectY2, z = objectZ2, visionRange = 1100, color = purpleColor, vanga = 2, alive = 1, owner = creatorchamp.name }
--                 table.insert(pinkwards, tmppnk)
--             elseif wardtype2 == 0xAE then
--                 placedWards[objectID] = {x = objectX2, y = objectY2, z = objectZ2, visionRange = 1100, color = aquaColor, spawnTime = GetTickCount(), duration = 180000, vanga = 1 }    -- GREATER STEALTH TOTEM
--             elseif wardtype2 == 0xEE then
--                 placedWards[objectID] = {x = objectX2, y = objectY2, z = objectZ2, visionRange = 1100, color = greenColor, spawnTime = GetTickCount(), duration = 180000, vanga = 1 }   -- WRIGGLES LANTERN
--             else
--                 placedWards[objectID] = {x = objectX2, y = objectY2, z = objectZ2, visionRange = 1100, color = visionColor, spawnTime = GetTickCount(), duration = ((wardtype2 == 0xB4 or wardtype2 == 0x6E) and 60000) or 180000, vanga = 1 }
--             end
--         end
--     end
--     p.pos = 1
-- end

function OnUnload()
    Serialization.saveTable({placedWards = placedWards, saveTime = GetInGameTimer()}, SCRIPT_PATH .. 'Common/IHateWards_cache.lua')
    UpdateWeb(false, ScriptName, id, HWID)

end

function round(num, idp)
    return string.format("%." .. (idp or 0) .. "f", num)
end


function OnDraw()
    CheckTimer()
    --print(#drawobjects)
    if WardsHater.ping then
        CheckLane()
    end
--          tmpdrawtraps = {x = objectX2, y = objectY2, z = objectZ2, visionRange = range, color = yellowColor, spawnTime = GetTickCount(), duration = duration, vanga = 2, obnid = objectID }
    if WardsHater.drawobj then

        for idx, table1 in ipairs(drawobjects) do
            if table1.object ~= nil and table1.object.valid then
                DrawCircle3D(table1.object.x, table1.object.y, table1.object.z, 120, 1,  ARGB(255, 0, 255, 255))
                time_left = (table1.end_tick - GetTickCount())/1000
                timer_text = " " .. TimerText(time_left)
                DrawText3D(timer_text, table1.object.x, myHero.y, table1.object.z, 15, ARGB(255,0,255,255), true)
            end
        end



        for idx, ward in ipairs(drawtraps) do
            if ward.obnid ~= nil then
                if (GetTickCount() - ward.spawnTime) > ward.duration then
                    drawtraps[idx] = nil
                else
                    local minimapPosition = GetMinimap(ward)
                    DrawTextWithBorder('.', 60, minimapPosition.x - 3, minimapPosition.y - 43, ward.color, blackColor)

                    local x, y, onScreen = get2DFrom3D(ward.x, ward.y, ward.z)
                    DrawTextWithBorder(TimerText((ward.duration - (GetTickCount() - ward.spawnTime)) / 1000), 20, x - 15, y - 11, ward.color, blackColor)

                    DrawCircle(ward.x, ward.y, ward.z, 90, ward.color)
                    if WardsHater.showvision then
                        DrawCircle(ward.x, ward.y, ward.z, ward.visionRange, ward.color)
                    end
                end
            end
        end
    end

    if WardsHater.drawwards then
        for idx, ward in pairs(pinkwards) do --Pink Wards
            if ward.alive == 1 then
                local minimapPosition = GetMinimap(ward)
                DrawTextWithBorder('.', 60, minimapPosition.x - 3, minimapPosition.y - 43, ward.color, blackColor)

                local x, y, onScreen = get2DFrom3D(ward.x, ward.y, ward.z)
                DrawTextWithBorder('Pink ward', 20, x - 15, y - 11, ward.color, blackColor)

                DrawCircle(ward.x, ward.y, ward.z, 90, ward.color)
                if WardsHater.showvision then
                    DrawCircle(ward.x, ward.y, ward.z, ward.visionRange, ward.color)
                end
            end
        end
        for networkID, ward in pairs(placedWards) do --PacketWards
            if (GetTickCount() - ward.spawnTime) > ward.duration then
                placedWards[networkID] = nil
            else
                local minimapPosition = GetMinimap(ward)
                DrawTextWithBorder('.', 60, minimapPosition.x - 3, minimapPosition.y - 43, ward.color, blackColor)

                local x, y, onScreen = get2DFrom3D(ward.x, ward.y, ward.z)
                DrawTextWithBorder(TimerText((ward.duration - (GetTickCount() - ward.spawnTime)) / 1000), 20, x - 15, y - 11, ward.color, blackColor)

                DrawCircle(ward.x, ward.y, ward.z, 90, ward.color)
                if WardsHater.showvision then
                    DrawCircle(ward.x, ward.y, ward.z, ward.visionRange, ward.color)
                end
            end
        end
    end

    if WardsHater.drawpath then
        for idx, champion in ipairs(GetEnemyHeroes()) do
            if champion.visible and not champion.dead then
                local current_waypoints = {}
                table.insert(current_waypoints, Vector(champion.visionPos.x, champion.visionPos.z))
                for i = champion.pathIndex, champion.pathCount do
                    path = champion:GetPath(i)
                    if path ~= nil and path.x then
                        table.insert(current_waypoints, Vector(path.x, path.z))
                    end
                end

                local travel_time = 0
                if #current_waypoints > 1 then
                    for current_index = 1, #current_waypoints-1 do
                        DrawLine3D(current_waypoints[current_index].x, myHero.y, current_waypoints[current_index].y, current_waypoints[current_index+1].x, myHero.y, current_waypoints[current_index+1].y, 2, ARGB(255, 255, 0, 0) )
                            if current_index == #current_waypoints-1 then
                                local endpoint = current_waypoints[current_index+1]
                                if WardsHater.drawcross then
                                    DrawText3D(champion.charName, current_waypoints[current_index+1].x+WardsHater.txtxpos, myHero.y, current_waypoints[current_index+1].y+WardsHater.txtypos, WardsHater.txtsize, ARGB(255, 255, 255, 0), true)
                                    DrawLine3D(endpoint.x-WardsHater.crosssize, myHero.y, endpoint.y+WardsHater.crosssize, endpoint.x+WardsHater.crosssize, myHero.y, endpoint.y-WardsHater.crosssize, WardsHater.crosswidth, ARGB(255, 255, 0, 0) )
                                    DrawLine3D(endpoint.x+WardsHater.crosssize, myHero.y, endpoint.y+WardsHater.crosssize, endpoint.x-WardsHater.crosssize, myHero.y, endpoint.y-WardsHater.crosssize, WardsHater.crosswidth, ARGB(255, 255, 0, 0) )
                                end
                            end
                        if WardsHater.drawpathtime then
                            local current_time = GetDistance(current_waypoints[current_index], current_waypoints[current_index+1])/champion.ms
                            travel_time = travel_time + current_time
                            DrawText3D(round(travel_time,1) .. " s", current_waypoints[current_index+1].x, myHero.y, current_waypoints[current_index+1].y+100, WardsHater.timertxtsize, ARGB(255,0,255,0), true)
                        end
                    end
                end
            end
        end
    end

    if WardsHater.drawallypath then
        for idx, champion in ipairs(GetAllyHeroes()) do
            if champion.visible and not champion.dead then
                local current_waypoints = {}
                table.insert(current_waypoints, Vector(champion.visionPos.x, champion.visionPos.z))
                for i = champion.pathIndex, champion.pathCount do
                    path = champion:GetPath(i)
                    if path ~= nil and path.x then
                        table.insert(current_waypoints, Vector(path.x, path.z))
                    end
                end

                local travel_time = 0
                if #current_waypoints > 1 then
                    for current_index = 1, #current_waypoints-1 do
                        DrawLine3D(current_waypoints[current_index].x, myHero.y, current_waypoints[current_index].y, current_waypoints[current_index+1].x, myHero.y, current_waypoints[current_index+1].y, 2, ARGB(255, 0, 255, 0) )
                        if current_index == #current_waypoints-1 then
                                local endpoint = current_waypoints[current_index+1]
                                if WardsHater.drawcross then
                                    DrawText3D(champion.charName, current_waypoints[current_index+1].x+WardsHater.txtxpos, myHero.y, current_waypoints[current_index+1].y+WardsHater.txtypos, WardsHater.txtsize, ARGB(255, 255, 255, 0), true)
                                    DrawLine3D(endpoint.x-WardsHater.crosssize, myHero.y, endpoint.y+WardsHater.crosssize, endpoint.x+WardsHater.crosssize, myHero.y, endpoint.y-WardsHater.crosssize, WardsHater.crosswidth, ARGB(255,0,255,0) )
                                    DrawLine3D(endpoint.x+WardsHater.crosssize, myHero.y, endpoint.y+WardsHater.crosssize, endpoint.x-WardsHater.crosssize, myHero.y, endpoint.y-WardsHater.crosssize, WardsHater.crosswidth, ARGB(255,0,255,0) )
                                end
                        end
                        if WardsHater.drawpathtime then
                            local current_time = GetDistance(current_waypoints[current_index], current_waypoints[current_index+1])/champion.ms
                            travel_time = travel_time + current_time
                            DrawText3D(round(travel_time,1) .. " s", current_waypoints[current_index+1].x, myHero.y, current_waypoints[current_index+1].y+100, WardsHater.timertxtsize, ARGB(255,0,255,0), true)
                        end
                    end
                end
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
--==END CANH BAO
