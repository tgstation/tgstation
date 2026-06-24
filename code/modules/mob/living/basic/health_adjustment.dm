
/mob/living/basic/adjust_brute_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	. = ..()

/mob/living/basic/adjust_fire_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	. = ..()

/mob/living/basic/adjust_oxy_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype, required_respiration_type)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	. = ..()

/mob/living/basic/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	. = ..()

/mob/living/basic/proc/on_adjust_damage_loss(amount, updating_health, forced)
	SHOULD_CALL_PARENT(TRUE)
	return amount
/mob/living/basic/received_stamina_damage(current_level, amount_actual, amount)
	if (stamina_recovery == 0)
		return ..()

/mob/living/basic/received_stamina_damage(current_level, amount_actual, amount)
	. = ..()
	if (stat == DEAD || stamina_crit_threshold == BASIC_MOB_NO_STAMCRIT)
		return

	if (100 / (max_stamina / current_level) >= stamina_crit_threshold)
		apply_status_effect(/datum/status_effect/incapacitating/stamcrit)

///For the samke of simplicity, basic mobs only suffer one standard damage type (this could be changed/modularized in the future though)
/mob/living/basic/updatehealth()
	var/damage_sources_converted_to_brute = get_oxy_loss() + get_tox_loss() + get_fire_loss()
	fireloss = 0
	toxloss = 0
	oxyloss = 0
	bruteloss = round(clamp(bruteloss + damage_sources_converted_to_brute, 0, maxHealth * 2), DAMAGE_PRECISION)
	return ..()
