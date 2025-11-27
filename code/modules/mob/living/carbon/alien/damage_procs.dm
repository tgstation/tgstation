///alien immune to tox damage
/mob/living/carbon/alien/get_tox_loss()
	return FALSE

///alien immune to tox damage
/mob/living/carbon/alien/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	return FALSE

///aliens are immune to stamina damage.
/mob/living/carbon/alien/adjust_stamina_loss(amount, updating_stamina = 1, forced = FALSE, required_biotype)
	return FALSE

///aliens are immune to stamina damage.
/mob/living/carbon/alien/set_stamina_loss(amount, updating_stamina = 1, forced = FALSE, required_biotype)
	return FALSE
