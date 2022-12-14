///alien immune to tox damage
/mob/living/carbon/alien/getToxLoss()
	return FALSE

///alien immune to tox damage
/mob/living/carbon/alien/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	return FALSE

///aliens are immune to stamina damage.
/mob/living/carbon/alien/adjustStaminaLoss(amount, updating_stamina = 1, forced = FALSE, required_biotype)
	return FALSE

///aliens are immune to stamina damage.
/mob/living/carbon/alien/setStaminaLoss(amount, updating_stamina = 1)
	return FALSE
