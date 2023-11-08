/**
 * AI controller for carp
 * Expected flow is:
 * * If health is low, mark that we want to run away.
 * * If we want to run away, find nearest target and run out of view of it.
 * * Look for anything we want to eat in the area and target it.
 * * If we don't have a target already, find something to attack.
 * * Go and attack our target (which might be food, or might be a mob).
 */
/datum/ai_controller/basic_controller/carp
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/carp_migration,
	)

/**
 * Carp which bites back, but doesn't look for targets.
 * 'Not hunting targets' includes food (and can rings), because they have been well trained.
 */
/datum/ai_controller/basic_controller/carp/pet
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

/**
 * AI for carp with a spell.
 * Flow is basically the same as regular carp, except it will try and cast a spell at its target whenever possible and not fleeing.
 */
/datum/ai_controller/basic_controller/carp/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/find_nearest_magicarp_spell_target,
		/datum/ai_planning_subtree/targeted_mob_ability/magicarp,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/magicarp,
		/datum/ai_planning_subtree/carp_migration,
	)

/**
 * Carp which bites back, but doesn't look for targets and doesnt do as much damage
 * Still migrate and stuff
 */
/datum/ai_controller/basic_controller/carp/passive
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic,
		BB_PET_TARGETTING_DATUM = new /datum/targetting_datum/basic/not_friends,
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/carp_migration,
	)
