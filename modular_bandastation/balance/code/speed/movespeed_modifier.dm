/proc/modified_move_delay(move_delay, ignore_zero = FALSE)
	if(move_delay == 0 && !ignore_zero)
		return round(max(RP_SPEED - TG_SPEED, 0) * TG_SPEED, 0.01)
	return round(RP_SPEED / TG_SPEED * move_delay, 0.01)

/datum/movespeed_modifier/proc/get_rp_speed()
	return modified_move_delay(multiplicative_slowdown, ignore_zero = TRUE)

/datum/movespeed_modifier/config_walk_run/get_rp_speed()
	return multiplicative_slowdown
