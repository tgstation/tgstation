/datum/round_event_control/living_lube
	name = "Ghost of Honks Past"
	typepath = /datum/round_event/ghost_role/living_lube
	weight = 2 //don't want this little lube appearing Too often
	max_occurrences = 1

/datum/round_event/ghost_role/living_lube
	minimum_required = 1
	role_name = "Living Lube"
	fakeable = FALSE

/datum/round_event/ghost_role/living_lube/spawn_role()
	var/list/candidates = get_candidates()

	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/turf/chosen_spawn
	chosen_spawn = GLOB.xeno_spawn.len ? pick(GLOB.xeno_spawn) : null
	var/mob/living/simple_animal/hostile/retaliate/clown/lube/living_lube = new(chosen_spawn)
	if(!chosen_spawn)
		SSjob.SendToLateJoin(living_lube, FALSE)

	var/datum/mind/ghost_mind = new /datum/mind(selected.key)
	ghost_mind.assigned_role = "Clown" //So Voice of God's 'Honk" slips people + anything else clown specific can work
	ghost_mind.special_role = "Ghost of Honks Past"
	ghost_mind.active = TRUE
	ghost_mind.transfer_to(living_lube)
	ghost_mind.add_antag_datum(/datum/antagonist/living_lube)

	message_admins("[ADMIN_LOOKUPFLW(living_lube)] has been made into a Ghost of Honks Past.")
	log_game("[key_name(living_lube)] was spawned as Ghost of Honks Past by an event.")
	spawned_mobs += living_lube
	return SUCCESSFUL_SPAWN

