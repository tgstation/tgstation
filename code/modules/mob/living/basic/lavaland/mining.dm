///prototype for mining mobs
/mob/living/basic/mining

	combat_mode = TRUE
	faction = list(FACTION_MINING)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
