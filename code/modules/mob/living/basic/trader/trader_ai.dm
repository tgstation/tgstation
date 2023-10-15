/datum/ai_controller/basic_controller/trader
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader,
		/datum/ai_planning_subtree/setup_shop,
	)

/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/syndicate

/datum/ai_behavior/basic_ranged_attack/trader
	action_cooldown = 3 SECONDS


///subtree to find our very first customer and set up our shop
/datum/ai_planning_subtree/setup_shop

/datum/ai_planning_subtree/setup_shop/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	var/obj/shop_spot = controller.blackboard[BB_SHOP_SPOT]

	//we still have our shop, don't set it up again
	if(!QDELETED(shop_spot))
		return

	var/mob/living/carbon/first_customer = controller.blackboard[BB_FIRST_CUSTOMER]

	//we haven't set our first customer yet
	if(QDELETED(first_customer))
		controller.queue_behavior(/datum/ai_behavior/find_and_set, BB_FIRST_CUSTOMER, /mob/living/carbon/human)
		return

	//we have our first customer, time to tell them about incredible deals
	controller.queue_behavior(/datum/ai_behavior/setup_shop, BB_FIRST_CUSTOMER)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/setup_shop
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/setup_shop/setup(datum/ai_controller/controller, target_key)
	. = ..()
	var/obj/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)


/datum/ai_behavior/setup_shop/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	var/atom/target = controller.blackboard[target_key]
	var/mob/living/basic/living_pawn = controller.pawn

	if(QDELETED(target))
		finish_action(controller, FALSE, target_key)
		return

	living_pawn.say("Welcome to my shop, friend!")
	var/shop_type_path =  controller.blackboard[BB_SHOP_SPOT_TYPE]
	var/obj/shop_spot = new shop_type_path(living_pawn.loc)
	shop_spot.dir = living_pawn.dir
	controller.set_blackboard_key(BB_SHOP_SPOT, shop_spot)
	playsound(living_pawn, controller.blackboard[BB_SHOP_SOUND], 50, TRUE)

	var/turf/sign_turf

	sign_turf = try_find_valid_spot(living_pawn.loc, turn(shop_spot.dir, -90))
	if(!sign_turf) //No space to my left, lets try right
		sign_turf = try_find_valid_spot(living_pawn.loc, turn(shop_spot.dir, 90))

	if(sign_turf)
		var/obj/sign = controller.blackboard[BB_SHOP_SIGN]
		if(QDELETED(sign))
			var/sign_type_path =  controller.blackboard[BB_SHOP_SIGN_TYPE]
			var/obj/new_sign = new sign_type_path(sign_turf)
			controller.set_blackboard_key(BB_SHOP_SIGN, new_sign)
			do_sparks(3, FALSE, new_sign)
		else
			do_teleport(sign,sign_turf)

	finish_action(controller, TRUE, target_key)

/datum/ai_behavior/setup_shop/proc/try_find_valid_spot(origin_turf, direction_to_check)
	var/turf/sign_turf = get_step(origin_turf, direction_to_check)
	if(sign_turf && !isgroundlessturf(sign_turf) && !isclosedturf(sign_turf))
		return sign_turf


/datum/ai_behavior/setup_shop/finish_action(datum/ai_controller/controller, succeeded, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)
