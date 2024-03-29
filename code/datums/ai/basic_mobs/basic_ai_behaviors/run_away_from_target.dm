/// Move to a position further away from your current target
/datum/ai_behavior/run_away_from_target
	required_distance = 0
	action_cooldown = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_MOVE_AND_PERFORM | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	/// How far do we try to run? Further makes for smoother running, but potentially weirder pathfinding
	var/run_distance = DEFAULT_BASIC_FLEE_DISTANCE
	/// Clear target if we finish the action unsuccessfully
	var/clear_failed_targets = TRUE

/datum/ai_behavior/run_away_from_target/setup(datum/ai_controller/controller, target_key, hiding_location_key)
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	run_distance = controller.blackboard[BB_BASIC_MOB_FLEE_DISTANCE] || initial(run_distance)
	if(!plot_path_away_from(controller, target))
		return FALSE
	return ..()

/datum/ai_behavior/run_away_from_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	if (controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if (QDELETED(target) || !can_see(controller.pawn, target, run_distance))
		finish_action(controller, succeeded = TRUE, target_key = target_key, hiding_location_key = hiding_location_key)
		return
	if (get_dist(controller.pawn, controller.current_movement_target) > required_distance)
		return // Still heading over
	if (plot_path_away_from(controller, target))
		return
	finish_action(controller, succeeded = FALSE, target_key = target_key, hiding_location_key = hiding_location_key)

/datum/ai_behavior/run_away_from_target/proc/plot_path_away_from(datum/ai_controller/controller, atom/target)
	var/turf/target_destination = get_turf(controller.pawn)
	var/static/list/offset_angles = list(45, 90, 135, 180, 225, 270)
	for(var/angle in offset_angles)
		var/turf/test_turf = get_furthest_turf(controller.pawn, angle, target)
		if(isnull(test_turf))
			continue
		var/distance_from_target = get_dist(target, test_turf)
		if(distance_from_target <= get_dist(target, target_destination))
			continue
		target_destination = test_turf
		if(distance_from_target == run_distance) //we already got the max running distance
			break

	if (target_destination == get_turf(controller.pawn))
		return FALSE
	set_movement_target(controller, target_destination)
	return TRUE

/datum/ai_behavior/run_away_from_target/proc/get_furthest_turf(atom/source, angle, atom/target)
	var/turf/return_turf
	var/list/airlocks = SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/door/airlock)
	for(var/i in 1 to run_distance)
		var/turf/test_destination = get_ranged_target_turf_direct(source, target, range = i, offset = angle)
		if(test_destination.is_blocked_turf(source_atom = source, ignore_atoms = airlocks))
			break
		return_turf = test_destination
	return return_turf

/datum/ai_behavior/run_away_from_target/finish_action(datum/ai_controller/controller, succeeded, target_key, hiding_location_key)
	. = ..()
	if (clear_failed_targets)
		controller.clear_blackboard_key(target_key)
