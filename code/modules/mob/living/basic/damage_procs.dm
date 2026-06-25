/mob/living/basic/on_damage_loss(amount, updating_health, forced, damage_type, actual_change)
	if(damage_type != BRUTE)
		simple_transfer_to_brute_loss(amount)
	return ..()

//Manage stamcrit for basic mobs
/mob/living/basic/on_damage_loss_changed(amount, updating_health, forced, damage_type)
	. = ..()

	if (damage_type != STAMINA || amount < 0 || stat == DEAD || stamina_crit_threshold == BASIC_MOB_NO_STAMCRIT)
		return

	if (100 / (max_stamina / staminaloss) >= stamina_crit_threshold)
		apply_status_effect(/datum/status_effect/incapacitating/stamcrit)

//if the stamina recovery is different than 0, then we use that to gradually restore stamina rather than all in one go after a timer
/mob/living/basic/timed_stamina_reset()
	if (stamina_recovery == 0)
		return ..()
