/**
 * AI controller for carp
 */
/datum/ai_controller/basic_controller/carp
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_FLEE_TARGETTING_DATUM = new /datum/targetting_datum/basic(),
		BB_BASIC_MOB_FLEE_BELOW_HP_RATIO = 0.5,
		BB_BASIC_MOB_STOP_FLEE_AT_HP_RATIO = 1
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_if_unhealthy,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/carp
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/carp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/while_healthy/carp

/datum/ai_behavior/basic_melee_attack/while_healthy/carp
	action_cooldown = 1.5 SECONDS

/// Carp which bites back, but doesn't look for targets
/datum/ai_controller/basic_controller/carp/retaliate
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_if_unhealthy,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/carp
	)
