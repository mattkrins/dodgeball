local Board = Material("dodgeball/scoreboard.png")
local Logo = Material("dodgeball/logo.png")
local Ball_Texture = Material("dodgeball/dodgeball")
local Scoreboard
local function AddPlayer(Parent, ply)
	local Person = vgui.Create( "DButton", Parent )
	Person:SetText( "" )
	Person.OnCursorEntered = function()
		Person.Hovered = true
	end
	Person.OnCursorExited = function()
		Person.Hovered = false
	end
	Person.Paint = function (self,w,h)
		local col = Color(255,255,255,150)
		if ply:Team() and Teams[ply:Team()] then col = Teams[ply:Team()].Color end
		if Person.Hovered then col = Color(255,255,255,150) end
		local text = {
			text = ply:Nick().." ("..ply:Frags().."/"..ply:Deaths()..")",
			font = "16",
			pos = {0,h/2},
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
			color = col,
		}
		draw.TextShadow( text, 1, 20 )
	end
	Person.DoClick = function()
		ply:ShowProfile()
	end
	Person:SizeToContents()
	Parent:Add( Person )
end
local function MakeScoreboard()
	if Scoreboard and IsValid(Scoreboard) then Scoreboard:Close() end
	Scoreboard = vgui.Create( "DFrame" )
	Scoreboard:SetSize( ScrW()/2, ScrH()/2 )
	Scoreboard:Center()
	Scoreboard:SetTitle( "" )
	Scoreboard:SetVisible( true )
	Scoreboard:SetDraggable( false )
	Scoreboard:ShowCloseButton( false )
	Scoreboard:SetKeyboardInputEnabled( true )
	Scoreboard.Players = player.GetAll()
	Scoreboard.Paint = function (self,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(Board)
		surface.DrawTexturedRect(0, 0, w, h)
		if LocalPlayer():KeyPressed( IN_USE ) then
			gui.EnableScreenClicker( true )
		end
	end
	local PlayerScroll = vgui.Create( "DScrollPanel", Scoreboard )
	PlayerScroll:SetSize( Scoreboard:GetWide()/6, Scoreboard:GetTall()/1.25 )
	PlayerScroll:SetPos( Scoreboard:GetWide()/20, Scoreboard:GetTall()/10 )
	local Players = vgui.Create( "DListLayout", PlayerScroll )
	Players:SetSize( PlayerScroll:GetWide(), PlayerScroll:GetTall() )
	for _,v in pairs(Scoreboard.Players) do
		AddPlayer(Players, v)
	end
	
	local ScorePanel = vgui.Create( "DPanel", Scoreboard )
	ScorePanel:SetSize( Scoreboard:GetWide()/1.3, Scoreboard:GetTall()/1.25 )
	ScorePanel:SetPos( ScorePanel:GetWide()/5, Scoreboard:GetTall()/10 )
	ScorePanel.Paint = function (self,w,h)
		local text = {
			text = "Press use to enable mouse",
			font = "24",
			pos = {w/2,h/50},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,255,255,120),
		}
		draw.TextShadow( text, 1, 20 )
		text.text = "Time Left: "..tostring(math.floor(math.Clamp((Game.Timer or 0) - CurTime() or 0, 0, RoundTimer or 300))) or 0
		text.pos = {w/2,h/1.1		}
		text.color.a = 255
		draw.TextShadow( text, 1, 20 )
	end
	local Team1 = vgui.Create( "DPanel", ScorePanel )
	Team1:SetPos( ScorePanel:GetWide()/6, 24+ScorePanel:GetTall()/4 )
	Team1:SetSize( ScorePanel:GetWide()/4, ScorePanel:GetTall()/2-24 )
	local c = Teams[1].Color
	Team1.Paint = function (self,w,h)
		surface.SetDrawColor(c.r,c.g,c.b,255)
		surface.SetMaterial(Ball_Texture)
		surface.DrawTexturedRect(0, 0, w, h)
		local text = {
			text = team.GetScore( 1 ),
			font = "60",
			pos = {w/2,h/2},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,255,255,255),
		}
		draw.TextShadow( text, 1, 255 )
	end
	local Team2 = vgui.Create( "DPanel", ScorePanel )
	Team2:SetPos( ScorePanel:GetWide()/2+ScorePanel:GetWide()/8, 24+ScorePanel:GetTall()/4 )
	Team2:SetSize( ScorePanel:GetWide()/4, ScorePanel:GetTall()/2-24 )
	local c = Teams[2].Color
	Team2.Paint = function (self,w,h)
		surface.SetDrawColor(c.r,c.g,c.b,255)
		surface.SetMaterial(Ball_Texture)
		surface.DrawTexturedRect(0, 0, w, h)
		local text = {
			text = team.GetScore( 2 ),
			font = "60",
			pos = {w/2,h/2},
			xalign = TEXT_ALIGN_CENTER,
			yalign = TEXT_ALIGN_CENTER,
			color = Color(255,255,255,255),
		}
		draw.TextShadow( text, 1, 255 )
	end
end
function GM:ScoreboardShow()
	if Scoreboard and IsValid(Scoreboard) then
		if Scoreboard.Players != player.GetAll() then
			MakeScoreboard()
		else
			Scoreboard:SetVisible(true)
		end
	else
		MakeScoreboard()
	end
end
function GM:ScoreboardHide()
	if Scoreboard and IsValid(Scoreboard) then
		Scoreboard:SetVisible(false)
	end
	gui.EnableScreenClicker( false )
end
function GM:HUDDrawScoreBoard()
	return false
end