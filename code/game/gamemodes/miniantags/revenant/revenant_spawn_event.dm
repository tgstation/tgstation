#define REVENANT_SPAWN_THRESHOLD 10

/datum/round_event_control/revenant
	name = "Spawn Revenant" // Did you mean 'griefghost'?
	typepath = /datum/round_event/revenant
	weight = 7
	max_occurrences = 1
	earliest_start = 6000 //Meant to mix things up early-game.
	min_players = 5


/datum/round_event/ghost_role/revenant
	var/force_spawn

/datum/round_event/ghost_role/revenant/New(my_force_spawn = FALSE)
	..()
	force_spawn = my_force_spawn

/datum/round_event/ghost_role/revenant/spawn_role()
	if(!force_spawn)
		var/deadMobs = 0
		for(var/mob/M in dead_mob_list)
			deadMobs++
		if(deadMobs < REVENANT_SPAWN_THRESHOLD)
			message_admins("Event attempted to spawn a revenant, but there were only [deadMobs]/[REVENANT_SPAWN_THRESHOLD] dead mobs.")
			return WAITING_FOR_SOMETHING

	var/list/mob/dead/observer/candidates = get_candidates("revenant", null, ROLE_REVENANT)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/observer/selected = popleft(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
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
	if(!spawn_locs) //If we can't find THAT, then just give up and cry
		return MAP_ERROR

	var/mob/living/simple_animal/revenant/revvie = new /mob/living/simple_animal/revenant/(pick(spawn_locs))
	player_mind.transfer_to(revvie)
	player_mind.assigned_role = "revenant"
	player_mind.special_role = "Revenant"
	ticker.mode.traitors |= player_mind
	message_admins("[player_mind.key] has been made into a revenant by an event.")
	log_game("[player_mind.key] was spawned as a revenant by an event.")
	return SUCCESSFUL_SPAWN
