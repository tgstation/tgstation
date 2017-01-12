

/mob/living/carbon/alien/getToxLoss()
	return 0

/mob/living/carbon/alien/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE) //alien immune to tox damage
	return FALSE

/mob/living/carbon/alien/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE) // Weak to Fire
	if(amount > 0)
		amount *= 2
	. = ..()



//aliens are immune to stamina damage.
/mob/living/carbon/alien/adjustStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/carbon/alien/setStaminaLoss(amount, updating_stamina = 1)
	return