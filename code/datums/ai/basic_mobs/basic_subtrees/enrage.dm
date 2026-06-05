// Performs the enrage behavior when health is below given threshold, and calm down behavior if above that value afterwards
/datum/ai_planning_subtree/enrage
	var/health_threshold = 0.5
	var/enrage_behavior = /datum/ai_behavior/enrage

/datum/ai_planning_subtree/enrage/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!isbasicmob(controller.pawn))
		return
	var/mob/living/basic/basic_pawn = controller.pawn
	var/low_health = (basic_pawn.health / basic_pawn.maxHealth) <= health_threshold

	var/is_enraged = controller.blackboard_key_exists(BB_BASIC_MOB_ENRAGE)
	if(low_health && !is_enraged)
		controller.queue_behavior(enrage_behavior, FALSE)
	else if(!low_health && is_enraged)
		controller.queue_behavior(enrage_behavior, TRUE)


/// Cuts down basic mob's melee attack cooldown in half
/datum/ai_behavior/enrage

/datum/ai_behavior/enrage/perform(seconds_per_tick, datum/ai_controller/controller, calm_down)
	var/mob/living/basic/basic_pawn = controller.pawn
	if(calm_down)
		var/previous_delay = controller.blackboard[BB_BASIC_MOB_PREVIOUS_MELEE_COOLDOWN]
		// Technically something else could have modified the cooldown before/after but that requires further consideration so don't use this behavior in these scenarios
		basic_pawn.melee_attack_cooldown = previous_delay
		controller.clear_blackboard_key(BB_BASIC_MOB_PREVIOUS_MELEE_COOLDOWN)
		controller.clear_blackboard_key(BB_BASIC_MOB_ENRAGE)
		return AI_BEHAVIOR_SUCCEEDED

	var/current_cooldown = basic_pawn.melee_attack_cooldown
	var/new_attack_cooldown = current_cooldown / 2

	controller.set_blackboard_key(BB_BASIC_MOB_ENRAGE, TRUE)
	controller.set_blackboard_key(BB_BASIC_MOB_PREVIOUS_MELEE_COOLDOWN, current_cooldown)
	basic_pawn.melee_attack_cooldown = new_attack_cooldown

	if(controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		var/current_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
		controller.pawn.visible_message(span_danger("\The [controller.pawn] gets an enraged look at [current_target]!"))
	else
		controller.pawn.visible_message(span_danger("\The [controller.pawn] gets an enraged look!"))
	return AI_BEHAVIOR_SUCCEEDED
