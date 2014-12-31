JunglePosOLD = {
	{ x = 7444.93, y = 56.3, z = 2980.3},
	{ x = 7232.64, y = 52, z = 4671.7},
	{ x = 7232.50, y = 55.3, z = 4671.7},
	{ x = 3402.36, y = 53.8, z = 8429},
	{ x = 6859.15, y = 52.7, z = 11497.3},
	{ x = 7010.93, y = 57.3, z = 10021.7},
	{ x = 9850.39, y = 52.7, z = 8781.2},
	{ x = 11127.33, y = 54.9, z = 6225.5},
	{ x = 10272.66, y = 54, z = 4974.5},
	{ x = 7214.80, y = 54.7, z = 2103.3},
	{ x = 4142.54, y = 55.3, z = 5696},
	{ x = 6905.49, y = 53.7, z = 12402.2},
}

JunglePos = {
	{ x = 7461.01, y = 52.5, z = 3253.56},
	{ x = 3511.6, y = 52.5, z = 8545.63},
	{ x = 7462.05, y = 52.5, z = 2489.82},
	{ x = 3144.89, y = 51.8, z = 7106.46},
	{ x = 7770.34, y = 49.3, z = 5061.25},
	{ x = 10930.9, y = -68.7, z = 5405.82},
	{ x = 7326.05, y = 50.2, z = 11643.03},
	{ x = 11417.6, y = 51, z = 6216.029},
	{ x = 7368.4, y = 56.4, z = 12488.36},
	{ x = 10342.7, y = 51.7, z = 8896.082},
	{ x = 7001.7, y = 54, z = 9915.715},
}

function OnLoad()
	Settings = scriptConfig("Jungle Positions", "dJunglePos")

	Settings:addParam("JunglePositions", "Show Jungle Positions", SCRIPT_PARAM_ONOFF, true)
	Settings:addParam("JunglePositionsMove", "Move to Jungle Positions", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("A"))
	Settings:addParam("JunglePositionsRange", "Range for Jungle Positions", SCRIPT_PARAM_SLICE, 1000, 0, 2000, 0)
end

function OnTick()
	if Settings.JunglePositionsMove then
		for _, Position in pairs(JunglePos) do
			if GetDistance(Position, mousePos) < 250 then
				myHero:MoveTo(Position.x, Position.z)
			end
		end
	end
end

function OnDraw()
	if Settings.JunglePositions then
		for _, Position in pairs(JunglePos) do
			if GetDistance(Position, myHero) < Settings.JunglePositionsRange then
				DrawCircle2(Position.x, Position.y, Position.z, 80, RGB(255, 255, 255))
			end
		end
	end
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
    DrawCircleNextLvl(x, y, z, radius, 1, color, 75)
  end
end
