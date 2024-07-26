/**
 * # Travel Towards
 * Moves towards the atom in the passed blackboard key.
 * Planning continues during this action so it can be interrupted by higher priority actions.
 */
/datum/ai_behavior/travel_towards
	required_distance = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// If true we will get rid of our target on completion
	var/clear_target = FALSE
	///should we use a different movement type?
	var/new_movement_type

/datum/ai_behavior/travel_towards/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target, new_movement_type)

/datum/ai_behavior/travel_towards/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/ai_behavior/travel_towards/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	if (clear_target)
		controller.clear_blackboard_key(target_key)
	if(new_movement_type)
		controller.change_ai_movement_type(initial(controller.ai_movement))

/datum/ai_behavior/travel_towards/stop_on_arrival
	clear_target = TRUE

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

/datum/ai_behavior/travel_towards_atom/perform(seconds_per_tick, datum/ai_controller/controller, atom/target_atom)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
