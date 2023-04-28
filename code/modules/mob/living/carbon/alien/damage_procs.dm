///alien immune to tox damage
/mob/living/carbon/alien/getToxLoss()
	return FALSE

///alien immune to tox damage
/mob/living/carbon/alien/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	return FALSE

///aliens are immune to stamina damage. - Not anymore
/mob/living/carbon/alien/pre_stamina_change(diff as num, forced)
	return diff

///aliens are immune to stamina damage.
/mob/living/carbon/alien/setStaminaLoss(amount, updating_stamina = 1)
	return FALSE
