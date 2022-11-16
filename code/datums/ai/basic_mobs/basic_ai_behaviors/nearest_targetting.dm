/// Picks targets based on which one is closest to you, choice between targets at equal distance is arbitrary
/datum/ai_behavior/find_potential_targets/nearest

/datum/ai_behavior/find_potential_targets/nearest/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/turf/our_position = get_turf(controller.pawn)

	var/shortest_distance = INFINITY
	var/list/shortest_distance_targets = list()
	for(var/atom/target as anything in filtered_targets)
		var/distance = get_dist(our_position, get_turf(target))
		if (distance > shortest_distance)
			continue
		if (distance < shortest_distance)
			shortest_distance = distance
			shortest_distance_targets = list()
		shortest_distance_targets += target

	var/picked = pick(shortest_distance_targets)
	to_chat(world, "fleeing [picked]")

	return picked

/// As above but targets have been filtered from the 'retaliate' blackboard list
/datum/ai_behavior/target_from_retaliate_list/nearest

/datum/ai_behavior/target_from_retaliate_list/nearest/pick_final_target(datum/ai_controller/controller, list/enemies_list)
	var/turf/our_position = get_turf(controller.pawn)

	var/shortest_distance = INFINITY
	var/list/shortest_distance_targets = list()
	for(var/atom/target as anything in enemies_list)
		var/distance = get_dist(our_position, get_turf(target))
		if (distance > shortest_distance)
			continue
		if (distance < shortest_distance)
			shortest_distance = distance
			shortest_distance_targets = list()
		shortest_distance_targets += target

	return pick(shortest_distance_targets)
