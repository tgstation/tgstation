/datum/component/shuttle_cling
	///The direction we push stuff towards
	var/direction
	///Path to the hyperspace tile, so we know if we're in hyperspace
	var/hyperspace_type = /turf/open/space/transit

	///Our moveloop, handles the transit pull
	var/datum/move_loop/move/hyperloop

	///If we can "hold on", how often do we move?
	var/clinging_move_delay = 1 SECONDS
	///If we can't hold onto anything, how fast do we get pulled away?
	var/not_clinging_move_delay = 0.2 SECONDS

/datum/component/shuttle_cling/Initialize(direction)
	. = ..()

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.direction = direction

	ADD_TRAIT(parent, TRAIT_HYPERSPACED, src)

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_state))
	hyperloop = SSmove_manager.move(moving = parent, direction = direction, delay = not_clinging_move_delay, subsystem = SShyperspace_drift, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)

///Check if we're in hyperspace and our state in hyperspace
/datum/component/shuttle_cling/proc/check_state(atom/movable/movee, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if(!is_on_hyperspace(parent))
		qdel(src)

	if(!is_holding_on(parent))
		hyperloop.delay = not_clinging_move_delay
	else
		hyperloop.delay = clinging_move_delay

///Check if we're "holding on" to the shuttle
/datum/component/shuttle_cling/proc/is_holding_on(atom/movable/clinger)
	if(!isliving(clinger))
		return FALSE

	for(var/atom/handlebar in range(clinger, 1))
		if(isclosedturf(handlebar))
			return TRUE
		if(isobj(handlebar))
			var/obj/object = handlebar
			if(object.anchored && object.density)
				return TRUE
	return FALSE

///Are we on a hyperspace tile? There's some special bullshit with lattices so we just wrap this check
/datum/component/shuttle_cling/proc/is_on_hyperspace(atom/movable/clinger)
	if(istype(clinger.loc, hyperspace_type) && !(locate(/obj/structure/lattice) in clinger.loc))
		return TRUE
	return FALSE

/datum/component/shuttle_cling/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_HYPERSPACED, src)
	qdel(hyperloop)

	return ..()
