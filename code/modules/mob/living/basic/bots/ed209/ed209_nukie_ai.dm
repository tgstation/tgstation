/datum/ai_controller/basic_controller/bot/ed209/syndicate
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
		BB_RANGED_SKIRMISH_MIN_DISTANCE = 2,
		BB_RANGED_SKIRMISH_MAX_DISTANCE = 4
	)
	behavior_tree_json = "code/modules/mob/living/basic/bots/ed209/ed209_syndicate.bt.json"
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
