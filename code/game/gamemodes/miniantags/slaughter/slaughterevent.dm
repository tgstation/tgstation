
/datum/round_event_control/slaughter
	name = "Spawn Slaughter Demon"
	typepath = /datum/round_event/slaughter
	weight = 1 //Very rare
	max_occurrences = 1
	earliest_start = 36000 //1 hour



/datum/round_event/slaughter
	var/key_of_slaughter


/datum/round_event/slaughter/proc/get_slaughter(end_if_fail = 0)
	key_of_slaughter = null
	if(!key_of_slaughter)
		var/list/candidates = get_candidates(ROLE_ALIEN)
		if(!candidates.len)
			if(end_if_fail)
				return 0
			return find_slaughter()
		var/client/C = pick(candidates)
		key_of_slaughter = C.key
	if(!key_of_slaughter)
		if(end_if_fail)
			return 0
		return find_slaughter()
	var/datum/mind/player_mind = new /datum/mind(key_of_slaughter)
	player_mind.active = 1
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(isturf(L.loc))
			switch(L.name)
				if("carpspawn")
					spawn_locs += L.loc
	if(!spawn_locs)
		return find_slaughter()
	var /obj/effect/dummy/slaughter/holder = PoolOrNew(/obj/effect/dummy/slaughter,(pick(spawn_locs)))
	var/mob/living/simple_animal/slaughter/S = new /mob/living/simple_animal/slaughter/(holder)
	S.holder = holder
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Slaughter Demon"
	player_mind.special_role = "Slaughter Demon"
	ticker.mode.traitors |= player_mind
	S << S.playstyle_string
	S << "<B>You are currently not currently in the same plane of existence as the station. Blood Crawl near a blood pool to manifest.</B>"
	S << 'sound/magic/demon_dies.ogg'
	message_admins("[key_of_slaughter] has been made into a slaughter demon by an event.")
	log_game("[key_of_slaughter] was spawned as a slaughter demon by an event.")
	return 1



/datum/round_event/slaughter/start()
	get_slaughter()



/datum/round_event/slaughter/proc/find_slaughter()
	message_admins("Attempted to spawn a slaughter demon but there was no players available. Will try again momentarily.")
	spawn(50)
		if(get_slaughter(1))
			message_admins("Situation has been resolved, [key_of_slaughter] has been spawned as a slaughter demon.")
			log_game("[key_of_slaughter] was spawned as a slaughter demon by an event.")
			return 0
		message_admins("Unfortunately, no candidates were available for becoming a slaughter demon. Shutting down.")
	return kill()
