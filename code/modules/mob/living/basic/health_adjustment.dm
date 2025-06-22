/**
 * Adjusts the health of a simple mob by a set amount
 *
 * Arguments:
 * * amount The amount that will be used to adjust the mob's health
 * * updating_health If the mob's health should be immediately updated to the new value
 * * forced If we should force update the adjustment of the mob's health no matter the restrictions, like TRAIT_GODMODE
 * returns the net change in bruteloss after applying the damage amount
 */
/mob/living/basic/proc/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	. = FALSE
	if(!forced && HAS_TRAIT(src, TRAIT_GODMODE))
		return 0
	. = bruteloss // bruteloss value before applying damage
	bruteloss = round(clamp(bruteloss + amount, 0, maxHealth * 2), DAMAGE_PRECISION)
	if(updating_health)
		updatehealth()
	return . - bruteloss

/mob/living/basic/get_damage_mod(damage_type)
	var/modifier = ..()
	if (damage_type in damage_coeff)
		return modifier * damage_coeff[damage_type]
	return modifier

/mob/living/basic/adjustBruteLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!can_adjust_brute_loss(amount, forced, required_bodytype))
		return 0
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[BRUTE])
		. = adjust_health(amount * damage_coeff[BRUTE] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE, required_bodytype)
	if(!can_adjust_fire_loss(amount, forced, required_bodytype))
		return 0
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[BURN])
		. = adjust_health(amount * damage_coeff[BURN] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustOxyLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype, required_respiration_type)
	if(!can_adjust_oxy_loss(amount, forced, required_biotype, required_respiration_type))
		return 0
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[OXY])
		. = adjust_health(amount * damage_coeff[OXY] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustToxLoss(amount, updating_health = TRUE, forced = FALSE, required_biotype)
	if(!can_adjust_tox_loss(amount, forced, required_biotype))
		return 0
	if(forced)
		. = adjust_health(amount * CONFIG_GET(number/damage_multiplier), updating_health, forced)
	else if(damage_coeff[TOX])
		. = adjust_health(amount * damage_coeff[TOX] * CONFIG_GET(number/damage_multiplier), updating_health, forced)

/mob/living/basic/adjustStaminaLoss(amount, updating_stamina = TRUE, forced = FALSE, required_biotype)
	if(!can_adjust_stamina_loss(amount, forced, required_biotype))
		return 0
	. = staminaloss

	var/stamina_delta = forced ? amount : amount * damage_coeff[STAMINA]
	staminaloss = max(0, min(max_stamina, staminaloss + stamina_delta))

	if(stamina_delta > 0)
		received_stamina_damage(staminaloss, -1 * stamina_delta, amount)
	if(updating_stamina && stamina_delta)
		update_stamina()
	. -= staminaloss

/mob/living/basic/received_stamina_damage(current_level, amount_actual, amount)
	if (stamina_recovery == 0)
		return ..()

/mob/living/basic/received_stamina_damage(current_level, amount_actual, amount)
	. = ..()
	if (stat == DEAD || stamina_crit_threshold == BASIC_MOB_NO_STAMCRIT)
		return

	if (100 / (max_stamina / current_level) >= stamina_crit_threshold)
		apply_status_effect(/datum/status_effect/incapacitating/stamcrit)
