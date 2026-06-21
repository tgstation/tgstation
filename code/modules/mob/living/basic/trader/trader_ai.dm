/datum/ai_controller/basic_controller/trader
	behavior_tree_json = "code/modules/mob/living/basic/trader/trader.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TRADER_RUSH_TO_SELL = FALSE
	)

	ai_movement = /datum/ai_movement/basic_avoidance

/datum/ai_controller/basic_controller/trader/jumpscare
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TRADER_RUSH_TO_SELL = TRUE
	)
