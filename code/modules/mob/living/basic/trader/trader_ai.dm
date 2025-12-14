/datum/ai_controller/basic_controller/trader
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/not_while_on_target/trader
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader,
		/datum/ai_planning_subtree/prepare_travel_to_destination/trader,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target,
		/datum/ai_planning_subtree/setup_shop,
	)

/datum/ai_controller/basic_controller/trader/jumpscare
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader,
		/datum/ai_planning_subtree/prepare_travel_to_destination/trader,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target,
		/datum/ai_planning_subtree/setup_shop/jumpscare,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/trader

/datum/ai_behavior/basic_ranged_attack/trader
	action_cooldown = 3 SECONDS
	avoid_friendly_fire = TRUE

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

	//If we don't have a costurmer to greet, look for one
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

///Version of setup show where the trader will run at you to assault you with incredible deals
/datum/ai_planning_subtree/setup_shop/jumpscare
	setup_shop_behavior = /datum/ai_behavior/setup_shop/jumpscare

/datum/ai_behavior/setup_shop/jumpscare
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH

/datum/ai_behavior/setup_shop/jumpscare/setup(datum/ai_controller/controller, target_key)
	. = ..()
	if(.)
		set_movement_target(controller, controller.blackboard[target_key])

/datum/ai_behavior/setup_shop/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
