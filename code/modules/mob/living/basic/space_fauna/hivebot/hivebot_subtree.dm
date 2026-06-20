/datum/ai_controller/basic_controller/hivebot
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "hivebot.bt.json"

/datum/ai_controller/basic_controller/hivebot/mechanic
	behavior_tree_json = "hivebot_mechanic.bt.json"

/datum/ai_controller/basic_controller/hivebot/ranged
	behavior_tree_json = "hivebot_ranged.bt.json"

/datum/ai_controller/basic_controller/hivebot/ranged/rapid
	behavior_tree_json = "hivebot_ranged_rapid.bt.json"
