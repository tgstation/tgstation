/datum/ai_behavior/slime_stacker
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT | AI_BEHAVIOR_REQUIRE_REACH | AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/slime_stacker/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!controller.blackboard[BB_TARGETING_STRATEGY])
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")

	if(controller.pawn.GetComponent(/datum/component/mob_stacker))
		return FALSE

	if(HAS_TRAIT(controller.pawn, TRAIT_IN_STACK))
		return FALSE
	//Hiding location is priority
	var/atom/real_target
	var/list/potential_targets = list()
	for(var/mob/living/basic/slime/target in oview(4, controller.pawn))
		if(target.GetComponent(/datum/component/latch_feeding))
			continue
		if(target.GetComponent(/datum/component/mob_stacker))
			if(target == controller.pawn)
				return FALSE
			if(!SEND_SIGNAL(target, COMSIG_CHECK_CAN_ADD_NEW_STACK))
				continue
			real_target = target
			break
		if(target == controller.pawn)
			continue

		if(HAS_TRAIT(target, TRAIT_IN_STACK))
			continue

		potential_targets += target

	if(!real_target && length(potential_targets))
		real_target = pick(potential_targets)
		real_target.AddComponent(/datum/component/mob_stacker)

	if(QDELETED(real_target))
		return FALSE

	controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, real_target)
	set_movement_target(controller, real_target)



/datum/ai_behavior/slime_stacker/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key, trait)
	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (world.time < pawn.next_move)
			return

	. = ..()

	finish_action(controller, TRUE, BB_BASIC_MOB_CURRENT_TARGET)

/datum/ai_behavior/slime_stacker/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(succeeded)
		var/mob/living/basic/basic_mob = controller.pawn
		var/atom/movable/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
		SEND_SIGNAL(target, COMSIG_ATOM_JOIN_STACK, basic_mob)
