/// Basically just keep away and shit out worms
/datum/ai_controller/basic_controller/hivelord
	behavior_tree_json = "code/modules/mob/living/basic/lavaland/hivelord/hivelord.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_AGGRO_RANGE = 5, // Only get mad at people nearby
	)

	ai_movement = /datum/ai_movement/basic_avoidance
