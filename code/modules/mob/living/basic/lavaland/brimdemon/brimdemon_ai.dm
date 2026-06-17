/**
 * Slap someone who is nearby, line up with target, blast with a beam
 */
/datum/ai_controller/basic_controller/brimdemon
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining/low_node_priority,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "brimdemon.bt.json"

/// Brimdemon's beam only fires when the target is lined up on a cardinal direction.
/datum/bt_node/ai_behavior/targeted_mob_ability/brimbeam/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(target) || !(get_dir(controller.pawn, target) in GLOB.cardinals))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()
