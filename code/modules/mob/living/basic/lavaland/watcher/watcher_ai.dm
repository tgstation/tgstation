/datum/ai_controller/basic_controller/watcher
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/watcher/watcher.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 3,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 5,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
