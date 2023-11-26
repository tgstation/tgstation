//An element that when given to an atom will make it be deleted if it ever leaves the listed areas
/datum/element/area_locked
	///areas we are restricted to
	var/list/allowed_areas = list()
	///whats our last area, used to reduce the amount of checks done
	VAR_PRIVATE/last_area

/datum/element/area_locked/Attach(datum/target, list/allowed_areas)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.allowed_areas = allowed_areas
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_movable_moved))

/datum/element/area_locked/Detach(datum/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/datum/element/area_locked/proc/on_movable_moved(atom/movable/source, atom/oldloc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/area/source_area = get_area(source)
	if(source_area != last_area)
		if(source_area && !is_type_in_list(source_area, allowed_areas))
			qdel(source) //doing it this way may lead to some visual bugs, but it will actually delete the item
			return
		last_area = source_area
