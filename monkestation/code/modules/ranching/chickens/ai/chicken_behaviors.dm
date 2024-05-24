/datum/ai_movement/jps/oneshot
	max_pathing_attempts = 1

/datum/ai_behavior/targeted_mob_ability/min_range/chicken
	new_movement = /datum/ai_movement/jps/oneshot

/datum/ai_behavior/targeted_mob_ability/min_range/chicken/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	controller.change_ai_movement_type(/datum/ai_movement/dumb)

/datum/ai_behavior/targeted_mob_ability/min_range/chicken/melee
	required_distance = 1

/datum/ai_behavior/targeted_mob_ability/min_range/chicken/gaze
	required_distance = 4

/datum/ai_behavior/targeted_mob_ability/min_range/chicken/on_top
	required_distance = 0

/datum/ai_planning_subtree/basic_ranged_attack_subtree/chicken
	ranged_attack_behavior = /datum/ai_behavior/basic_ranged_attack/chicken

/datum/ai_behavior/basic_ranged_attack/chicken
	required_distance = 5

/datum/ai_behavior/basic_ranged_attack/chicken/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key)
	var/atom/target = controller.blackboard[target_key]
	if(SEND_SIGNAL(controller.pawn, COMSIG_FRIENDSHIP_CHECK_LEVEL, target, FRIENDSHIP_FRIEND))
		controller.clear_blackboard_key(target_key)
		finish_action(controller, succeeded = FALSE)
		return
	. = ..()
