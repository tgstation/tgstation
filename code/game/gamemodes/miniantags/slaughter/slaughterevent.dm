/datum/round_event_control/slaughter
	name = "Spawn Slaughter Demon"
	typepath = /datum/round_event/ghost_role/slaughter
	weight = 1 //Very rare
	max_occurrences = 1
	earliest_start = 36000 //1 hour
	min_players = 20



/datum/round_event/ghost_role/slaughter
	minimum_required = 1
	role_name = "slaughter demon"

/datum/round_event/ghost_role/slaughter/spawn_role()
	var/list/candidates = get_candidates("alien", null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1

	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			switch(L.name)
				if("carpspawn")
					spawn_locs += L.loc

	if(!spawn_locs)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	var /obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter((pick(spawn_locs)))
	var/mob/living/simple_animal/slaughter/S = new /mob/living/simple_animal/slaughter/(holder)
	S.holder = holder
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Slaughter Demon"
	player_mind.special_role = "Slaughter Demon"
	SSticker.mode.traitors |= player_mind
	to_chat(S, S.playstyle_string)
	to_chat(S, "<B>You are currently not currently in the same plane of existence as the station. Blood Crawl near a blood pool to manifest.</B>")
	SEND_SOUND(S, 'sound/magic/demon_dies.ogg')
	message_admins("[key_name_admin(S)] has been made into a slaughter demon by an event.")
	log_game("[key_name(S)] was spawned as a slaughter demon by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
