/obj/machinery/nuclearbomb/syndicate

/obj/machinery/nuclearbomb/syndicate/get_cinematic_type(detonation_status)
	switch(detonation_status)
		// The nuke detonated on station
		if(DETONATION_HIT_STATION)
			if(length(get_antag_minds(/datum/antagonist/nukeop)) && is_infiltrator_docked_at_centcom())
				// And the ops escaped, they won!
				return CINEMATIC_NUKE_WIN
			else
				// And the ops failed to escape, mutually assured destruction!
				return CINEMATIC_ANNIHILATION

		// The nuke detonated on station Z, but in space
		if(DETONATION_NEAR_MISSED_STATION)
			return CINEMATIC_NUKE_MISS

		// The nuke detonated off station Z, and/or on the syndicate base
		if(DETONATION_HIT_SYNDIE_BASE, DETONATION_MISSED_STATION)
			return CINEMATIC_NUKE_FAR

	stack_trace("[type] - get_cinematic_type got a detonation_status it was not expecting. (Got: [detonation_status])")
	return CINEMATIC_NUKE_FAR
