/datum/ai_controller/basic_controller/trader
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/not_while_on_target/trader
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_ranged_attack_subtree/trader,
		/datum/ai_planning_subtree/prepare_travel_to_destination/trader,
		/datum/ai_planning_subtree/travel_to_point/and_clear_target,
		/datum/ai_planning_subtree/setup_shop,
	)

/datum/ai_controller/basic_controller/trader/jumpscare
	planning_subtrees = list(
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

///subtree to find our very first customer and set up our shop after walking right into their face
/datum/ai_planning_subtree/setup_shop
	/// What do we do in order to offer our deals?
	var/datum/ai_behavior/setup_shop/setup_shop_behavior = /datum/ai_behavior/setup_shop

/datum/ai_planning_subtree/setup_shop/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	//if we already have a shop spot, return
	if(controller.blackboard_key_exists(BB_SHOP_SPOT))
		return

	//if we don't have a costurmer to greet, look for one
	if(!controller.blackboard_key_exists(BB_FIRST_CUSTOMER))
		controller.queue_behavior(/datum/ai_behavior/find_and_set/conscious_person, BB_FIRST_CUSTOMER, /mob/living/carbon/human)
		return

	//we have our first customer, time to tell them about incredible deals
	controller.queue_behavior(setup_shop_behavior, BB_FIRST_CUSTOMER)
	return SUBTREE_RETURN_FINISH_PLANNING

///The ai will create a shop the moment they see a potential costumer
/datum/ai_behavior/setup_shop

/datum/ai_behavior/setup_shop/setup(datum/ai_controller/controller, target_key)
	var/obj/target = controller.blackboard[target_key]
	return !QDELETED(target)

/datum/ai_behavior/setup_shop/perform(seconds_per_tick, datum/ai_controller/controller, target_key)
	. = ..()

	//we lost track of our costumer, abort
	if(!controller.blackboard_key_exists(target_key))
		finish_action(controller, FALSE, target_key)
		return

	var/mob/living/basic/living_pawn = controller.pawn

	living_pawn.say("Welcome to my shop, friend!")
	var/shop_type_path =  controller.blackboard[BB_SHOP_SPOT_TYPE]
	var/obj/shop_spot = new shop_type_path(living_pawn.loc)
	shop_spot.dir = living_pawn.dir
	controller.set_blackboard_key(BB_SHOP_SPOT, shop_spot)
	playsound(living_pawn, controller.blackboard[BB_SHOP_SOUND], 50, TRUE)

	var/turf/sign_turf

	sign_turf = try_find_valid_spot(living_pawn.loc, turn(shop_spot.dir, -90))
	if(isnull(sign_turf)) //No space to my left, lets try right
		sign_turf = try_find_valid_spot(living_pawn.loc, turn(shop_spot.dir, 90))

	if(!isnull(sign_turf))
		var/obj/sign = controller.blackboard[BB_SHOP_SIGN]
		if(QDELETED(sign))
			var/sign_type_path =  controller.blackboard[BB_SHOP_SIGN_TYPE]
			var/obj/new_sign = new sign_type_path(sign_turf)
			controller.set_blackboard_key(BB_SHOP_SIGN, new_sign)
			do_sparks(3, FALSE, new_sign)
		else
			do_teleport(sign,sign_turf)

	controller.clear_blackboard_key(BB_FIRST_CUSTOMER)

	finish_action(controller, TRUE, target_key)

///Look for a spot we can place our sign on
/datum/ai_behavior/setup_shop/proc/try_find_valid_spot(origin_turf, direction_to_check)
	var/turf/sign_turf = get_step(origin_turf, direction_to_check)
	if(sign_turf && !isgroundlessturf(sign_turf) && !isclosedturf(sign_turf) && !sign_turf.is_blocked_turf())
		return sign_turf
	return null

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
