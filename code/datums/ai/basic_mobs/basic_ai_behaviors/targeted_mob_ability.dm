/**
 * # Targeted Mob Ability
 * Attempts to use a mob's cooldown ability on a target
 */
/datum/ai_behavior/targeted_mob_ability

/datum/ai_behavior/targeted_mob_ability/perform(delta_time, datum/ai_controller/controller, ability_key, target_key)
	var/datum/weakref/weak_ability = controller.blackboard[ability_key]
	var/datum/action/cooldown/ability = weak_ability?.resolve()

	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target?.resolve()
	if(!ability || QDELETED(target))
		finish_action(controller, FALSE, ability_key, target_key)
		return
	var/mob/pawn = controller.pawn
	var/result = ability.InterceptClickOn(pawn, null, target)
	finish_action(controller, result, ability_key, target_key)

/datum/ai_behavior/targeted_mob_ability/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if (QDELETED(target))
		controller.blackboard[target_key] = null
		return
	if (!isliving(target))
		return
	var/mob/living/living_target = target
	if(living_target.stat >= UNCONSCIOUS)
		controller.blackboard[target_key] = null

/**
 * # Try Mob Ability and plan execute
 * Attempts to use a mob's cooldown ability on a target and then move the target into a special target blackboard datum
 * Doesn't need another subtype to clear BB_BASIC_MOB_EXECUTION_TARGET because it will be the target key for the normal action
 */
/datum/ai_behavior/targeted_mob_ability/and_plan_execute

/datum/ai_behavior/targeted_mob_ability/and_plan_execute/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	controller.blackboard[BB_BASIC_MOB_EXECUTION_TARGET] = controller.blackboard[target_key]
	return ..()

/**
 * # Try Mob Ability and clear target
 * Attempts to use a mob's cooldown ability on a target and releases the target when the action completes
 */
/datum/ai_behavior/targeted_mob_ability/and_clear_target

/datum/ai_behavior/targeted_mob_ability/and_clear_target/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	controller.blackboard[target_key] = null
