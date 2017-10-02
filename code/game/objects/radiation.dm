/mob/living/rad_act(amount, silent = 0)
	if(amount)
		var/blocked = getarmor(null, "rad")

		if(!silent && amount >= 10)
			to_chat(src, "Your skin feels warm.")

		apply_effect(amount/10, IRRADIATE, blocked)
		if(amount > 100)
			apply_damage(amount/100, BURN, null, blocked)

/mob/living/carbon/rad_act(amount, silent = 0)
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
