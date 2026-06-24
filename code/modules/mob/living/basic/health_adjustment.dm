/mob/living/basic/on_damage_loss_changed(amount, updating_health, forced, damage_type)
	if(damage_type != BRUTE)
		simple_transfer_to_brute_loss(amount)
	return ..()

/mob/living/basic/received_stamina_damage(current_level, amount_actual, amount)
	if (stamina_recovery == 0)
		. = ..() //In this case, we recover all our stamina in one go after a timer.

	if (stat == DEAD || stamina_crit_threshold == BASIC_MOB_NO_STAMCRIT)
		return

	if (100 / (max_stamina / current_level) >= stamina_crit_threshold)
		apply_status_effect(/datum/status_effect/incapacitating/stamcrit)
