/// Finds the best adjacent turf to flee to away from a threat and stores it in a blackboard key.
/// Tries get_step_away first, then falls back to shuffled directions if blocked.
/// Returns INSTANT SUCCESS if a step was found, INSTANT FAILURE if completely cornered.
/datum/bt_node/ai_behavior/find_flee_location
	var/target_key
	var/hiding_location_key
	var/destination_key

/datum/bt_node/ai_behavior/find_flee_location/perform(seconds_per_tick, datum/ai_controller/controller)
	var/run_distance = controller.blackboard[BB_BASIC_MOB_FLEE_DISTANCE] || DEFAULT_BASIC_FLEE_DISTANCE
	var/atom/target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	if(QDELETED(target) || !can_see(controller.pawn, target, run_distance))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/turf/flee_turf = get_flee_step(controller, target)
	if(!flee_turf)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	controller.set_blackboard_key(destination_key, flee_turf)
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

/datum/bt_node/ai_behavior/find_flee_location/proc/get_flee_step(datum/ai_controller/controller, atom/target)
	var/mob/living/pawn = controller.pawn
	var/turf/pawn_turf = get_turf(pawn)
	var/datum/can_pass_info/pass_info = new(pawn, controller.get_access())
	var/turf/next_step = get_step_away(pawn, target)
	if(!isnull(next_step) && next_step != pawn_turf && !next_step.density && !pawn_turf.LinkBlockedWithAccess(next_step, pass_info))
		return next_step
	var/list/all_dirs = GLOB.alldirs.Copy()
	all_dirs -= get_dir(pawn, next_step)
	all_dirs -= get_dir(pawn, target)
	shuffle_inplace(all_dirs)
	for(var/dir in all_dirs)
		next_step = get_step(pawn, dir)
		if(!isnull(next_step) && !next_step.density && !pawn_turf.LinkBlockedWithAccess(next_step, pass_info))
			return next_step
	return null
