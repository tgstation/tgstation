/datum/reagent/drug/nicotine/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, -rand(1, 2))
