local TeamPanel
function ShowTeamPanel()
	TeamPanel = vgui.Create( "DFrame" )
	TeamPanel:SetSize( ScrW()/2, ScrH()/2 )
	TeamPanel:Center()
	TeamPanel:SetTitle( "" )
	TeamPanel:SetVisible( true )
	TeamPanel:SetDraggable( false )
	TeamPanel:ShowCloseButton( DEVELOPER_MODE )
	TeamPanel:MakePopup()
	TeamPanel.Paint = function (self,w,h) end
	local Ball_Texture = Material("dodgeball/dodgeball")
	
	local Team1 = vgui.Create( "DButton", TeamPanel )
	Team1:SetText( "" )
	Team1:SetPos( TeamPanel:GetWide()/8, 24+TeamPanel:GetTall()/4 )
	Team1:SetSize( TeamPanel:GetWide()/4, TeamPanel:GetTall()/2-24 )
	local c = Teams[1].Color
	Team1.OnCursorEntered = function()
		surface.PlaySound( "weapons/dodgeball/bounce1.wav" )
	end
	Team1.Paint = function (self,w,h)
		surface.SetDrawColor(c.r,c.g,c.b,255)
		surface.SetMaterial(Ball_Texture)
		surface.DrawTexturedRect(0, 0, w, h)
		local text = {
			text = Teams[1].Name,
			font = "60",
			pos = {w/2,h/2},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,255,255,255),
		}
		draw.TextShadow( text, 1, 255 )
	end
	Team1.DoClick = function ()
		if LocalPlayer():Team() == 1 then if TeamPanel and IsValid(TeamPanel) and TeamPanel:IsVisible() then TeamPanel:Close() end return end
		net.Start( "Team" )
			net.WriteFloat(1)
		net.SendToServer()
		if TeamPanel and IsValid(TeamPanel) and TeamPanel:IsVisible() then TeamPanel:Close() end
	end
	local Team2 = vgui.Create( "DButton", TeamPanel )
	Team2:SetText( "" )
	Team2:SetPos( TeamPanel:GetWide()/2+TeamPanel:GetWide()/8, 24+TeamPanel:GetTall()/4 )
	Team2:SetSize( TeamPanel:GetWide()/4, TeamPanel:GetTall()/2-24 )
	local c = Teams[2].Color
	Team2.OnCursorEntered = function()
		surface.PlaySound( "weapons/dodgeball/bounce3.wav" )
	end
	Team2.Paint = function (self,w,h)
		surface.SetDrawColor(c.r,c.g,c.b,255)
		surface.SetMaterial(Ball_Texture)
		surface.DrawTexturedRect(0, 0, w, h)
		local text = {
			text = Teams[2].Name,
			font = "60",
			pos = {w/2,h/2},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,255,255,255),
		}
		draw.TextShadow( text, 1, 255 )
	end
	Team2.DoClick = function ()
		if LocalPlayer():Team() == 2 then if TeamPanel and IsValid(TeamPanel) and TeamPanel:IsVisible() then TeamPanel:Close() end return end
		net.Start( "Team" )
			net.WriteFloat(2)
		net.SendToServer()
		if TeamPanel and IsValid(TeamPanel) and TeamPanel:IsVisible() then TeamPanel:Close() end
	end
end
concommand.Add( "team", ShowTeamPanel)


local Intro
function ShowIntro()
	Intro = vgui.Create( "DFrame" )
	surface.PlaySound( Sound("dodgeball/music/opening.mp3") )
	local WallPaper = Material("dodgeball/wallpaper.jpg")
	local Logo = Material("dodgeball/logo.png")
	Intro:SetPos( 0,0 )
	Intro:SetSize( ScrW(), ScrH() )
	Intro:SetTitle( "" )
	Intro:SetVisible( true )
	Intro:SetDraggable( false )
	Intro:ShowCloseButton( DEVELOPER_MODE )
	local alpha = 255
	local start = false
	timer.Simple( 4, function()
		start = true
	end )
	Intro.Paint = function (self,w,h)
		if start or TeamPanel then alpha = alpha - 1 end
		surface.SetDrawColor(255,255,255,alpha)
		surface.SetMaterial(WallPaper)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetMaterial(Logo)
		surface.DrawTexturedRect(w/2-250, h/2-50, 500, 100)
		if alpha <= 0 and IsValid(Intro) then Intro:Close() end
	end
end
concommand.Add( "intro", ShowIntro)

local Respawn
function Respawner(DefaultTime, Killer)
	if Respawn and IsValid(Respawn) then Respawn:Close() end
	Respawn = vgui.Create( "DFrame" )
	Respawn:SetPos( 0,0 )
	Respawn:SetSize( ScrW()/2, ScrH()/2 )
	Respawn:Center()
	Respawn:SetTitle( "" )
	Respawn:SetVisible( true )
	Respawn:SetDraggable( false )
	Respawn:ShowCloseButton( DEVELOPER_MODE )
	Respawn.Paint = function (self,w,h)
		local text = {
			text = "Respawning in "..tostring(math.floor(math.Clamp(LocalPlayer().RespawnTime - CurTime() or 0, 0, DefaultTime or RespawnTime))),
			font = "60",
			pos = {w/2,h/2},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,255,255,255),
		}
		draw.TextShadow( text, 1, 255 )
		if Killer and Killer:IsPlayer() and Killer != LocalPlayer() then
			text.text = "Killed By "..Killer:Nick()
			text.font = "30"
			text.pos = {w/2,h/2+60}
			draw.TextShadow( text, 1, 255 )
		end
		if (CurTime()>=(LocalPlayer().RespawnTime or 0)) then
			LocalPlayer().RespawnTime = 0
			if Respawn and IsValid(Respawn) then Respawn:Close() end
		end
	end
end

net.Receive( "ReSpawn", function()
	local Time = net.ReadFloat() or 0
	local DefaultTime = net.ReadFloat() or 0
	local Killer = net.ReadEntity() or false
	LocalPlayer().RespawnTime = Time or 0
	Respawner(DefaultTime, Killer or false)
end)