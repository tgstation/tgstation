/datum/component/shuttle_cling
	var/direction
	var/hyperspace_type = /turf/open/space/transit
	var/datum/move_loop/move/hyperloop

	var/clinging_move_delay = 1 SECONDS
	var/not_clinging_move_delay = 0.1 SECONDS

/datum/component/shuttle_cling/Initialize(direction)
	. = ..()

	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.direction = direction

	ADD_TRAIT(parent, TRAIT_HYPERSPACED, src)

	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(check_state))
	hyperloop = SSmove_manager.move(moving = parent, direction = turn(direction, 180), delay = not_clinging_move_delay, subsystem = SShyperspace_drift, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)

/datum/component/shuttle_cling/proc/check_state()
	SIGNAL_HANDLER

	if(!is_on_hyperspace(parent))
		qdel(src)

	if(!is_holding_on(parent))
		hyperloop.delay = not_clinging_move_delay
	else
		hyperloop.delay = clinging_move_delay

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

/datum/component/shuttle_cling/proc/is_on_hyperspace(atom/movable/clinger)
	if(istype(clinger.loc, hyperspace_type) && !(locate(/obj/structure/lattice) in clinger.loc))
		return TRUE
	return FALSE

/datum/component/shuttle_cling/proc/launch_very_hard(atom/movable/byebye)
	var/turf/throw_target = get_edge_target_turf(byebye, turn(direction, 180))
	//byebye.safe_throw_at(throw_target, 200, 1, spin = FALSE, force = MOVE_FORCE_EXTREMELY_STRONG)

/datum/component/shuttle_cling/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_HYPERSPACED, src)
	qdel(hyperloop)

	return ..()


