// Not a creature was fighting. Not even a mouse.

/datum/round_modifier/trait/mass_pacifism
	name = "Mass Pacifism"
	desc = "All mobs, players or not will have the pacifism trait, preventing most forms of direct harm."
	modifier_traits = list(TRAIT_PACIFISM)

	apply_to_mob = TRUE
	apply_to_mind = TRUE

/datum/round_modifier/trait/mass_pacifism/get_mob_list()
	return GLOB.mob_list

/datum/round_modifier/trait/mass_pacifism/is_eligible(mob/M)
	return TRUE

/datum/round_modifier/trait/mass_pacifism/announce_enabling()
	priority_announce("Through a combination of gene thearapy, extensive modification of clone templates and paintchips in the donk pockets, no person or animal on or around the station is capable of harming another directly.")

/datum/round_modifier/trait/mass_pacifism/announce_disabling()
	priority_announce("Central Command has disabled the pacification satellite in orbit around your station.")
