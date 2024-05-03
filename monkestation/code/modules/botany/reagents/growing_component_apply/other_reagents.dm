/datum/reagent/blood/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, rand(2, 3))

/datum/reagent/chlorine/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(1, 3))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 1.5))

/datum/reagent/fluorine/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(1, 4))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 2.5))

/datum/reagent/phosphorus/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(1, 2))

/datum/reagent/uranium/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 1))

/datum/reagent/diethylamine/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, -rand(1, 2))

/datum/reagent/brimdust/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -1)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, -1)
