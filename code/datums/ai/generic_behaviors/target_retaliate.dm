
///Pick a target from our retaliate list
/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list
	target_source = /datum/target_source/from_bb_list/retaliate_list
	target_priority_strategy = BB_TARGET_PRIORITY_STRATEGY
	revalidation_mode = TARGET_RESELECT_WITH_SELECTION
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

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	var/atom/hiding = strategy.find_hidden_mobs(controller.pawn, target)
	if(hiding)
		controller.set_blackboard_key(hiding_location_key, hiding)
	else if(hiding_location_key)
		controller.clear_blackboard_key(hiding_location_key)

/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/on_no_valid_candidates(datum/ai_controller/controller, atom/current_target)
	if(current_target)
		controller.clear_blackboard_key(target_key)

/// Nearest-attacker variant
/datum/bt_node/ai_behavior/acquire_target/target_from_retaliate_list/nearest
	target_priority_strategy = /datum/target_priority_strategy/nearest
