/datum/ai_movement/jps/oneshot
	max_pathing_attempts = 1

/datum/ai_behavior/targeted_mob_ability/min_range/chicken
	new_movement = /datum/ai_movement/jps/oneshot

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
