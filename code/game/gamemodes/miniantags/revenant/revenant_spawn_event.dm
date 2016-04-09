#define REVENANT_SPAWN_THRESHOLD 10

/datum/round_event_control/revenant
	name = "Spawn Revenant"
	typepath = /datum/round_event/revenant
	weight = 7
	max_occurrences = 1
	earliest_start = 6000 //Meant to mix things up early-game.
	min_players = 5


/datum/round_event/revenant
	var/key_of_revenant


/datum/round_event/revenant/proc/get_revenant(end_if_fail = 0)
	var/deadMobs = 0
	for(var/mob/M in dead_mob_list)
		deadMobs++
	if(deadMobs < REVENANT_SPAWN_THRESHOLD)
		message_admins("Random event attempted to spawn a revenant, but there were only [deadMobs]/[REVENANT_SPAWN_THRESHOLD] dead mobs.")
		return
	key_of_revenant = null
	if(!key_of_revenant)
		var/list/candidates = get_candidates(ROLE_REVENANT)
		if(!candidates.len)
			if(end_if_fail)
				return 0
			return find_revenant()
		var/client/C = pick(candidates)
		key_of_revenant = C.key
	if(!key_of_revenant)
		if(end_if_fail)
			return 0
		return find_revenant()
	var/datum/mind/player_mind = new /datum/mind(key_of_revenant)
	player_mind.active = 1
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(isturf(L.loc))
			switch(L.name)
				if("revenantspawn")
					spawn_locs += L.loc
	if(!spawn_locs) //If we can't find any revenant spawns, try the carp spawns
		for(var/obj/effect/landmark/L in landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("carpspawn")
						spawn_locs += L.loc
	if(!spawn_locs) //If we can't find either, just spawn the revenant at the player's location
		spawn_locs += get_turf(player_mind.current)
	if(!spawn_locs) //If we can't find THAT, then just retry
		return find_revenant()
	var/mob/living/simple_animal/revenant/revvie = new /mob/living/simple_animal/revenant/(pick(spawn_locs))
	player_mind.transfer_to(revvie)
	player_mind.assigned_role = "revenant"
	player_mind.special_role = "Revenant"
	ticker.mode.traitors |= player_mind
	message_admins("[key_of_revenant] has been made into a revenant by an event.")
	log_game("[key_of_revenant] was spawned as a revenant by an event.")
	return 1


/datum/round_event/revenant/start()
	get_revenant()


/datum/round_event/revenant/proc/find_revenant()
	message_admins("An event failed to spawn a revenant. Retrying momentarily...")
	spawn(50)
		if(get_revenant(1))
			message_admins("[key_of_revenant] has been spawned as a revenant.")
			log_game("[key_of_revenant] was spawned as a revenant by an event.")
			return 0
		message_admins("No candidates were available for becoming a revenant.")
	return kill()
