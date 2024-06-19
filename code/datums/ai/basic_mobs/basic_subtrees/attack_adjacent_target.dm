/// Attack something which is already adjacent to us, without ending planning
/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/opportunistic
	end_planning = FALSE

/datum/ai_planning_subtree/basic_melee_attack_subtree/opportunistic/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target) || !controller.pawn.Adjacent(target))
		return
	if (isliving(controller.pawn))
		var/mob/living/pawn = controller.pawn
		if (LAZYLEN(pawn.do_afters))
			return
	controller.queue_behavior(melee_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)

/// Attack something which is already adjacent to us without moving
/datum/ai_behavior/basic_melee_attack/opportunistic
	action_cooldown = 0.2 SECONDS // We gotta check unfortunately often because we're in a race condition with nextmove
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/basic_melee_attack/opportunistic/setup(datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	if (!controller.blackboard_key_exists(targeting_strategy_key))
		CRASH("No target datum was supplied in the blackboard for [controller.pawn]")
	return controller.blackboard_key_exists(target_key)

/datum/ai_behavior/basic_melee_attack/opportunistic/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/atom/movable/atom_pawn = controller.pawn
	if(!atom_pawn.CanReach(controller.blackboard[target_key]))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	. = ..()
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
