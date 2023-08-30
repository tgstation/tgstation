/datum/ai_behavior/follow_leader

/datum/ai_behavior/follow_leader/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/mob/living/target = controller.blackboard[BB_CHICKEN_CURRENT_LEADER]

	if(controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]) // they care more about attacking right now
		finish_action(controller, TRUE)
	if(target)
		step_to(living_pawn, target,1)
	else
		finish_action(controller, TRUE)

/datum/ai_behavior/targeted_mob_ability/min_range/melee
	required_distance = 1

/datum/ai_behavior/targeted_mob_ability/min_range/gaze
	required_distance = 4

/datum/ai_behavior/targeted_mob_ability/min_range/on_top
	required_distance = 0

/datum/ai_planning_subtree/basic_ranged_attack_subtree/chicken
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/chicken

/datum/ai_behavior/basic_ranged_attack/chicken
	required_distance = 5
