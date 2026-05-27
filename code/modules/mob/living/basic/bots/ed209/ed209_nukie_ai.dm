/datum/ai_controller/basic_controller/bot/ed209/syndicate
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_UNREACHABLE_LIST_COOLDOWN = 1 MINUTES,
	)
	behavior_tree_json = "ed209_syndicate.bt.json"
	reset_keys = list(
		BB_BEACON_TARGET,
		BB_PREVIOUS_BEACON_TARGET,
		BB_BOT_SUMMON_TARGET,
	)
