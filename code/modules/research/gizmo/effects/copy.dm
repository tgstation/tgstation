/// Scan the nearest mob/object
/datum/gizmo_effect/scan/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmo_effect_combination/copier))
		return

	var/datum/gizmo_effect_combination/copier/copier = master

	for(var/atom/movable/candidate in oview(1, holder))
		if(candidate.anchored || HAS_TRAIT(candidate, TRAIT_UNDERFLOOR)) // skips most undertile and hidden objects
			continue

		copier.marked = WEAKREF(candidate)
		playsound(src, 'sound/items/weapons/flash.ogg', 80) //give some feedback that *something* happened
		return

/// Make a copy of whatever you previously scanned
/datum/gizmo_effect/copy
	/// Reference to the gizmodes' copies list so we can track deletions
	var/list/copies

/datum/gizmo_effect/copy/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmo_effect_combination/copier))
		return

	var/datum/gizmo_effect_combination/copier/copier = master
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

	RegisterSignal(copy, COMSIG_QDELETING, PROC_REF(remove_from_list))

/// Remove a copy from a list if they're deleted
/datum/gizmo_effect/copy/proc/remove_from_list(datum/source)
	SIGNAL_HANDLER

	copies.Remove(source)

/// Wipe all current copies
/datum/gizmo_effect/erase/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmo_effect_combination/copier))
		return

	var/datum/gizmo_effect_combination/copier/copier = master

	for(var/copy in copier.copies)
		qdel(copy)

	copier.copies.Cut()

/obj/item/gizmo_copy/emp_act(severity)
	. = ..()

	do_sparks(2, FALSE, "gizmo copy")
	qdel(src)
