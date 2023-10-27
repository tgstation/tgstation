
///Subtree that checks if we are on the target atom's tile, and sets it as a travel target if not
///The target is taken from the blackboard. This one always requires a specific implementation.
/datum/ai_planning_subtree/prepare_travel_to_destination
	var/target_key
	var/travel_destination_key = BB_TRAVEL_DESTINATION

/datum/ai_planning_subtree/prepare_travel_to_destination/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/atom/target = controller.blackboard[target_key]

	//Target is deleted, or we are already standing on it
	if(QDELETED(target) || (isturf(target) && controller.pawn.loc == target) || (target.loc == controller.pawn.loc))
		return

	//Already set with this value, return
	if(controller.blackboard[target_key] == controller.blackboard[travel_destination_key])
		return

	controller.queue_behavior(/datum/ai_behavior/set_travel_destination, target_key, travel_destination_key)
	return //continue planning regardless of success

/datum/ai_planning_subtree/prepare_travel_to_destination/trader
	target_key = BB_SHOP_SPOT
