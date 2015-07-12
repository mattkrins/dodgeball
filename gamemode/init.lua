AddCSLuaFile( "config.lua" )
include( "config.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function GM:ShowTeam( ply )
	ply:ConCommand( "team" )
end

function GM:ShowSpare2( ply )
	return false
end

function GM:ShowSpare1( ply )
	return false
end

function GM:PlayerAuthed( ply )
	ply:ConCommand( "intro" )
	if UseMOTD then
		timer.Simple( 5, function()
			ply:ConCommand( "motd" )
		end )
	else
		timer.Simple( 3, function()
			ply:ConCommand( "team" )
		end )
	end
end

function GM:PlayerDisconnected( ply )
	if !ply.Kicked and ply:Name() then
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint( ply:Name() .. " has left the game." )
		end
	end
end

function GM:PlayerInitialSpawn( ply )
	if ply:IsBot() then
		local Team = team.BestAutoJoinTeam()
		ply:SetTeam( Team )
	else
		ply:KillSilent()
		timer.Simple( 0.1, function()
			ply:SetTeam( TEAM_SPECTATOR )
			ply:Spectate( OBS_MODE_ROAMING )
		end )
	end
end

function GM:PlayerSpawn( ply )
	if ply:Team() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED and Teams[ply:Team()] then
		//ply:SetupHands()
		local TeamTable = Teams[ply:Team()]
		ply:SetCustomCollisionCheck( true )
		ply:SetSuppressPickupNotices( true )
		local spawns = false
		if game.GetMap() and TeamTable.Spawns[game.GetMap()] then spawns = TeamTable.Spawns[game.GetMap()] end
		if spawns then
			local pos
			if istable(spawns) then pos = table.Random( spawns )
			elseif isstring(spawns) then pos = spawns end
			if pos then ply:SetPos( pos ) end
		end
		if SpawnProtection then
			ply.Spawning = true
			timer.Simple( SpawnProtection, function()
				if ply and IsValid(ply) then ply.Spawning = false end
			end )
		else
			ply.Spawning = false
		end
	else
		GAMEMODE:PlayerSpawnAsSpectator( ply )
	end
	self.BaseClass:PlayerSpawn( ply )
end

function GM:PlayerLoadout( ply )
	self.BaseClass:PlayerLoadout( ply )
	ply:StripWeapons()
	ply:StripAmmo()
	ply:SetWalkSpeed( 260 )
	ply:SetRunSpeed( 350 )
	if ply:Team() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
		timer.Simple( 3, function()
			ply:GiveBall()
		end )
		if ply and IsValid(ply) then
			if DEVELOPER_MODE and ply:IsAdmin() then ply:Give("weapon_physgun") ply:Give("gmod_tool") end
		end
	end
end

function GM:PlayerSetModel( ply )
	if PLAYERMODELS then ply:SetModel(table.Random(PLAYERMODELS)) end
	if ply:Team() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
		local tCol = team.GetColor( ply:Team() )
		if tCol then
			col = Vector(tCol.r/255,tCol.g/255,tCol.b/255)
			ply:SetPlayerColor( col )
		end
	end
end

function GM:PlayerDeath( ply, inf, att )
	self.BaseClass:PlayerDeath( ply, inf, att )
	local Time = RespawnTime //+ #player.GetAll()
	ply.RespawnTime = CurTime() + Time or 0
	if att:IsPlayer() and att:Team() and att != ply then
		team.AddScore( att:Team(), 1 )
	end
	if ply:Team() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED and ply:Team() != 0 and #team.GetPlayers( ply:Team() ) > 0 then
		local found = false
		if att and IsValid(att) and att:IsPlayer() then
			found = att
		end
		if !found then
			for _,v in pairs(team.GetPlayers( ply:Team() )) do
				if v != ply and v:Alive() then
					found = v
					break
				end
			end
		end
		if found then
			ply:SetObserverMode( OBS_MODE_CHASE )
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity( found )
		else
			ply:SetObserverMode( OBS_MODE_ROAMING )
			ply:Spectate( OBS_MODE_ROAMING )
		end
		local str = 'ReSpawn "'..(ply.RespawnTime or 0)..'" "'..(Time or 0)..'"'
		if att and IsValid(att) then str = str..' "'..tostring(att:EntIndex())..'"' end
		ply:ConCommand( str )
	end
end

function GM:PlayerDeathThink( ply )
	if !ply:Team() or ply:Team() == TEAM_SPECTATOR or ply:Team() == 0 then return false end
	if (CurTime()<(ply.RespawnTime or 0)) then return false end
	if GameStatus != 0 then return false end
	if GameStatus == 0 then ply:Spawn() end
	self.BaseClass:PlayerDeathThink( ply )
end

function GM:PlayerNoClip(ply)
	self.BaseClass:PlayerNoClip( ply )
	if DEVELOPER_MODE then return true end
	if ply:IsAdmin() then return true end
	return false
end

function GM:PlayerDeathSound()
	return true
end
