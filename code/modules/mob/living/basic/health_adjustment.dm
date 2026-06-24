/mob/living/basic/adjust_brute_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	. = ..()

/mob/living/basic/adjust_fire_loss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	var/old_update = updating_health
	updating_health = FALSE
	. = ..()
	convert_to_brute_loss(BURN, old_update)

/mob/living/basic/adjust_oxy_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype, required_respiration_type)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	var/old_update = updating_health
	updating_health = FALSE
	. = ..()
	convert_to_brute_loss(OXY, old_update)

/mob/living/basic/adjust_tox_loss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	amount = on_adjust_damage_loss(amount, updating_health, forced)
	var/old_update = updating_health
	updating_health = FALSE
	. = ..()
	convert_to_brute_loss(TOX, old_update)

/mob/living/basic/proc/on_adjust_damage_loss(amount, updating_health, forced)
	SHOULD_CALL_PARENT(TRUE)
	return amount

/mob/living/basic/received_stamina_damage(current_level, amount_actual, amount)
	if (stamina_recovery == 0)
		. = ..() //In this case, we recover all our stamina in one go after a timer.

	if (stat == DEAD || stamina_crit_threshold == BASIC_MOB_NO_STAMCRIT)
		return

	if (100 / (max_stamina / current_level) >= stamina_crit_threshold)
		apply_status_effect(/datum/status_effect/incapacitating/stamcrit)
