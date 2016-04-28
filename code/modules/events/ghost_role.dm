/datum/round_event/ghost_role
	// We expect 0 or more /clients in this list
	var/list/priority_candidates = list()
	var/minimum_required = 1
	var/role_name = "cancer rat" // Q U A L I T Y  M E M E S

/datum/round_event/ghost_role/proc/try_spawning()
	// The event does not run until the spawning has been successful
	// or attempted twice, to prevent the spawn(300) from being gc'd
	processing = FALSE
	var/success = spawn_role()
	if(success)
		processing = TRUE
	else
		message_admins("Insufficient players for [role_name]. Retrying in 30s.")
		spawn(300)
			success = spawn_role()
			if(!success)
				message_admins("Insufficient players for [role_name]. Giving up.")
			processing = TRUE

/datum/round_event/ghost_role/proc/spawn_role()
	// Return true if role was successfully spawned, false if insufficent
	// players could be found, and just runtime if anything else happens
	return TRUE

/datum/round_event/ghost_role/proc/get_candidates(jobban, gametypecheck, be_special)
	// Returns a list of candidates in priority order, with candidates from
	// `priority_candidates` first, and ghost roles randomly shuffled and
	// appended after
	var/list/mob/dead/observer/regular_candidates = pollCandidates("Do you wish to be considered for the special role of '[role_name]'?", jobban, gametypecheck, be_special)
	shuffle(regular_candidates)

	var/list/candidates = priority_candidates + regular_candidates

	return candidates
	
