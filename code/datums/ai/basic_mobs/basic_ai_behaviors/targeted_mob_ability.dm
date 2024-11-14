/**
 * # Targeted Mob Ability
 * Attempts to use a mob's cooldown ability on a target
 */
/datum/ai_behavior/targeted_mob_ability

/datum/ai_behavior/targeted_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/ability = get_ability_to_use(controller, ability_key)
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(ability) || QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/pawn = controller.pawn
	pawn.face_atom(target)
	var/result = ability.Trigger(target = target)
	if(result)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/ai_behavior/targeted_mob_ability/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if (QDELETED(target))
		controller.clear_blackboard_key(target_key)

/datum/ai_behavior/targeted_mob_ability/proc/get_ability_to_use(datum/ai_controller/controller, ability_key)
	return controller.blackboard[ability_key]

/**
 * # Try Mob Ability and plan execute
 * Attempts to use a mob's cooldown ability on a target and then move the target into a special target blackboard datum
 * Doesn't need another subtype to clear BB_BASIC_MOB_EXECUTION_TARGET because it will be the target key for the normal action
 */
/datum/ai_behavior/targeted_mob_ability/and_plan_execute

/datum/ai_behavior/targeted_mob_ability/and_plan_execute/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	controller.set_blackboard_key(BB_BASIC_MOB_EXECUTION_TARGET, controller.blackboard[target_key])
	return ..()

/**
 * # Try Mob Ability and clear target
 * Attempts to use a mob's cooldown ability on a target and releases the target when the action completes
 */
/datum/ai_behavior/targeted_mob_ability/and_clear_target

/datum/ai_behavior/targeted_mob_ability/and_clear_target/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)

/**
 * Attempts to move into the provided range and then use a mob's cooldown ability on a target
 */
/datum/ai_behavior/targeted_mob_ability/min_range
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT
	required_distance = 6

/datum/ai_behavior/targeted_mob_ability/min_range/setup(datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	var/atom/target = controller.blackboard[target_key]
	if(QDELETED(target))
		return FALSE
	set_movement_target(controller, target)

/datum/ai_behavior/targeted_mob_ability/min_range/short
	required_distance = 3
