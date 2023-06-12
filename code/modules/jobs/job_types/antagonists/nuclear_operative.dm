/datum/job/nuclear_operative
	title = ROLE_NUCLEAR_OPERATIVE

/datum/job/nuclear_operative/get_roundstart_spawn_point()
	return pick(GLOB.nukeop_start)

/datum/job/nuclear_operative/get_latejoin_spawn_point()
	return pick(GLOB.nukeop_start)
