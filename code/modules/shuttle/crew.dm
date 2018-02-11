/obj/docking_port/mobile/crew
	name = "Crew Shuttle"
	id = "crew_shuttle"
	
	timid = FALSE
	preferred_direction = WEST
	port_direction = SOUTH

	ignitionTime = 1    //first launch is instant, don't use 0 though or it could potentially just NOT launch because world.time + timer memes
	callTime = INFINITY

	ignore_already_docked = TRUE

	var/sound_played = FALSE
	var/list/areas

/obj/docking_port/mobile/crew/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/mobile/crew/LateInitialize()
	..()
	areas = list()
	for(var/area/shuttle/lobby/A in GLOB.sortedAreas)
		areas += A
	Launch()

/obj/docking_port/mobile/crew/check()
	. = ..()
	switch(mode)
		if(SHUTTLE_IGNITING)
			if(!sound_played)
				hyperspace_sound(HYPERSPACE_WARMUP, areas)
				sound_played = TRUE
		if(SHUTTLE_CALL)
			if(sound_played)
				hyperspace_sound(HYPERSPACE_LAUNCH, areas)
				sound_played = FALSE

/obj/docking_port/mobile/crew/proc/Launch()
	request(SSshuttle.getDock(id))
	ignitionTime = 50

/obj/docking_port/mobile/crew/proc/StopFlying()
	setTimer(5)
	hyperspace_sound(HYPERSPACE_END, areas)	//for the new guy
