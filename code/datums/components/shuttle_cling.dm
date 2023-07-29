
//Below defines are for the is_holding_on proc to see how well they're holding on and respond accordingly
///Instead of a high move force we just get launched away dramatically because we're that hopeless
#define SUPER_NOT_HOLDING_ON 0
///We're not holdin on and will get thrown off
#define NOT_HOLDING_ON 1
///We're holding on, but will be pulled slowly
#define CLINGING 2
///We're holding on really well and aren't suffering from any pull
#define ALL_GOOD 3

///Gets added to all movables that enter hyperspace and are supposed to suffer from "hyperspace drift"
///This lets people fly around shuttles during transit using jetpacks, or cling to the side if they got a spacesuit
///Dumping into deepspace is handled by the hyperspace turf, not the component.
///Not giving something this component while on hyperspace is safe, it just means free movement like carps
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

	RegisterSignals(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_UNBUCKLE, COMSIG_ATOM_NO_LONGER_PULLED), PROC_REF(update_state))
	RegisterSignal(parent, SIGNAL_REMOVETRAIT(TRAIT_FREE_HYPERSPACE_MOVEMENT), PROC_REF(initialize_loop))
	RegisterSignal(parent, SIGNAL_ADDTRAIT(TRAIT_FREE_HYPERSPACE_MOVEMENT), PROC_REF(clear_loop))

	//Items have this cool thing where they're first put on the floor if you grab them from storage, and then into your hand, which isn't caught by movement signals that well
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, PROC_REF(do_remove))

	if(!HAS_TRAIT(parent, TRAIT_FREE_HYPERSPACE_MOVEMENT))
		initialize_loop()

	update_state(parent) //otherwise we'll get moved 1 tile before we can correct ourselves, which isnt super bad but just looks jank

/datum/component/shuttle_cling/proc/initialize_loop()
	hyperloop = SSmove_manager.move(moving = parent, direction = direction, delay = not_clinging_move_delay, subsystem = SShyperspace_drift, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_NO_DIR_UPDATE|MOVEMENT_LOOP_OUTSIDE_CONTROL)
	update_state()

/datum/component/shuttle_cling/proc/clear_loop()
	QDEL_NULL(hyperloop)

///Check if we're in hyperspace and our state in hyperspace
/datum/component/shuttle_cling/proc/update_state()
	SIGNAL_HANDLER

	if(!is_on_hyperspace(parent))
		qdel(src)
		return

	if(!hyperloop)
		return

	var/should_loop = FALSE

	switch(is_holding_on(parent))
		if(SUPER_NOT_HOLDING_ON)
			launch_very_hard(parent)
			should_loop = TRUE
		if(NOT_HOLDING_ON)
			hyperloop.set_delay(not_clinging_move_delay)
			should_loop = TRUE
			hyperloop.direction = direction //we're not close to anything so reset direction if we got diagonalized
		if(CLINGING)
			hyperloop.set_delay(clinging_move_delay)
			should_loop = TRUE
			update_drift_direction(parent)
		if(ALL_GOOD)
			should_loop = FALSE

	//Do pause/unpause/nothing for the hyperloop
	if(should_loop && hyperloop.paused)
		hyperloop.resume_loop()
	else if(!should_loop && !hyperloop.paused)
		hyperloop.pause_loop()

///Check if we're "holding on" to the shuttle
/datum/component/shuttle_cling/proc/is_holding_on(atom/movable/movee)
	if(movee.pulledby || !isturf(movee.loc) || HAS_TRAIT(movee, TRAIT_FREE_HYPERSPACE_MOVEMENT))
		return ALL_GOOD

	if(!isliving(movee))
		if(is_tile_solid(get_step(movee, direction))) //something is blocking us so do the cool drift
			return CLINGING
		return SUPER_NOT_HOLDING_ON

	var/mob/living/living = movee

	//Check if we can interact with stuff (checks for alive, arms, stun, etc)
	if(!living.can_perform_action(living, FORBID_TELEKINESIS_REACH|NEED_HANDS))
		return NOT_HOLDING_ON

	if(living.buckled)
		return ALL_GOOD

	for(var/atom/handlebar in range(living, 1))
		if(isclosedturf(handlebar))
			return CLINGING
		if(isobj(handlebar))
			var/obj/object = handlebar
			if(object.anchored && object.density)
				return CLINGING
	return NOT_HOLDING_ON

///Are we on a hyperspace tile? There's some special bullshit with lattices so we just wrap this check
/datum/component/shuttle_cling/proc/is_on_hyperspace(atom/movable/clinger)
	if(istype(clinger.loc, hyperspace_type) && !(locate(/obj/structure/lattice) in clinger.loc))
		return TRUE
	return FALSE

///Launch the atom very hard, away from hyperspace
/datum/component/shuttle_cling/proc/launch_very_hard(atom/movable/byebye)
	byebye.safe_throw_at(get_edge_target_turf(byebye, direction), 200, 1, spin = TRUE, force = MOVE_FORCE_EXTREMELY_STRONG)

///Check if we arent just being blocked, and if we are give us some diagonal push so we cant just infinitely cling to the front
/datum/component/shuttle_cling/proc/update_drift_direction(atom/movable/clinger)
	var/turf/potential_blocker = get_step(clinger, direction)
	//We are not being blocked, so just give us cardinal drift
	if(!is_tile_solid(potential_blocker))
		hyperloop.direction = direction
		return

	//We're already moving diagonally
	if(hyperloop.direction != direction)
		var/side_dir = hyperloop.direction - direction

		if(is_tile_solid(get_step(clinger, side_dir)))
			hyperloop.direction = direction + REVERSE_DIR(side_dir) //We're bumping a wall to the side, so switch to the other side_dir (yes this adds pingpong protocol)
		return

	//Get the directions from the side of our current drift direction (so if we have drift south, get all cardinals and remove north and south, leaving only east and west)
	var/side_dirs = shuffle(GLOB.cardinals - direction - REVERSE_DIR(direction))

	//We check if one side is solid
	if(!is_tile_solid(get_step(clinger, side_dirs[1])))
		hyperloop.direction = direction + side_dirs[1]
	else //if one side isnt solid, send it to the other side (it can also be solid but we dont care cause we're boxed in then and not like itll matter much then)
		hyperloop.direction = direction + side_dirs[2]

///Check if it's a closed turf or contains a dense object
/datum/component/shuttle_cling/proc/is_tile_solid(turf/maybe_solid)
	if(isclosedturf(maybe_solid))
		return TRUE
	for(var/obj/blocker in maybe_solid.contents)
		if(blocker.density)
			return TRUE
	return FALSE

///This is just for signals and doesn't run for most removals, so dont add behaviour here expecting it to do much
/datum/component/shuttle_cling/proc/do_remove()
	SIGNAL_HANDLER

	qdel(src)

/datum/component/shuttle_cling/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_HYPERSPACED, src)
	QDEL_NULL(hyperloop)

	return ..()

#undef SUPER_NOT_HOLDING_ON
#undef NOT_HOLDING_ON
#undef CLINGING
#undef ALL_GOOD
