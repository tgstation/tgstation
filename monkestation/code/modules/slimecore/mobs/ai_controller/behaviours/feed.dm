/datum/ai_behavior/basic_melee_attack/try_latch_feed
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION
	terminate_after_action = TRUE
	melee_attacks = FALSE

/datum/ai_behavior/basic_melee_attack/try_latch_feed/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/mob/living/basic/basic_mob = controller.pawn
	if(HAS_TRAIT(basic_mob, TRAIT_FEEDING))
		return FALSE
	. = ..()

/datum/ai_behavior/basic_melee_attack/try_latch_feed/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	if(SEND_SIGNAL(controller.pawn, COMSIG_FRIENDSHIP_CHECK_LEVEL, controller.blackboard[target_key], FRIENDSHIP_FRIEND))
		controller.clear_blackboard_key(target_key)
	else if(succeeded && isliving(controller.blackboard[target_key]))
		var/atom/target = controller.blackboard[target_key]
		var/mob/living/basic/slime/basic_mob = controller.pawn
		if(basic_mob.CanReach(target) && !HAS_TRAIT(target, TRAIT_LATCH_FEEDERED))
			basic_mob.AddComponent(/datum/component/latch_feeding, target, TOX, 2, 4, FALSE, CALLBACK(basic_mob, TYPE_PROC_REF(/mob/living/basic/slime, latch_callback), target))
		controller.clear_blackboard_key(target_key)
	. = ..()

