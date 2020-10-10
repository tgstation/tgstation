
/mob/living/carbon/human/Stun(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Paralyze(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Immobilize(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= (rand(125, 130) * 0.01)
	return ..()

/mob/living/carbon/human/Sleeping(amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= (rand(125, 130) * 0.01)
	return ..()

/mob/living/carbon/human/cure_husk(list/sources)
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/become_husk(source)
	if(istype(dna.species, /datum/species/skeleton)) //skeletons shouldn't be husks.
		cure_husk()
		return
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/set_drugginess(amount)
	..()
	if(!amount)
		remove_language(/datum/language/beachbum, TRUE, TRUE, LANGUAGE_HIGH)

/mob/living/carbon/human/adjust_drugginess(amount)
	..()
	if(druggy)
		grant_language(/datum/language/beachbum, TRUE, TRUE, LANGUAGE_HIGH)
	else
		remove_language(/datum/language/beachbum, TRUE, TRUE, LANGUAGE_HIGH)
