/mob/living/proc/update_trait_slowdown()
	. = 0
	if(has_trait(TRAIT_GOTTAGOFAST))
		. -= 1
	else if(has_trait(TRAIT_GOTTAGOREALLYFAST))
		. -= 2
	add_movespeed_modifier(MOVESPEED_ID_TRAITS, override = TRUE, multiplicative_slowdown = .)
