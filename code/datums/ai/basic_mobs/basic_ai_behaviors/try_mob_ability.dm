/datum/ai_behavior/try_mob_ability

/datum/ai_behavior/try_mob_ability/perform(delta_time, datum/ai_controller/controller, ability_key, target_key)

	var/mob/pawn = controller.pawn
	var/datum/action/cooldown/mob_cooldown/ability = controller.blackboard[ability_key]
	var/mob/living/target = controller.blackboard[target_key]
	if(!ability || !target)
		return
	var/result = ability.InterceptClickOn(pawn, null, target)
	finish_action(controller, result, ability_key, target_key)
