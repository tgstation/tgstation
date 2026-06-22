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

///Triggers the shop setup action and clears the first customer key
/datum/bt_node/ai_behavior/setup_shop

/datum/bt_node/ai_behavior/setup_shop/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/setup_shop/shop = controller.blackboard[BB_SETUP_SHOP]
	if(!shop || !controller.blackboard_key_exists(BB_FIRST_CUSTOMER))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	shop.Trigger()
	controller.clear_blackboard_key(BB_FIRST_CUSTOMER)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
