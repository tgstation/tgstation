/mob/living/carbon/proc/update_limb_movespeed()
	. = 0
	if(!get_leg_ignore())
		var/leg_amount = get_num_legs()
		. += 6 - 3*leg_amount
		if(!leg_amount)
			. += 6 - 3 * get_num_arms()
		if(legcuffed)
			. += legcuffed.slowdown
	add_movespeed_modifier(MOVESPEED_ID_CARBON_LIMB, update = TRUE, flags = MOVESPEED_MODIFIER_IGNORES_NOSLOW, override = TRUE, multiplicative_slowdown.)

/mob/living/carbon/update_trait_slowdown()
	. = ..()
	if(has_trait(TRAIT_RESISTCOLD))
		remove_movespeed_modifier(MOVESPEED_ID_CARBON_TEMPERATURE)
		update_temperature_slowdown()

/mob/living/carbon/adjust_bodytemperature()
	. = ..()
	update_temperature_slowdown()

/mob/living/carbon/proc/update_temperature_slowdown()
	if(bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !has_trait(TRAIT_RESISTCOLD))
		var/amount = (BODYTEMP_COLD_DAMAGE_LIMIT - bodytemperature) / COLD_SLOWDOWN_FACTOR
		add_movespeed_modifier(MOVESPEED_ID_CARBON_TEMPERATURE, override = TRUE, multiplicative_slowdown = amount)
