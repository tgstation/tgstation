/// Move to a position further away from your current target
/datum/ai_behavior/run_away_from_target
	required_distance = 0
	action_cooldown = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	/// How far do we try to run? Further makes for smoothe running, but potentially weirder pathfinding
	var/run_distance = 9

/datum/ai_behavior/run_away_from_target/setup(datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE

	var/run_direction = get_dir(controller.pawn, get_step_away(controller.pawn, target))
	var/turf/target_destination = get_ranged_target_turf(controller.pawn, run_direction, run_distance)
	if (!target_destination)
		return FALSE

	controller.current_movement_target = target_destination

/datum/ai_behavior/run_away_from_target/perform(delta_time, datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	finish_action(controller, TRUE)
