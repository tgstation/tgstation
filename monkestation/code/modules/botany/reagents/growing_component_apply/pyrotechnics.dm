/datum/reagent/napalm/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(5, 9))
