/datum/round_event_control/floor_cluwne
	name = "Floor Cluwne"
	typepath = /datum/round_event/floor_cluwne
	max_occurrences = 1
	min_players = 20


/datum/round_event/floor_cluwne/start()
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/X in GLOB.xeno_spawn)
		spawn_locs += X.loc

	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR
  
	var/turf/T = get_turf(pick(spawn_locs))
	var/mob/living/simple_animal/hostile/floor_cluwne/S = new(T)
	playsound(S, 'hippiestation/sound/misc/bikehorn_creepy.ogg', 50, 1, -1)
	message_admins("A floor cluwne has been spawned at [COORD(T)][ADMIN_JMP(T)]")
	log_game("A floor cluwne has been spawned at [COORD(T)]")
	return SUCCESSFUL_SPAWN
