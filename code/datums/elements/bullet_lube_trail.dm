// Adds a trail of lube on the tiles following the bullet.
/datum/element/bullet_lube_trail
	element_flags = ELEMENT_DETACH

/datum/element/bullet_lube_trail/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/lubricate)

/datum/element/bullet_lube_trail/proc/lubricate(atom/movable/coin_b)
	SIGNAL_HANDLER

	var/turf/open/OT = get_turf(coin_b)
	if(istype(OT))
		OT.MakeSlippery(TURF_WET_LUBE, 20)
		return TRUE
