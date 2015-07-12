Teams = {}
local function AddTeam( id, team )
	if !id or !team then print("AddTeam Error: 1") return false end
	Teams[id] = team
	if DEVELOPER_MODE and Teams[id] then print("Setup Team: "..Teams[id].Name) end
	Teams[id].Id = id
	return true
end

AddTeam( 1, {
	Name = "Red",
	Color = Color( 255, 75, 75 ),
	Spawns = {
		db_EastLA_A4 = {Vector(467.462036, -541.962891, 66.042885),Vector(598.259277, -647.713806, 66.016838),Vector(455.191681, -754.771118, 66.082100),Vector(584.964600, -908.733032, 66.030548),Vector(395.841095, -1068.044556, 65.992142)},
		db_skyscraper_A4 = {Vector(-452.625000, 9.000000, 4642.031250),Vector(-462.250000, 145.625000, 4642.031250),Vector(-557.000000, 209.500000, 4641.968750),Vector(-555.937500, 77.062500, 4642.031250),Vector(-556.843750, -80.375000, 4641.968750)},
		db_skeeball_A4 = {Vector(-334.218750, -77.656250, 23.656250),Vector(-330.281250, -254.250000, 24.750000),Vector(-329.968750, -435.531250, 24.843750),Vector(-436.625000, -331.125000, 25.375000),Vector(-438.093750, -176.781250, 26.093750)},
		db_caveball_A4 = {Vector(-612.781250, -794.718750, 42.000000),Vector(-605.281250, -491.062500, 42.031250),Vector(-611.031250, -203.687500, 42.000000),Vector(109.812500, -708.968750, 265.968750),Vector(123.375000, -315.000000, 266.031250)},
		db_tetriz_A4 = {Vector(336.375000, -100.937500, 59.781250),Vector(443.125000, 18.375000, 71.906250),Vector(305.031250, 185.187500, 49.281250),Vector(452.531250, 362.750000, 78.437500),Vector(350.281250, 536.375000, 62.031250)},
	},
} )

AddTeam( 2, {
	Name = "Blue",
	Color = Color( 75, 75, 255 ),
	Spawns = {
		db_EastLA_A4 = {Vector(-255.950912, -1081.518311, 65.996941),Vector(38.442261, -953.122070, 66.024849),Vector(-171.425995, -777.159607, 66.044540),Vector(-35.925667, -623.678284, 66.050926),Vector(-229.236526, -557.046448, 66.012650)},
		db_skyscraper_A4 = {Vector(454.343750, 113.718750, 4642.000000),Vector(448.781250, 1.718750, 4642.031250),Vector(497.218750, -82.718750, 4642.000000),Vector(506.312500, 54.687500, 4642.000000),Vector(502.281250, 183.250000, 4642.000000)},
		db_skeeball_A4 = {Vector(-1195.093750, -436.062500, 22.687500),Vector(-1197.406250, -254.812500, 23.156250),Vector(-1199.500000, -77.281250, 23.593750),Vector(-1095.000000, -182.562500, 23.593750),Vector(-1094.343750, -332.031250, 24.156250)},
		db_caveball_A4 = {Vector(75.843750, -241.875000, 42.031250),Vector(58.000000, -513.781250, 41.968750),Vector(84.625000, -812.625000, 42.000000),Vector(-615.125000, -334.000000, 266.000000),Vector(-615.968750, -685.156250, 266.000000)},
		db_tetriz_A4 = {Vector(1593.906250, 535.937500, 47.500000),Vector(1502.093750, 354.562500, 65.062500),Vector(1589.875000, 168.281250, 45.375000),Vector(1489.062500, 16.343750, 72.875000),Vector(1570.812500, -119.781250, 55.437500)},
	},
} )

function GM:CreateTeams()
	for k,v in pairs(Teams) do
		team.SetUp( k, v.Name, v.Color )
		team.SetScore( k, 0 )
		if DEVELOPER_MODE then print("Team "..v.Name.." Registered.") end
	end
end

if SERVER then
	util.AddNetworkString( "Team" )
	net.Receive( "Team", function( len, ply )
		local Team = net.ReadFloat() or false
		timer.Simple( 1, function()
			if !IsValid(ply) or !Team or !Teams[Team] then return end
			ply:SetTeam( Team )
			if ply:Alive() then
				ply:KillSilent()
				ply:StripWeapons()
				ply:StripAmmo()
				ply:Spectate( OBS_MODE_ROAMING )
			end
			ply.RespawnTime = (RespawnTime or 0) + 2
			if DEVELOPER_MODE and SERVER then file.Append( "dodgeball_debug.txt", "\n "..tostring(ply).." Team Set." ) end
		end )
	end )
end