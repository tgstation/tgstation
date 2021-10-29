/obj/docking_port/mobile
	/// Does this shuttle play sounds upon landing and takeoff?
	var/shuttle_sounds = TRUE
	/// The take off sound to be played
	var/takeoff_sound = sound('modular_skyrat/modules/advanced_shuttles/sound/engine_startup.ogg')
	/// The landing sound to be played
	var/landing_sound = sound('modular_skyrat/modules/advanced_shuttles/sound/engine_landing.ogg')
	/// The sound range coeff for the landing and take off sound effect
	var/sound_range = 20


//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S, forced = FALSE)
	if(!check_dock(S) && !forced)
		testing("check_dock failed on request for [src]")
		return

	if(forced)
		admin_forced = TRUE

	if(mode == SHUTTLE_IGNITING && destination == S)
		return

	switch(mode)
		if(SHUTTLE_CALL)
			if(!can_be_called_in_transit) //SKYRAT EDIT ADDITION
				return
			if(S == destination)
				if(timeLeft(1) < callTime * engine_coeff)
					setTimer(callTime * engine_coeff)
			else
				destination = S
				setTimer(callTime * engine_coeff)
		if(SHUTTLE_RECALL)
			if(!can_be_called_in_transit) //SKYRAT EDIT ADDITION
				return
			if(S == destination)
				setTimer(callTime * engine_coeff - timeLeft(1))
			else
				destination = S
				setTimer(callTime * engine_coeff)
			mode = SHUTTLE_CALL
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING)
			destination = S
			mode = SHUTTLE_IGNITING
			bolt_all_doors()
			play_engine_sound(src, TRUE) //SKYRAT EDIT ADDITION
			setTimer(ignitionTime)

/obj/docking_port/mobile/proc/bolt_all_doors() //Expensive procs :(
	var/list/turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to turfs.len)
		var/turf/T = turfs[i]
		for(var/obj/machinery/door/airlock/airlock_door in T)
			if(airlock_door.external)
				airlock_door.close(force_crush = TRUE)
				airlock_door.bolt()

/obj/docking_port/mobile/proc/unbolt_all_doors()
	var/list/turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to turfs.len)
		var/turf/T = turfs[i]
		for(var/obj/machinery/door/airlock/airlock_door in T)
			if(airlock_door.external)
				airlock_door.unbolt()

/obj/docking_port/mobile/proc/play_engine_sound(atom/distant_source, takeoff)
	if(distant_source)
		for(var/mob/M in range(sound_range, distant_source))
			if(M && M.client)
				var/dist = get_dist(M.loc, distant_source.loc)
				var/vol = clamp(50-((dist-7)*5), 10, 50) //Every tile decreases sound volume by 5
				if(takeoff)
					if(M.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
						M.playsound_local(distant_source, takeoff_sound, vol)
				else
					if(M.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
						M.playsound_local(distant_source, landing_sound, vol)
