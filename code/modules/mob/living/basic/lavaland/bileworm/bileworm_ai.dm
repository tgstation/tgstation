/datum/ai_controller/basic_controller/bileworm
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/bileworm_attack,
		/datum/ai_planning_subtree/bileworm_execute,
	)

/datum/ai_planning_subtree/bileworm_attack

/datum/ai_planning_subtree/bileworm_attack/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target))
		return

	var/datum/action/cooldown/mob_cooldown/resurface = controller.blackboard[BB_BILEWORM_RESURFACE]

	//because one ability is always INFINITY cooldown, this actually works to check which ability should be used
	//sometimes it will try to spew bile on infinity cooldown, but that's okay because as soon as resurface is ready it will attempt that
	if(resurface.next_use_time <= world.time)
		controller.queue_behavior(/datum/ai_behavior/try_mob_ability/and_plan_execute, BB_BILEWORM_RESURFACE, BB_BASIC_MOB_CURRENT_TARGET)
	else
		controller.queue_behavior(/datum/ai_behavior/try_mob_ability/and_plan_execute, BB_BILEWORM_SPEW_BILE, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING //focus on the fight

/datum/ai_planning_subtree/bileworm_execute

/datum/ai_planning_subtree/bileworm_execute/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_EXECUTION_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target) || target.stat < UNCONSCIOUS)
		return

	controller.queue_behavior(/datum/ai_behavior/try_mob_ability, BB_BILEWORM_DEVOUR, BB_BASIC_MOB_EXECUTION_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING //focus on devouring this fool
