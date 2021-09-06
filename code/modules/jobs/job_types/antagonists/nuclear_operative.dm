/datum/job/nuclear_operative
	title = ROLE_NUCLEAR_OPERATIVE
	faction_trait = TRAIT_FACTION_SYNDICATE


/datum/job/nuclear_operative/get_roundstart_spawn_point()
	return pick(GLOB.nukeop_start)


/datum/job/nuclear_operative/get_latejoin_spawn_point()
	return pick(GLOB.nukeop_start)
