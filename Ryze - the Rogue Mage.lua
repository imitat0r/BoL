local version = "1.5"

--[[
	Ryze - the Rogue Mage
		Author: Draconis
		Version: 1.5
		Copyright 2015
			
	Dependency: Standalone
--]]

if myHero.charName ~= "Ryze" then return end

require 'SxOrbwalk'
require 'UPL'

------------------------------------------------------
--			 Callbacks				
------------------------------------------------------

function OnLoad()
	print("<b><font color=\"#6699FF\">Ryze - the Rogue Mage:</font></b> <font color=\"#FFFFFF\">Good luck and have fun!</font>")
	Variables()
	Menu()
	PriorityOnLoad()
	
	if VIP_USER then
		HookPackets()
	end
end

function OnTick()
	ComboKey = Settings.combo.comboKey
	HarassKey = Settings.harass.harassKey
	HarassToggle = Settings.harass.harassToggle
	LaneClearKey = Settings.lane.laneKey
	JungleClearKey = Settings.jungle.jungleKey
	FarmKey = Settings.farm.farmKey
	FarmToggle = Settings.farm.farmToggle
	
	if ComboKey then
		if Settings.combo.comboMode == 1 then
			burstCombo(Target)
		else
			longCombo(Target)
		end
	end
	
	if HarassKey then
		Harass(Target)
	elseif HarassToggle then
		Harass(Target)
	end
	
	if FarmKey then
		Farm()
	elseif FarmToggle and not (ComboKey or HarassKey) then
		Farm()
	end
	
	if JungleClearKey then
		JungleClear()
	end
	
	if LaneClearKey then
		LaneClear()
	end
	
	if Settings.ks.killSteal then
		KillSteal()
	end

	Checks()
end

function OnDraw()
	if not myHero.dead and not Settings.drawing.mDraw then
		if SkillQ.ready and Settings.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
		end
		if SkillW.ready and Settings.drawing.wDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, RGB(Settings.drawing.wColor[2], Settings.drawing.wColor[3], Settings.drawing.wColor[4]))
		end
		if SkillE.ready and Settings.drawing.eDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillE.range, RGB(Settings.drawing.eColor[2], Settings.drawing.eColor[3], Settings.drawing.eColor[4]))
		end
		
		if Settings.drawing.Target and Target ~= nil then
			DrawCircle(Target.x, Target.y, Target.z, 70, 0xCE00FF)
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range + GetDistance(myHero, myHero.minBBox), RGB(Settings.drawing.myColor[2], Settings.drawing.myColor[3], Settings.drawing.myColor[4]))
		end
	end
end

------------------------------------------------------
--			 Functions				
------------------------------------------------------

function burstCombo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if isFacing(myHero, unit) then
			if Settings.combo.comboItems then
				UseItems(unit)
			end
			
			CastQ(unit)
			if Settings.combo.useR then CastR() end
			CastW(unit)
			CastE(unit)
		elseif not isFacing(unit, myHero) then
			if Settings.combo.comboItems then
				UseItems(unit)
			end
			
			CastW(unit)
			if Settings.combo.useR then CastR() end
			CastQ(unit)
			CastE(unit)
		end
	end
end

function longCombo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
			if Settings.combo.comboItems then
				UseItems(unit)
			end
			
			CastQ(unit)
			if Settings.combo.useR then CastR() end
			CastQ(unit)
			CastW(unit)
			CastQ(unit)
			CastE(unit)
			CastQ(unit)
			CastW(unit)
			CastQ(unit)
			CastE(unit)
			CastQ(unit)
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and not IsMyManaLow("Harass") then
		if Settings.harass.useW then CastW(unit) end
		if Settings.harass.useE then CastE(unit) end
		if Settings.harass.useQ then CastQ(unit) end
	end
end

function JungleClear()
	if Settings.jungle.jungleKey then
		local JungleMob = GetJungleMob()
		
		if JungleMob ~= nil then
			if Settings.jungle.jungleE and GetDistance(JungleMob) <= SkillE.range then
				CastSpell(_E, JungleMob)
			end
			if Settings.jungle.jungleQ and GetDistance(JungleMob) <= SkillQ.range then
				CastSpell(_Q, JungleMob.x, JungleMob.z)
			end
			if Settings.jungle.jungleW and GetDistance(JungleMob) <= SkillW.range then
				CastSpell(_W, JungleMob)
			end
		end
	end
end

function Farm()
	enemyMinions:update()
	for i, minion in pairs(enemyMinions.objects) do
		qDmg = getDmg("Q", minion, myHero)
		wDmg = getDmg("W", minion, myHero)
		eDmg = getDmg("E", minion, myHero)
		
		if ValidTarget(minion) and minion ~= nil and not IsMyManaLow("Farm") then
			if minion.health <= qDmg and Settings.farm.farmQ then
				CastQ(minion)
			elseif minion.health <= wDmg and Settings.farm.farmW then
				CastW(minion)
			elseif minion.health <= eDmg and Settings.farm.farmE then
				CastE(minion)
			end
		end		 
	end
end

function LaneClear()
	enemyMinions:update()
	if LaneClearKey then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil then
				if Settings.lane.laneR and GetDistance(minion) <= SkillQ.range and SkillR.ready then CastSpell(_R) end
				if Settings.lane.laneQ and GetDistance(minion) <= SkillQ.range and SkillQ.ready then CastSpell(_Q, minion) end
				if Settings.lane.laneW and GetDistance(minion) <= SkillW.range and SkillW.ready then CastSpell(_W, minion) end
				if Settings.lane.laneE and GetDistance(minion) <= SkillE.range and SkillE.ready then CastSpell(_E, minion) end
			end		 
		end
	end
end

function CastQ(unit)	
	if unit ~= nil and GetDistance(unit) <= SkillQ.range and SkillQ.ready then
		local CastPosition, HitChance, HeroPosition = UPL:Predict(_Q, myHero, unit)
				
		if HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastE(unit)
	if unit ~= nil and GetDistance(unit) <= SkillE.range and SkillE.ready then
		if VIP_USER and Settings.misc.packets then
			Packet("S_CAST", {spellId = _E, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_E, unit)
		end
	end
end

function CastW(unit)
	if unit ~= nil and SkillW.ready and GetDistance(unit) <= SkillW.range then
		if VIP_USER and Settings.misc.packets then
			Packet("S_CAST", {spellId = _W, targetNetworkId = unit.networkID}):send()
		else
			CastSpell(_W, unit)
		end
	end
end

function CastR()
	if SkillR.ready then
		if Settings.combo.useR == 1 then
			return
		elseif Settings.combo.useR == 2 and CountEnemyHeroInRange(SkillQ.range, myHero) >= 1 then
			CastSpell(_R) 
		elseif Settings.combo.useR == 3 and CountEnemyHeroInRange(SkillQ.range, myHero) >= 2 then
			CastSpell(_R)
		elseif Settings.combo.useR == 4 and CountEnemyHeroInRange(SkillQ.range, myHero) >= 3 then
			CastSpell(_R)
		elseif Settings.combo.useR == 5 and CountEnemyHeroInRange(SkillQ.range, myHero) >= 4 then
			CastSpell(_R)
		end
	end
end

function KillSteal()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", enemy, myHero)
		wDmg = getDmg("W", enemy, myHero)
		
		if ValidTarget(enemy) and enemy.visible then
			if enemy.health <= qDmg then
				CastQ(enemy)
			elseif enemy.health <= wDmg then
				CastW(enemy)
			elseif enemy.health <= qDmg + wDmg then
				CastW(enemy)
				CastQ(enemy)
			end

			if Settings.ks.autoIgnite then
				AutoIgnite(enemy)
			end
		end
	end
end

function AutoIgnite(unit)
	if ValidTarget(unit, Ignite.range) and unit.health <= 50 + (20 * myHero.level) then
		if Ignite.ready then
			CastSpell(Ignite.slot, unit)
		end
	end
end

------------------------------------------------------
--			 Checks, menu & stuff				
------------------------------------------------------

function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillE.ready = (myHero:CanUseSpell(_E) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)
	
	if myHero:GetSpellData(SUMMONER_1).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find(Ignite.name) then
		Ignite.slot = SUMMONER_2
	end
	
	Ignite.ready = (Ignite.slot ~= nil and myHero:CanUseSpell(Ignite.slot) == READY)
	
	TargetSelector:update()
	enemyMinions:update()
	
	Target = GetCustomTarget()
	
	if Settings.drawing.lfc.lfc then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
	
	if Settings.combo.comboSwitch and Settings.combo.comboMode == 1 then
		Settings.combo.comboMode = 2
	elseif not Settings.combo.comboSwitch and Settings.combo.comboMode == 2 then
		Settings.combo.comboMode = 1
	end
end

function IsMyManaLow(mode)
	if mode == "Harass" then
		if myHero.mana < (myHero.maxMana * ( Settings.harass.harassMana / 100)) then
			return true
		else
			return false
		end
	elseif mode == "Farm" then
		if myHero.mana < (myHero.maxMana * ( Settings.farm.farmMana / 100)) then
			return true
		else
			return false
		end
	end
end

function Menu()
	Settings = scriptConfig("Ryze - the Rogue Mage "..version.."", "DraconisRyze")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("comboSwitch", "Combo Switch", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("A"))
		Settings.combo:addParam("comboMode", "Combo Mode", SCRIPT_PARAM_LIST, 1, { "Burst", "Long" })
		Settings.combo:addParam("useR", "Use "..SkillR.name.." (R) in Combo", SCRIPT_PARAM_LIST, 1, { "No", ">1 targets", ">2 targets", ">3 targets", ">4 targets" })
		Settings.combo:addParam("comboItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:permaShow("comboKey")
		Settings.combo:permaShow("comboMode")
	
	Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
		Settings.harass:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		Settings.harass:addParam("harassToggle", "Harass Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
		Settings.harass:addParam("useQ", "Use "..SkillQ.name.." (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useW", "Use "..SkillW.name.." (W) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useE", "Use "..SkillE.name.." (E) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.harass:permaShow("harassKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Farm Settings", "farm")
		Settings.farm:addParam("farmKey", "Farm Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("X"))
		Settings.farm:addParam("farmToggle", "Farm Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
		Settings.farm:addParam("farmQ", "Farm with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.farm:addParam("farmW", "Farm with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, false)
		Settings.farm:addParam("farmE", "Farm with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, false)
		Settings.farm:addParam("farmMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.farm:permaShow("farmKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "lane")
		Settings.lane:addParam("laneKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.lane:addParam("laneQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:addParam("laneW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:addParam("laneE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:addParam("laneR", "Clear with "..SkillR.name.." (R)", SCRIPT_PARAM_ONOFF, false)
		Settings.lane:permaShow("laneKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Jungle Clear Settings", "jungle")
		Settings.jungle:addParam("jungleKey", "Jungle Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.jungle:addParam("jungleQ", "Clear with "..SkillQ.name.." (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:addParam("jungleE", "Clear with "..SkillE.name.." (E)", SCRIPT_PARAM_ONOFF, true)
		Settings.jungle:permaShow("jungleKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal Settings", "ks")
		Settings.ks:addParam("killSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Settings.ks:addParam("autoIgnite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		Settings.ks:permaShow("killSteal")
			
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("Target", "Draw Circle on Target", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Settings.drawing:addParam("wDraw", "Draw "..SkillW.name.." (W) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("wColor", "Draw "..SkillW.name.." (W) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		Settings.drawing:addParam("eDraw", "Draw "..SkillE.name.." (E) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("eColor", "Draw "..SkillE.name.." (E) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		
		Settings.drawing:addSubMenu("Lag Free Circles", "lfc")	
			Settings.drawing.lfc:addParam("lfc", "Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
			Settings.drawing.lfc:addParam("CL", "Quality", 4, 1500, 75, 2000, 0)
			Settings.drawing.lfc:addParam("Width", "Width", 4, 1, 1, 10, 0)
		
	Settings:addSubMenu("["..myHero.charName.."] - Misc Settings", "misc")	
		Settings.misc:addParam("packets", "Cast spells using Packets", SCRIPT_PARAM_ONOFF, true)
		
	Settings:addSubMenu("["..myHero.charName.."] - Prediction Settings", "Prediction")
		UPL:AddToMenu(Settings.Prediction)
	
	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		if _G.Reborn_Loaded ~= nil then
			Settings.Orbwalking:addParam("Info", "Sida's Auto Carry detected!", SCRIPT_PARAM_INFO, "")
		elseif _G.MMA_Loaded ~= nil then
			Settings.Orbwalking:addParam("Info", "Marksman's Mighty Assistant detected!", SCRIPT_PARAM_INFO, "")
		else
			SxOrb:LoadToMenu(Settings.Orbwalking)
		end
		
	TargetSelector = TargetSelector(TARGET_LESS_CAST, SkillQ.range, DAMAGE_MAGIC, true)
	TargetSelector.name = "Ryze"
	Settings:addTS(TargetSelector)
end

function Variables()
	SkillQ = { name = "Overload", range = 900, delay = 0.25, speed = 1700, width = 50, ready = false }
	SkillW = { name = "Rune Prison", range = 600, delay = nil, speed = nil, width = nil, ready = false }
	SkillE = { name = "Spell Flux", range = 600, delay = nil, speed = nil, width = nil, ready = false }
	SkillR = { name = "Desperate Power", range = nil, delay = nil, speed = nil, width = nil, ready = false }
	Ignite = { name = "summonerdot", range = 600, slot = nil }
	
	enemyMinions = minionManager(MINION_ENEMY, SkillQ.range, myHero, MINION_SORT_HEALTH_ASC)
	
	UPL = UPL()
	UPL:AddSpell(_Q, { speed = SkillQ.speed, delay = SkillQ.delay, range = SkillQ.range, width = SkillQ.width, collision = true, aoe = false, type = "linear" })
	
	JungleMobs = {}
	JungleFocusMobs = {}
	
	if GetGame().map.shortName == "twistedTreeline" then
		TwistedTreeline = true 
	else
		TwistedTreeline = false
	end
	
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
	
	priorityTable = {
			AP = {
				"Annie", "Ahri", "Akali", "Anivia", "Annie", "Brand", "Cassiopeia", "Diana", "Evelynn", "FiddleSticks", "Fizz", "Gragas", "Heimerdinger", "Karthus",
				"Kassadin", "Katarina", "Kayle", "Kennen", "Leblanc", "Lissandra", "Lux", "Malzahar", "Mordekaiser", "Morgana", "Nidalee", "Orianna",
				"Ryze", "Sion", "Swain", "Syndra", "Teemo", "TwistedFate", "Veigar", "Viktor", "Vladimir", "Xerath", "Ziggs", "Zyra", "Velkoz"
			},
			
			Support = {
				"Alistar", "Blitzcrank", "Janna", "Karma", "Leona", "Lulu", "Nami", "Nunu", "Sona", "Soraka", "Taric", "Thresh", "Zilean", "Braum"
			},
			
			Tank = {
				"Amumu", "Chogath", "DrMundo", "Galio", "Hecarim", "Malphite", "Maokai", "Nasus", "Rammus", "Sejuani", "Nautilus", "Shen", "Singed", "Skarner", "Volibear",
				"Warwick", "Yorick", "Zac"
			},
			
			AD_Carry = {
				"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jayce", "Jinx", "KogMaw", "Lucian", "MasterYi", "MissFortune", "Pantheon", "Quinn", "Shaco", "Sivir",
				"Talon","Tryndamere", "Tristana", "Twitch", "Urgot", "Varus", "Vayne", "Yasuo", "Zed"
			},
			
			Bruiser = {
				"Aatrox", "Darius", "Elise", "Fiora", "Gangplank", "Garen", "Irelia", "JarvanIV", "Jax", "Khazix", "LeeSin", "Nocturne", "Olaf", "Poppy",
				"Renekton", "Rengar", "Riven", "Rumble", "Shyvana", "Trundle", "Udyr", "Vi", "MonkeyKing", "XinZhao"
			}
	}

	Items = {
		BRK = { id = 3153, range = 450, reqTarget = true, slot = nil },
		BWC = { id = 3144, range = 400, reqTarget = true, slot = nil },
		DFG = { id = 3128, range = 750, reqTarget = true, slot = nil },
		HGB = { id = 3146, range = 400, reqTarget = true, slot = nil },
		RSH = { id = 3074, range = 350, reqTarget = false, slot = nil },
		STD = { id = 3131, range = 350, reqTarget = false, slot = nil },
		TMT = { id = 3077, range = 350, reqTarget = false, slot = nil },
		YGB = { id = 3142, range = 350, reqTarget = false, slot = nil },
		BFT = { id = 3188, range = 750, reqTarget = true, slot = nil },
		RND = { id = 3143, range = 275, reqTarget = false, slot = nil }
	}
	
	if not TwistedTreeline then
		JungleMobNames = { 
			["SRU_MurkwolfMini2.1.3"]	= true,
			["SRU_MurkwolfMini2.1.2"]	= true,
			["SRU_MurkwolfMini8.1.3"]	= true,
			["SRU_MurkwolfMini8.1.2"]	= true,
			["SRU_BlueMini1.1.2"]		= true,
			["SRU_BlueMini7.1.2"]		= true,
			["SRU_BlueMini21.1.3"]		= true,
			["SRU_BlueMini27.1.3"]		= true,
			["SRU_RedMini10.1.2"]		= true,
			["SRU_RedMini10.1.3"]		= true,
			["SRU_RedMini4.1.2"]		= true,
			["SRU_RedMini4.1.3"]		= true,
			["SRU_KrugMini11.1.1"]		= true,
			["SRU_KrugMini5.1.1"]		= true,
			["SRU_RazorbeakMini9.1.2"]	= true,
			["SRU_RazorbeakMini9.1.3"]	= true,
			["SRU_RazorbeakMini9.1.4"]	= true,
			["SRU_RazorbeakMini3.1.2"]	= true,
			["SRU_RazorbeakMini3.1.3"]	= true,
			["SRU_RazorbeakMini3.1.4"]	= true
		}
		
		FocusJungleNames = {
			["SRU_Blue1.1.1"]			= true,
			["SRU_Blue7.1.1"]			= true,
			["SRU_Murkwolf2.1.1"]		= true,
			["SRU_Murkwolf8.1.1"]		= true,
			["SRU_Gromp13.1.1"]			= true,
			["SRU_Gromp14.1.1"]			= true,
			["Sru_Crab16.1.1"]			= true,
			["Sru_Crab15.1.1"]			= true,
			["SRU_Red10.1.1"]			= true,
			["SRU_Red4.1.1"]			= true,
			["SRU_Krug11.1.2"]			= true,
			["SRU_Krug5.1.2"]			= true,
			["SRU_Razorbeak9.1.1"]		= true,
			["SRU_Razorbeak3.1.1"]		= true,
			["SRU_Dragon6.1.1"]			= true,
			["SRU_Baron12.1.1"]			= true
		}
	else
		FocusJungleNames = {
			["TT_NWraith1.1.1"]			= true,
			["TT_NGolem2.1.1"]			= true,
			["TT_NWolf3.1.1"]			= true,
			["TT_NWraith4.1.1"]			= true,
			["TT_NGolem5.1.1"]			= true,
			["TT_NWolf6.1.1"]			= true,
			["TT_Spiderboss8.1.1"]		= true
		}		
		JungleMobNames = {
			["TT_NWraith21.1.2"]		= true,
			["TT_NWraith21.1.3"]		= true,
			["TT_NGolem22.1.2"]			= true,
			["TT_NWolf23.1.2"]			= true,
			["TT_NWolf23.1.3"]			= true,
			["TT_NWraith24.1.2"]		= true,
			["TT_NWraith24.1.3"]		= true,
			["TT_NGolem25.1.1"]			= true,
			["TT_NWolf26.1.2"]			= true,
			["TT_NWolf26.1.3"]			= true
		}
	end
		
	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object and object.valid and not object.dead then
			if FocusJungleNames[object.name] then
				JungleFocusMobs[#JungleFocusMobs+1] = object
			elseif JungleMobNames[object.name] then
				JungleMobs[#JungleMobs+1] = object
			end
		end
	end
end

function SetPriority(table, hero, priority)
	for i=1, #table, 1 do
		if hero.charName:find(table[i]) ~= nil then
			TS_SetHeroPriority(priority, hero.charName)
		end
	end
end
 
function arrangePrioritys()
        for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,       enemy, 2)
		SetPriority(priorityTable.Support,  enemy, 3)
		SetPriority(priorityTable.Bruiser,  enemy, 4)
		SetPriority(priorityTable.Tank,     enemy, 5)
        end
end

function arrangePrioritysTT()
        for i, enemy in ipairs(GetEnemyHeroes()) do
		SetPriority(priorityTable.AD_Carry, enemy, 1)
		SetPriority(priorityTable.AP,       enemy, 1)
		SetPriority(priorityTable.Support,  enemy, 2)
		SetPriority(priorityTable.Bruiser,  enemy, 2)
		SetPriority(priorityTable.Tank,     enemy, 3)
        end
end

function UseItems(unit)
	if unit ~= nil then
		for _, item in pairs(Items) do
			item.slot = GetInventorySlotItem(item.id)
			if item.slot ~= nil then
				if item.reqTarget and GetDistance(unit) < item.range then
					CastSpell(item.slot, unit)
				elseif not item.reqTarget then
					if (GetDistance(unit) - getHitBoxRadius(myHero) - getHitBoxRadius(unit)) < 50 then
						CastSpell(item.slot)
					end
				end
			end
		end
	end
end

function getHitBoxRadius(target)
    return GetDistance(target.minBBox, target.maxBBox)/2
end

function PriorityOnLoad()
	if heroManager.iCount < 10 or (TwistedTreeline and heroManager.iCount < 6) then
		print("<b><font color=\"#6699FF\">Ryze - the Rogue Mage:</font></b> <font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function GetJungleMob()
	for _, Mob in pairs(JungleFocusMobs) do
		if ValidTarget(Mob, SkillQ.range) then return Mob end
	end
	for _, Mob in pairs(JungleMobs) do
		if ValidTarget(Mob, SkillQ.range) then return Mob end
	end
end

function OnCreateObj(obj)
	if obj.valid then
		if FocusJungleNames[obj.name] then
			JungleFocusMobs[#JungleFocusMobs+1] = obj
		elseif JungleMobNames[obj.name] then
			JungleMobs[#JungleMobs+1] = obj
		end
	end
end

function OnDeleteObj(obj)
	for i, Mob in pairs(JungleMobs) do
		if obj.name == Mob.name then
			table.remove(JungleMobs, i)
		end
	end
	for i, Mob in pairs(JungleFocusMobs) do
		if obj.name == Mob.name then
			table.remove(JungleFocusMobs, i)
		end
	end
end

-- Trees
function GetCustomTarget()
 	TargetSelector:update() 	
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
	return TargetSelector.target
end

-- Feez
function isFacing(source, target, lineLength)
	local sourceVector = Vector(source.pos.x, source.pos.z)
	local sourcePos = Vector(source.x, source.z)
	sourceVector = (sourceVector-sourcePos):normalized()
	sourceVector = sourcePos + (sourceVector*(GetDistance(target, source)))
	return GetDistanceSqr(target, {x = sourceVector.x, z = sourceVector.y}) <= (lineLength and lineLength^2 or 90000)
end

function isBothFacing(source, target, lineLength)
	return isFacing(source, target, lineLength) and isFacing(target, source, lineLength)
end

-- Barasia, vadash, viseversa
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
  radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
  
  local points = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = D3DXVECTOR2(c.x, c.y)
  end
  
  DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
  if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
  
  if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
    DrawCircleNextLvl(x, y, z, radius, Settings.drawing.lfc.Width, color, Settings.drawing.lfc.CL) 
  end
end
