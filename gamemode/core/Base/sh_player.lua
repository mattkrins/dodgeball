local meta = FindMetaTable( "Player" )

function meta:HasBall()
	return (self.HoldingBall or false)
end

function GM:ShouldCollide( ent1, ent2 )
	if ent1:IsPlayer() and ent2:IsPlayer() then
		if ent1:Team() == ent2:Team() then
			return false
		end
	end
	if ent2.IsBall and ent1:IsPlayer() then
		return true
	end
	if ent1.IsBall and ent2:IsPlayer() then
		return true
	end
	return true
end

if SERVER then
	util.AddNetworkString( "UpdatePlayer" )
	function meta:GiveBall()
		self.HoldingBall = true
		net.Start( "UpdatePlayer" )
			net.WriteEntity(self)
			net.WriteBool(true)
		net.Broadcast()
		local ball_class = "weapon_dodgeball"
		if !self:HasWeapon( ball_class ) then
			self:Give(ball_class)
			if self:GetActiveWeapon():GetClass() != ball_class then self:SelectWeapon( ball_class ) end
		elseif self:GetActiveWeapon():GetClass() != ball_class then
			self:SelectWeapon( ball_class )
		end
	end
	function meta:TakeBall()
		self.HoldingBall = false
		net.Start( "UpdatePlayer" )
			net.WriteEntity(self)
			net.WriteBool(false)
		net.Broadcast()
	end
end

if CLIENT then
	net.Receive( "UpdatePlayer", function()
		local ply = net.ReadEntity() or false
		local has = net.ReadBool() or false
		if !ply then return end
		ply.HoldingBall = has or false
	end )
	
	function GM:PrePlayerDraw( ply )
		self.BaseClass:PrePlayerDraw( ply )
		local ball_class = "weapon_dodgeball"
		if ply:Alive() and ply:HasWeapon( ball_class ) and ply:Team() and ply:Team() != TEAM_SPECTATOR and ply:Team() != TEAM_UNASSIGNED then
			local ball = ply:GetWeapon( ball_class )
			if ball and ball.WElements and ball.WElements.ball then
				if ply:HasBall() then
					if (ball.WElements.ball.color.a or 255) != 255 then ball.WElements.ball.color.a = 255 end
					if ply:Team() and team.GetColor( ply:Team() ) and ball.WElements.ball.color != team.GetColor( ply:Team() ) then
						ball.WElements.ball.color = ( team.GetColor( ply:Team() ) or ball.WElements.ball.color )
					end
				else
					if (ball.WElements.ball.color.a or 0) != 0 then ball.WElements.ball.color.a = 0 end
				end
			end
		end
		return false
	end
end