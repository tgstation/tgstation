/datum/reagent/consumable/honey/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, rand(1, 2))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, rand(1, 2))

/datum/reagent/consumable/sugar/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, rand(1, 2))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, rand(1, 2))
