local version = 0.2
--Version 0.1
--Init All In One for BolScript.com by BomD
--Orbwaler standalone and skillshoot
--Version 0.2
--Add TurnAround.
--Advanced Turn Around - Dodge it, by turning around!



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
    require("SourceLib")
else
    DOWNLOADING_SOURCELIB = true
    DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end
require "old2dgeo"
local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Init Freaking Evadee
--end evadee




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
    }
}
--Skillshoot init 0.1
if not Champs[myHero.charName] then return end -- put other declarations after this check
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
}

function OnLoad()
    DelayAction(DelayedLoad, 1)
    --New Aiming
      VP = VPrediction()
    Config = scriptConfig("BolScript-Skillshoot: Cài Ðät.", "BolScript")
   -- if Champs[myHero.charName] ~= nil then -- this check is on line 297
    for i, spell in pairs(data) do
        Config:addParam(str[i], "Xài'-" .. str[i], ConfigType, false, GetKey(keybindings[i]))
        predictions[str[i]] = {spell.range, spell.speed, spell.delay, spell.minionCollisionWidth, i}
    end 
    Config:addParam("accuracy", "Ðoán Chính Xác", SCRIPT_PARAM_SLICE, 1, 0, 5, 0)
    Config:addParam("rangeoffset", "Giäm? Range Xài Chiêu", SCRIPT_PARAM_SLICE, 0, 0, 200, 0)
    Config:addParam("autocast", "Auto Xài khi 100% trung' (L)", SCRIPT_PARAM_ONKEYTOGGLE, false, 76)
	Config:permaShow("autocast")
	ts2.name = "Skillshoot"
    Config:addTS(ts2)
    initDone = true
    PrintChat ("<font color='#14C4DB'>Skillshoot and Olbwalker</font> <font color='#7fe8c2'>of</font> <font color='#DB32D0'>BolScript.com</font> <font color='#7fe8c2'>cho free user by</font> <font color='#e97fa5'>BomD</font></font>")

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

        TurnAroundMenu:addSubMenu("Champions and Spells", "cas")
        for i = 1, #TurnAroundTable.champions, 1 do
            if i ~= 3 then
                TurnAroundMenu.cas:addSubMenu("Né -"..TurnAroundTable.champions[i].charName, TurnAroundTable.champions[i].charName)
            end
            TurnAroundMenu.cas[TurnAroundTable.champions[i].charName]:addParam(TurnAroundTable.champions[i].key, TurnAroundTable.champions[i].spellName, SCRIPT_PARAM_ONOFF, true)
        end

    --End Turn Around

end

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
            Menu:addSubMenu("Spells", "Spells"..myHero.charName)
            for id, spell in pairs(Spells[myHero.charName]) do
                Menu["Spells"..myHero.charName]:addSubMenu(SpellToString(id).." - "..spell.name, "id"..id)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Enabled", "Enabled", SCRIPT_PARAM_ONOFF, false)

                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode3", "Enabled khi Last Hit mode", SCRIPT_PARAM_ONOFF, true)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode2", "Enabled khi Lane Clear mode", SCRIPT_PARAM_ONOFF, true)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode1", "Enabled khi Mixed mode", SCRIPT_PARAM_ONOFF, true)
                Menu["Spells"..myHero.charName]["id"..id]:addParam("Mode0", "Enabled khi CarryMe mode", SCRIPT_PARAM_ONOFF, true)

                Menu["Spells"..myHero.charName]["id"..id]:addParam(tostring(string.gsub(myHero.type, "_", "")), "Use against champions", SCRIPT_PARAM_ONOFF, true)
                Menu["Spells"..myHero.charName]["id"..id]:addParam(tostring(string.gsub("obj_AI_Minion", "_", "")), "Use against minions", SCRIPT_PARAM_ONOFF, true)
            end
        end
        Menu:addSubMenu("Drawing", "Drawing")

        AArangeCircle = DManager:CreateCircle(myHero, SOWi:MyRange()+50, 1, {255, 255, 255, 255})
        AArangeCircle:AddToMenu(Menu.Drawing, "Tâm`Ðánh AA", false, true, true)

        SOWi:LoadToMenu(Menu)
        SOWi:RegisterAfterAttackCallback(AfterAttack)
        --Config:permaShow("Mode0")
        Menu:permaShow("Mode0")
    end
end

--Aiming
--Credit Trees
function GetCustomTarget()
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
    ts2:update()
    --print('tstarget called')
    return ts2.target
end
--End Credit Trees

--End Aiming
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
end

--Off





