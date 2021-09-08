/datum/round_event_control/nightmare
	name = "Spawn Nightmare"
	typepath = /datum/round_event/ghost_role/nightmare
	max_occurrences = 1
	min_players = 20
	dynamic_should_hijack = TRUE

/datum/round_event/ghost_role/nightmare
	minimum_required = 1
	role_name = "nightmare"
	fakeable = FALSE

/datum/round_event/ghost_role/nightmare/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/list/spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T

	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/mob/living/carbon/human/nightmare = new ((pick(spawn_locs)))
	nightmare.make_special_mind(selected.key, /datum/job/nightmare, ROLE_NIGHTMARE, /datum/antagonist/nightmare)
	nightmare.set_species(/datum/species/shadow/nightmare)
	playsound(nightmare, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	message_admins("[ADMIN_LOOKUPFLW(nightmare)] has been made into a Nightmare by an event.")
	log_game("[key_name(nightmare)] was spawned as a Nightmare by an event.")
	spawned_mobs += nightmare
	return SUCCESSFUL_SPAWN
