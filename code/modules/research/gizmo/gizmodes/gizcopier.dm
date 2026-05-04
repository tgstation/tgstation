/// Scan and copies the nearest object. The copy copies no functionality, only visually
/datum/gizmodes/copier
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/scan,
		/datum/gizpulse/copy,
		/datum/gizpulse/erase,
	)

	/// Weakref of what is marked to copy
	var/datum/weakref/marked
	/// List of copies currently in circulation
	var/list/copies = list()
	/// The max amount of copies that can exist at a time
	var/max_copies = 50

/// Scan the nearest mob/object
/datum/gizpulse/scan/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/copier))
		return

	var/datum/gizmodes/copier/copier = master

	for(var/atom/movable/candidate in oview(1, holder))
		if(candidate.anchored || HAS_TRAIT(candidate, TRAIT_UNDERFLOOR)) // skips most undertile and hidden objects
			continue

		copier.marked = WEAKREF(candidate)
		playsound(src, 'sound/items/weapons/flash.ogg', 80) //give some feedback that *something* happened
		return

/// Make a copy of whatever you previously scanned
/datum/gizpulse/copy
	/// Reference to the gizmodes' copies list so we can track deletions
	var/list/copies

/datum/gizpulse/copy/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/copier))
		return

	var/datum/gizmodes/copier/copier = master
	copies = copier.copies

	var/atom/movable/object_to_copy = copier.marked?.resolve()

	if(!object_to_copy)
		return

	// So you can pick up copied items but not copied structures and mobs
	var/obj/item/copy = new /obj/item/gizmo_copy (get_turf(holder))
	if(!isitem(object_to_copy))
		copy.interaction_flags_item = NONE //so you cant pick it up anymore

	copy.appearance = object_to_copy
	copy.density = object_to_copy.density

	copies.Add(copy)

	if(copies.len > copier.max_copies)
		var/obj/item/gizmo_copy/copy_to_delete = copies[1]
		qdel(copy_to_delete) //it gets removed from the list on del

	RegisterSignal(copy, COMSIG_ATOM_DESTRUCTION, PROC_REF(remove_from_list))

/// Remove a copy from a list if they're deleted
/datum/gizpulse/copy/proc/remove_from_list(datum/source)
	SIGNAL_HANDLER

	copies.Remove(source)

/// Wipe all current copies
/datum/gizpulse/erase/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/copier))
		return

	var/datum/gizmodes/copier/copier = master

	for(var/copy in copier.copies)
		qdel(copy)

	copier.copies.Cut()

/obj/item/gizmo_copy/emp_act(severity)
	. = ..()

	do_sparks(2, FALSE, "gizmo copy")
	qdel(src)
