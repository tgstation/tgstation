// There is currently no [/mob/living/carbon] support due to complexity

///  B A S I C   M O B S  ///

/mob/living/is_saveable(turf/current_loc, list/obj_blacklist)
	. = ..()
	if(stat == DEAD) // what is dead may never die
		return FALSE

	return .

/mob/living/basic/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stat)
	. += NAMEOF(src, health)

	. -= NAMEOF(src, density)
	return .

/mob/living/basic/PersistentInitialize()
	. = ..()
	updatehealth()

///  S I M P L E   A N I M A L S  ///

/mob/living/simple_animal/get_save_vars(save_flags=ALL)
	. = ..()
	. += NAMEOF(src, stat)
	. += NAMEOF(src, health)

	. -= NAMEOF(src, density)
	return .

/mob/living/simple_animal/PersistentInitialize()
	. = ..()
	updatehealth()
