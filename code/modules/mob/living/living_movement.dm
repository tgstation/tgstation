/mob/living/can_zFall(turf/T, levels)
	return !(movement_type & FLYING)

/mob/living/canZMove(dir, turf/target)
	return can_zTravel(target, dir) && (movement_type & FLYING)
