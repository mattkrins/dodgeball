hook.Add("HUDPaint","DevHUD",function()
	if DEVELOPER_MODE then draw.SimpleText( "Warning: Developer Mode Enabled.", "12", 10, 25, Color( 255, 0, 0, 200 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER ) end
end)