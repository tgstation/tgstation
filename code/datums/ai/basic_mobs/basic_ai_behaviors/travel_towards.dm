/**
 * # Travel Towards
 * Moves towards the atom in the passed blackboard key.
 * Planning continues during this action so it can be interrupted by higher priority actions.
 */
/datum/ai_behavior/travel_towards
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/travel_towards/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(isnull(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/travel_towards/perform(delta_time, datum/ai_controller/controller, target_key)
	. = ..()
	finish_action(controller, TRUE)

/**
 * # Travel Towards Atom
 * Travel towards an atom you pass directly from the controller rather than a blackboard key.
 * You might need to do this to avoid repeating some checks in both a controller and an action.
 */
/datum/ai_behavior/travel_towards_atom
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/travel_towards_atom/setup(datum/ai_controller/controller, atom/target_atom)
	. = ..()
	if(isnull(target_atom))
		return FALSE
	set_movement_target(controller, target_atom)

/datum/ai_behavior/travel_towards_atom/perform(delta_time, datum/ai_controller/controller, atom/target_atom)
	. = ..()
	finish_action(controller, TRUE)
