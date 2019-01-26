/datum/round_modifier/trait/law_immutability
	name = "Silicon Law Immutability"
	modifier_traits = list(TRAIT_NO_LAW_CHANGE)

	apply_to_mob = TRUE

/datum/round_modifier/trait/law_immutability/get_mob_list()
	return GLOB.silicon_mobs

/datum/round_modifier/trait/law_immutability/announce_enabling()
	priority_announce("All silicon law modification has been disabled by Central Command.")

/datum/round_modifier/trait/law_immutability/announce_disabling()
	priority_announce("Silicon law modification has been reenabled by Central Command.")
