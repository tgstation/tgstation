///prototype for mining mobs
/mob/living/basic/mining

	combat_mode = TRUE
	faction = list("mining")
	unsuitable_atmos_damage = 0
	min_body_temp = 0
	max_body_temp = INFINITY

/mob/living/basic/mining/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_ASHSTORM_IMMUNE, INNATE_TRAIT)
	AddElement(/datum/element/mob_killed_tally, "mobs_killed_mining")
