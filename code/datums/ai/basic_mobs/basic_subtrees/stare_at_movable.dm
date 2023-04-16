/// Locate a movable to stop and stare at.
/datum/ai_behavior/stare_at_movable
	action_cooldown = 5 SECONDS
	behavior_flags = AI_BEHAVIOR_MOVE_AND_PERFORM

	/// How long are we meant to stop for?
	var/seconds_to_stop_for = 5 SECONDS
	/// List of stuff that we are meant to stop at and stare at. Only modify on subtypes.
	var/list/movables_of_interest = list()
	/// Typecache of movables_of_interest, do not modify outside of setup.
	var/list/movables_typecache = list()

/datum/ai_behavior/stare_at_movable/setup(datum/ai_controller/controller)
	if(!length(movables_of_interest))
		stack_trace("No movables_of_interest set for [type] behavior.")
		return FALSE

	if(!length(movables_typecache))
		movables_typecache = typecacheof(movables_of_interest)

	return ..()


/datum/ai_behavior/stare_at_movable/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/atom/target = weak_target?.resolve()

	if(!ismovable(target))
		return

	var/atom/movable/movable_target = target
	if(!is_type_in_typecache(movable_target, movables_of_interest))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/in_list, BB_BASIC_MOB_CURRENT_TARGET, movables_of_interest)
		return

	controller.blackboard[BB_STATIONARY_SECONDS] = seconds_to_stop_for
	controller.queue_behavior(/datum/ai_behavior/stop_and_stare, BB_BASIC_MOB_CURRENT_TARGET)

