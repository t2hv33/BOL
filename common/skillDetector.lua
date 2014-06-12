--[[
	Skill Detector Library 1.6
		by eXtragoZ
]]
do
--[[		Code		]]
local spellsFile = LIB_PATH.."missedspells.txt"
local spellslist = {}
local textlist = ""
local spellexists = false
local spelltype = "Unknown"

function writeConfigsspells()
	local file = io.open(spellsFile, "w")
	if file then
		textlist = "return {"
		for i=1,#spellslist do
			textlist = textlist.."'"..spellslist[i].."', "
		end
		textlist = textlist.."}"
		if spellslist[1] ~=nil then
			file:write(textlist)
			file:close()
		end
	end
end
if file_exists(spellsFile) then spellslist = dofile(spellsFile) end

--[[function OnProcessSpell(unit, spell)
	if unit ~= nil and unit.type == "obj_AI_Hero" then
		local spellName = spell.name
		local spelltypeprint = getSpellType(unit, spellName)
		PrintChat(""..spelltypeprint)
		--PrintChat(""..spellName)
	end
	--if unit.isMe then
	--	PrintChat(""..spell.name)
	--end
end]]

local Others = {"Recall","recall","OdinCaptureChannel","LanternWAlly"}
local Items = {"RegenerationPotion","FlaskOfCrystalWater","ItemCrystalFlask","ItemMiniRegenPotion","PotionOfBrilliance","PotionOfElusiveness","PotionOfGiantStrength","OracleElixirSight","OracleExtractSight","VisionWard","SightWard","ItemGhostWard","ItemMiniWard","ElixirOfRage","ElixirOfIllumination","wrigglelantern","DeathfireGrasp","HextechGunblade","shurelyascrest","IronStylus","ZhonyasHourglass","YoumusBlade","MorellosTome","randuinsomen","RanduinsOmen","Mourning","OdinEntropicClaymore","BilgewaterCutlass","QuicksilverSash","HextechSweeper","ItemGlacialSpike","ItemMercurial","ItemWraithCollar","ItemSoTD","ItemMorellosBane","ItemPromote","ItemTiamatCleave","Muramana","ItemSeraphsEmbrace","ItemSwordOfFeastAndFamine"}
local MSpells = {"JayceStaticField","JayceToTheSkies","JayceThunderingBlow","Takedown","Pounce","Swipe","EliseSpiderQCast","EliseSpiderW","EliseSpiderEInitial","elisespidere","elisespideredescent"}
local PSpells = {"CaitlynHeadshotMissile","RumbleOverheatAttack","JarvanIVMartialCadenceAttack","ShenKiAttack","MasterYiDoubleStrike","sonahymnofvalorattackupgrade","sonaariaofperseveranceupgrade","sonasongofdiscordattackupgrade","NocturneUmbraBladesAttack","NautilusRavageStrikeAttack","ZiggsPassiveAttack"}

local QSpells = {"TrundleQ","LeonaShieldOfDaybreakAttack","XenZhaoThrust","NautilusAnchorDragMissile","RocketGrabMissile","VayneTumbleAttack","VayneTumbleUltAttack","NidaleeTakedownAttack","GragasBarrelRollMissile","ShyvanaDoubleAttackHit","ShyvanaDoubleAttackHitDragon","frostarrow","FrostArrow","MonkeyKingQAttack","MaokaiTrunkLineMissile","FlashFrostSpell","xeratharcanopulsedamage","xeratharcanopulsedamageextended","xeratharcanopulsedarkiron","xeratharcanopulsediextended","SpiralBladeMissile","EzrealMysticShotMissile","EzrealMysticShotPulseMissile","jayceshockblast","BrandBlazeMissile","UdyrTigerAttack","TalonNoxianDiplomacyAttack","LuluQMissile","GarenSlash2","VolibearQAttack","khazixqevo","dravenspinningattack","karmaheavenlywavec","ZiggsQSpell","UrgotHeatseekingHomeMissile","UrgotHeatseekingLineMissile","JavelinToss","RivenTriCleave","namiqmissile","SiphoningStrikeAttack","BlindMonkQOne","ThreshQInternal"}
local WSpells = {"KogMawBioArcaneBarrageAttack","RicochetAttack","TwitchVenomCaskMissile","gravessmokegrenadeboom","mordekaisercreepingdeath","DrainChannel","jaycehypercharge","redcardpreattack","goldcardpreattack","bluecardpreattack","RenektonExecute","RenektonSuperExecute","EzrealEssenceFluxMissile","DariusNoxianTacticsONHAttack","UdyrTurtleAttack","talonrakemissileone","LuluWTwo","ObduracyAttack","KennenMegaProc","NautilusWideswingAttack","NautilusBackswingAttack","khazixwevo","XerathLocusOfPower","yoricksummondecayed"}
local ESpells = {"KogMawVoidOozeMissile","ToxicShotAttack","LeonaZenithBladeMissile","PowerFistAttack","VayneCondemnMissile","ShyvanaFireballMissile","maokaisapling2boom","VarusEMissile","varusemissiledummy","CaitlynEntrapmentMissile","jayceaccelerationgate","syndrae5","JudicatorRighteousFuryAttack","UdyrBearAttack","RumbleGrenadeMissile","khazixeevo","Slash","hecarimrampattack","ziggse2","UrgotPlasmaGrenadeBoom","SkarnerFractureMissile","YorickSummonRavenous","BlindMonkEOne","EliseHumanE","PrimalSurge","Swipe","ViEAttack"}
local RSpells = {"Pantheon_GrandSkyfall_Fall","LuxMaliceCannonMis","infiniteduresschannel","JarvanIVCataclysmAttack","jarvanivcataclysmattack","VayneUltAttack","RumbleCarpetBombDummy","ShyvanaTransformLeap","jaycepassiverangedattack", "jaycepassivemeleeattack","jaycestancegth","MissileBarrageMissile","SprayandPrayAttack","jaxrelentlessattack","syndrarcasttime","khazixrevo","InfernalGuardian","UdyrPhoenixAttack","FioraDanceStrike","xeratharcanebarragedi","NamiRMissile","HallucinateFull"}

function getSpellType(unit, spellName)
	spelltype = "Unknown"
	if unit ~= nil and unit.type == "obj_AI_Hero" then
		if spellName:find("BasicAttack") or spellName:find("basicattack") or spellName:find("JayceRangedAttack") or spellName == "SonaHymnofValorAttack" or spellName == "SonaSongofDiscordAttack" or spellName == "SonaAriaofPerseveranceAttack" then
			spelltype = "BAttack"
		elseif spellName:find("CritAttack") or spellName:find("critattack") then
			spelltype = "CAttack"
		elseif unit:GetSpellData(_Q).name:find(spellName) then
			spelltype = "Q"
		elseif unit:GetSpellData(_W).name:find(spellName) then
			spelltype = "W"
		elseif unit:GetSpellData(_E).name:find(spellName) then
			spelltype = "E"
		elseif unit:GetSpellData(_R).name:find(spellName) then
			spelltype = "R"
		elseif spellName:find("Summoner") or spellName:find("summoner") then
			spelltype = "Summoner"
		else
			spellexists = false
			if not spellexists then
				for i=1,#Others do
					if spellName:find(Others[i]) then
						spelltype = "Other"
						spellexists = true
					end
				end
			end
			if not spellexists then
				for i=1,#Items do
					if spellName:find(Items[i]) then
						spelltype = "Item"
						spellexists = true
					end
				end
			end
			if not spellexists then
				for i=1,#PSpells do
					if spellName:find(PSpells[i]) then
						spelltype = "P"
						spellexists = true
					end
				end
			end
			if not spellexists then
				for i=1,#QSpells do
					if spellName:find(QSpells[i]) then
						spelltype = "Q"
						spellexists = true
					end
				end
			end
			if not spellexists then
				for i=1,#WSpells do
					if spellName:find(WSpells[i]) then
						spelltype = "W"
						spellexists = true
					end
				end
			end
			if not spellexists then
				for i=1,#ESpells do
					if spellName:find(ESpells[i]) then
						spelltype = "E"
						spellexists = true
					end
				end
			end
			if not spellexists then
				for i=1,#RSpells do
					if spellName:find(RSpells[i]) then
						spelltype = "R"
						spellexists = true
					end
				end
			end
			if #spellslist > 0 and not spellexists then
				for i=1,#spellslist do
					if spellName == spellslist[i] then
						spellexists = true
					end
				end
			end
			if not spellexists then
				table.insert(spellslist, spellName)
				writeConfigsspells()
				PrintChat(""..spellName)
			end
		end
		for i=1,#MSpells do
			if spellName == MSpells[i] then
				spelltype = spelltype.."M"
			end
		end
	end
	return spelltype
end
end