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

GLOBAL_LIST_INIT(mafia_setups,generate_mafia_setups())

/proc/generate_mafia_setups()
	. = list()
	for(var/T in subtypesof(/datum/mafia_setup))
		if(assoc_value_sum(T) > 12)
			var/datum/mafia_setup/S = T
			message_admins("MAFIA: [S.name] has bad player count! The maps cannot support more than 12 players!")
		var/datum/mafia_setup/N = new T
		. += list(N.roles)

/datum/mafia_setup
	var/name = "Make subtypes with the list and a name, more readable than list(list(),list()) etc"
	var/list/roles

// 12 Player

/datum/mafia_setup/twelve_basic
	name = "12 Player Setup Basic"
	roles = list(
		/datum/mafia_role=6,
		/datum/mafia_role/md=1,
		/datum/mafia_role/detective=1,
		/datum/mafia_role/clown=1,
		/datum/mafia_role/mafia=3
	)

/datum/mafia_setup/twelve_md
	name = "12 Player Setup Mostly MD"
	roles = list(
		/datum/mafia_role=5,
		/datum/mafia_role/chaplain=1,
		/datum/mafia_role/md=3,
		/datum/mafia_role/mafia=3
	)

/datum/mafia_setup/twelve_all
	name = "12 Player Setup Madness"
	roles = list(
		/datum/mafia_role/psychologist=1,
		/datum/mafia_role/md=1,
		/datum/mafia_role/detective=1,
		/datum/mafia_role/clown=1,
		/datum/mafia_role/chaplain=1,
		/datum/mafia_role/lawyer=1,
		/datum/mafia_role/traitor=1,
		/datum/mafia_role/nightmare=1,
		/datum/mafia_role/mafia=3,
		/datum/mafia_role/fugitive=1,
		/datum/mafia_role/obsessed=1
	)

/datum/mafia_setup/twelve_joke
	name = "12 Player Setup Funny"
	roles = list(
		/datum/mafia_role=5,
		/datum/mafia_role/detective=2,
		/datum/mafia_role/clown=2,
		/datum/mafia_role/mafia=2,
		/datum/mafia_role/mafia/thoughtfeeder=1
	)

/datum/mafia_setup/twelve_lockdown
	name = "12 Player Setup Lockdown"
	roles = list(
		/datum/mafia_role=5,
		/datum/mafia_role/md=1,
		/datum/mafia_role/detective=1,
		/datum/mafia_role/lawyer=2,
		/datum/mafia_role/mafia=2,
		/datum/mafia_role/mafia/thoughtfeeder=1
	)

/datum/mafia_setup/twelve_rip
	name = "12 Player Setup RIP"
	roles = list(
		/datum/mafia_role=6,
		/datum/mafia_role/md=1,
		/datum/mafia_role/detective=1,
		/datum/mafia_role/mafia=3,
		/datum/mafia_role/traitor=1
	)

/datum/mafia_setup/twelve_double_treason
	name = "12 Player Setup Double Treason"
	roles = list(
		/datum/mafia_role=8,
		/datum/mafia_role/detective=1,
		/datum/mafia_role/traitor=1,
		/datum/mafia_role/obsessed=2
	)

/datum/mafia_setup/twelve_fugitives
	name = "12 Player Fugitives"
	roles = list(
		/datum/mafia_role=6,
		/datum/mafia_role/psychologist=1,
		/datum/mafia_role/mafia=3,
		/datum/mafia_role/fugitive=2
	)

//very op town to balance out three traitors
/datum/mafia_setup/twelve_traitor_mafia
	name = "12 Player Traitor Mafia"
	roles = list(
		/datum/mafia_role=1,
		/datum/mafia_role/chaplain=1,
		/datum/mafia_role/lawyer=1,
		/datum/mafia_role/psychologist=2,
		/datum/mafia_role/md=2,
		/datum/mafia_role/detective=2,
		/datum/mafia_role/traitor=3
	)

//very weak town to balance out one changeling (albeit a thoughtfeeder)
/datum/mafia_setup/twelve_mafia_traitor
	name = "12 Player Mafia Traitor"
	roles = list(
		/datum/mafia_role=6,
		/datum/mafia_role/chaplain=2,
		/datum/mafia_role/psychologist=1,
		/datum/mafia_role/md=2,
		/datum/mafia_role/mafia/thoughtfeeder=1
	)

/datum/mafia_setup/twelve_hopline
	name = "12 Player Hopline"
	roles = list(
		/datum/mafia_role=3,
		/datum/mafia_role/hop=1,
		/datum/mafia_role/chaplain=2,
		/datum/mafia_role/mafia=3
	)

/datum/mafia_setup/twelve_nightmare
	name = "12 Player Nightmare"
	roles = list(
		/datum/mafia_role=10,
		/datum/mafia_role/hop=1,
		/datum/mafia_role/chaplain=2,
		/datum/mafia_role/traitor=1,
		/datum/mafia_role/nightmare=1
	)
