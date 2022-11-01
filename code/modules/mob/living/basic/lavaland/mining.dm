///prototype for mining mobs
/mob/living/basic/mining

	combat_mode = TRUE
	faction = list("mining")

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
	AddElement(/datum/element/basic_body_temp_sensitive, max_body_temp = INFINITY)
