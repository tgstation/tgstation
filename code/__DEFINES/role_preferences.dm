

//Values for antag preferences, event roles, etc. unified here



//These are synced with the Database, if you change the values of the defines
//then you MUST update the database!
#define ROLE_TRAITOR			"traitor"
#define ROLE_OPERATIVE			"operative"
#define ROLE_CHANGELING			"changeling"
#define ROLE_WIZARD				"wizard"
#define ROLE_MALF				"malf AI"
#define ROLE_REV				"revolutionary"
#define ROLE_ALIEN				"xenomorph"
#define ROLE_PAI				"pAI"
#define ROLE_CULTIST			"cultist"
#define ROLE_BLOB				"blob"
#define ROLE_NINJA				"space ninja"
#define ROLE_MONKEY				"monkey"
#define ROLE_GANG				"gangster"
#define ROLE_ABDUCTOR			"abductor"
#define ROLE_REVENANT			"revenant"
#define ROLE_DEVIL				"devil"
#define ROLE_SERVANT_OF_RATVAR	"servant of Ratvar"
#define ROLE_BORER				"borer"

//Missing assignment means it's not a gamemode specific role, IT'S NOT A BUG OR ERROR.
//The gamemode specific ones are just so the gamemodes can query whether a player is old enough
//(in game days played) to play that role
GLOBAL_LIST_INIT(special_roles, list(
	ROLE_TRAITOR = /datum/game_mode/traitor,
	ROLE_OPERATIVE = /datum/game_mode/nuclear,
	ROLE_CHANGELING = /datum/game_mode/changeling,
	ROLE_WIZARD = /datum/game_mode/wizard,
	ROLE_MALF,
	ROLE_REV = /datum/game_mode/revolution,
	ROLE_ALIEN,
	ROLE_PAI,
	ROLE_CULTIST = /datum/game_mode/cult,
	ROLE_BLOB = /datum/game_mode/blob,
	ROLE_NINJA,
	ROLE_MONKEY = /datum/game_mode/monkey,
	ROLE_GANG = /datum/game_mode/gang,
	ROLE_REVENANT,
	ROLE_ABDUCTOR = /datum/game_mode/abduction,
	ROLE_DEVIL = /datum/game_mode/devil,
	ROLE_SERVANT_OF_RATVAR = /datum/game_mode/clockwork_cult,
	ROLE_BORER,
))

//Job defines for what happens when you fail to qualify for any job during job selection
#define BEASSISTANT 	1
#define BERANDOMJOB 	2
#define RETURNTOLOBBY 	3