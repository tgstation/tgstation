//An element that when given to an atom will make it be deleted if it ever leaves the listed areas
/datum/element/area_locked
	///areas we are restricted to
	var/list/allowed_areas = list()
	///whats our last area, used to reduce the amount of checks done
	VAR_PRIVATE/last_area

/datum/element/area_locked/Attach(atom/movable/target, list/allowed_areas)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.allowed_areas = allowed_areas
	RegisterSignal(target, COMSIG_ENTER_AREA, PROC_REF(on_enter_area))
	target.become_area_sensitive(REF(src))

/datum/element/area_locked/Detach(atom/movable/source, ...)
	. = ..()

	UnregisterSignal(source, COMSIG_ENTER_AREA)
	source.lose_area_sensitivity(REF(src))

/datum/element/area_locked/proc/on_enter_area(atom/movable/source, area/new_area)
	SIGNAL_HANDLER

	if(new_area != last_area)
		if(new_area && !is_type_in_list(new_area, allowed_areas))
			source.lose_area_sensitivity(REF(src))
			qdel(source)
			return
		last_area = new_area
