if SERVER then util.AddNetworkString( "Announcer" ) end

Announcer = {}
Announcer.Play = function(self, audio, players)
	if !audio then return false end
	local sending = false
	if istable(audio) then sending = table.Random(audio) end
	if isstring(audio) then sending = audio end
	if !sending then return end
	if SERVER then
		net.Start( "Announcer" )
		net.WriteString(tostring(sending))
		if players then
			net.Send(players)
		else
			net.Broadcast()
		end
	end
end

if CLIENT then
	net.Receive( "Announcer", function()
		local audio = net.ReadString() or false
		if !audio then return end
		surface.PlaySound( Sound(audio) )
	end )
end

if UseAnnouncer and SERVER then
	FirstBlood = false
	local function KillAnouncments( ply, inf, att )
		if att:IsPlayer() and att:Team() and att != ply then
			if !FirstBlood then
				FirstBlood = att
				Announcer:Play("dodgeball/announcer/firstblood.mp3")
			end
			if (att.KillSpree or 0) < 1 then
				timer.Simple( 8, function()
					if att and IsValid(att) then
						if att.KillSpree > 1 then
							if att.KillSpree == 2 then
								Announcer:Play("dodgeball/announcer/kill_double.mp3", att)
							elseif att.KillSpree == 3 then
								Announcer:Play("dodgeball/announcer/kill_triple.mp3")
							elseif att.KillSpree == 4 then
								Announcer:Play("dodgeball/announcer/kill_ultra.mp3")
							elseif att.KillSpree >= 5 then
								Announcer:Play("dodgeball/announcer/kill_rampage.mp3")
							end
						end
						att.KillSpree = 0
					end
				end )
			end
			att.KillSpree = (att.KillSpree or 0) + 1
			--if (att.KillSpree or 0) > CurTime() then
				--att.KillSpree = CurTime() + 0.8
			--end
		end
	end
	hook.Add( "PlayerDeath", "KillAnouncments", KillAnouncments )
end