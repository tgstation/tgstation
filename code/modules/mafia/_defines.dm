///how many people can play mafia without issues (running out of spawns, procs not expecting more than this amount of people, etc)
#define MAFIA_MAX_PLAYER_COUNT 12

#define MAFIA_TEAM_TOWN "town"
#define MAFIA_TEAM_MAFIA "mafia"
#define MAFIA_TEAM_SOLO "solo"

//types of town roles for random setup gen
/// Add this if you don't want a role to be a choice in the selection
#define TOWN_OVERFLOW "overflow"
/// roles that learn info about others in the game (chaplain, detective, psych)
#define TOWN_INVEST "invest"
/// roles that keep other roles safe (doctor, sec officer, and weirdly enough lawyer counts)
#define TOWN_PROTECT "protect"
/// roles that are only there to kill bad guys.
#define TOWN_KILLING "killing"
/// roles that don't fit into anything else (hop)
#define TOWN_SUPPORT "support"

//other types (mafia team, neutrals)
/// normal vote kill changelings
#define MAFIA_REGULAR "regular"
/// every other changeling role that has extra abilities
#define MAFIA_SPECIAL "special"
/// role that wins solo that nobody likes
#define NEUTRAL_KILL "kill"
/// role that upsets the game aka obsessed, usually worse for town than mafia but they can vote against mafia
#define NEUTRAL_DISRUPT "disrupt"

//role flags (special status of roles like detection immune)
///to all forms of detection, shows themselves as an assistant.
#define ROLE_UNDETECTABLE (1<<0)
///has the ability to kill at night and thus, blocks the game from ending with other teams alive.
#define ROLE_CAN_KILL (1<<1)
///can only be one in a randomly generated game
#define ROLE_UNIQUE (1<<2)
///role is public to all other players in the game.
#define ROLE_REVEALED (1<<3)
///can not be defended, protected, or any other form of protection. all kills succeed no matter what.
#define ROLE_VULNERABLE (1<<4)
///cannot perform any actions that night, preselected actions fail
#define ROLE_ROLEBLOCKED (1<<5)

#define MAFIA_PHASE_SETUP 1
#define MAFIA_PHASE_DAY 2
#define MAFIA_PHASE_VOTING 3
#define MAFIA_PHASE_JUDGEMENT 4
#define MAFIA_PHASE_NIGHT 5
#define MAFIA_PHASE_VICTORY_LAP 6

#define MAFIA_ALIVE 1
#define MAFIA_DEAD 2

#define COMSIG_MAFIA_ON_VISIT "mafia_onvisit"
#define MAFIA_VISIT_INTERRUPTED 1

#define COMSIG_MAFIA_ON_KILL "mafia_onkill"
#define MAFIA_PREVENT_KILL 1

//in order of events + game end

/// when the shutters fall, before the 45 second wait and night event resolution
#define COMSIG_MAFIA_SUNDOWN "sundown"
/// after the 45 second wait, for actions that must go first
#define COMSIG_MAFIA_NIGHT_START "night_start"
/// most night actions now resolve
#define COMSIG_MAFIA_NIGHT_ACTION_PHASE "night_actions"
/// now killing happens from the roles that do that. the reason this is post action phase is to ensure doctors can protect and lawyers can block
#define COMSIG_MAFIA_NIGHT_KILL_PHASE "night_kill"
/// now undoing states like protection, actions that must happen last, etc. right before shutters raise and the day begins
#define COMSIG_MAFIA_NIGHT_END "night_end"

/// signal sent to roles when the game is confirmed ending
#define COMSIG_MAFIA_GAME_END "game_end"

/// list of ghosts who want to play mafia, every time someone enters the list it checks to see if enough are in
GLOBAL_LIST_EMPTY(mafia_signup)
/// list of ghosts who want to play mafia that have since disconnected. They are kept in the lobby, but not counted for starting a game.
GLOBAL_LIST_EMPTY(mafia_bad_signup)
/// the current global mafia game running.
GLOBAL_VAR(mafia_game)
