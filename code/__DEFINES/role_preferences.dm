

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
#define ROLE_SYNDICATE				"Syndicate"
#define ROLE_TRAITOR				"traitor"
#define ROLE_OPERATIVE				"operative"
#define ROLE_CHANGELING				"changeling"
#define ROLE_WIZARD					"wizard"
#define ROLE_MALF					"malf AI"
#define ROLE_REV					"revolutionary"
#define ROLE_REV_HEAD				"Head Revolutionary"
#define ROLE_ALIEN					"xenomorph"
#define ROLE_PAI					"pAI"
#define ROLE_CULTIST				"cultist"
#define ROLE_BLOB					"blob"
#define ROLE_NINJA					"space ninja"
#define ROLE_MONKEY					"monkey"
#define ROLE_ABDUCTOR				"abductor"
#define ROLE_REVENANT				"revenant"
#define ROLE_DEVIL					"devil"
#define ROLE_SERVANT_OF_RATVAR		"servant of Ratvar"
#define ROLE_BROTHER				"blood brother"
#define ROLE_BRAINWASHED			"brainwashed victim"
#define ROLE_OVERTHROW				"syndicate mutineer"
#define ROLE_HIVE					"hivemind host"
#define ROLE_SENTIENCE          	"sentience potion spawn"
#define ROLE_MIND_TRANSFER          "mind transfer potion"
#define ROLE_POSIBRAIN              "posibrain"
#define ROLE_DRONE                  "drone"
#define ROLE_DEATHSQUAD             "deathsquad"
#define ROLE_LAVALAND               "lavaland"
#define ROLE_INTERNAL_AFFAIRS	"internal affairs agent"

//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
GLOBAL_LIST_INIT(special_roles, list(
	ROLE_TRAITOR = /datum/game_mode/traitor,
	ROLE_BROTHER = /datum/game_mode/traitor/bros,
	ROLE_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_CHANGELING = /datum/game_mode/changeling,
	ROLE_WIZARD = /datum/game_mode/wizard,
	ROLE_MALF,
	ROLE_REV = /datum/game_mode/revolution,
	ROLE_ALIEN,
	ROLE_PAI,
	ROLE_CULTIST = /datum/game_mode/cult,
	ROLE_BLOB,
	ROLE_NINJA,
	ROLE_MONKEY = /datum/game_mode/monkey,
	ROLE_REVENANT,
	ROLE_ABDUCTOR,
	ROLE_DEVIL = /datum/game_mode/devil,
	ROLE_SERVANT_OF_RATVAR = /datum/game_mode/clockwork_cult,
	ROLE_OVERTHROW = /datum/game_mode/overthrow,
	ROLE_HIVE = /datum/game_mode/hivemind,
	ROLE_INTERNAL_AFFAIRS = /datum/game_mode/traitor/internal_affairs,
	ROLE_SENTIENCE
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEOVERFLOW 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3
