
/mob/living/carbon/human/Stun(amount, updating = 1, ignore_canstun = 0)
	amount = dna.species.spec_stun(src,amount)
	..()

/mob/living/carbon/human/Weaken(amount, updating = 1, ignore_canstun = 0)
	amount = dna.species.spec_stun(src,amount)
	..()

/mob/living/carbon/human/cure_husk()
	. = ..()
	if(.)
		update_hair()

/mob/living/carbon/human/become_husk()
	. = ..()
	if(.)
		update_hair()