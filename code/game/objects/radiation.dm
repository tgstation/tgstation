/mob/living/rad_act(amount)
	amount = max(amount-RAD_BACKGROUND_RADIATION, 0)

	if(amount)
		var/blocked = getarmor(null, "rad")

		apply_effect(amount/50, IRRADIATE, blocked)
		if(amount > RAD_AMOUNT_EXTREME)
			apply_damage((amount-RAD_AMOUNT_EXTREME)/RAD_AMOUNT_EXTREME, BURN, null, blocked)

/mob/living/carbon/rad_act(amount)
	if(dna && (RADIMMUNE in dna.species.species_traits))
		silent = TRUE
	..()

//Silicons will inherently not get irradiated due to having an empty handle_mutations_and_radiation, but they need to not hear this
/mob/living/silicon/rad_act(amount)
	. = ..(amount, TRUE)

/mob/living/simple_animal/bot/rad_act(amount)
	. = ..(amount, TRUE)

/mob/living/simple_animal/drone/rad_act(amount)
	. = ..(amount, TRUE)

/mob/living/simple_animal/hostile/swarmer/rad_act(amount)
	. = ..(amount, TRUE)
