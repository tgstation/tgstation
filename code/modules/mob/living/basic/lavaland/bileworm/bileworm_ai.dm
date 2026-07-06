/datum/ai_controller/basic_controller/bileworm
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/bileworm,
		BB_TARGET_PRIORITY_STRATEGY = /datum/target_priority_strategy/mining,
		BB_BILEWORM_FLEE_DISTANCE = 3,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/call_reinforcements/mining,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/bileworm_attack,
		/datum/ai_planning_subtree/bileworm_execute,
	)

/datum/targeting_strategy/basic/bileworm
	ignore_sight = TRUE

/datum/ai_planning_subtree/bileworm_attack

/datum/ai_planning_subtree/bileworm_attack/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (!controller.blackboard_key_exists(BB_BASIC_MOB_CURRENT_TARGET))
		return

	var/datum/action/cooldown/mob_cooldown/resurface = controller.blackboard[BB_BILEWORM_RESURFACE]
	var/datum/action/cooldown/mob_cooldown/bile = controller.blackboard[BB_BILEWORM_SPEW_BILE]

	if(resurface?.IsAvailable() && (controller.blackboard[BB_BILEWORM_SCARED] || get_dist(controller.pawn, controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]) <= controller.blackboard[BB_BILEWORM_FLEE_DISTANCE]))
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_plan_execute, BB_BILEWORM_RESURFACE, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(bile?.IsAvailable())
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_plan_execute, BB_BILEWORM_SPEW_BILE, BB_BASIC_MOB_CURRENT_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING //focus on the fight

/datum/ai_planning_subtree/bileworm_execute

/datum/ai_planning_subtree/bileworm_execute/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)

	var/atom/movable/target = controller.blackboard[BB_BASIC_MOB_EXECUTION_TARGET]
	if(QDELETED(target) || !isliving(target))
		return

	var/datum/action/cooldown/mob_cooldown/devour = controller.blackboard[BB_BILEWORM_DEVOUR]

	if(!(devour?.IsAvailable()))
		return

	var/mob/living/living_target = target
	if(living_target.stat < UNCONSCIOUS)
		return

	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_clear_target, BB_BILEWORM_DEVOUR, BB_BASIC_MOB_EXECUTION_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING //focus on devouring this fool
