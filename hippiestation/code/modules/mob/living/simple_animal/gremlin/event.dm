/datum/round_event_control/gremlin
	name = "Spawn Gremlins"
	typepath = /datum/round_event/gremlin
	weight = 50
	max_occurrences = 2
	earliest_start = 12000 //Meant to mix things up early-game.
	min_players = 5


/datum/round_event/gremlin

/datum/round_event/gremlin/announce()
	priority_announce("Bioscans indicate that some gremlins entered through the vents. Deal with them!", "Gremlin Alert", 'sound/ai/attention.ogg')

/datum/round_event/gremlin/start()

	var/list/spawn_locs = list()

	for(var/obj/effect/landmark/L in GLOB.landmarks_list)
		if(isturf(L.loc))
			switch(L.name)
				if("gremlinspawn")
					spawn_locs += L.loc
	if(!spawn_locs.len) //If we can't find any gremlin spawns, try the xeno spawns
		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("xeno_spawn")
						spawn_locs += L.loc
	if(!spawn_locs.len) //If we can't find THAT, then just give up and cry
		return MAP_ERROR

	var/gremlins_to_spawn = rand(2,5)
	var/list/gremlin_areas = list()
	for(var/i = 0, i <= gremlin_areas, i++)
		var/spawnat = pick(spawn_locs)
		spawn_locs -= spawnat
		gremlin_areas += get_area(spawnat)
		new /mob/living/simple_animal/hostile/gremlin(spawnat)
	message_admins("Gremlins have been spawned at the areas: [gremlin_areas]")
	log_game("Gremlins have been spawned at the areas: [gremlin_areas]")
	return SUCCESSFUL_SPAWN