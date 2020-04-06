/turf/proc/turf_take_damage(damage_amount, damage_type = BURN, damage_flag = "", sound_effect = TRUE, armour_penetration = 0)
	if(QDELETED(src))
		stack_trace("[src] taking damage after deletion")
		return
	if((resistance_flags & INDESTRUCTIBLE) || turf_integrity <= 0)
		return
	if(damage_amount < DAMAGE_PRECISION)
		return
	. = damage_amount
	turf_integrity = max(turf_integrity - damage_amount, 0)
	//BREAKING FIRST
	if(integrity_failure && turf_integrity <= integrity_failure * max_integrity)
		turf_break(damage_flag)
	//DESTROYING SECOND
	if(turf_integrity <= 0)
		turf_destruction(damage_flag)

/turf/proc/turf_break(damage_flag)
	return

/turf/proc/turf_destruction(damage_flag)
	if(damage_flag == "fire")
		Melt()
	else
		deconstruct(FALSE)
