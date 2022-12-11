
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

	RegisterSignals(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_UNBUCKLE, COMSIG_ATOM_NO_LONGER_PULLED), PROC_REF(check_state))

	hyperloop = SSmove_manager.move(moving = parent, direction = direction, delay = not_clinging_move_delay, subsystem = SShyperspace_drift, priority = MOVEMENT_ABOVE_SPACE_PRIORITY, flags = MOVEMENT_LOOP_START_FAST)

	if(is_holding_on(parent) >= CLINGING)
		hyperloop.blocked = TRUE //otherwise we'll get moved 1 tile before we can correct ourselves, which isnt super bad but just looks jank


///Check if we're in hyperspace and our state in hyperspace
/datum/component/shuttle_cling/proc/check_state()
	SIGNAL_HANDLER

	if(!is_on_hyperspace(parent))
		qdel(src)
		return

	hyperloop.blocked = FALSE

	switch(is_holding_on(parent))
		if(SUPER_NOT_HOLDING_ON)
			launch_very_hard(parent)
		if(NOT_HOLDING_ON)
			hyperloop.delay = not_clinging_move_delay
		if(CLINGING)
			hyperloop.delay = clinging_move_delay
		if(ALL_GOOD)
			hyperloop.blocked = TRUE

///Check if we're "holding on" to the shuttle
/datum/component/shuttle_cling/proc/is_holding_on(atom/movable/movee)
	if(movee.pulledby)
		return ALL_GOOD
	if(!isliving(movee))
		return SUPER_NOT_HOLDING_ON

	var/mob/living/living = movee

	//Check if we can interact with stuff (checks for alive, arms, stun, etc)
	if(!living.canUseTopic(living, be_close = TRUE, no_dexterity = FALSE, no_tk = TRUE, need_hands = TRUE))
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

/datum/component/shuttle_cling/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_HYPERSPACED, src)
	QDEL_NULL(hyperloop)

	return ..()

#undef SUPER_NOT_HOLDING_ON
#undef NOT_HOLDING_ON
#undef CLINGING
#undef ALL_GOOD
