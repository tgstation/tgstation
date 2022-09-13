/datum/ai_behavior/try_mob_ability

/datum/ai_behavior/try_mob_ability/perform(delta_time, datum/ai_controller/controller, ability_key, target_key)

	var/datum/action/cooldown/mob_cooldown/ability = controller.blackboard[ability_key]
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target.resolve()
	if(!ability || QDELETED(target))
		finish_action(controller, FALSE, ability_key, target_key)
	var/mob/pawn = controller.pawn
	var/result = ability.InterceptClickOn(pawn, null, target)
	finish_action(controller, result, ability_key, target_key)

/datum/ai_behavior/try_mob_ability/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target.resolve()
	if(QDELETED(target) || target.stat >= UNCONSCIOUS)
		controller.blackboard[target_key] = null

///subtype of normal mob ability that moves the target into a special execution targetting.
///doesn't need another subtype to clear BB_BASIC_MOB_EXECUTION_TARGET because it will be the target key for above type
/datum/ai_behavior/try_mob_ability/and_plan_execute

/datum/ai_behavior/try_mob_ability/and_plan_execute/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	controller.blackboard[BB_BASIC_MOB_EXECUTION_TARGET] = controller.blackboard[target_key]
	return ..()
