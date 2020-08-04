///how many people can play mafia without issues (running out of spawns, procs not expecting more than this amount of people, etc)
#define MAFIA_MAX_PLAYER_COUNT 12

#define MAFIA_TEAM_TOWN "town"
#define MAFIA_TEAM_MAFIA "mafia"
#define MAFIA_TEAM_SOLO "solo"

//types of town roles for random setup gen
/// assistants it's just assistants filling up the rest of the roles
#define TOWN_OVERFLOW "overflow"
/// roles that learn info about others in the game (chaplain, detective, psych)
#define TOWN_INVEST "invest"
/// roles that keep other roles safe (doctor, and weirdly enough lawyer counts)
#define TOWN_PROTECT "protect"
/// roles that don't fit into anything else (hop)
#define TOWN_MISC "misc"

//other types (mafia team, neutrals)
/// normal vote kill changelings
#define MAFIA_REGULAR "regular"
/// every other changeling role that has extra abilities
#define MAFIA_SPECIAL "special"
/// role that wins solo that nobody likes
#define NEUTRAL_KILL "kill"
/// role that upsets the game aka obsessed, usually worse for town than mafia but they can vote against mafia
#define NEUTRAL_DISRUPT "disrupt"

#define MAFIA_PHASE_SETUP 1
#define MAFIA_PHASE_DAY 2
#define MAFIA_PHASE_VOTING 3
#define MAFIA_PHASE_JUDGEMENT 4
#define MAFIA_PHASE_NIGHT 5
#define MAFIA_PHASE_VICTORY_LAP 6

#define MAFIA_ALIVE 1
#define MAFIA_DEAD 2

#define COMSIG_MAFIA_ON_KILL "mafia_onkill"
#define MAFIA_PREVENT_KILL 1

#define COMSIG_MAFIA_CAN_PERFORM_ACTION "mafia_can_perform_action"
#define MAFIA_PREVENT_ACTION 1

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
/// the current global mafia game running.
GLOBAL_VAR(mafia_game)
