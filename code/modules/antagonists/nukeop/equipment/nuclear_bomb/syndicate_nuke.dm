/obj/machinery/nuclearbomb/syndicate

/obj/machinery/nuclearbomb/syndicate/get_cinematic_type(detonation_status)
	switch(detonation_status)
		// The nuke detonated on station
		if(DETONATION_HIT_STATION)
			if(length(get_antag_minds(/datum/antagonist/nukeop)) && is_infiltrator_docked_at_centcom())
				// And the ops escaped, they won!
				return /datum/cinematic/nuke/ops_victory
			else
				// And the ops failed to escape, mutually assured destruction!
				return /datum/cinematic/nuke/mutual_destruction

		// The nuke detonated on station Z, but in space
		if(DETONATION_NEAR_MISSED_STATION)
			return /datum/cinematic/nuke/ops_miss

		// The nuke detonated off station Z, and/or on the syndicate base
		if(DETONATION_HIT_SYNDIE_BASE, DETONATION_MISSED_STATION)
			return /datum/cinematic/nuke/far_explosion

	stack_trace("[type] - get_cinematic_type got a detonation_status it was not expecting. (Got: [detonation_status])")
	return /datum/cinematic/nuke/far_explosion
