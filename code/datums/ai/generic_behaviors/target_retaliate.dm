
///Pick a target from our retaliate list
/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list
	target_source = /datum/target_source/from_bb_list/retaliate_list
	revalidation_mode = TARGET_REVALIDATE
	time_between_perform = 2 SECONDS
	vision_range = 9
	/// Blackboard key in which to store the target's hiding location.
	var/hiding_location_key
	/// If FALSE, temporarily ignores faction during the search.
	var/check_faction = FALSE

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!check_faction) // This is lame, but comeon man the polar bears kept killing each other
		controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, TRUE)
	. = ..()
	var/usually_ignores_faction = controller.blackboard[BB_ALWAYS_IGNORE_FACTION] || FALSE
	controller.set_blackboard_key(BB_TEMPORARILY_IGNORE_FACTION, usually_ignores_faction)

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/filter_candidates(datum/ai_controller/controller, list/candidates, datum/targeting_strategy/strategy, atom/current_target)
	var/mob/living/pawn = controller.pawn
	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[BB_TARGET_PRIORITY_STRATEGY])
	var/current_priority = priority_strategy ? priority_strategy.get_target_priority(controller, current_target) : 0
	var/list/filtered = list()
	for(var/atom/candidate as anything in candidates)
		if(!strategy.is_valid_target(pawn, candidate, vision_range, controller))
			continue
		if(priority_strategy && priority_strategy.get_target_priority(controller, candidate) < current_priority)
			continue
		filtered += candidate
	return filtered

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	var/atom/hiding = strategy.find_hidden_mobs(controller.pawn, target)
	if(hiding)
		controller.set_blackboard_key(hiding_location_key, hiding)

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/on_no_valid_candidates(datum/ai_controller/controller, atom/current_target)
	if(current_target)
		controller.clear_blackboard_key(target_key)

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/datum/target_priority_strategy/priority_strategy = GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[BB_TARGET_PRIORITY_STRATEGY])
	if(!priority_strategy)
		return pick(filtered_targets)
	return priority_strategy.select_target(controller, filtered_targets)

/// Nearest-attacker variant
/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/nearest

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/nearest/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	var/turf/our_position = get_turf(controller.pawn)
	return get_closest_atom(/atom/, filtered_targets, our_position)
