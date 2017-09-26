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

CONFIG_DEF(number/security_scaling_coeff)	//how many players per abductor team
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

CONFIG_DEF(flag/join_with_mutant_race)	//players can choose their mutant race before joining the game

CONFIG_DEF(keyed_flag_list/roundstart_races)	//races you can play as from the get go. If left undefined the game's roundstart var for species is used
	var/first_edit = TRUE

/datum/config_entry/keyed_flag_list/roundstart_races/New()
	for(var/I in subtypesof(/datum/species))
		var/datum/species/S = I
		if(initial(S.roundstart))
			value[initial(S.id)] = TRUE
	..()

/datum/config_entry/keyed_flag_list/roundstart_races/ValidateAndSet(str_val)
	var/list/old_val
	if(first_edit)
		old_val = value.Copy()
	. = ..()
	if(first_edit)
		if(!.)
			value = old_val
		else
			first_edit = FALSE

CONFIG_DEF(flag/join_with_mutant_humans)	//players can pick mutant bodyparts for humans before joining the game

CONFIG_DEF(flag/no_summon_guns)	//No

CONFIG_DEF(flag/no_summon_magic)	//Fun

CONFIG_DEF(flag/no_summon_events)	//Allowed

CONFIG_DEF(flag/no_intercept_report)	//Whether or not to send a communications intercept report roundstart. This may be overriden by gamemodes.
	var/alert_desc_green = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_desc_blue_upto = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	var/alert_desc_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/alert_desc_red_upto = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/alert_desc_red_downto = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/alert_desc_delta = "Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

	var/revival_pod_plants = FALSE
	var/revival_cloning = FALSE
	var/revival_brain_life = -1

	var/rename_cyborg = 0
	var/ooc_during_round = 0
	var/emojis = 0
	var/no_credits_round_end = FALSE

	//Used for modifying movement speed for mobs.
	//Unversal modifiers
	var/run_speed = 0
	var/walk_speed = 0

	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
	var/human_delay = 0
	var/robot_delay = 0
	var/monkey_delay = 0
	var/alien_delay = 0
	var/slime_delay = 0
	var/animal_delay = 0

	var/gateway_delay = 18000 //How long the gateway takes before it activates. Default is half an hour.
	var/ghost_interaction = 0

	var/silent_ai = 0
	var/silent_borg = 0

	var/sandbox_autoclose = FALSE // close the sandbox panel after spawning an item, potentially reducing griff

	var/default_laws = 0 //Controls what laws the AI spawns with.
	var/silicon_max_law_amount = 12
	var/list/lawids = list()

	var/list/law_weights = list()

	var/assistant_cap = -1

	var/starlight = 0
	var/grey_assistants = 0

	var/lavaland_budget = 60
	var/space_budget = 16

	// Enables random events mid-round when set to 1
	var/allow_random_events = 0

	// Multipliers for random events minimal starting time and minimal players amounts
	var/events_min_time_mul = 1
	var/events_min_players_mul = 1

	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

	var/cross_name = "Other server"
	var/cross_address = "byond://"
	var/cross_allowed = FALSE

	var/arrivals_shuttle_dock_window = 55	//Time from when a player late joins on the arrivals shuttle to when the shuttle docks on the station
	var/arrivals_shuttle_require_undocked = FALSE	//Require the arrivals shuttle to be undocked before latejoiners can join
	var/arrivals_shuttle_require_safe_latejoin = FALSE	//Require the arrivals shuttle to be operational in order for latejoiners to join

	var/mice_roundstart = 10 // how many wire chewing rodents spawn at roundstart.

	var/list/policies = list()
				if("revival_pod_plants")
					revival_pod_plants		= TRUE
				if("revival_cloning")
					revival_cloning			= TRUE
				if("revival_brain_life")
					revival_brain_life		= text2num(value)
				if("rename_cyborg")
					rename_cyborg			= 1
				if("ooc_during_round")
					ooc_during_round			= 1
				if("emojis")
					emojis					= 1
				if("no_credits_round_end")
					no_credits_round_end	= TRUE
				if("run_delay")
					run_speed				= text2num(value)
				if("walk_delay")
					walk_speed				= text2num(value)
				if("human_delay")
					human_delay				= text2num(value)
				if("robot_delay")
					robot_delay				= text2num(value)
				if("monkey_delay")
					monkey_delay				= text2num(value)
				if("alien_delay")
					alien_delay				= text2num(value)
				if("slime_delay")
					slime_delay				= text2num(value)
				if("animal_delay")
					animal_delay				= text2num(value)
				if("alert_red_upto")
					alert_desc_red_upto		= value
				if("alert_red_downto")
					alert_desc_red_downto	= value
				if("alert_blue_downto")
					alert_desc_blue_downto	= value
				if("alert_blue_upto")
					alert_desc_blue_upto		= value
				if("alert_green")
					alert_desc_green			= value
				if("alert_delta")
					alert_desc_delta			= value
				if("gateway_delay")
					gateway_delay			= text2num(value)
				if("ghost_interaction")
					ghost_interaction		= 1
				if("traitor_objectives_amount")
					traitor_objectives_amount = text2num(value)
				if("brother_objectives_amount")
					brother_objectives_amount = text2num(value)
				if("allow_random_events")
					allow_random_events		= 1

				if("events_min_time_mul")
					events_min_time_mul		= text2num(value)
				if("events_min_players_mul")
					events_min_players_mul	= text2num(value)

				if("silent_ai")
					silent_ai 				= 1
				if("silent_borg")
					silent_borg				= 1
				if("sandbox_autoclose")
					sandbox_autoclose		= 1
				if("default_laws")
					default_laws				= text2num(value)
				if("random_laws")
					var/law_id = lowertext(value)
					lawids += law_id
				if("law_weight")
					// Value is in the form "LAWID,NUMBER"
					var/list/L = splittext(value, ",")
					if(L.len != 2)
						WRITE_FILE(GLOB.config_error_log, "Invalid LAW_WEIGHT: " + t)
						continue
					var/lawid = L[1]
					var/weight = text2num(L[2])
					law_weights[lawid] = weight

				if("silicon_max_law_amount")
					silicon_max_law_amount	= text2num(value)
				if("assistant_cap")
					assistant_cap			= text2num(value)
				if("starlight")
					starlight			= 1
				if("grey_assistants")
					grey_assistants			= 1
				if("lavaland_budget")
					lavaland_budget			= text2num(value)
				if("space_budget")
					space_budget			= text2num(value)
				if("bombcap")
					var/BombCap = text2num(value)
					if (!BombCap)
						continue
					if (BombCap < 4)
						BombCap = 4

					GLOB.MAX_EX_DEVESTATION_RANGE = round(BombCap/4)
					GLOB.MAX_EX_HEAVY_RANGE = round(BombCap/2)
					GLOB.MAX_EX_LIGHT_RANGE = BombCap
					GLOB.MAX_EX_FLASH_RANGE = BombCap
					GLOB.MAX_EX_FLAME_RANGE = BombCap
				if("arrivals_shuttle_dock_window")
					arrivals_shuttle_dock_window = max(PARALLAX_LOOP_TIME, text2num(value))
				if("arrivals_shuttle_require_undocked")
					arrivals_shuttle_require_undocked = TRUE
				if("arrivals_shuttle_require_safe_latejoin")
					arrivals_shuttle_require_safe_latejoin = TRUE
				if("mice_roundstart")
					mice_roundstart = text2num(value)