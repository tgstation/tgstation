
/mob/living/carbon/human/Stun(amount, ignore_canstun = FALSE)
	amount = spec_stun(amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, daze_amount = 0, ignore_canstun = FALSE)
	amount = spec_stun(amount)
	return ..()

/mob/living/carbon/human/Paralyze(amount, ignore_canstun = FALSE)
	amount = spec_stun(amount)
	return ..()

/mob/living/carbon/human/Immobilize(amount, ignore_canstun = FALSE)
	amount = spec_stun(amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, ignore_canstun = FALSE)
	amount = spec_stun(amount)
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
		update_body_parts()

/mob/living/carbon/human/proc/spec_stun(amount)
	var/list/stun_amount = list(dna.species.stunmod * amount)
	SEND_SIGNAL(src, COMSIG_HUMAN_SPEC_STUN, stun_amount)
	return stun_amount[1]
