/**
 * AI controller for carp
 */
/datum/ai_controller/basic_controller/carp
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/carp
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/carp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/carp

/datum/ai_behavior/basic_melee_attack/carp
	action_cooldown = 1.5 SECONDS

/// Carp which bites back, but doesn't look for targets
/datum/ai_controller/basic_controller/carp/retaliate
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction()
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/carp
	)
