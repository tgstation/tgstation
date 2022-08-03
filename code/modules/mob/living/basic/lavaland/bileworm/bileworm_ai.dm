/datum/ai_controller/basic_controller/bileworm
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_SHOULD_RESURFACE = TRUE,
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/bileworm_attack
	)

/datum/ai_planning_subtree/bileworm_attack

/datum/ai_planning_subtree/bileworm_attack/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/atom/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target || QDELETED(target))
		return

	if(controller.blackboard[BB_SHOULD_RESURFACE])
		controller.queue_behavior(/datum/ai_behavior/try_mob_ability/resurface, BB_RESURFACE, BB_BASIC_MOB_CURRENT_TARGET)
	else
		controller.queue_behavior(/datum/ai_behavior/try_mob_ability/spew_bile, BB_SPEW_BILE, BB_BASIC_MOB_CURRENT_TARGET)

//making try_mob_ability flop which ability should be done after completion

/datum/ai_behavior/try_mob_ability/resurface

/datum/ai_behavior/try_mob_ability/resurface/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	if(succeeded)
		//will now try to bury
		controller.blackboard[BB_SHOULD_RESURFACE] = !controller.blackboard[BB_SHOULD_RESURFACE]

/datum/ai_behavior/try_mob_ability/spew_bile

/datum/ai_behavior/try_mob_ability/spew_bile/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	if(succeeded)
		//will now try to resurface
		controller.blackboard[BB_SHOULD_RESURFACE] = !controller.blackboard[BB_SHOULD_RESURFACE]
