///-------------------------------------------------------------------------///
///-------------------------DodgeBall: By StealthPaw------------------------///
///----------------------------www.studiopaw.com----------------------------///

// How long is the respawn timer?
RespawnTime = 5
// How long do we have before a new round starts?
AfterRoundWait = 10
// How long should the rounds go for (in seconds)?
RoundTimer = 300
// Do you want to use the voiced announcer system?
UseAnnouncer = true
// Are you using your own administration system?
UseAdministration = true
// Should bots have AI?
Enable_Bots = true
if Enable_Bots then
	// How hard should the bot players be (lower is better)?
	Bot_Difficulty = 20
	// Should the AI use the NextBot system?
	Bot_UseNextBotSystem = true
end
// Are you using your own map voting system?
UseMapVote = true
if UseMapVote then
	// Inbuilt voting map list:
	MapList = {
	"db_caveball_A4",
	"db_EastLA_A4",
	"db_skeeball_A4",
	"db_skyscraper_A4",
	"db_tetriz_A4"
	}
end
// There is no player model selection at the moment - only random models from this table:
PLAYERMODELS = {
	"models/player/barney.mdl",
	"models/player/breen.mdl",
	"models/player/police.mdl",
	"models/player/combine_soldier.mdl",
	"models/player/combine_soldier_prisonguard.mdl",
	"models/player/combine_super_soldier.mdl",
	"models/player/eli.mdl",
	"models/player/gman_high.mdl",
	"models/player/kleiner.mdl",
	"models/player/monk.mdl"
}

///-------------------------------------------------------------------------///
// Do not alter anything under here unless you know what you are doing.
WinningScore = 4
DEVELOPER_MODE = false
Server_ContentID = 473783835
