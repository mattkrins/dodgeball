if UseMOTD then
	local FirstJoin = true
	local Motd
	function MOTD()
		Motd = vgui.Create( "DFrame" )
		Motd:SetSize( ScrW()*0.75, ScrH()*0.75 )
		Motd:Center()
		Motd:SetTitle( "" )
		Motd:SetVisible( true )
		Motd:SetDraggable( false )
		Motd:ShowCloseButton( DEVELOPER_MODE )
		Motd:MakePopup()
		Motd.Paint = function (self,w,h) end
		local html = vgui.Create( "HTML", Motd )
		html:SetPos( 0, 50 )
		html:SetSize( Motd:GetWide(), Motd:GetTall()-30 )
		html:OpenURL( UseMOTD )
		if MOTD_Link then
			local Web = vgui.Create( "DButton", Motd )
			Web:SetText( "" )
			Web:SetPos( Motd:GetWide()/2-200, 0 )
			Web:SetSize( 200, 30 )
			Web.Color = Color(255,255,255,255)
			Web.OnCursorEntered = function() Web.Color = Color(200,200,200,255) end
			Web.OnCursorExited = function() Web.Color = Color(255,255,255,255) end
			Web.DoClick = function () gui.OpenURL( MOTD_Link ) end
			Web.Paint = function (self,w,h)
				local text = {
					text = "Visit Website",
					font = "30",
					pos = {w/2,h/2},
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
					color = Web.Color,
				}
				draw.TextShadow( text, 1, 200 )
			end
		end
		local Close = vgui.Create( "DButton", Motd )
		Close:SetText( "" )
		if MOTD_Link then Close:SetPos( Motd:GetWide()/2, 0 ) end
		if !MOTD_Link then Close:SetPos( Motd:GetWide()/2-100, 0 ) end
		Close:SetSize( 200, 30 )
		Close.Color = Color(255,255,255,255)
		Close.OnCursorEntered = function() Close.Color = Color(200,200,200,255) end
		Close.OnCursorExited = function() Close.Color = Color(255,255,255,255) end
		Close.DoClick = function ()
			if Motd and IsValid(Motd) and Motd:IsVisible() then Motd:Close() end
			if FirstJoin then
				FirstJoin = false
				timer.Simple( 0.5, function()
					ShowTeamPanel()
				end)
			end
		end
		Close.Paint = function (self,w,h)
			local text = {
				text = "Close MOTD",
				font = "30",
				pos = {w/2,h/2},
				xalign = TEXT_ALIGN_CENTER,
				yalign = TEXT_ALIGN_CENTER,
				color = Close.Color,
			}
			draw.TextShadow( text, 1, 200 )
		end
	end
	concommand.Add( "motd", MOTD)
	
	local function MotdChat(ply, text)
		if text == "!motd" then
			chat.AddText( "Opening MOTD..." )
			MOTD()
			return true
		end
	end
	hook.Add( "OnPlayerChat", "MotdChat", MotdChat )
end