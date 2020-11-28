/mob/living/carbon/human/become_husk(source)
	if(!HAS_TRAIT(src, TRAIT_NO_HUSK))
		. = ..()
