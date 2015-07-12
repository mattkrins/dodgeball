if Enable_Bots and !game.SinglePlayer() then
	Ai_Enabled = true
	Ai_Think = true
	Ai_Names = {
		"StealthPaw",
		"Ataskuri",
		"Nate",
		"ZoboCamel",
		"Cliffe",
		"Crusher",
		"Gunner",
		"Minh",
		"Pheonix",
		"Clarence",
		"Elliot",
		"Rock",
		"Shark",
		"Eugene",
		"Fergus",
		"Ferris",
		"Frank",
		"Steel",
		"Fred",
		"George",
		"Stone",
		"Vitaliy",
		"Wolf",
		"Zed",
		"Vladimir"
	}

	local function CanBotsThink()
		if (#player.GetAll() or 0) < 2 then return false end
		if !Ai_Think then return false end
		if GameStatus != 0 then return false end
		return true
	end
	
	local function BotMove(ply,mv, cmd)
		if ply:IsBot() and CanBotsThink() and ply:Alive() then
			if ply.FindingBall then
				mv:SetMoveAngles( ply:EyeAngles() )
			else
				if ply.target and ply:GetPos():Distance(ply.target:GetPos()) > 200 then
					mv:SetMoveAngles( ply:EyeAngles() )
				end
			end
		end
	end
	hook.Add( "SetupMove", "BotMover", BotMove )
	
	local function FindSpot(ply)
		local OldVector = ply:GetPos()
		local seed = 200
		local NewVector = Vector(OldVector.x+math.Rand(-seed,seed),OldVector.y+math.Rand(-seed,seed),OldVector.z+math.Rand(-seed,seed))
		return NewVector
	end
	
	local function FindBall(ply)
		local FindBalls = 200
		local closest_ditance = FindBalls
		local FoundBall = false
		for _,v in pairs(ents.FindInSphere( ply:GetPos(), FindBalls )) do
			if (v:GetClass() == "dodgeball") and v.Bounced and ply:GetPos():Distance(v:GetPos()) < (closest_ditance or FindBalls) then
				closest_ditance = ply:GetPos():Distance(v:GetPos())
				FoundBall = v
			end
		end
		return FoundBall or false
	end

	local function BotControl(ply,cmd)
		local Difficulty = math.Clamp(Bot_Difficulty or 10, 0, 50) or 10
		if ply:IsBot() and CanBotsThink() and ply:Alive() then
			if !ply:Alive() then cmd:SetButtons( IN_ATTACK ) end
			ply.target = ply.target or false
			ply.FindingBall = ply.FindingBall or false
			if !ply:HasBall() then
				ply.target = nil
			else
				ply.FindingBall = nil
			end
			if ply.target and IsValid(ply.target) and ply.target:Alive() then
				local vec1 = ply.target:GetPos()
				local vec2 = ply:GetShootPos()
				local ang = ( vec1 - vec2 ):Angle()
				ply:SetEyeAngles( Angle(ang.p+math.Rand(-Difficulty,Difficulty), ang.y+math.Rand(-Difficulty,Difficulty), ang.r+math.Rand(-Difficulty,Difficulty)) )
				if ply:GetPos():Distance(ply.target:GetPos()) > 200 then
					cmd:SetButtons( IN_FORWARD )
					cmd:SetForwardMove( 260-(Difficulty) )
				end
				local watching = ply:GetEyeTrace().Entity or false
				if watching then
					cmd:SetButtons( IN_ATTACK )
				end
			elseif ply:HasBall() then
				for _,v in pairs(player.GetAll()) do
					if v:Alive() and (ply:Team() != v:Team()) then
						ply.target = v
						break
					end
				end
			end
			if ply.FindingBall and IsValid(ply.FindingBall) then
				ply.FindingBall = FindBall(ply)
				if ply.FindingBall then
					local vec1 = ply.FindingBall:GetPos()
					local vec2 = ply:GetShootPos()
					ply:SetEyeAngles( ( vec1 - vec2 ):Angle() )
					cmd:SetButtons( IN_FORWARD )
					cmd:SetForwardMove( 350-(Difficulty) )
				end
			elseif !ply.target then 
				ply.FindingBall = FindBall(ply)
			end
			if !ply.FindingBall and !ply.target then
				if (ply.RunTime or 0) < CurTime() then
					ply.GoTo = FindSpot(ply)
					ply.RunTime = CurTime() + 2
				end
				if ply.GoTo and ply:GetPos():Distance(ply.GoTo) > 100 then
					ply:SetEyeAngles( ( ply.GoTo - ply:GetShootPos() ):Angle() )
					cmd:SetButtons( IN_FORWARD )
					cmd:SetForwardMove( 260-(Difficulty) )
				end
			else
				if ply.RunTime > 0 then ply.RunTime = 0 end
			end
		end
	end
	hook.Add( "StartCommand", "BotController", BotControl )
	
	// NextBot AI can't seem to respawn by themselves - we need to force them to.
	local function BotThink()
		if CanBotsThink() then
			for _,v in pairs(player.GetAll()) do
				if v:IsBot() and !v:Alive() then
					if (CurTime()>=(v.RespawnTime or 0)) then
						v:Spawn()
					end
				end
			end
		end
	end
	hook.Add( "Think", "BotThinking", BotThink )
	
	local function AddBot(ply, cmd, args)
		if !ply or !ply:IsAdmin() then return end
		if Bot_UseNextBotSystem then
			local name = false
			if args and args[1] then name = tostring(args[1]) or false end
			if !name and Ai_Names then name = table.Random(Ai_Names) end
			player.CreateNextBot( name )
		else
			ply:ConCommand( "bot" )
		end
		ply:ChatPrint( "Added Bot." )
	end
	concommand.Add( "bot_add", AddBot)
	
	local function ToggleBot(ply, cmd, args)
		if !ply or !ply:IsAdmin() then return end
		if Ai_Think then
			Ai_Think = false
		else
			Ai_Think = true
		end
		ply:ChatPrint( "Toggled Bot AI" )
	end
	concommand.Add( "bot_toggle", ToggleBot)
	
	local function KillBot(ply, cmd, args)
		if !ply or !ply:IsAdmin() then return end
		local find = false
		if args and args[1] then find = tostring(args[1]) or false end
		for _,v in pairs(player.GetAll()) do
			if v:IsBot() and v:Alive() then
				if find then
					if find == v:Nick() or string.match( v:Nick(), find ) then v:Kill() end
				else
					v:Kill()
				end
			end
		end
		ply:ChatPrint( "Bot Holocaust!" )
	end
	concommand.Add( "bot_kill", KillBot)
end