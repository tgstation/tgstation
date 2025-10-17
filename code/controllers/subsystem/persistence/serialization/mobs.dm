// There is currently no [/mob/living/carbon] support due to complexity

///  B A S I C   M O B S  ///

/mob/living/basic/get_save_vars()
	. = ..()
	. += NAMEOF(src, stat)
	. += NAMEOF(src, health)

	. -= NAMEOF(src, density)
	. -= NAMEOF(src, icon)
	. -= NAMEOF(src, icon_state)
	return .

/mob/living/basic/PersistentInitialize()
	. = ..()
	updatehealth()

///  S I M P L E   A N I M A L S  ///

/mob/living/simple_animal/get_save_vars()
	. = ..()
	. += NAMEOF(src, stat)
	. += NAMEOF(src, health)

	. -= NAMEOF(src, density)
	. -= NAMEOF(src, icon)
	. -= NAMEOF(src, icon_state)
	return .

/mob/living/simple_animal/PersistentInitialize()
	. = ..()
	updatehealth()
