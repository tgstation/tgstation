/mob/living/can_zFall(turf/T, levels)
	return !(movement_type & FLYING)

/mob/living/canZMove(dir, turf/target)
	return (movement_type & FLYING)
