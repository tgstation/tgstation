#define MAFIA_TEAM_TOWN "town"
#define MAFIA_TEAM_MAFIA "mafia"
#define MAFIA_TEAM_SOLO "solo"

//types of town roles for random setup gen
#define TOWN_OVERFLOW "overflow" //assistants it's just assistants filling up the rest of the roles
#define TOWN_INVEST "invest" //roles that learn info about others in the game (chaplain, detective, psych)
#define TOWN_PROTECT "protect" //roles that keep other roles safe (doctor, and weirdly enough lawyer counts)
#define TOWN_MISC "misc" //roles that don't fit into anything else (hop)
//other types (mafia team, neutrals)
#define MAFIA_REGULAR "regular" //normal vote kill changelings
#define MAFIA_SPECIAL "special" //every other changeling role that has extra abilities
#define NEUTRAL_KILL "kill" //role that wins solo that nobody likes
#define NEUTRAL_DISRUPT "disrupt" //role that upsets the game aka obsessed, usually worse for town than mafia but they can vote against mafia

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

#define COMSIG_MAFIA_SUNDOWN "sundown" //the rest of these phases are at the end of the night when shutters raise, in a different order of resolution
#define COMSIG_MAFIA_NIGHT_START "night_start"
#define COMSIG_MAFIA_NIGHT_ACTION_PHASE "night_actions"
#define COMSIG_MAFIA_NIGHT_KILL_PHASE "night_kill"
#define COMSIG_MAFIA_NIGHT_END "night_end"

#define COMSIG_MAFIA_GAME_END "game_end"

//list of ghosts who want to play mafia, every time someone enters the list it checks to see if enough are in
GLOBAL_LIST_EMPTY(mafia_signup)
//the current global mafia game running.
GLOBAL_VAR(mafia_game)
