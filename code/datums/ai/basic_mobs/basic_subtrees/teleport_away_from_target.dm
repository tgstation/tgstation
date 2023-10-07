///behavior to activate ability to escape from target
/datum/ai_planning_subtree/teleport_away_from_target
	///minimum distance away from the target before we execute behavior
	var/minimum_distance = 2
	///the ability we will execute
	var/ability_key

/datum/ai_planning_subtree/teleport_away_from_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/distance_from_target = get_dist(target, controller.pawn)
	if(distance_from_target >= minimum_distance)
		controller.clear_blackboard_key(BB_ESCAPE_DESTINATION)
		return
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	if(!ability?.IsAvailable())
		return
	var/turf/location_turf = controller.blackboard[BB_ESCAPE_DESTINATION]

	if(isnull(location_turf))
		controller.queue_behavior(/datum/ai_behavior/find_furthest_turf_from_target, BB_BASIC_MOB_CURRENT_TARGET, BB_ESCAPE_DESTINATION, minimum_distance)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(get_dist(location_turf, target) < minimum_distance || !can_see(controller.pawn, location_turf)) //target moved close too close or we moved too far since finding the target turf
		controller.clear_blackboard_key(BB_ESCAPE_DESTINATION)
		return

	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target, ability_key, BB_ESCAPE_DESTINATION)

///find furtherst turf target so we may teleport to it
/datum/ai_behavior/find_furthest_turf_from_target

/datum/ai_behavior/find_furthest_turf_from_target/perform(seconds_per_tick, datum/ai_controller/controller, target_key, set_key, range)
	var/mob/living/living_target = controller.blackboard[target_key]
	if(QDELETED(living_target))
		return

	var/distance = 0
	var/turf/chosen_turf
	for(var/turf/open/potential_destination in oview(range, living_target))
		if(potential_destination.is_blocked_turf())
			continue
		var/new_distance_to_target = get_dist(potential_destination, living_target)
		if(new_distance_to_target > distance)
			chosen_turf = potential_destination
			distance = new_distance_to_target
		if(distance == range)
			break //we have already found the max distance

	if(isnull(chosen_turf))
		finish_action(controller, FALSE)
		return

	controller.set_blackboard_key(set_key, chosen_turf)
	finish_action(controller, TRUE)
