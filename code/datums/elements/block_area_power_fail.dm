// Used to differentiate what is protecting an area
#define AREA_TRAIT_SOURCE(the_source) "[type]_[the_source.type]"
#define MOVABLE_TRAIT_SOURCE(the_source) "[type]_[REF(the_source)]"
#define TURF_TRAIT_SOURCE(the_source) "[type]_[the_source.x]-[the_source.y]-[the_source.z]"

/**
 * ## block_area_power_fail
 *
 * Element that interacts with the grid check event (and similar effects) to protect certain rooms
 *
 * * Attach to an area to prevent arbitrary power outages from affecting it
 * * Attach to a movable to prevent arbitrary power outages from affecting the area it's in
 * * Attach to a turf to prevent arbitrary power outages from affecting its area
 */
/datum/element/block_area_power_fail
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/block_area_power_fail/Attach(datum/target)
	. = ..()
	if(isarea(target)) // practically just a complicated way to do add trait
		ADD_TRAIT(target, TRAIT_AREA_BLOCK_POWER_FAIL, AREA_TRAIT_SOURCE(target))

	else if(ismovable(target)) // manages adding and removing the trait as the movable moves
		var/atom/movable/movable_target = target
		movable_target.become_area_sensitive(type)
		RegisterSignal(target, COMSIG_ENTER_AREA, PROC_REF(on_movable_entered_area))
		RegisterSignal(target, COMSIG_EXIT_AREA, PROC_REF(on_movable_exited_area))
		on_movable_entered_area(target, get_area(movable_target))

	else if(isturf(target)) // turfs don't move so it just adds the trait to the turf's area
		var/turf/turf_target = target
		ADD_TRAIT(turf_target.loc, TRAIT_AREA_BLOCK_POWER_FAIL, TURF_TRAIT_SOURCE(turf_target))

	else
		return ELEMENT_INCOMPATIBLE

/datum/element/block_area_power_fail/Detach(datum/source)
	. = ..()
	if(isarea(source))
		REMOVE_TRAIT(source, TRAIT_AREA_BLOCK_POWER_FAIL, AREA_TRAIT_SOURCE(source))

	else if(ismovable(source))
		var/atom/movable/movable_source = source
		movable_source.lose_area_sensitivity(type)
		UnregisterSignal(source, COMSIG_ENTER_AREA)
		UnregisterSignal(source, COMSIG_EXIT_AREA)
		on_movable_exited_area(source, get_area(movable_source))

	else if(isturf(source))
		var/turf/turf_source = source
		REMOVE_TRAIT(turf_source.loc, TRAIT_AREA_BLOCK_POWER_FAIL, TURF_TRAIT_SOURCE(turf_source))

/datum/element/block_area_power_fail/proc/on_movable_entered_area(atom/movable/source, area/new_area)
	SIGNAL_HANDLER

	if(new_area)
		ADD_TRAIT(new_area, TRAIT_AREA_BLOCK_POWER_FAIL, MOVABLE_TRAIT_SOURCE(source))

/datum/element/block_area_power_fail/proc/on_movable_exited_area(atom/movable/source, area/old_area)
	SIGNAL_HANDLER

	if(old_area)
		REMOVE_TRAIT(old_area, TRAIT_AREA_BLOCK_POWER_FAIL, MOVABLE_TRAIT_SOURCE(source))

#undef AREA_TRAIT_SOURCE
#undef MOVABLE_TRAIT_SOURCE
#undef TURF_TRAIT_SOURCE
