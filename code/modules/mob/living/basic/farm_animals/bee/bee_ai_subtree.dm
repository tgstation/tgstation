/datum/ai_controller/basic_controller/bee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bee,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/bee/bee.bt.json"

/datum/ai_controller/basic_controller/queen_bee
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bee,
	)

	ai_traits = PASSIVE_AI_FLAGS
	ai_movement = /datum/ai_movement/basic_avoidance
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/bee/queen_bee.bt.json"


/datum/bt_node/subtree/pollinate_target
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/bee/pollinate_target.bt.json"

/datum/bt_node/subtree/find_hive
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/bee/find_hive.bt.json"

/datum/bt_node/subtree/transition_hive_status
	behavior_tree_json = "code/modules/mob/living/basic/farm_animals/bee/transition_hive_status.bt.json"
