/datum/ai_controller/basic_controller/bileworm
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/bileworm_attack,
	)

/datum/ai_planning_subtree/bileworm_attack

/datum/ai_planning_subtree/bileworm_attack/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target || QDELETED(target))
		return

	var/datum/action/cooldown/mob_cooldown/resurface = controller.blackboard[BB_RESURFACE]

	//because one ability is always INFINITY cooldown, this actually works to check which ability should be used
	//sometimes it will try to spew bile on infinity cooldown, but that's okay because as soon as resurface is ready it will attempt that
	if(resurface.next_use_time <= world.time)
		controller.queue_behavior(/datum/ai_behavior/try_mob_ability, BB_RESURFACE, BB_BASIC_MOB_CURRENT_TARGET)
	else
		controller.queue_behavior(/datum/ai_behavior/try_mob_ability, BB_SPEW_BILE, BB_BASIC_MOB_CURRENT_TARGET)
