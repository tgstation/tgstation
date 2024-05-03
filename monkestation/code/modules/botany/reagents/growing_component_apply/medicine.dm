/datum/reagent/medicine/cryoxadone/on_plant_grower_apply(atom/movable/parent)
	SEND_SIGNAL(parent, COMSIG_GROWING_ADJUST_TOXIN, -round(volume * 3))

/datum/reagent/medicine/earthsblood/on_plant_grower_apply(atom/movable/parent)
	. = ..()
	SEND_SIGNAL(parent, COMSIG_GROWER_ADJUST_SELFGROW, volume)
	SEND_SIGNAL(parent, COMSIG_GROWER_INCREASE_WORK_PROCESSES, 30)
