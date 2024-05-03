/datum/reagent/toxin/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 2))

/datum/reagent/toxin/plantbgone/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 6))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(4, 8))

/datum/reagent/toxin/plantbgone/weedkiller/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 0.5))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(1, 2))

/datum/reagent/toxin/pestkiller/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 1))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, -rand(1, 2))

/datum/reagent/toxin/pestkiller/organic/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 0.1))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_PEST, -rand(1, 2))

/datum/reagent/toxin/acid/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 1.5))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(1, 2))

/datum/reagent/toxin/acid/fluacid/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, round(volume * 3))
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_WEED, -rand(1, 4))
