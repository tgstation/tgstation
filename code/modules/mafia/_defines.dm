///The amount of players required to start a Mafia game
#define MAFIA_MIN_PLAYER_COUNT 6
///how many people can play mafia without issues (running out of spawns, procs not expecting more than this amount of people, etc)
#define MAFIA_MAX_PLAYER_COUNT 12

///The time spent during the first day, which is shorter due to not having a voting period.
#define FIRST_DAY_PERIOD_LENGTH (20 SECONDS)
///The length of a Day period
#define DAY_PERIOD_LENGTH (1 MINUTES)
///The length of a Voting period, when people decide who they want to put up for hanging that day.
#define VOTING_PERIOD_LENGTH (30 SECONDS)
///The length of the judgment period, where people vote on whether to lynch the person they voted up.
#define JUDGEMENT_PERIOD_LENGTH (30 SECONDS)
///The length of the lynch period, if the judged person is deemed guilty and is sentenced to death.
#define LYNCH_PERIOD_LENGTH (5 SECONDS)
///The length of the night period where people can do their night abilities and speak with their mafia team.
#define NIGHT_PERIOD_LENGTH (40 SECONDS)
///The length of the roundend report, where people can look over the round and the details.
#define VICTORY_LAP_PERIOD_LENGTH (20 SECONDS)

///The cooldown between being able to send your notes in chat.
#define MAFIA_NOTE_SENDING_COOLDOWN (15 SECONDS)

///How fast the game will speed up when half the players are gone.
#define MAFIA_SPEEDUP_INCREASE 2

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
///has the ability to theoretically kill someone singlehandedly, blocks their team from losing against another teams.
#define ROLE_CAN_KILL (1<<1)
///can only be one in a randomly generated game
#define ROLE_UNIQUE (1<<2)
///role is public to all other players in the game.
#define ROLE_REVEALED (1<<3)
///can not be defended, protected, or any other form of protection. all kills succeed no matter what.
#define ROLE_VULNERABLE (1<<4)
///cannot perform any actions that night, preselected actions fail
#define ROLE_ROLEBLOCKED (1<<5)

///Flag that decides whether the Mafia ability can be used on other people.
#define CAN_USE_ON_OTHERS (1<<0)
///Flag that decides whether the Mafia ability can be used on themselves.
#define CAN_USE_ON_SELF (1<<1)
///Flag that decides whether the Mafia ability can be used on dead players.
#define CAN_USE_ON_DEAD (1<<2)

#define MAFIA_PHASE_SETUP "No Game"
#define MAFIA_PHASE_DAY "Morning Period"
#define MAFIA_PHASE_VOTING "Voting Period"
#define MAFIA_PHASE_JUDGEMENT "Judgment"
#define MAFIA_PHASE_NIGHT "Night Period"
#define MAFIA_PHASE_VICTORY_LAP "Victory Lap"

#define MAFIA_ALIVE 1
#define MAFIA_DEAD 2

#define COMSIG_MAFIA_ON_VISIT "mafia_onvisit"
#define MAFIA_VISIT_INTERRUPTED 1

#define COMSIG_MAFIA_ON_KILL "mafia_onkill"
#define MAFIA_PREVENT_KILL 1

//in order of events + game end

///Sends all signals that must go immediately as night starts.
#define COMSIG_MAFIA_SUNDOWN "sundown"
///Sends all signals that must go first, aka roleblocks.
#define COMSIG_MAFIA_NIGHT_PRE_ACTION_PHASE "night_start"
///Sends the signal that all regular actions must go, such as
#define COMSIG_MAFIA_NIGHT_ACTION_PHASE "night_actions"
/// now killing happens from the roles that do that. the reason this is post action phase is to ensure doctors can protect and lawyers can block
#define COMSIG_MAFIA_NIGHT_KILL_PHASE "night_kill"
/// now clearing refs to prepare for the next day. Do not do any actions here, it's just for ref clearing.
#define COMSIG_MAFIA_NIGHT_END "night_end"

/// signal sent to roles when the game is confirmed ending
#define COMSIG_MAFIA_GAME_END "game_end"

/// list of ghosts who want to play mafia, every time someone enters the list it checks to see if enough are in
GLOBAL_LIST_EMPTY(mafia_signup)
/// list of ghosts who want to play mafia that have since disconnected. They are kept in the lobby, but not counted for starting a game.
GLOBAL_LIST_EMPTY(mafia_bad_signup)
/// the current global mafia game running.
GLOBAL_VAR(mafia_game)
/// list of ghosts in mafia_signup who have voted to start early
GLOBAL_LIST_EMPTY(mafia_early_votes)
