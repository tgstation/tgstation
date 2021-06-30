/datum/component/vacuum
	var/obj/item/storage/bag/trash/vacuum_bag

/datum/component/vacuum/Initialize()
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/suck)
	RegisterSignal(parent, COMSIG_VACUUM_BAG_ATTACH, .proc/attach_bag)
	RegisterSignal(parent, COMSIG_VACUUM_BAG_DETACH, .proc/detach_bag)

/datum/component/vacuum/proc/suck(datum/suckee)
	SIGNAL_HANDLER

	var/atom/movable/AM = suckee
	var/turf/tile = AM.loc
	if (!isturf(tile))
		return

	// no bag attached
	if (!vacuum_bag)
		return

	// suck the things
	for (var/potential_item in tile)
		if (!isitem(potential_item))
			continue
		var/obj/item/item = potential_item
		INVOKE_ASYNC(vacuum_bag, /atom/.proc/attackby, item)

/datum/component/vacuum/proc/attach_bag(datum/source, obj/item/storage/bag/trash/new_bag)
	SIGNAL_HANDLER

	vacuum_bag = new_bag

/datum/component/vacuum/proc/detach_bag(datum/source)
	SIGNAL_HANDLER

	vacuum_bag = null
