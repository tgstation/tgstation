

/mob/living/carbon/alien/getToxLoss()
	return 0

/mob/living/carbon/alien/adjustToxLoss(amount) //alien immune to tox damage
	return 0

/mob/living/carbon/alien/adjustFireLoss(amount) // Weak to Fire
	if(amount > 0)
		..(amount * 2)
	else
		..(amount)



//aliens are immune to stamina damage.
/mob/living/carbon/alien/adjustStaminaLoss(amount, updating_stamina = 1)
	return

/mob/living/carbon/alien/setStaminaLoss(amount, updating_stamina = 1)
	return