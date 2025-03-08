/mob/living/carbon/human/painful_scream(force = FALSE)
	if(HAS_TRAIT(src, TRAIT_ANALGESIA) && !force)
		return
	if (dna?.species == /datum/species/android) // don't scream if we're a robot, dude...
		return
	INVOKE_ASYNC(src, PROC_REF(emote), "scream")
