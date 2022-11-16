/// Move to a position further away from your current target
/datum/ai_behavior/run_away_from_target
	required_distance = 0
	action_cooldown = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	/// How far do we try to run?
	var/steps_per_perform = 9

/datum/ai_behavior/run_away_from_target/setup(datum/ai_controller/controller, target_key, hiding_location_key)
	if (!find_escape_route(controller, target_key, hiding_location_key))
		return FALSE
	return ..()

/datum/ai_behavior/run_away_from_target/perform(delta_time, datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	finish_action(controller, TRUE)

/datum/ai_behavior/run_away_from_target/proc/find_escape_route(datum/ai_controller/controller, target_key, hiding_location_key)
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE
	var/turf/target_turf = get_turf(target)
	var/atom/target_destination = get_turf(controller.pawn)
	for (var/i in 1 to steps_per_perform)
		var/atom/new_target = get_step_away(target_destination, target_turf)
		if (new_target)
			target_destination = new_target
	if (!target_destination)
		return FALSE
	controller.current_movement_target = target_destination
	return TRUE
