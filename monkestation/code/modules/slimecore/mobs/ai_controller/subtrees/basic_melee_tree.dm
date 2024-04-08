/datum/ai_planning_subtree/basic_melee_attack_subtree/slime
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/try_latch_feed

/datum/ai_planning_subtree/basic_melee_attack_subtree/slime/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(!controller.blackboard[BB_BASIC_MOB_STOP_FLEEING])
		return
