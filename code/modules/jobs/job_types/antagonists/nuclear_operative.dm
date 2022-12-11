/datum/job/nuclear_operative
	title = ROLE_NUCLEAR_OPERATIVE


/datum/job/nuclear_operative/get_roundstart_spawn_point()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NUKIEBASE)
	return pick(GLOB.nukeop_start)

/datum/job/nuclear_operative/get_latejoin_spawn_point()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_NUKIEBASE)
	return pick(GLOB.nukeop_start)
