if myHero.charName ~= "Xerath" then return end

local version = "1.01"

_G.UseUpdater = true

local REQUIRED_LIBS = {
	["SOW"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
	["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
	["SourceLib"] = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
}

local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b><font color=\"#6699FF\">Xerath - Continuation:</font></b> <font color=\"#FFFFFF\">Required libraries downloaded successfully, please reload (double F9).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end

if DOWNLOADING_LIBS then return end

local UPDATE_NAME = "Xerath - Continuation"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/DraconisBoL/BoL/master/Xerath%20-%20Continuation.lua" .. "?rand=" .. math.random(1, 10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..UPDATE_NAME..".lua"
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<b><font color=\"#6699FF\">"..UPDATE_NAME..":</font></b> <font color=\"#FFFFFF\">"..msg..".</font>") end
if _G.UseUpdater then
	local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
	if ServerData then
		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
		if ServerVersion then
			ServerVersion = tonumber(ServerVersion)
			if tonumber(version) < ServerVersion then
				AutoupdaterMsg("New version available "..ServerVersion)
				AutoupdaterMsg("Updating, please don't press F9")
				DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)	 
			else
				AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
			end
		end
	else
		AutoupdaterMsg("Error downloading version info")
	end
end

local StealCharNames = {"ancientgolem", "dragon", "worm"}

local Ranges = {[_Q] = {750, 1550},  [_W] = 1000, [_E] = 1050, [_R] = {3000, 4200, 5400}}
local Widths = {[_Q] = 100, [_W] = 200, [_E] = 60, [_R] = 200}
local Delays = {[_Q] = 0.7, [_W] = 0.7, [_E] = 0.25, [_R] = 0.9}
local Speeds = {[_Q] = math.huge, [_W] = math.huge, [_E] = 1400, [_R] = math.huge}
local RangeCircles = {}


local PassiveUp = true
local LastPing = 0

local CastingQ = 0
local CastingR = 0

local MainCombo = {_Q, _W, _E, _R, _R, _R}
local _RM = 1322


local RStartTime = 0
local UsedCharges = 0

local RCooldownTime = 0

local CurrentRTarget
local LastRTarget

local RPressTime = 0
local JSPressTime = 0
local RTapped = false
local RPressTime2 = false

function GetClosestTargetToMouse()
	local result
	local mindist = math.huge

	for i, enemy in ipairs(GetEnemyHeroes()) do
		local dist = GetDistanceSqr(mousePos, enemy)
		if ValidTarget(enemy) and dist < 1000 * 1000 then
			if dist <= mindist then
				mindist = dist
				result = enemy
			end
		end
	end

	return result
end

function JungleSteal()
	local oldrange = JungleMinions.range
	JungleMinions.range = R.range
	JungleMinions:update()
	local minion = JungleMinions.objects[1]
	if ValidTarget(minion) then
		if table.contains(StealCharNames, minion.charName:lower()) and DLib:IsKillable(minion, {_R}) then 
			R:Cast(minion)
		end
	end
	JungleMinions.range = oldrange
end

function HandleRCast()
	local RTarget
	if os.clock() - JSPressTime < 10 then
		JungleSteal()
		do return end
	end

	if not (os.clock() - RPressTime < 10) and not RPressTime2 then
		return 
	end

	if UsedCharges == 0 and RCooldownTime == 0 then
		if Menu.RSnipe.Advanced["Delay"..UsedCharges] ~= 0 then
			RCooldownTime = os.clock() + Menu.RSnipe.Advanced["Delay"..UsedCharges] / 1000
		end
	end

	if not CanUseNextCharge() then
		return
	end

	if Menu.RSnipe.Targetting == 2 then
		RTarget = STS:GetTarget(R.range)
	else
		RTarget = GetClosestTargetToMouse()
	end

	if RTarget then
		CurrentRTarget = RTarget
		R.packetCast = Menu.RSnipe.Advanced.Packets
		R:Cast(RTarget)
	end
end

function OnCastR(spell)
	if spell.name == "XerathLocusOfPower2" then
		RStartTime = os.clock()
		UsedCharges = 0
	end

	if spell.name == "xerathlocuspulse" then
		UsedCharges = UsedCharges + 1
		RPressTime2 = false
		if CurrentRTarget and DLib:IsKillable(CurrentRTarget, {_R}) and Menu.RSnipe.Advanced.Dead then
			RCooldownTime = os.clock() + Delays[_R]
		end

		if Menu.RSnipe.Advanced["Delay"..UsedCharges] and Menu.RSnipe.Advanced["Delay"..UsedCharges] ~= 0 then
			RCooldownTime = os.clock() + Menu.RSnipe.Advanced["Delay"..UsedCharges] / 1000
		end

		if LastRTarget and CurrentRTarget and CurrentRTarget.hash ~= LastRTarget.hash then
			RCooldownTime = os.clock() + Menu.RSnipe.Advanced.Delay / 1000
		end

		if UsedCharges == 3 then
			RStartTime = 0
		end

		LastRTarget = CurrentRTarget
	end
end

function CanUseNextCharge()
	if os.clock() - RCooldownTime >= 0 then
		return true
	end
end

function ResetRVars()
	if not ImCastingR() then
		CurrentRTarget = nil
		RCooldownTime = 0
		LastRTarget = nil
		RStartTime = 0
	end
end
TickLimiter(ResetRVars, 1)

function ImCastingR()
	return ((os.clock() - RStartTime) < 10 and (myHero:GetSpellData(_R).currentCd < 10))
end

function OnLoad()
	VP = VPrediction()
	SOWi = SOW(VP)
	STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)
	DLib = DamageLib()
	DManager = DrawManager()

	DLib:RegisterDamageSource(_Q, _MAGIC, 40, 40, _MAGIC, _AP, 0.75, function() return (player:CanUseSpell(_Q) == READY) end)
	DLib:RegisterDamageSource(_W, _MAGIC, 30, 30, _MAGIC, _AP, 0.6, function() return (player:CanUseSpell(_W) == READY) end)
	DLib:RegisterDamageSource(_E, _MAGIC, 50, 30, _MAGIC, _AP, 0.45, function() return (player:CanUseSpell(_E) == READY) end)
	DLib:RegisterDamageSource(_R, _MAGIC, 135, 55, _MAGIC, _AP, 0.43, function() return (player:CanUseSpell(_R) == READY) end)

	Q = Spell(_Q, Ranges[_Q][1])
	Q:SetSkillshot(VP, SKILLSHOT_LINEAR, Widths[_Q], Delays[_Q], Speeds[_Q], false)
	Q:SetCharged("xeratharcanopulsechargeup", 3, Ranges[_Q][2], 1.5)
	Q:SetAOE(true)

	W = Spell(_W, Ranges[_W])
	W:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Widths[_W], Delays[_W], Speeds[_W], false)
	W:SetAOE(true)

	E = Spell(_E, Ranges[_E])
	E:SetSkillshot(VP, SKILLSHOT_LINEAR, Widths[_E], Delays[_E], Speeds[_E], true)

	R = Spell(_R, Ranges[_R][1])
	R:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Widths[_R], Delays[_R], Speeds[_R], false)
	R:TrackCasting({"XerathLocusOfPower2", "xerathlocuspulse"})
	R:RegisterCastCallback(OnCastR)
	
	Menu = scriptConfig("Xerath - Continuation", "Xerath")
	Menu:addSubMenu("Orbwalking", "Orbwalking")
		SOWi:LoadToMenu(Menu.Orbwalking, STS)

	Menu:addSubMenu("Target selector", "STS")
		STS:AddToMenu(Menu.STS)

	Menu:addSubMenu("Combo", "Combo")
		Menu.Combo:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF , true)
		Menu.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("Erange",  "E range", SCRIPT_PARAM_SLICE, Ranges[_E], 0, Ranges[_E])
		Menu.Combo:addParam("CastE", "Use E!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("O"))
		Menu.Combo:addParam("Enabled", "Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	
	Menu:addSubMenu("Harass", "Harass")
		Menu.Harass:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF , true)
		Menu.Harass:addParam("ManaCheck", "Don't harass if mana < %", SCRIPT_PARAM_SLICE, 10, 0, 100)
		Menu.Harass:addParam("Enabled", "Harass!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
	
	Menu:addSubMenu("RSnipe", "RSnipe")
		
		Menu.RSnipe:addParam("AutoR", "Use all charges", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("R"))
		AllMenu = #Menu.RSnipe._param
		Menu.RSnipe:addParam("AutoR2", "Use 1 charge (tap)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
		TapMenu = #Menu.RSnipe._param

		Menu.RSnipe:addParam("JS", "Jungle Steal", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("J"))
		JungleMenu = #Menu.RSnipe._param

		Menu.RSnipe:addParam("Targetting", "Targetting mode: ", SCRIPT_PARAM_LIST, 2, { "Near mouse (1000) range from mouse", "Most killable"})
		
		Menu.RSnipe:addSubMenu("Alerter", "Alerter")
			Menu.RSnipe.Alerter:addParam("Alert", "Draw \"Snipe\" on killable enemies", SCRIPT_PARAM_ONOFF , true)
			Menu.RSnipe.Alerter:addParam("Ping", "Ping if an enemy is killable", SCRIPT_PARAM_ONOFF , true)

		Menu.RSnipe:addSubMenu("Advanced", "Advanced")
			Menu.RSnipe.Advanced:addParam("Delay0", "Delay between 0-1", SCRIPT_PARAM_SLICE, 0, 0, 3000)
			Menu.RSnipe.Advanced:addParam("Delay1", "Delay between 1-2", SCRIPT_PARAM_SLICE, 0, 0, 3000)
			Menu.RSnipe.Advanced:addParam("Delay2", "Delay between 2-3", SCRIPT_PARAM_SLICE, 0, 0, 3000)
			Menu.RSnipe.Advanced:addParam("Delay",  "Wait before changing target", SCRIPT_PARAM_SLICE, 1000, 0, 3000)
			Menu.RSnipe.Advanced:addParam("Packets", "Use Packets", SCRIPT_PARAM_ONOFF , false)
			Menu.RSnipe.Advanced:addParam("Dead", "Avoid shoting on people about to die", SCRIPT_PARAM_ONOFF , true)

	Menu:addSubMenu("Farm", "Farm")
		Menu.Farm:addParam("UseQ",  "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.Farm:addParam("UseW",  "Use W", SCRIPT_PARAM_ONOFF, false)
		Menu.Farm:addParam("ManaCheck", "Don't farm if mana < %", SCRIPT_PARAM_SLICE, 10, 0, 100)
		Menu.Farm:addParam("Enabled", "Farm!", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))
	
	Menu:addSubMenu("JungleFarm", "JungleFarm")
		Menu.JungleFarm:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.JungleFarm:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Menu.JungleFarm:addParam("Enabled", "Farm jungle!", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))

	Menu:addSubMenu("Misc", "Misc")
		Menu.Misc:addParam("WCenter", "Cast W centered", SCRIPT_PARAM_ONOFF, false)
		Menu.Misc:addParam("WMR", "Cast W at max range", SCRIPT_PARAM_ONOFF, false)
		Menu.Misc:addParam("AutoEDashing", "Auto E on dashing enemies", SCRIPT_PARAM_ONOFF, true)
		Menu.Misc:addParam("AutoEImmobile", "Auto E on immobile enemies", SCRIPT_PARAM_ONOFF, true)
		Menu.Misc:addSubMenu("Anti-Gapclosers", "AG")
			AntiGapcloser(Menu.Misc.AG, OnGapclose)

			Menu:addSubMenu("Drawing", "Drawing")
	 	DManager:CreateCircle(myHero, SOWi:MyRange() + 50, 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawing, "AA Range", true, true, true)

	 	for spell, range in pairs(Ranges) do
	 		RangeCircles[spell] = DManager:CreateCircle(myHero, type(range) == "number" and range or range[1], 1, {255, 255, 255, 255})
	 		RangeCircles[spell]:AddToMenu(Menu.Drawing, SpellToString(spell).." Range", true, true, true)
	 	end

	 	RangeCircles[_RM] = DManager:CreateCircle(myHero, Ranges[_R][1], 1, {255, 255, 255, 255}):SetMinimap()
	 	RangeCircles[_RM]:AddToMenu(Menu.Drawing, "R Range (minimap)", true, true, true)


	DLib:AddToMenu(Menu.Drawing, MainCombo)

	Menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
	
	EnemyMinions = minionManager(MINION_ENEMY, Ranges[_Q][2], myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Ranges[_Q][2], myHero, MINION_SORT_MAXHEALTH_DEC)

end

function OnGapclose(unit, data)
	if E:IsReady() then
		E:Cast(unit)
	end
end

function SetQRange()
	if Q and RangeCircles[_Q] then
		RangeCircles[_Q].radius = Q.range == Ranges[_Q][1] and Ranges[_Q][2] or Q.range
	end
end
TickLimiter(SetQRange, 120)

function Cast2Q(to)
	local p = CLoLPacket(230)
	p:EncodeF(myHero.networkID)
	p:Encode1(0x80)
	p:EncodeF(to.x)
	p:EncodeF(to.y)
	p:EncodeF(to.z)
	SendPacket(p)
end

function SetRRange()
	if R and RangeCircles[_R] then
		R:SetRange(Ranges[_R][math.max(myHero:GetSpellData(_R).level, 1)])
		RangeCircles[_R].radius = R.range
		RangeCircles[_RM].radius = R.range
	end
end
TickLimiter(SetRRange, 1)

function GetRCombo()
	return {_R , _R, _R}
end

function OnGainBuff(unit, buff) 
	if unit.isMe and buff.name == "xerathascended2onhit" then
		PassiveUp = true
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe then
		if buff.name == "xerathascended2onhit" then
			PassiveUp = false
		end
		if buff.nam == "xerathrshots" then
			RStartTime = 0
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe then
		if spell.name == "xeratharcanopulse2" then
			Q:_AbortCharge()
		end
	end
end

function OnTick()
	SOWi:EnableAttacks()

	if Menu.RSnipe._param[AllMenu].key == Menu.RSnipe._param[JungleMenu].key then
		Menu.RSnipe._param[AllMenu].key    = 82
		Menu.RSnipe._param[JungleMenu].key = 74
		Menu.RSnipe.AutoR = false
		Menu.RSnipe.JS    = false
		Menu.RSnipe:save()
		print("Xerath: Key binding issue found, RSnipe keys resetted")
	end

	if Menu.RSnipe.AutoR then
		RPressTime = os.clock()
		JSPressTime = 0
	end

	if Menu.RSnipe.JS then
		JSPressTime = os.clock()
	end

	if ImCastingR() then
		HandleRCast()
		do return end
	end
	
	if Menu.Combo.CastE then
		local ETarget = STS:GetTarget(Ranges[_E])
		if ETarget then
			E:Cast(ETarget)
		end
	end

	if Menu.Combo.Enabled then
		Combo()
	elseif Menu.Harass.Enabled and ((myHero.mana / myHero.maxMana * 100) >= Menu.Harass.ManaCheck or Q:IsCharging()) then
		Harass()
	end

	if Menu.Farm.Enabled and ((myHero.mana / myHero.maxMana * 100) >= Menu.Farm.ManaCheck or Q:IsCharging()) then
		Farm()
	end

	if Menu.JungleFarm.Enabled then
		JungleFarm()
	end

	if Menu.Misc.AutoEDashing then
		for i, target in ipairs(SelectUnits(GetEnemyHeroes(), function(t) return ValidTarget(t, Ranges[_E] * 1.5) end)) do
			E:CastIfDashing(target)
		end
	end

	if Menu.Misc.AutoEImmobile then
		for i, target in ipairs(SelectUnits(GetEnemyHeroes(), function(t) return ValidTarget(t, Ranges[_E] * 1.5) end)) do
			E:CastIfImmobile(target)
		end
	end

	if Menu.RSnipe.Alerter.Ping and myHero:CanUseSpell(_R) == READY and (os.clock() - LastPing > 30) then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, R.range) and DLib:IsKillable(enemy, GetRCombo()) then
				for i = 1, 3 do
					DelayAction(PingClient,  1000 * 0.3 * i/1000, {enemy.x, enemy.z})
				end
				LastPing = os.clock()
			end
		end
	end
	
	AutoIgnite()
end

function Combo()
	local QTarget = STS:GetTarget(Ranges[_Q][2])
	local WTarget = STS:GetTarget(Ranges[_W] + Widths[_W])
	local ETarget = STS:GetTarget(Menu.Combo.Erange)

	local AAtarget = SOWi:GetTarget()
	SOWi:DisableAttacks()

	if (AAtarget and AAtarget.health < 200) or PassiveUp then
		SOWi:EnableAttacks()
	end

	if QTarget and Menu.Combo.UseQ then
		if Q:IsCharging() then
			local castPosition, hitChance, nTargets = Q:GetPrediction(QTarget)
			if Q.range ~= Ranges[_Q][2] and GetDistanceSqr(castPosition) < (Q.range - 200)^2 or Q.range == Ranges[_Q][2] and GetDistanceSqr(castPosition) < (Q.range)^2 then
				Cast2Q(castPosition)
			end
		else
			CastSpell(_Q, mousePos.x, mousePos.z)
		end
	end

	if WTarget and Menu.Combo.UseW then
		if Menu.Misc.WCenter then
			W.width = 50
		else
			W.width = Widths[_W]
		end
		VP.ShotAtMaxRange = Menu.Misc.WMR
		W:Cast(WTarget)
		VP.ShotAtMaxRange = false
	end

	if ETarget and Menu.Combo.UseE then
		E:Cast(ETarget)
	end
end

function Harass()
	local QTarget = STS:GetTarget(Ranges[_Q][2])
	if QTarget and Menu.Harass.UseQ then
		if Q:IsCharging() then
			local castPosition, hitChance, nTargets = Q:GetPrediction(QTarget)
			if Q.range ~= Ranges[_Q][2] and GetDistanceSqr(castPosition) < (Q.range - 200)^2 or Q.range == Ranges[_Q][2] and GetDistanceSqr(castPosition) < (Q.range)^2 then
				Cast2Q(castPosition)
			end
		else
			CastSpell(_Q, mousePos.x, mousePos.z)
		end
	end
end

function Farm()
	EnemyMinions:update()
	if Menu.Farm.UseQ then
		if not Q:IsCharging() then
			if #EnemyMinions.objects > 1 then
				CastSpell(_Q, mousePos.x, mousePos.z)
			end
		else
			local AllMinions = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) and GetDistanceSqr(t) < Q.rangeSqr end)
			local AllMinions2 = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) and GetDistanceSqr(t) < Ranges[_Q][2] * Ranges[_Q][2] end)

			if #AllMinions == #AllMinions2 or Q.range == Ranges[_Q][2] then
				AllMinions = GetPredictedPositionsTable(VP, AllMinions, Delays[_Q], Widths[_Q], Q.range, math.huge, myHero, false)
				local BestPos1, BestHit1 = GetBestLineFarmPosition(Q.range, Widths[_Q], AllMinions)
				if BestPos1 then
					Cast2Q(BestPos1)
				end
			end
			
		end
	end

	if Menu.Farm.UseW then
		local CasterMinions = SelectUnits(EnemyMinions.objects, function(t) return (t.charName:lower():find("wizard") or t.charName:lower():find("caster")) and ValidTarget(t) and GetDistanceSqr(t) < W.rangeSqr end)
		
		CasterMinions = GetPredictedPositionsTable(VP, CasterMinions, Delays[_W], Widths[_W], Ranges[_W] + Widths[_W], math.huge, myHero, false)
		local BestPos1, BestHit1 = GetBestCircularFarmPosition(Ranges[_W] + Widths[_W], Widths[_W], CasterMinions)

		if BestPos1 and BestHit1 > 1 then
			CastSpell(_W, BestPos1.x, BestPos1.z)
		else
			local AllMinions = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) and GetDistanceSqr(t) < E.rangeSqr end)
			AllMinions = GetPredictedPositionsTable(VP, AllMinions, Delays[_W], Widths[_W], Ranges[_W] + Widths[_W], math.huge, myHero, false)
			BestPos1, BestHit1 = GetBestCircularFarmPosition(Ranges[_W] + Widths[_W], Widths[_W], AllMinions)
			if BestPos1 and BestHit1 > 1 then
				CastSpell(_W, BestPos1.x, BestPos1.z)
			end
		end
	end
end

function JungleFarm()
	JungleMinions:update()
	if JungleMinions.objects[1] ~= nil then
		if Menu.JungleFarm.UseQ and GetDistance(JungleMinions.objects[1]) <= Ranges[_Q][1] and myHero:CanUseSpell(_Q) == READY then
			CastSpell(_Q, JungleMinions.objects[1].x, JungleMinions.objects[1].z)
			Cast2Q(JungleMinions.objects[1])
		end

		if Menu.JungleFarm.UseW and myHero:CanUseSpell(_W) == READY then
			CastSpell(_W, JungleMinions.objects[1].x, JungleMinions.objects[1].z)		
		end
	end
end

function AutoIgnite()	
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		Ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		Ignite = SUMMONER_2
	end
	
	for _, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) and enemy.visible and enemy.health <= getDmg("IGNITE", enemy, myHero) then
			CastSpell(Ignite, enemy)
		end
	end
end

function OnSendPacket(p)
	if p.header == Packet.headers.S_MOVE and Q:IsCharging() then
		local packet = Packet(p)
		if packet:get("type") ~= 2 then
			Packet('S_MOVE',{x = mousePos.x, y = mousePos.z}):send()
			p:Block()
		end
	elseif p.header == Packet.headers.S_MOVE and ImCastingR() then
		p:Block()
	end
end

function OnDraw()
	if Menu.RSnipe.Alerter.Alert and myHero:GetSpellData(_R).level > 0 then
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, R.range) and DLib:IsKillable(enemy, GetRCombo()) then
				local pos = WorldToScreen(D3DXVECTOR3(enemy.x, enemy.y, enemy.z))
				DrawText("Snipe!", 17, pos.x, pos.y, ARGB(255,0,255,0))
			end
		end
	end 
end

function OnWndMsg(Msg, Key)
	if Msg == 256 and Key == Menu.RSnipe._param[TapMenu].key then
		RPressTime2 = true
		RCooldownTime = 0
	end
end
