#define CURRENT_RESIDENT_FILE "game_options.txt"

CONFIG_DEF(number_list/repeated_mode_adjust)

CONFIG_DEF(keyed_number_list/probability)

/datum/config_entry/keyed_number_list/probability/ValidateKeyName(key_name)
	return key_name in config.modes

CONFIG_DEF(keyed_number_list/max_pop)

/datum/config_entry/keyed_number_list/max_pop/ValidateKeyName(key_name)
	return key_name in config.modes

CONFIG_DEF(keyed_number_list/min_pop)

/datum/config_entry/keyed_number_list/min_pop/ValidateKeyName(key_name)
	return key_name in config.modes

CONFIG_DEF(keyed_flag_list/continuous)	// which roundtypes continue if all antagonists die

/datum/config_entry/keyed_flag_list/continuous/ValidateKeyName(key_name)
	return key_name in config.modes

CONFIG_DEF(keyed_flag_list/midround_antag)	// which roundtypes use the midround antagonist system

/datum/config_entry/keyed_flag_list/midround_antag/ValidateKeyName(key_name)
	return key_name in config.modes

CONFIG_DEF(keyed_string_list/policy)

CONFIG_DEF(number/damage_multiplier)
	value = 1
	integer = FALSE

CONFIG_DEF(number/minimal_access_threshold)	//If the number of players is larger than this threshold, minimal access will be turned on.
	min_val = 0

CONFIG_DEF(flag/jobs_have_minimal_access)	//determines whether jobs use minimal access or expanded access.

CONFIG_DEF(flag/assistants_have_maint_access)

CONFIG_DEF(flag/security_has_maint_access)

CONFIG_DEF(flag/everyone_has_maint_access)

CONFIG_DEF(flag/sec_start_brig)	//makes sec start in brig instead of dept sec posts

CONFIG_DEF(flag/force_random_names)

CONFIG_DEF(flag/humans_need_surnames)

CONFIG_DEF(flag/allow_ai)	// allow ai job

CONFIG_DEF(flag/disable_secborg)	// disallow secborg module to be chosen.

CONFIG_DEF(flag/disable_peaceborg)

CONFIG_DEF(number/traitor_scaling_coeff)	//how much does the amount of players get divided by to determine traitors
	value = 6
	min_val = 1

CONFIG_DEF(number/brother_scaling_coeff)	//how many players per brother team
	value = 25
	min_val = 1

CONFIG_DEF(number/changeling_scaling_coeff)	//how much does the amount of players get divided by to determine changelings
	value = 6
	min_val = 1

CONFIG_DEF(number/security_scaling_coeff)	//how much does the amount of players get divided by to determine open security officer positions
	value = 8
	min_val = 1

CONFIG_DEF(number/abductor_scaling_coeff)	//how many players per abductor team
	value = 15
	min_val = 1

CONFIG_DEF(number/traitor_objectives_amount)
	value = 2
	min_val = 0

CONFIG_DEF(number/brother_objectives_amount)
	value = 2
	min_val = 0

CONFIG_DEF(flag/reactionary_explosions)	//If we use reactionary explosions, explosions that react to walls and doors

CONFIG_DEF(flag/protect_roles_from_antagonist)	//If security and such can be traitor/cult/other

CONFIG_DEF(flag/protect_assistant_from_antagonist)	//If assistants can be traitor/cult/other

CONFIG_DEF(flag/enforce_human_authority)	//If non-human species are barred from joining as a head of staff

CONFIG_DEF(flag/allow_latejoin_antagonists)	// If late-joining players can be traitor/changeling

CONFIG_DEF(number/midround_antag_time_check)	// How late (in minutes) you want the midround antag system to stay on, setting this to 0 will disable the system
	value = 60
	min_val = 0

CONFIG_DEF(number/midround_antag_life_check)	// A ratio of how many people need to be alive in order for the round not to immediately end in midround antagonist
	value = 0.7
	integer = FALSE
	min_val = 0
	max_val = 1

CONFIG_DEF(number/shuttle_refuel_delay)
	value = 12000
	min_val = 0

CONFIG_DEF(flag/show_game_type_odds)	//if set this allows players to see the odds of each roundtype on the get revision screen

CONFIG_DEF(keyed_flag_list/roundstart_races)	//races you can play as from the get go.

CONFIG_DEF(flag/join_with_mutant_humans)	//players can pick mutant bodyparts for humans before joining the game

CONFIG_DEF(flag/no_summon_guns)	//No

CONFIG_DEF(flag/no_summon_magic)	//Fun

CONFIG_DEF(flag/no_summon_events)	//Allowed

CONFIG_DEF(flag/no_intercept_report)	//Whether or not to send a communications intercept report roundstart. This may be overriden by gamemodes.

CONFIG_DEF(number/arrivals_shuttle_dock_window)	//Time from when a player late joins on the arrivals shuttle to when the shuttle docks on the station
	value = 55
	min_val = 30

CONFIG_DEF(flag/arrivals_shuttle_require_undocked)	//Require the arrivals shuttle to be undocked before latejoiners can join

CONFIG_DEF(flag/arrivals_shuttle_require_safe_latejoin)	//Require the arrivals shuttle to be operational in order for latejoiners to join

CONFIG_DEF(string/alert_green)
	value = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."

CONFIG_DEF(string/alert_blue_upto)
	value = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."

CONFIG_DEF(string/alert_blue_downto)
	value = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."

CONFIG_DEF(string/alert_red_upto)
	value = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."

CONFIG_DEF(string/alert_red_downto)
	value = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."

CONFIG_DEF(string/alert_delta)
	value = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

CONFIG_DEF(flag/revival_pod_plants)

CONFIG_DEF(flag/revival_cloning)

CONFIG_DEF(number/revival_brain_life)
	value = -1
	min_val = -1

CONFIG_DEF(flag/rename_cyborg)

CONFIG_DEF(flag/ooc_during_round)

CONFIG_DEF(flag/emojis)

CONFIG_DEF(number/run_delay)	//Used for modifying movement speed for mobs.
	var/static/value_cache = 0

CONFIG_TWEAK(number/run_delay/ValidateAndSet())
	. = ..()
	if(.)
		value_cache = value

CONFIG_DEF(number/walk_delay)
	var/static/value_cache = 0

CONFIG_TWEAK(number/walk_delay/ValidateAndSet())
	. = ..()
	if(.)
		value_cache = value

CONFIG_DEF(number/human_delay)	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
CONFIG_DEF(number/robot_delay)
CONFIG_DEF(number/monkey_delay)
CONFIG_DEF(number/alien_delay)
CONFIG_DEF(number/slime_delay)
CONFIG_DEF(number/animal_delay)

CONFIG_DEF(number/gateway_delay)	//How long the gateway takes before it activates. Default is half an hour.
	value = 18000
	min_val = 0

CONFIG_DEF(flag/ghost_interaction)

CONFIG_DEF(flag/silent_ai)
CONFIG_DEF(flag/silent_borg)

CONFIG_DEF(flag/sandbox_autoclose)	// close the sandbox panel after spawning an item, potentially reducing griff

CONFIG_DEF(number/default_laws) //Controls what laws the AI spawns with.
	value = 0
	min_val = 0
	max_val = 3

CONFIG_DEF(number/silicon_max_law_amount)
	value = 12
	min_val = 0

CONFIG_DEF(keyed_flag_list/random_laws)

CONFIG_DEF(keyed_number_list/law_weight)
	splitter = ","

CONFIG_DEF(number/assistant_cap)
	value = -1
	min_val = -1

CONFIG_DEF(flag/starlight)
CONFIG_DEF(flag/grey_assistants)

CONFIG_DEF(number/lavaland_budget)
	value = 60
	min_val = 0

CONFIG_DEF(number/space_budget)
	value = 16
	min_val = 0

CONFIG_DEF(flag/allow_random_events)	// Enables random events mid-round when set

CONFIG_DEF(number/events_min_time_mul)	// Multipliers for random events minimal starting time and minimal players amounts
	value = 1
	min_val = 0
	integer = FALSE

CONFIG_DEF(number/events_min_players_mul)
	value = 1
	min_val = 0
	integer = FALSE

CONFIG_DEF(number/mice_roundstart)
	value = 10
	min_val = 0

CONFIG_DEF(number/bombcap)
	value = 14
	min_val = 4

/datum/config_entry/number/bombcap/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.MAX_EX_DEVESTATION_RANGE = round(value / 4)
		GLOB.MAX_EX_HEAVY_RANGE = round(value / 2)
		GLOB.MAX_EX_LIGHT_RANGE = value
		GLOB.MAX_EX_FLASH_RANGE = value
		GLOB.MAX_EX_FLAME_RANGE = value

CONFIG_DEF(number/emergency_shuttle_autocall_threshold)
	min_val = 0
	max_val = 1
	integer = FALSE

CONFIG_DEF(flag/ic_printing)