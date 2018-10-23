/mob/living/carbon/proc/update_limb_movespeed()
	. = 0
	if(!get_leg_ignore())
		var/leg_amount = get_num_legs()
		. += 6 - 3*leg_amount
		if(!leg_amount)
			. += 6 - 3 * get_num_arms()
		if(legcuffed)
			. += legcuffed_slowdown
	add_movespeed_modifier(MOVESPEED_ID_CARBON_LIMB, TRUE, IGNORE_NOSLOW, NONE, TRUE,
