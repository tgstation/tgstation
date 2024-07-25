/mob/living/carbon/is_pepper_proof(check_flags = ALL)
	if(HAS_TRAIT(src, TRAIT_NOBREATH) && is_eyes_covered())
		return src // this returns an object instead of a bool for some reason, even tho nothing uses it, let's be safe
	return ..()
