/datum/round_event_control/nightmare
	name = "Spawn Nightmare"
	typepath = /datum/round_event/ghost_role/nightmare
	max_occurrences = 1
	min_players = 20

/datum/round_event/ghost_role/nightmare
	minimum_required = 1
	role_name = "nightmare"

/datum/round_event/ghost_role/nightmare/spawn_role()
	var/list/candidates = get_candidates("alien", null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE

	var/list/spawn_locs = list()
	for(var/X in GLOB.xeno_spawn)
		var/turf/T = X
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			spawn_locs += T

	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var/mob/living/carbon/human/S = new ((pick(spawn_locs)))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Nightmare"
	player_mind.special_role = "Nightmare"
	SSticker.mode.traitors += player_mind
	S.set_species(/datum/species/shadow/nightmare)
	playsound(S, 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
	message_admins("[key_name_admin(S)] has been made into a Nightmare by an event.")
	log_game("[key_name(S)] was spawned as a Nightmare by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
