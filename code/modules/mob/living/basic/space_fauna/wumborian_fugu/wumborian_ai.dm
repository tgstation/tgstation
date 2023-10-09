/// Cowardly when small, aggressive when big. Tries to transform whenever possible.
/datum/ai_controller/basic_controller/wumborian_fugu
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targeted_mob_ability/inflate,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/wumborian_fugu,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/datum/ai_planning_subtree/attack_obstacle_in_path/wumborian_fugu
	attack_behaviour = /datum/ai_behavior/attack_obstructions/wumborian_fugu

/datum/ai_behavior/attack_obstructions/wumborian_fugu
	can_attack_turfs = TRUE
	action_cooldown = 2.5 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/inflate
	ability_key = BB_FUGU_INFLATE
