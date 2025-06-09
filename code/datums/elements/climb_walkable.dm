/// Allows objects that entered parent's tile to move freely through other objects with this component regardless of density
/datum/element/climb_walkable

/datum/element/climb_walkable/Attach(datum/parent)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	var/static/list/turf_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter),
		COMSIG_ATOM_EXITED = PROC_REF(on_exit),
	)
	AddComponent(/datum/component/connect_loc_behalf, parent, turf_connections)
	RegisterSignal(parent, COMSIG_ATOM_CAN_ALLOW_THROUGH, PROC_REF(can_allow_through))

/datum/element/climb_walkable/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_CAN_ALLOW_THROUGH)
	for (var/atom/movable/climber in get_turf(parent))
		REMOVE_TRAIT(parent, TRAIT_ON_CLIMBABLE, REF(src))

/datum/element/climb_walkable/proc/on_enter(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	ADD_TRAIT(arrived, TRAIT_ON_CLIMBABLE, REF(src))

/datum/element/climb_walkable/proc/on_exit(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	REMOVE_TRAIT(gone, TRAIT_ON_CLIMBABLE, REF(src))

/datum/element/climb_walkable/proc/can_allow_through(datum/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(HAS_TRAIT(mover, TRAIT_ON_CLIMBABLE))
		return COMSIG_FORCE_ALLOW_THROUGH
