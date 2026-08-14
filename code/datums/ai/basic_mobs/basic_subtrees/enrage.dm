/// Halves the basic mob's melee attack cooldown while its health is at or below a threshold, and restores it once recovered.
/datum/bt_node/ai_behavior/enrage
	/// Fraction of max health at or below which the mob becomes enraged.
	var/health_threshold = 0.5

/datum/bt_node/ai_behavior/enrage/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!isbasicmob(controller.pawn))
		return AI_BEHAVIOR_FAILED

	var/mob/living/basic/basic_pawn = controller.pawn
	var/low_health = (basic_pawn.health / basic_pawn.maxHealth) <= health_threshold
	var/is_enraged = controller.blackboard_key_exists(BB_BASIC_MOB_ENRAGE)

	if(low_health && !is_enraged)
		var/current_cooldown = basic_pawn.melee_attack_cooldown
		controller.set_blackboard_key(BB_BASIC_MOB_ENRAGE, TRUE)
		controller.set_blackboard_key(BB_BASIC_MOB_PREVIOUS_MELEE_COOLDOWN, current_cooldown)
		basic_pawn.melee_attack_cooldown = current_cooldown / 2

		if(controller.blackboard_key_exists(BB_CURRENT_TARGET))
			basic_pawn.visible_message(span_danger("\The [basic_pawn] gets an enraged look at [controller.blackboard[BB_CURRENT_TARGET]]!"))
		else
			basic_pawn.visible_message(span_danger("\The [basic_pawn] gets an enraged look!"))
		return AI_BEHAVIOR_SUCCEEDED

	if(!low_health && is_enraged)
		// Technically something else could have modified the cooldown before/after but that requires further consideration so don't use this behavior in these scenarios
		basic_pawn.melee_attack_cooldown = controller.blackboard[BB_BASIC_MOB_PREVIOUS_MELEE_COOLDOWN]
		controller.clear_blackboard_key(BB_BASIC_MOB_PREVIOUS_MELEE_COOLDOWN)
		controller.clear_blackboard_key(BB_BASIC_MOB_ENRAGE)
		return AI_BEHAVIOR_SUCCEEDED

	return AI_BEHAVIOR_FAILED
