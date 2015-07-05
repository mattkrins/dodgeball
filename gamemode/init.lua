AddCSLuaFile( "config.lua" )
include( "config.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

util.AddNetworkString( "UpdateBalls" )
util.AddNetworkString( "Team" )
util.AddNetworkString( "ReSpawn" )

net.Receive( "Team", function( len, ply )
	local Team = net.ReadFloat()
	if !Team then return end
	ply:SetTeam( Team )
	ply:StripWeapons()
	ply:StripAmmo()
	ply:KillSilent()
	ply:Spectate( OBS_MODE_ROAMING )
	ply.RespawnTime = (RespawnTime or 0) + 2
end )

function GM:ShowTeam( ply )
	ply:ConCommand( "team" )
end

function GM:ShowSpare2( ply )
	return false
end

function GM:PlayerAuthed( ply )
	self.BaseClass:PlayerAuthed( ply )
	ply:ConCommand( "intro" )
	timer.Simple( 3, function()
		if UseMOTD then
			ply:ConCommand( "motd" )
		else
			ply:ConCommand( "team" )
		end
	end )
end

function GM:PlayerDisconnected( ply )
	if !ply.Kicked then
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
		self.BaseClass:PlayerInitialSpawn( ply )
		ply:StripWeapons()
		ply:StripAmmo()
		ply:KillSilent()
		timer.Simple( 0.1, function()
			ply:SetTeam( TEAM_SPECTATOR )
			ply:Spectate( OBS_MODE_ROAMING )
		end )
	end
end

function GM:PlayerSpawn( ply )
	local walk = 260
	local run = 350
	if ply:Team() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
		ply.Spawning = true
		ply:SetupHands()
		local Team = Teams[ply:Team()]
		ply:SetCustomCollisionCheck( true )
		ply:SetSuppressPickupNotices( true )
		ply:StripWeapons()
		ply:StripAmmo()
		self.BaseClass:PlayerSpawn( ply )
		ply:SetRunSpeed( 350 )
		ply:SetWalkSpeed( 260 )
		local spawns = false
		if Team.Spawns[game.GetMap()] then spawns = Team.Spawns[game.GetMap()] end
		if spawns then
			local pos
			if istable(spawns) then pos = table.Random( spawns ) end
			if isstring(spawns) then pos = spawns end
			if pos then ply:SetPos( pos ) end
		end
		timer.Simple( 2, function()
			if ply and IsValid(ply) then ply.Spawning = false end
		end )
	end
end

function GM:PlayerLoadout( ply )
	if !Teams or !ply:Team() or !Teams[ply:Team()] then return end
	local Team = Teams[ply:Team()]
	if ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
		ply:StripWeapons()
		ply:StripAmmo()
		ply:SetArmor(0)
	end
	ply.HasBall = true
	ply:GiveBall()
	if DEVELOPER_MODE and ply:IsAdmin() then ply:Give("weapon_physgun") ply:Give("gmod_tool") end
end

function GM:PlayerSetModel( ply )
	self.BaseClass:PlayerSetModel( ply )
	ply:SetModel(table.Random(PLAYERMODELS))
	if ply:Team() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
		local tCol = team.GetColor( ply:Team() )
		col = Vector(tCol.r/255,tCol.g/255,tCol.b/255)
		ply:SetPlayerColor( col )
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
		net.Start( "ReSpawn" )
			net.WriteFloat(ply.RespawnTime)
			net.WriteFloat(Time)
			if att then net.WriteEntity(att) end
		net.Send( ply )
	end
end

function GM:PlayerDeathThink( ply )
	if !ply:Team() or ply:Team() == TEAM_SPECTATOR or ply:Team() == 0 then return false end
	if (CurTime()<(ply.RespawnTime or 0)) then return false end
	if GameStatus != 0 then return false end
	ply:Spawn()
	self.BaseClass:PlayerDeathThink( ply )
end

function GM:ScalePlayerDamage( ply, hit, dmg )
	if IsValid( dmg:GetAttacker() ) then
		if dmg:GetAttacker():IsPlayer() then
			if ply:Team() and ply:Team() == dmg:GetAttacker():Team() and dmg:GetAttacker() != ply then
				dmg:ScaleDamage( 0 )
				return
			end
		end
	end
end

function GM:ShouldCollide(ent1, ent2)
	if (ent2:IsPlayer() and ent2:Team()) and ent1:IsPlayer() then
		return false
	end
	if (ent1:IsPlayer() and ent1:IsPlayer()) and (ent1:Team() == ent1:Team()) then
		return true
	end
	return true
end

function GM:PlayerNoClip(ply)
	if DEVELOPER_MODE then return true end
	if ply:IsAdmin() then return true end
	return false
end

function GM:PlayerDeathSound()
	return true
end
