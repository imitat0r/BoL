JunglePos = {
	{ x = 7444.93, y = 56.26, z = 2980.26},
	{ x = 7232.64, y = 51.95, z = 4671.71},
	{ x = 7232.50, y = 55.25, z = 4671.71},
	{ x = 3402.36, y = 53.79, z = 8429.14},
	{ x = 6859.15, y = 52.69, z = 11497.25},
	{ x = 7010.93, y = 57.37, z = 10021.69},
	{ x = 9850.39, y = 52.63, z = 8781.23},
	{ x = 11127.33, y = 54.85, z = 6225.54},
	{ x = 10272.66, y = 54, z = 4974.52},
	{ x = 7214.80, y = 54.74, z = 2103.27},
	{ x = 4142.53, y = 55.26, z = 5695.95},
	{ x = 6905.49, y = 53.68, z = 12402.21},
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
				DrawCircle(Position.x, Position.y, Position.z, 80, RGB(255, 255, 255))
			end
		end
	end
end
