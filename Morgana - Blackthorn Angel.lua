local version = "1.2"

--[[
	Morgana - Blackthorn Angel
		Author: Draconis
		Version: 1.2
		Copyright 2014
			
	Dependency: Standalone
--]]

if myHero.charName ~= "Morgana" then return end

require 'SxOrbwalk'
require 'VPrediction'

------------------------------------------------------
--			 Callbacks				
------------------------------------------------------

function OnLoad()
	print("<b><font color=\"#6699FF\">Morgana - Blackthorn Angel:</font></b> <font color=\"#FFFFFF\">Sucessfully loaded!</font>")
	Variables()
	Menu()
	PriorityOnLoad()
end

function OnTick()
	ComboKey = Settings.combo.comboKey
	HarassKey = Settings.harass.harassKey
	LaneClearKey = Settings.lane.laneKey
	
	if ComboKey then
		Combo(Target)
	end
	
	if HarassKey then
		Harass(Target)
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
		if SkillR.ready and Settings.drawing.rDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillR.range, RGB(Settings.drawing.rColor[2], Settings.drawing.rColor[3], Settings.drawing.rColor[4]))
		end
		
		if Settings.drawing.Target and Target ~= nil then
			DrawCircle(Target.x, Target.y, Target.z, 70, 0xCE00FF)
		end
		
		if Settings.drawing.myHero then
			DrawCircle(myHero.x, myHero.y, myHero.z, TrueRange(), RGB(Settings.drawing.myColor[2], Settings.drawing.myColor[3], Settings.drawing.myColor[4]))
		end
	end
end

------------------------------------------------------
--			 Functions				
------------------------------------------------------

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
		if Settings.combo.comboItems then UseItems(unit) end
		CastQ(unit)
		if Settings.combo.useW then CastW(unit) end
		if Settings.combo.useW then CastR(unit) end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and not IsMyManaLow("Harass") then
		if Settings.harass.harassMode == 1 then
			if Settings.harass.useQ then CastQ(unit) end
			if Settings.harass.useW then CastW(unit) end
		elseif Settings.harass.harassMode == 2 then
			if Settings.harass.useQ then CastQ(unit) end
		end
	end
end

function LaneClear()
	enemyMinions:update()
	if LaneClearKey and not IsMyManaLow("Clean") then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil then
				if Settings.lane.laneW and GetDistance(minion) <= SkillW.range then 
					local BestPos, BestHit = GetBestCircularFarmPosition(SkillW.range, SkillW.width, enemyMinions.objects)

					if BestPos ~= nil then
						CastSpell(_W, BestPos.x, BestPos.z)
					end
				end
			end		 
		end
	end
end

function CastQ(unit)	
	if unit ~= nil and GetDistance(unit) <= SkillQ.range and SkillQ.ready then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
				
		if HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastE(unit)
	if SkillE.ready and GetDistance(unit) <= SkillE.range then
		CastSpell(_E, unit)
	end
end

function CastW(unit)
	if Settings.combo.useW == 1 then return end
	if (ComboKey and not TargetHaveBuff("DarkBindingMissile", unit) and Settings.combo.comboQ) or (HarassKey and not TargetHaveBuff("DarkBindingMissile", unit) and Settings.harass.harassQ) then return end
	
	if unit ~= nil and GetDistance(unit) <= SkillW.range and SkillW.ready then
	AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(unit, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero)
	
		if MainTargetHitChance >= 2 then
			if Settings.combo.useW == 2 and nTargets >= 1 then
				CastSpell(_W, AOECastPosition.x, AOECastPosition.z) 
			elseif Settings.combo.useW == 3 and nTargets >= 2 then
				CastSpell(_W, AOECastPosition.x, AOECastPosition.z) 
			elseif Settings.combo.useW == 4 and nTargets >= 3 then
				CastSpell(_W, AOECastPosition.x, AOECastPosition.z) 
			elseif Settings.combo.useW == 5 and nTargets >= 4 then
				CastSpell(_W, AOECastPosition.x, AOECastPosition.z) 
			end
		end
	end
end

function CastR(unit)
	if Settings.combo.useR == 1 then return end
	
	if SkillR.ready then
		if Settings.combo.useE then
			CastE(myHero)
		end
		
		if CountEnemyHeroInRange(SkillR.range, myHero) >= 1 and Settings.combo.useR == 2 then
			CastSpell(_R)
		elseif CountEnemyHeroInRange(SkillR.range, myHero) >= 2 and Settings.combo.useR == 3 then
			CastSpell(_R)
		elseif CountEnemyHeroInRange(SkillR.range, myHero) >= 3 and Settings.combo.useR == 3 then
			CastSpell(_R)
		elseif CountEnemyHeroInRange(SkillR.range, myHero) >= 4 and Settings.combo.useR == 4 then
			CastSpell(_R)
		end
	end
end

function KillSteal()
	for _, enemy in ipairs(GetEnemyHeroes()) do
		qDmg = getDmg("Q", enemy, myHero)
		
		if ValidTarget(enemy) and enemy.visible then
			if enemy.health <= qDmg then
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
	Target = GetCustomTarget()
	SxOrb:ForceTarget(Target)
	
	if Settings.drawing.lfc.lfc then _G.DrawCircle = DrawCircle2 else _G.DrawCircle = _G.oldDrawCircle end
end

function IsMyManaLow(mode)
	if mode == "Harass" then
		if myHero.mana < (myHero.maxMana * ( Settings.harass.harassMana / 100)) then
			return true
		else
			return false
		end
	elseif mode == "Clean" then
		if myHero.mana < (myHero.maxMana * ( Settings.lane.laneMana / 100)) then
			return true
		else
			return false
		end
	end
end

function Menu()
	Settings = scriptConfig("Morgana - Blackthorn Angel "..version.."", "DraconisMorgana")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("useW", "Use "..SkillW.name.." (W) in Combo", SCRIPT_PARAM_LIST, 2, { "No", ">1 targets", ">2 targets", ">3 targets", ">4 targets" })
		Settings.combo:addParam("comboQ", "Wait with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useR", "Use "..SkillR.name.." (R) in Combo", SCRIPT_PARAM_LIST, 2, { "No", ">1 targets", ">2 targets", ">3 targets", ">4 targets" })
		Settings.combo:addParam("useE", "Use "..SkillE.name.." (E) with (R)", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("comboItems", "Use Items in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:permaShow("comboKey")
	
	Settings:addSubMenu("["..myHero.charName.."] - Harass Settings", "harass")
		Settings.harass:addParam("harassKey", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
		Settings.harass:addParam("harassMode", "Choose Harass Mode", SCRIPT_PARAM_LIST, 1, { "Q + W", "Q" })
		Settings.harass:addParam("useQ", "Use "..SkillQ.name.." (Q) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useW", "Use "..SkillW.name.." (W) in Harass", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("harassQ", "Wait with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("harassMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 50, 0, 100, 0)
		Settings.harass:permaShow("harassKey")
		
	Settings:addSubMenu("["..myHero.charName.."] - Lane Clear Settings", "lane")
		Settings.lane:addParam("laneKey", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
		Settings.lane:addParam("laneW", "Clear with "..SkillW.name.." (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.lane:addParam("laneMana", "Min. Mana Percent: ", SCRIPT_PARAM_SLICE, 30, 0, 100, 0)
		Settings.lane:permaShow("laneKey")	
		
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
		Settings.drawing:addParam("rDraw", "Draw "..SkillR.name.." (R) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("rColor", "Draw "..SkillR.name.." (R) Color", SCRIPT_PARAM_COLOR, {255, 255, 255, 255})
		
		Settings.drawing:addSubMenu("Lag Free Circles", "lfc")	
			Settings.drawing.lfc:addParam("lfc", "Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
			Settings.drawing.lfc:addParam("CL", "Quality", 4, 75, 75, 2000, 0)
			Settings.drawing.lfc:addParam("Width", "Width", 4, 1, 1, 10, 0)

	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)
	
	TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, SkillQ.range, DAMAGE_MAGIC, true)
	TargetSelector.name = "Morgana"
	Settings:addTS(TargetSelector)
end

function Variables()
	SkillQ = { name = "Dark Binding", range = 1175, delay = 0.250, speed = 1200, width = 70, ready = false }
	SkillW = { name = "Dark Frenzy", range = 900, delay = 0.250, speed = 1200, width = 175, ready = false }
	SkillE = { name = "Black Shield", range = 750, delay = nil, speed = nil, width = nil, ready = false }
	SkillR = { name = "Soul Shackles", range = 600, delay = nil, speed = nil, width = nil, ready = false }
	Ignite = { name = "summonerdot", range = 600, slot = nil }
	
	enemyMinions = minionManager(MINION_ENEMY, SkillQ.range, myHero, MINION_SORT_HEALTH_ASC)
	
	VP = VPrediction()
	
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
		SetPriority(priorityTable.AP,	   enemy, 2)
		SetPriority(priorityTable.Support,  enemy, 3)
		SetPriority(priorityTable.Bruiser,  enemy, 4)
		SetPriority(priorityTable.Tank,	 enemy, 5)
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
		print("<b><font color=\"#6699FF\">Morgana - Blackthorn Angel:</font></b> <font color=\"#FFFFFF\">Too few champions to arrange priority.</font>")
	elseif heroManager.iCount == 6 then
		arrangePrioritysTT()
    else
		arrangePrioritys()
	end
end

function GetBestCircularFarmPosition(range, radius, objects)
    local BestPos 
    local BestHit = 0
    for i, object in ipairs(objects) do
        local hit = CountObjectsNearPos(object.pos or object, range, radius, objects)
        if hit > BestHit then
            BestHit = hit
            BestPos = Vector(object)
            if BestHit == #objects then
               break
            end
         end
    end

    return BestPos, BestHit
end

function CountObjectsNearPos(pos, range, radius, objects)
    local n = 0
    for i, object in ipairs(objects) do
        if GetDistanceSqr(pos, object) <= radius * radius then
            n = n + 1
        end
    end

    return n
end

-- Trees
function GetCustomTarget()
 	TargetSelector:update() 	
    if _G.MMA_Target and _G.MMA_Target.type == myHero.type then return _G.MMA_Target end
    if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then return _G.AutoCarry.Attack_Crosshair.target end
	return TargetSelector.target
end

function TrueRange()
	return myHero.range + GetDistance(myHero, myHero.minBBox)
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
