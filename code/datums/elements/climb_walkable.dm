/// Allows objects that entered parent's tile to move freely through other objects with this component regardless of density
/datum/element/climb_walkable
	var/static/list/turf_connections = list(
		COMSIG_ATOM_ENTERED = TYPE_PROC_REF(/obj/structure, on_climb_enter),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = TYPE_PROC_REF(/obj/structure, on_climb_enter),
		COMSIG_ATOM_EXITED = TYPE_PROC_REF(/obj/structure, on_climb_exit),
	)

/datum/element/climb_walkable/Attach(datum/target)
	. = ..()
	target.AddElement(/datum/element/connect_loc, turf_connections)
	RegisterSignal(target, COMSIG_ATOM_TRIED_PASS, PROC_REF(can_allow_through))
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_climbable_moved))

/datum/element/climb_walkable/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_TRIED_PASS, COMSIG_MOVABLE_MOVED))
	for (var/atom/movable/climber in get_turf(source))
		if(HAS_TRAIT(climber, TRAIT_ON_CLIMBABLE))
			REMOVE_TRAIT(climber, TRAIT_ON_CLIMBABLE, ELEMENT_TRAIT(type))
	source.RemoveElement(/datum/element/connect_loc, turf_connections)

/datum/element/climb_walkable/proc/can_allow_through(datum/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(HAS_TRAIT(mover, TRAIT_ON_CLIMBABLE))
		return COMSIG_COMPONENT_PERMIT_PASSAGE

// Removes the climbable trait if the crate or whatever it is gets pushed away.
/datum/element/climb_walkable/proc/on_climbable_moved(datum/source, atom/old_loc)
	SIGNAL_HANDLER
	for (var/atom/movable/climber in get_turf(old_loc))
		if(HAS_TRAIT(climber, TRAIT_ON_CLIMBABLE))
			REMOVE_TRAIT(climber, TRAIT_ON_CLIMBABLE, ELEMENT_TRAIT(type))

/obj/structure/proc/on_climb_enter(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(arrived.density)
		ADD_TRAIT(arrived, TRAIT_ON_CLIMBABLE, ELEMENT_TRAIT(/datum/element/climb_walkable))

/obj/structure/proc/on_climb_exit(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(HAS_TRAIT(gone, TRAIT_ON_CLIMBABLE))
		REMOVE_TRAIT(gone, TRAIT_ON_CLIMBABLE, ELEMENT_TRAIT(/datum/element/climb_walkable))
