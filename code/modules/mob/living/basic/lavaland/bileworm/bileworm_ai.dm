/datum/ai_controller/basic_controller/bileworm
	behavior_tree_json = "bileworm.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bileworm,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining,
		BB_BILEWORM_FLEE_DISTANCE = 3,
		BB_TARGET_MINIMUM_STAT = UNCONSCIOUS,
	)

/datum/targeting_strategy/basic/bileworm
	ignore_sight = TRUE

/// Passes when the worm should burrow and reposition: it's been scared, or its target has gotten within flee distance.
/datum/bt_node/decorator/bileworm_should_resurface
	/// Blackboard key holding the atom we want to keep our distance from.
	var/target_key = BB_CURRENT_TARGET

/datum/bt_node/decorator/bileworm_should_resurface/check_condition(datum/ai_controller/controller)
	if(controller.blackboard[BB_BILEWORM_SCARED])
		return TRUE
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	return get_dist(controller.pawn, target) <= controller.blackboard[BB_BILEWORM_FLEE_DISTANCE]
