if UseMapVote and MapList and #MapList > 1 then
	if SERVER then
		util.AddNetworkString( "mapvote" )
	end
	local function SendChat(message)
		if !SERVER or !message then return end
		for _,v in pairs(player.GetAll()) do
			v:ChatPrint( message )
		end
	end
	MapVote = {}
	MapVote.Votes = {}
	MapVote.Voting = false
	MapVote.Changing = false
	MapVote.Start = function(self)
		if MapVote.Voting or MapVote.Changing then return false end
		MapVote.Voting = true
		MapVote.Votes = {}
		for k,v in pairs(MapList) do
			if v != game.GetMap() then
				MapVote.Votes[k] = 0
			end
		end
		if SERVER then
			timer.Simple( 2, function()
				for _,v in pairs(player.GetAll()) do
					v:ChatPrint( "Vote for the next map!" )
					v:ConCommand( "mapvote" )
				end
			end)
		end
		timer.Simple( 20, function()
			MapVote:Finish()
		end)
	end
	MapVote.Finish = function(self)
		if !MapVote.Voting then return false end
		for _,v in pairs(player.GetAll()) do
			v:ConCommand( "voteclose" )
		end
		MapVote.Voting = false
		local winner = false
		local highest = 0
		for k,v in pairs(MapVote.Votes) do
			if (v or 0) > highest then winner = k break end
		end
		if winner then
			if winner == 0 then
				SendChat("Another round won, restarting...")
				timer.Simple( 5, function()
					Game:New()
				end)
			else
				MapVote.Changing = true
				SendChat(MapList[winner].." won the vote, map changing in 10 seconds.")
				timer.Simple( 10, function()
					MapVote:ChangeMap(MapList[winner])
				end)
			end
		else
			SendChat("No map won, round restarting...")
			timer.Simple( 5, function()
				Game:New()
			end)
		end
	end
	MapVote.ChangeMap = function(self, map)
		if !MapVote.Changing or !map then return false end
		if SERVER then
			timer.Simple( 2, function()
				print("Changing map to "..map.."...")
				RunConsoleCommand("changelevel", map)
			end)
		end
	end
	if SERVER then
		net.Receive( "mapvote", function( len, ply )
			if !ply then return end
			if !MapVote.Voting or !MapVote.Votes then return end
			local Command = net.ReadString()
			if !Command then return end
			if Command == "vote" then
				local Map = net.ReadFloat()
				if !Map then return end
				MapVote.Votes[Map] = (MapVote.Votes[Map] or 0) + 1
			end 
		end )
	end
	if CLIENT then
		local MapVotePanel
		local function Vote(Map)
			net.Start("mapvote")
				net.WriteString("vote")
				net.WriteFloat(Map)
			net.SendToServer()
		end

		local function AddMap(Parent, Key, Map)
			local MapButton = vgui.Create( "DButton", Parent )
			MapButton:SetText( "" )
			MapButton.OnCursorEntered = function()
				MapButton.Hovered = true
			end
			MapButton.OnCursorExited = function()
				MapButton.Hovered = false
			end
			MapButton.Paint = function (self,w,h)
				local col = Color(255,255,255,255)
				if MapButton.Hovered then col = Color(200,200,200,255) end
				local text = {
					text = Map,
					font = "24",
					pos = {0,h/2},
					xalign = TEXT_ALIGN_LEFT,
					yalign = TEXT_ALIGN_CENTER,
					color = col,
				}
				draw.TextShadow( text, 1, 20 )
			end
			MapButton.DoClick = function()
				Vote(Key)
				if MapVotePanel and IsValid(MapVotePanel) then MapVotePanel:Close() end
			end
			Parent:Add( MapButton )
		end

		local function ShowMapVoter()
			if MapVotePanel and IsValid(MapVotePanel) then MapVotePanel:Close() end
			MapVotePanel = vgui.Create( "DFrame" )
			MapVotePanel:SetPos( 20,ScrH()/4 )
			MapVotePanel:SetSize( 200, ScrH()/2 )
			MapVotePanel:SetTitle( "" )
			MapVotePanel:SetVisible( true )
			MapVotePanel:SetDraggable( false )
			MapVotePanel:ShowCloseButton( DEVELOPER_MODE )
			MapVotePanel:MakePopup()
			MapVotePanel.Paint = function( self, w, h )
				draw.RoundedBoxEx( 8, 0, 0, w, h, Color(0,0,0,200), true, true, true, true)
				local text = {
					text = "Vote for the next map",
					font = "20",
					pos = {w/2,15},
					xalign = TEXT_ALIGN_CENTER,
					yalign = TEXT_ALIGN_CENTER,
					color = Color(255,255,255,255),
				}
				draw.TextShadow( text, 1, 20 )
			end
			local MapScroll = vgui.Create( "DScrollPanel", MapVotePanel )
			MapScroll:SetPos( 10, 25 )
			MapScroll:SetSize( MapVotePanel:GetWide()-10, MapVotePanel:GetTall() )
			local MapLayout = vgui.Create( "DListLayout", MapScroll )
			MapLayout:SetSize( MapScroll:GetWide(), MapScroll:GetTall() )
			AddMap(MapLayout, 0, "Play this map again")
			for k,v in pairs(MapList) do
				if v != game.GetMap() then
					AddMap(MapLayout, k, v)
				end
			end
			MapVotePanel:SizeToContents()
		end
		concommand.Add( "mapvote", ShowMapVoter)
		local function CloseMapVoter()
			if MapVotePanel and IsValid(MapVotePanel) then MapVotePanel:Close() end
		end
		concommand.Add( "voteclose", CloseMapVoter)
	end
end