if Enable_Bots then
	Ai_Enabled = true
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

	local function BotMove(ply,mv, cmd)
		if ply:IsBot() and GameStatus == 0 and ply:Alive() then
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

	local function FindBall(ply)
		local FindBalls = 400
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
		if ply:IsBot() and GameStatus == 0 and ply:Alive() then
			if !ply:Alive() then cmd:SetButtons( IN_ATTACK ) end
			ply.target = ply.target or false
			ply.FindingBall = ply.FindingBall or false
			if !ply.HasBall then ply.target = nil else ply.FindingBall = nil end
			if ply.target and IsValid(ply.target) and ply.target:Alive() then
				local vec1 = ply.target:GetPos()
				local vec2 = ply:GetShootPos()
				local ang = ( vec1 - vec2 ):Angle()
				ply:SetEyeAngles( Angle(ang.p+math.Rand(-Difficulty,Difficulty), ang.y+math.Rand(-Difficulty,Difficulty), ang.r+math.Rand(-Difficulty,Difficulty)) )
				if ply:GetPos():Distance(ply.target:GetPos()) > 200 then
					cmd:SetButtons( IN_FORWARD )
					cmd:SetForwardMove( 210+(Difficulty) )
				end
				local watching = ply:GetEyeTrace().Entity or false
				if watching then
					cmd:SetButtons( IN_ATTACK )
				end
			elseif ply.HasBall then
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
					cmd:SetForwardMove( 300+(Difficulty) )
				end
			elseif !ply.target then 
				ply.FindingBall = FindBall(ply)
			end
		end
	end
	hook.Add( "StartCommand", "BotController", BotControl )

	local function BotThink()
		if GameStatus == 0  then
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
end