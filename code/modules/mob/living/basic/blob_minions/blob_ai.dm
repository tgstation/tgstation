/**
 * Extremely simple AI, this isn't a very smart boy
 * Only notable quirk is that it uses JPS movement, simple avoidance would fail to realise it can path through blobs
 */
/datum/ai_controller/basic_controller/blobbernaut
	behavior_tree_json = "code/modules/mob/living/basic/blob_minions/blobbernaut.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/jps

/**
 * Move to a point designated by the overmind, otherwise just slap people nearby
 */
/datum/ai_controller/basic_controller/blob_zombie
	behavior_tree_json = "code/modules/mob/living/basic/blob_minions/blob_zombie.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/jps

/**
 * As blob zombie but will prioritise attacking corpses to zombify them
 */
/datum/ai_controller/basic_controller/blob_spore
	behavior_tree_json = "code/modules/mob/living/basic/blob_minions/blob_spore.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/jps
