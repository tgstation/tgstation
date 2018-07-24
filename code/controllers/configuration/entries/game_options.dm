/datum/config_entry/number_list/repeated_mode_adjust

/datum/config_entry/keyed_number_list/probability

/datum/config_entry/keyed_number_list/probability/ValidateListEntry(key_name)
	return key_name in config.modes

/datum/config_entry/keyed_number_list/max_pop

/datum/config_entry/keyed_number_list/max_pop/ValidateListEntry(key_name)
	return key_name in config.modes

/datum/config_entry/keyed_number_list/min_pop

/datum/config_entry/keyed_number_list/min_pop/ValidateListEntry(key_name, key_value)
	return key_name in config.modes

/datum/config_entry/keyed_flag_list/continuous	// which roundtypes continue if all antagonists die

/datum/config_entry/keyed_flag_list/continuous/ValidateListEntry(key_name, key_value)
	return key_name in config.modes

/datum/config_entry/keyed_flag_list/midround_antag	// which roundtypes use the midround antagonist system

/datum/config_entry/keyed_flag_list/midround_antag/ValidateListEntry(key_name, key_value)
	return key_name in config.modes

/datum/config_entry/keyed_string_list/policy

/datum/config_entry/number/damage_multiplier
	config_entry_value = 1
	integer = FALSE

/datum/config_entry/number/minimal_access_threshold	//If the number of players is larger than this threshold, minimal access will be turned on.
	min_val = 0

/datum/config_entry/flag/jobs_have_minimal_access	//determines whether jobs use minimal access or expanded access.

/datum/config_entry/flag/assistants_have_maint_access

/datum/config_entry/flag/security_has_maint_access

/datum/config_entry/flag/everyone_has_maint_access

/datum/config_entry/flag/sec_start_brig	//makes sec start in brig instead of dept sec posts

/datum/config_entry/flag/force_random_names

/datum/config_entry/flag/humans_need_surnames

/datum/config_entry/flag/allow_ai	// allow ai job

/datum/config_entry/flag/disable_human_mood

/datum/config_entry/flag/disable_secborg	// disallow secborg module to be chosen.

/datum/config_entry/flag/disable_peaceborg

/datum/config_entry/number/traitor_scaling_coeff	//how much does the amount of players get divided by to determine traitors
	config_entry_value = 6
	min_val = 1

/datum/config_entry/number/brother_scaling_coeff	//how many players per brother team
	config_entry_value = 25
	min_val = 1

/datum/config_entry/number/changeling_scaling_coeff	//how much does the amount of players get divided by to determine changelings
	config_entry_value = 6
	min_val = 1

/datum/config_entry/number/security_scaling_coeff	//how much does the amount of players get divided by to determine open security officer positions
	config_entry_value = 8
	min_val = 1

/datum/config_entry/number/abductor_scaling_coeff	//how many players per abductor team
	config_entry_value = 15
	min_val = 1

/datum/config_entry/number/traitor_objectives_amount
	config_entry_value = 2
	min_val = 0

/datum/config_entry/number/brother_objectives_amount
	config_entry_value = 2
	min_val = 0

/datum/config_entry/flag/reactionary_explosions	//If we use reactionary explosions, explosions that react to walls and doors

/datum/config_entry/flag/protect_roles_from_antagonist	//If security and such can be traitor/cult/other

/datum/config_entry/flag/protect_assistant_from_antagonist	//If assistants can be traitor/cult/other

/datum/config_entry/flag/enforce_human_authority	//If non-human species are barred from joining as a head of staff

/datum/config_entry/flag/allow_latejoin_antagonists	// If late-joining players can be traitor/changeling

/datum/config_entry/flag/use_antag_rep // see game_options.txt for details

/datum/config_entry/number/antag_rep_maximum
	config_entry_value = 200
	min_val = 0

/datum/config_entry/number/default_antag_tickets
	config_entry_value = 100
	min_val = 0

/datum/config_entry/number/max_tickets_per_roll
	config_entry_value = 100
	min_val = 0

/datum/config_entry/number/midround_antag_time_check	// How late (in minutes you want the midround antag system to stay on, setting this to 0 will disable the system)
	config_entry_value = 60
	min_val = 0

/datum/config_entry/number/midround_antag_life_check	// A ratio of how many people need to be alive in order for the round not to immediately end in midround antagonist
	config_entry_value = 0.7
	integer = FALSE
	min_val = 0
	max_val = 1

/datum/config_entry/number/shuttle_refuel_delay
	config_entry_value = 12000
	min_val = 0

/datum/config_entry/flag/show_game_type_odds	//if set this allows players to see the odds of each roundtype on the get revision screen

/datum/config_entry/keyed_flag_list/roundstart_races	//races you can play as from the get go.

/datum/config_entry/flag/join_with_mutant_humans	//players can pick mutant bodyparts for humans before joining the game

/datum/config_entry/flag/no_summon_guns	//No

/datum/config_entry/flag/no_summon_magic	//Fun

/datum/config_entry/flag/no_summon_events	//Allowed

/datum/config_entry/flag/no_intercept_report	//Whether or not to send a communications intercept report roundstart. This may be overridden by gamemodes.

/datum/config_entry/number/arrivals_shuttle_dock_window	//Time from when a player late joins on the arrivals shuttle to when the shuttle docks on the station
	config_entry_value = 55
	min_val = 30

/datum/config_entry/flag/arrivals_shuttle_require_undocked	//Require the arrivals shuttle to be undocked before latejoiners can join

/datum/config_entry/flag/arrivals_shuttle_require_safe_latejoin	//Require the arrivals shuttle to be operational in order for latejoiners to join

/datum/config_entry/string/alert_green
	config_entry_value = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."

/datum/config_entry/string/alert_blue_upto
	config_entry_value = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."

/datum/config_entry/string/alert_blue_downto
	config_entry_value = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."

/datum/config_entry/string/alert_red_upto
	config_entry_value = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."

/datum/config_entry/string/alert_red_downto
	config_entry_value = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."

/datum/config_entry/string/alert_delta
	config_entry_value = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

/datum/config_entry/flag/revival_pod_plants

/datum/config_entry/flag/revival_cloning

/datum/config_entry/number/revival_brain_life
	config_entry_value = -1
	min_val = -1

/datum/config_entry/flag/ooc_during_round

/datum/config_entry/flag/emojis

/datum/config_entry/number/run_delay	//Used for modifying movement speed for mobs.
	var/static/value_cache = 0

/datum/config_entry/number/run_delay/ValidateAndSet()
	. = ..()
	if(.)
		value_cache = config_entry_value

/datum/config_entry/number/walk_delay
	var/static/value_cache = 0

/datum/config_entry/number/walk_delay/ValidateAndSet()
	. = ..()
	if(.)
		value_cache = config_entry_value

/datum/config_entry/number/human_delay	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
/datum/config_entry/number/robot_delay
/datum/config_entry/number/monkey_delay
/datum/config_entry/number/alien_delay
/datum/config_entry/number/slime_delay
/datum/config_entry/number/animal_delay

/datum/config_entry/flag/roundstart_away	//Will random away mission be loaded.

/datum/config_entry/number/gateway_delay	//How long the gateway takes before it activates. Default is half an hour. Only matters if roundstart_away is enabled.
	config_entry_value = 18000
	min_val = 0

/datum/config_entry/flag/ghost_interaction

/datum/config_entry/flag/silent_ai
/datum/config_entry/flag/silent_borg

/datum/config_entry/flag/sandbox_autoclose	// close the sandbox panel after spawning an item, potentially reducing griff

/datum/config_entry/number/default_laws //Controls what laws the AI spawns with.
	config_entry_value = 0
	min_val = 0
	max_val = 3

/datum/config_entry/number/silicon_max_law_amount
	config_entry_value = 12
	min_val = 0

/datum/config_entry/keyed_flag_list/random_laws

/datum/config_entry/keyed_number_list/law_weight
	splitter = ","

/datum/config_entry/number/overflow_cap
	config_entry_value = -1
	min_val = -1

/datum/config_entry/string/overflow_job
	config_entry_value = "Assistant"

/datum/config_entry/flag/starlight
/datum/config_entry/flag/grey_assistants

/datum/config_entry/number/lavaland_budget
	config_entry_value = 60
	min_val = 0

/datum/config_entry/number/space_budget
	config_entry_value = 16
	min_val = 0

/datum/config_entry/flag/allow_random_events	// Enables random events mid-round when set

/datum/config_entry/number/events_min_time_mul	// Multipliers for random events minimal starting time and minimal players amounts
	config_entry_value = 1
	min_val = 0
	integer = FALSE

/datum/config_entry/number/events_min_players_mul
	config_entry_value = 1
	min_val = 0
	integer = FALSE

/datum/config_entry/number/mice_roundstart
	config_entry_value = 10
	min_val = 0

/datum/config_entry/number/bombcap
	config_entry_value = 14
	min_val = 4

/datum/config_entry/number/bombcap/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.MAX_EX_DEVESTATION_RANGE = round(config_entry_value / 4)
		GLOB.MAX_EX_HEAVY_RANGE = round(config_entry_value / 2)
		GLOB.MAX_EX_LIGHT_RANGE = config_entry_value
		GLOB.MAX_EX_FLASH_RANGE = config_entry_value
		GLOB.MAX_EX_FLAME_RANGE = config_entry_value

/datum/config_entry/number/emergency_shuttle_autocall_threshold
	min_val = 0
	max_val = 1
	integer = FALSE

/datum/config_entry/flag/ic_printing

/datum/config_entry/flag/roundstart_traits

/datum/config_entry/flag/enable_night_shifts

/datum/config_entry/flag/randomize_shift_time

/datum/config_entry/flag/shift_time_realtime

/datum/config_entry/keyed_number_list/antag_rep

/datum/config_entry/number/monkeycap
	config_entry_value = 64
	min_val = 0
