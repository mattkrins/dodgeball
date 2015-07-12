hook.Add("HUDPaint","DevHUD",function()
	if DEVELOPER_MODE then draw.SimpleText( "Warning: Developer Mode Enabled.", "12", 10, 25, Color( 255, 0, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) end
	if (#player.GetAll() or 0) < 2 then
		local text = {
			text = "Waiting for more players",
			font = "42",
			pos = {ScrW()/2,50},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,255,255,220),
		}
		draw.TextShadow( text, 1, 250 )
	end
end)