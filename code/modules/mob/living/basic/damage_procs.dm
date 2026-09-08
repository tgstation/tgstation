/// basic mobs will transfer BURN / OXY / TOX damage into brute.
/mob/living/basic/on_damage_loss(amount, updating_health, forced, damage_type, difference)
	var/transfered_loss //In the case of transfered loss, return the delta of old bruteloss and new bruteloss instead
	if(damage_type != BRUTE && damage_type != STAMINA)
		transfered_loss = simple_transfer_to_brute_loss(amount)
	. = ..()
	return transfered_loss || .

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
