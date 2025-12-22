/// Allows objects that entered parent's tile to move freely through other objects with this component regardless of density
/datum/element/climb_walkable

/datum/element/climb_walkable/Attach(datum/target)
	. = ..()
	var/static/list/turf_connections = list(
		COMSIG_ATOM_ENTERED= TYPE_PROC_REF(/obj/structure, on_climb_enter),
		COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON = TYPE_PROC_REF(/obj/structure, on_climb_enter),
		COMSIG_ATOM_EXITED = TYPE_PROC_REF(/obj/structure, on_climb_exit),
	)
	target.AddComponent(/datum/component/connect_loc_behalf, target, turf_connections)
	RegisterSignal(target, COMSIG_ATOM_TRIED_PASS, PROC_REF(can_allow_through))

/datum/element/climb_walkable/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_TRIED_PASS)
	for (var/atom/movable/climber in get_turf(source))
		REMOVE_TRAIT(climber, TRAIT_ON_CLIMBABLE, REF(src))

/datum/element/climb_walkable/proc/can_allow_through(datum/source, atom/movable/mover, border_dir)
	SIGNAL_HANDLER
	if(HAS_TRAIT(mover, TRAIT_ON_CLIMBABLE))
		return COMSIG_COMPONENT_PERMIT_PASSAGE

/obj/structure/proc/on_climb_enter(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	ADD_TRAIT(arrived, TRAIT_ON_CLIMBABLE, REF(src))

/obj/structure/proc/on_climb_exit(datum/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	REMOVE_TRAIT(gone, TRAIT_ON_CLIMBABLE, REF(src))
