/// Basically just keep away and shit out worms
/datum/ai_controller/basic_controller/hivelord
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 5, // Only get mad at people nearby
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/datums/ai/basic_mobs/simple_ability_ranged_combat.bt.json"
