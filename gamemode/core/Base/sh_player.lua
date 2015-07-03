local meta = FindMetaTable( "Player" )

function meta:GiveBall()
	local ball_class = "weapon_dodgeball"
	if self:HasWeapon( ball_class ) then
		if !self:Ball() then
			local ball = self:GetWeapon( ball_class )
			ball:GiveBall()
		end
	else
		self:Give(ball_class)
	end
end

function meta:Ball()
	return self.HasBall or false
end