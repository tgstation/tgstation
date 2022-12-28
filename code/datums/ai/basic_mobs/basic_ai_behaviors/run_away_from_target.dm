/// Move to a position further away from your current target
/datum/ai_behavior/run_away_from_target
	required_distance = 0
	action_cooldown = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// How far do we try to run? Further makes for smoother running, but potentially weirder pathfinding
	var/run_distance = 9

/datum/ai_behavior/run_away_from_target/setup(datum/ai_controller/controller, target_key, hiding_location_key)
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE

	plot_path_away_from(controller, target)
	return ..()

/datum/ai_behavior/run_away_from_target/perform(delta_time, datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	var/escaped =  !target || !can_see(controller.pawn, target, run_distance) // If we can't see it we got away
	if (escaped)
		finish_action(controller, succeeded = TRUE, target_key = target_key, hiding_location_key = hiding_location_key)
		return
	if (!in_range(controller.pawn, controller.current_movement_target))
		return
	plot_path_away_from(controller, target)

/datum/ai_behavior/run_away_from_target/proc/plot_path_away_from(datum/ai_controller/controller, atom/target)
	var/run_direction = get_dir(controller.pawn, get_step_away(controller.pawn, target))
	var/turf/target_destination = get_ranged_target_turf(controller.pawn, run_direction, run_distance)
	set_movement_target(controller, target_destination)

/datum/ai_behavior/run_away_from_target/finish_action(datum/ai_controller/controller, succeeded, target_key, hiding_location_key)
	. = ..()
	controller.blackboard[target_key] = null
