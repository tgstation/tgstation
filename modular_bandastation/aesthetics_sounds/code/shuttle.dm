/obj/docking_port/mobile
	/// Tracks whether the hyperspace warmup sound has been played during the shuttle's ignition phase
	var/sound_played_start = FALSE
	/// Tracks whether the hyperspace end sound has been played during the shuttle's call or landing phase
	var/sound_played_end = FALSE
	/// Custom sound for shuttle's HYPERSPACE_WARMUP. Doesn't include emergency & arrival shuttles
	var/custom_hyperspace_warmup_sound = 'modular_bandastation/aesthetics_sounds/sound/shuttle/hyperspace_mini.ogg'
	/// Custom sound for shuttle's HYPERSPACE_END. Doesn't include emergency & arrival shuttles
	var/custom_hyperspace_end_sound = 'modular_bandastation/aesthetics_sounds/sound/shuttle/hyperspace_end_new.ogg'

/obj/docking_port/mobile/proc/get_custom_sound(phase)
	if(shuttle_id == "emergency" || shuttle_id == "arrival")
		return

	switch(phase)
		if(HYPERSPACE_WARMUP)
			return custom_hyperspace_warmup_sound
		if(HYPERSPACE_END)
			return custom_hyperspace_end_sound

/obj/docking_port/mobile/check()
	. = ..()
	// We already have in core sounds for emergency & arrival shuttles
	if(shuttle_id == "emergency" || shuttle_id == "arrival")
		return

	switch(mode)
		if(SHUTTLE_IGNITING)
			if(!sound_played_start)
				var/list/areas = list()
				for(var/area/shuttle/S in shuttle_areas)
					areas += S
				// Check if there are 2 seconds or less left before SHUTTLE_IGNITING ends
				if(timeLeft(1) <= 3 SECONDS)
					sound_played_start = TRUE
					hyperspace_sound(HYPERSPACE_WARMUP, areas)
		if(SHUTTLE_CALL)
			if(!sound_played_end)
				var/turf/destination_turf = get_turf(destination)
				var/list/areas = list()
				for(var/area/shuttle/S in shuttle_areas)
					areas += S
				// Check if there are 2 seconds or less left before SHUTTLE_CALL ends
				if(timeLeft(1) <= 2 SECONDS)
					sound_played_end = TRUE
					hyperspace_sound(HYPERSPACE_END, areas)
					// Call shuttle arrival sound on destination (docking) point
					if(!destination_turf)
						stack_trace("Destination turf is invalid. Sound not played.")
						return
					playsound(destination_turf, custom_hyperspace_end_sound, vol = 100, vary = TRUE, pressure_affected = FALSE)
		if(SHUTTLE_IDLE)
			// Our sounds should be played once
			if(sound_played_start)
				sound_played_start = FALSE
			if(sound_played_end)
				sound_played_end = FALSE
