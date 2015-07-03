TAUNTS = {
	KILL = {
	"vo/coast/odessa/male01/nlo_cheer02.wav",
	"vo/coast/odessa/male01/nlo_cheer03.wav",
	"vo/coast/odessa/male01/nlo_cheer04.wav",
	"vo/episode_1/npc/male01/cit_kill03.wav",
	"vo/episode_1/npc/male01/cit_kill03.wav",
	"vo/episode_1/npc/male01/cit_kill14.wav",
	"vo/episode_1/npc/male01/cit_kill19.wav",
	"vo/episode_1/npc/male01/cit_kill15.wav",
	"vo/npc/male01/gotone01.wav",
	"vo/npc/male01/gotone02.wav",
	"vo/npc/male02/reb2_buddykilled13.wav",
	"vo/npc/barney/ba_gotone.wav"
	}
}

if SERVER then
	meta = FindMetaTable( "Player" )
	function meta:Taunt()
		if !self:Alive() or (self.NextTaunt or 0) > CurTime() or (math.random(0,2) > 1) then return end
		self.NextTaunt = CurTime() + 30
		local emit = false
		if istable(TAUNTS.KILL) then emit = table.Random(TAUNTS.KILL) end
		if isstring(TAUNTS.KILL) then emit = TAUNTS.KILL end
		if !emit then return end
		self:EmitSound(emit,140,100)
	end
end