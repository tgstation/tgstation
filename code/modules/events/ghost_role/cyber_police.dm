/datum/round_event_control/cyber_police
	name = "Spawn Cyber Police"
	category = EVENT_CATEGORY_INVASION
	description = "Compiles a binary marshal to ensure data integrity in the virtual domain."
	dynamic_should_hijack = FALSE
	max_occurrences = 5
	min_players = 1
	typepath = /datum/round_event/ghost_role/cyber_police
	weight = 10

/datum/round_event_control/cyber_police/can_spawn_event(players_amt, allow_magic = FALSE)
	. = ..()
	if(!.)
		return .

	if(length(SSbitrunning.active_servers) && length(SSbitrunning.get_mutation_candidates()))
		return TRUE

/datum/round_event/ghost_role/cyber_police
	minimum_required = 1
	role_name = "Cyber Police"
	fakeable = FALSE

/datum/round_event/ghost_role/cyber_police/spawn_role()
	var/mob/living/new_agent = SSbitrunning.initialize_glitch(ROLE_CYBER_POLICE)

	if(isnull(new_agent))
		return MAP_ERROR

	spawned_mobs += new_agent

	return SUCCESSFUL_SPAWN
