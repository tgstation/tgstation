/datum/ai_controller/basic_controller/legion
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/legion_attack,
	)

/datum/ai_planning_subtree/legion_attack

/datum/ai_planning_subtree/legion_attack/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target))
		return

	var/datum/weakref/weak_action = controller.blackboard[BB_LEGION_LASERS]
	var/datum/action/cooldown/mob_cooldown/lasers = weak_action?.resolve()

	weak_action = controller.blackboard[BB_LEGION_BONE]
	var/datum/action/cooldown/mob_cooldown/bone = weak_action?.resolve()

	if(lasers && lasers.next_use_time <= world.time)
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_plan_execute, BB_LEGION_LASERS, BB_BASIC_MOB_CURRENT_TARGET)
	else
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability/and_plan_execute, BB_LEGION_BONE, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/legion_execute

/datum/ai_planning_subtree/legion_execute/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_EXECUTION_TARGET]
	var/mob/living/target = weak_target?.resolve()
	if(QDELETED(target) || target.stat < UNCONSCIOUS)
		return

	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, BB_LEGION_BONE, BB_BASIC_MOB_EXECUTION_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING
