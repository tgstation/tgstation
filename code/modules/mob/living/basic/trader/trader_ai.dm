/datum/ai_controller/basic_controller/trader
	behavior_tree_json = "trader.bt.json"
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

///Subtree to find our very first customer and set up our shop after walking right into their face
/datum/ai_planning_subtree/setup_shop
	///What do we do in order to offer our deals?
	var/datum/ai_behavior/setup_shop/setup_shop_behavior = /datum/ai_behavior/setup_shop

/datum/ai_planning_subtree/setup_shop/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	//If we don't have our ability, return
	if(!controller.blackboard_key_exists(BB_SETUP_SHOP))
		return

	//If we already have a shop spot, return
	if(controller.blackboard_key_exists(BB_SHOP_SPOT))
		return

	//If we don't have a customer to greet, look for one
	if(!controller.blackboard_key_exists(BB_FIRST_CUSTOMER))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/conscious_person, BB_FIRST_CUSTOMER, /mob/living/carbon/human)
		return

	//We have our first customer, time to tell them about incredible deals
	controller.queue_behavior(setup_shop_behavior, BB_FIRST_CUSTOMER)
	return SUBTREE_RETURN_FINISH_PLANNING

///The ai will create a shop the moment they see a potential costumer
/datum/ai_behavior/setup_shop

/datum/ai_behavior/setup_shop/setup(datum/ai_controller/controller, target_key)
	var/obj/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/ai_behavior/setup_shop/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	//We lost track of our costumer or our ability, abort
	if(!controller.blackboard_key_exists(target_key) || !controller.blackboard_key_exists(BB_SETUP_SHOP))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/action/setup_shop/shop = controller.blackboard[BB_SETUP_SHOP]
	shop.Trigger()

	controller.clear_blackboard_key(BB_FIRST_CUSTOMER)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/datum/idle_behavior/idle_random_walk/not_while_on_target/trader
	target_key = BB_SHOP_SPOT

/datum/ai_behavior/setup_shop/jumpscare/setup(datum/ai_controller/controller, target_key)
	. = ..()
	if(.)
		set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/setup_shop/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

// BT behaviors

///Finds a nearby conscious human carbon and sets them as our first customer
/datum/bt_node/ai_behavior/find_and_set/conscious_person

/datum/bt_node/ai_behavior/find_and_set/conscious_person/search_tactic(datum/ai_controller/controller, locate_path, search_range = SEARCH_TACTIC_DEFAULT_RANGE)
	var/list/customers = list()
	for(var/mob/living/carbon/human/target in oview(search_range, controller.pawn))
		if(IS_DEAD_OR_INCAP(target) || !target.mind)
			continue
		customers += target
	if(customers.len)
		return pick(customers)
	return null

///Triggers the shop setup action and clears the first customer key
/datum/bt_node/ai_behavior/setup_shop

/datum/bt_node/ai_behavior/setup_shop/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/setup_shop/shop = controller.blackboard[BB_SETUP_SHOP]
	if(!shop || !controller.blackboard_key_exists(BB_FIRST_CUSTOMER))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED
	shop.Trigger()
	controller.clear_blackboard_key(BB_FIRST_CUSTOMER)
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
