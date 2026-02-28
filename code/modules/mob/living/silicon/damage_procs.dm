/mob/living/silicon/apply_effect(effect = 0,effecttype = EFFECT_STUN, blocked = FALSE)
	return FALSE //The only effect that can hit them atm is flashes and they still directly edit so this works for now. (This was written in at least 2016. Help)

/mob/living/silicon/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype) //immune to tox damage
	return FALSE

/mob/living/silicon/set_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	return FALSE

/mob/living/silicon/adjust_stamina_loss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype) //immune to stamina damage.
	return FALSE

/mob/living/silicon/set_stamina_loss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	return FALSE

/mob/living/silicon/received_stamina_damage(current_level, amount_actual, amount)
	return

/mob/living/silicon/adjust_organ_loss(slot, amount, maximum = 500, required_organ_flag) //immune to organ damage (no organs, duh)
	return FALSE

/mob/living/silicon/set_organ_loss(slot, amount)
	return FALSE

/mob/living/silicon/adjust_oxy_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype, required_respiration_type) //immune to oxygen damage
	if(isAI(src)) //ais are snowflakes and use oxyloss for being in AI cards and having no battery
		return ..()

	return FALSE

/mob/living/silicon/set_oxy_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(isAI(src)) //ditto
		return ..()

	return FALSE
