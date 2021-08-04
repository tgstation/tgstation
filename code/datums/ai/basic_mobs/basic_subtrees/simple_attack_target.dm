/datum/ai_planning_subtree/basic_melee_attack_subtree
	var/datum/ai_behavior/basic_melee_attack/melee_attack_behavior = /datum/ai_behavior/basic_melee_attack

/datum/ai_planning_subtree/basic_melee_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(!controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	controller.AddBehavior(/datum/ai_behavior/can_still_attack_target, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM)
	controller.AddBehavior(melee_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)


//If you give this to something without the element you are a dumbass.
/datum/ai_planning_subtree/basic_ranged_attack_subtree
	var/datum/ai_behavior/basic_ranged_attack/ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack

/datum/ai_planning_subtree/basic_ranged_attack_subtree/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(!controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
		return
	controller.AddBehavior(/datum/ai_behavior/can_still_attack_target, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM)
	controller.AddBehavior(ranged_attack_behavior, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)





