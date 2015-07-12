///-------------------------------------------------------------------------///
///-------------------------DodgeBall: By StealthPaw------------------------///
///----------------------------www.studiopaw.com----------------------------///

// How long is the respawn timer?
RespawnTime = 5
// How long should you have god-mode for after spawning (set to false to disable)
SpawnProtection = 3
// How many points does a team need to score? (set to false for auto)
WinningScore = false
// How long do we have before a new round starts?
AfterRoundWait = 10
// How long should the rounds go for (in seconds)?
RoundTimer = 300
// Do you want to use the voiced announcer system?
UseAnnouncer = true
// Are you using your own administration system?
UseAdministration = true
// What is the URL of your MOTD? (set to false to disable)
UseMOTD = "http://studiopaw.com/files/dodgeball_motd/"
if UseMOTD then
	// What is the URL of your website/forum? (set to false to disable)
	MOTD_Link = "http://steamcommunity.com/sharedfiles/filedetails/?id=473793126"
end
// Should bots have AI?
Enable_Bots = true
if Enable_Bots then
	// How hard should the bot players be 0-50 (lower is better)
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

// Set to true to enable sandbox and debugging options. Good for placing spawn points etc.
DEVELOPER_MODE = false

///-------------------------------------------------------------------------///