/mob/living/carbon/hypnosis_vulnerable()
	if(HAS_MIND_TRAIT(src, TRAIT_UNCONVERTABLE))
		return FALSE
	return ..()
