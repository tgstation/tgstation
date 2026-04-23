/// Scan and copies the nearest object. The copy copies no functionality, only visually
/datum/gizmodes/copier
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/scan,
		/datum/gizpulse/copy,
		/datum/gizpulse/erase,
	)

	/// Weakref of what is marked to copy
	var/datum/weakref/marked
	/// List of copies currently in circulation (all weakrefs)
	var/list/copies = list()

/// Scan the nearest mob/object
/datum/gizpulse/scan/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/copier))
		return

	var/datum/gizmodes/copier/copier = master

	for(var/atom/movable/candidate in oview(1, holder))
		if(candidate.anchored) // skips most undertile and hidden objects
			continue

		copier.marked = WEAKREF(candidate)
		playsound(src, 'sound/machines/ping.ogg', 50)
		return

/// Make a copy of whatever you previously scanned
/datum/gizpulse/copy/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/copier))
		return

	var/datum/gizmodes/copier/copier = master

	var/atom/movable/object_to_copy = copier.marked?.resolve()

	if(!object_to_copy)
		return

	// So you can pick up copied items but not copied structures and mobs
	var/obj/copy = /obj/structure/gizmo_copy
	if(isitem(object_to_copy))
		copy = /obj/item/gizmo_copy

	copy = new copy (get_turf(holder))
	copy.appearance = object_to_copy
	copy.density = object_to_copy.density

	copier.copies.Add(WEAKREF(copy))

/// Wipe all current copies
/datum/gizpulse/erase/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	if(!istype(master, /datum/gizmodes/copier))
		return

	var/datum/gizmodes/copier/copier = master

	for(var/datum/weakref/ref as anything in copier.copies)
		var/obj/item/gizmo_copy/copy = ref?.resolve()
		if(copy)
			qdel(copy)

	copier.copies.Cut()

/obj/item/gizmo_copy/emp_act(severity)
	. = ..()
	qdel(src)

/obj/structure/gizmo_copy/emp_act(severity)
	. = ..()
	qdel(src)
