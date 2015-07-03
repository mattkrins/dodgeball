if CLIENT then
	for _,v in pairs({8,10,12,16,20,24,30,42,50,55,60,70,80,90,100}) do
		surface.CreateFont( tostring(v), {
			font = "Arial",
			weight = 500,
			size = tonumber(v),
			antialias = true
		} )
	end
	
	if !DEVELOPER_MODE then
		function GM:OnSpawnMenuOpen()
			if UseAdministration and LocalPlayer():IsAdmin() then LocalPlayer():ConCommand( "admin" ) end
		end
	end
	
	hook.Add("HUDShouldDraw", "HideSelector", function( name )
		if ( name == "CHudHealth" ) then return false end
		if ( name == "CHudBattery" ) then return false end
		if DEVELOPER_MODE then return true end
		if ( name == "CHudWeaponSelection" ) then return false end
	end)
	
	function GM:PrePlayerDraw( ply )
		self.BaseClass:PrePlayerDraw( ply )
		local ball_class = "weapon_dodgeball"
		if ply:HasWeapon( ball_class ) then
			local ball = ply:GetWeapon( ball_class )
			if ply.HasBall then
				ball.WElements.ball.color.a = 255
			else
				ball.WElements.ball.color.a = 0
			end
		end
		return false
	end

	net.Receive( "UpdateBalls", function()
		local ply = net.ReadEntity() or false
		local has = net.ReadBool() or false
		if !ply then return end
		ply.HasBall = has
	end )
	
	if DEVELOPER_MODE then
		function getthepos2(ply)
				if !ply:IsAdmin() and !DEVELOPER_MODE then return end
				local tr = ply:GetEyeTrace( )
				local ent = tr.Entity
				print("----------GET POS----------");
				if ent:IsValid() then
					print("Entity("..tostring(ent)..")")
					if ent:GetModel( ) then print( 'Model("'..ent:GetModel( )..'")' ) end
					if ent:GetPos( ) then
						print( "Vector("..string.Replace( tostring(ent:GetPos( )), " ", ", " )..")" )
						SetClipboardText( "Vector("..string.Replace( tostring(ent:GetPos( )), " ", ", " )..")" )
					end
					if ent:GetAngles( ) then print( "Angle("..string.Replace( tostring(ent:GetAngles( )), " ", ", " )..")" ) end
				else
					print("Invalid Target");
				end
				print("----------GET POS----------");
		end
		concommand.Add( "getpos2", getthepos2)
	end
end