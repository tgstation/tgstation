/**
 * # Vacuum Component
 *
 * Adds a vacuum functionality to an atom, requires a trashbag to be linked
 * using signals
 *
 */
/datum/component/vacuum
	/// The linked trash bag to vacuum trash into
	var/obj/item/storage/bag/trash/vacuum_bag

/datum/component/vacuum/Initialize(obj/item/storage/bag/trash/connected_bag = null)
	. = ..()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	if (connected_bag)
		attach_bag(null, connected_bag)
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(suck))
	RegisterSignal(parent, COMSIG_VACUUM_BAG_ATTACH, PROC_REF(attach_bag))
	RegisterSignal(parent, COMSIG_VACUUM_BAG_DETACH, PROC_REF(detach_bag))

/**
 * Called when parent moves, deligates vacuuming functionality
 *
 * Arguments:
 * * suckee - The source of the signal
 */
/datum/component/vacuum/proc/suck(datum/suckee)
	SIGNAL_HANDLER

	// get tile to suck on
	var/atom/movable/AM = suckee
	var/turf/tile = AM.loc
	if (!isturf(tile))
		return

	// no bag attached, don't bother
	if (!vacuum_bag)
		return

	// suck the things
	INVOKE_ASYNC(src, PROC_REF(suck_items), tile)

/**
 * Sucks up items as possible from a provided turf into the connected trash bag
 *
 * Arguments:
 * * tile - The tile upon which to vacuum up items
 */
/datum/component/vacuum/proc/suck_items(turf/tile)
	var/sucked = FALSE
	for (var/potential_item in tile)
		if (!isitem(potential_item))
			continue
		var/obj/item/item = potential_item
		if (vacuum_bag.atom_storage.attempt_insert(item))
			sucked = TRUE // track that we successfully sucked up something

	// if we did indeed suck up something, play a funny noise
	if (sucked)
		playsound(parent, SFX_RUSTLE, 50, TRUE, -5)

/**
 * Handler for when a new trash bag is attached
 *
 * Arguments:
 * * source - The source of the signal
 * * new_bag - The new bag being installed
 */
/datum/component/vacuum/proc/attach_bag(datum/source, obj/item/storage/bag/trash/new_bag)
	SIGNAL_HANDLER

	vacuum_bag = new_bag
	RegisterSignal(new_bag, COMSIG_QDELETING, PROC_REF(detach_bag))

/**
 * Handler for when a trash bag is detached
 *
 * Arguments:
 * * source - The source of the signal
 */
/datum/component/vacuum/proc/detach_bag(datum/source)
	SIGNAL_HANDLER
	if (vacuum_bag) // null check to avoid runtime on bag being deleted then sending detach as a result from parent
		UnregisterSignal(vacuum_bag, COMSIG_QDELETING)
		vacuum_bag = null
