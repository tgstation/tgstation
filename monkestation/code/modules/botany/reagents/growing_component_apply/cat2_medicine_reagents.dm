/datum/reagent/medicine/c2/multiver/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, -round(volume * 2))
