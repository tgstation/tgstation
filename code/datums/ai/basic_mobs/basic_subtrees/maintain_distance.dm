/// Step away if too close, or towards if too far
/datum/ai_planning_subtree/maintain_distance
	/// Blackboard key holding atom we want to stay away from
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// How close will we allow our target to get?
	var/minimum_distance = 3
	/// How far away will we allow our target to get?
	var/maximum_distance = 6
	/// How far do we look for our target?
	var/view_distance = 10

/datum/ai_planning_subtree/maintain_distance/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if (!isliving(target) || !can_see(controller.pawn, target, view_distance))
		return // Don't run away from cucumbers, they're not snakes
	var/range = get_dist(controller.pawn, target)
	if (range < minimum_distance)
		controller.queue_behavior(/datum/ai_behavior/step_away, target_key)
		return
	if (range > maximum_distance)
		controller.queue_behavior(/datum/ai_behavior/pursue_to_range, target_key, maximum_distance)
		return

/// Take one step away
/datum/ai_behavior/step_away
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	required_distance = 0
	action_cooldown = 0.2 SECONDS

/datum/ai_behavior/step_away/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/atom/current_target = controller.blackboard[target_key]
	if (QDELETED(current_target))
		return FALSE

	var/mob/living/our_pawn = controller.pawn
	our_pawn.face_atom(current_target)

	var/turf/next_step = get_step_away(controller.pawn, current_target)
	if (!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
		set_movement_target(controller, target = next_step, new_movement = /datum/ai_movement/basic_avoidance/backstep)
		return TRUE

	var/list/all_dirs = GLOB.alldirs.Copy()
	all_dirs -= get_dir(controller.pawn, next_step)
	all_dirs -= get_dir(controller.pawn, current_target)
	shuffle_inplace(all_dirs)

	for (var/dir in all_dirs)
		next_step = get_step(controller.pawn, dir)
		if (!isnull(next_step) && !next_step.is_blocked_turf(exclude_mobs = TRUE))
			set_movement_target(controller, target = next_step, new_movement = /datum/ai_movement/basic_avoidance/backstep)
			return TRUE
	return FALSE

/datum/ai_behavior/step_away/perform(seconds_per_tick, datum/ai_controller/controller)
	. = ..()
	finish_action(controller, succeeded = TRUE)

/datum/ai_behavior/step_away/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.change_ai_movement_type(initial(controller.ai_movement))

/// Pursue a target until we are within a provided range
/datum/ai_behavior/pursue_to_range
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION | AI_BEHAVIOR_MOVE_AND_PERFORM

/datum/ai_behavior/pursue_to_range/setup(datum/ai_controller/controller, target_key, range)
	. = ..()
	var/atom/current_target = controller.blackboard[target_key]
	if (QDELETED(current_target))
		return FALSE
	if (get_dist(controller.pawn, current_target) <= range)
		return FALSE
	set_movement_target(controller, current_target)

/datum/ai_behavior/pursue_to_range/perform(seconds_per_tick, datum/ai_controller/controller, target_key, range)
	var/atom/current_target = controller.blackboard[target_key]
	if (!QDELETED(current_target) && get_dist(controller.pawn, current_target) > range)
		return
	finish_action(controller, succeeded = TRUE)
