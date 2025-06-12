/datum/job/nuclear_operative
	title = ROLE_OPERATIVE

/datum/job/nuclear_operative/get_roundstart_spawn_point()
	return pick(GLOB.nukeop_start)

/datum/job/nuclear_operative/get_latejoin_spawn_point()
	return pick(GLOB.nukeop_start)

/datum/job/nuclear_operative/leader

/datum/job/nuclear_operative/leader/get_roundstart_spawn_point()
	return pick(GLOB.nukeop_leader_start)

/datum/job/nuclear_operative/leader/get_latejoin_spawn_point()
	return pick(GLOB.nukeop_leader_start)

/datum/job/nuclear_operative/clown_operative
	title = ROLE_CLOWN_OPERATIVE

/datum/job/nuclear_operative/clown_operative/leader

/datum/job/nuclear_operative/clown_operative/leader/get_roundstart_spawn_point()
	return pick(GLOB.nukeop_leader_start)

/datum/job/nuclear_operative/clown_operative/leader/get_latejoin_spawn_point()
	return pick(GLOB.nukeop_leader_start)
