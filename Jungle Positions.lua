JunglePos = {
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
