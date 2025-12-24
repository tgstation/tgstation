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

/mob/living/silicon/robot/substitute_with_typepath(map_string)
	TGM_MAP_BLOCK(map_string, /obj/item/robot_suit/prebuilt, null)
	return /obj/item/robot_suit/prebuilt

/mob/living/silicon/ai/substitute_with_typepath(map_string)
	TGM_MAP_BLOCK(map_string, /obj/structure/ai_core/latejoin_inactive, null)
	return /obj/structure/ai_core/latejoin_inactive
