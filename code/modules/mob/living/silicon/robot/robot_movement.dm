/mob/living/silicon/robot/Process_Spacemove(movement_dir = 0)
	if(ionpulse())
		return 1
	return ..()

/mob/living/carbon/human/update_config_movespeed()
	var/static/datum/config_entry/number/movedelay/robot_delay/config_robot_delay
	if(!istype(config_robot_delay))
		config_robot_delay = CONFIG_GET_DATUM(number/movedelay/robot_delay)
	add_movespeed_modifier(MOVESPEED_ID_ROBOT_CONFIG_SPEEDMOD, FALSE, 100, override = TRUE, legacy_slowdown = config_robot_delay.config_entry_value)
	return ..()

/mob/living/silicon/robot/mob_negates_gravity()
	return magpulse

/mob/living/silicon/robot/mob_has_gravity()
	return ..() || mob_negates_gravity()

/mob/living/silicon/robot/experience_pressure_difference(pressure_difference, direction)
	if(!magpulse)
		return ..()
