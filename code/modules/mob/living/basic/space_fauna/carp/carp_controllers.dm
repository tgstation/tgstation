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
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN,
		BB_CARPS_FEAR_FISHERMAN = TRUE,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/find_target_prioritize_traits,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target/from_fisherman,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/no_fisherman,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/carp_migration,
	)

///Megacarps. The only difference is that they don't flee from scary fishermen and prioritize them.
/datum/ai_controller/basic_controller/carp/mega
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN,
		BB_CARPS_FEAR_FISHERMAN = FALSE,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_target_prioritize_traits,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/carp_migration,
	)
/**
 * Carp which bites back, but doesn't look for targets.
 * 'Not hunting targets' includes food (and can rings), because they have been well trained.
 */
/datum/ai_controller/basic_controller/carp/pet
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN,
		BB_CARPS_FEAR_FISHERMAN = TRUE,
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target/from_fisherman,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/no_fisherman,
	)

/**
 * AI for carp with a spell.
 * Flow is basically the same as regular carp, except it will try and cast a spell at its target whenever possible and not fleeing.
 */
/datum/ai_controller/basic_controller/carp/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/find_target_prioritize_traits,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport,
		/datum/ai_planning_subtree/flee_target/from_fisherman,
		/datum/ai_planning_subtree/find_nearest_magicarp_spell_target,
		/datum/ai_planning_subtree/targeted_mob_ability/magicarp,
		/datum/ai_planning_subtree/attack_obstacle_in_path/carp,
		/datum/ai_planning_subtree/shortcut_to_target_through_carp_rift,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/magicarp,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/carp_migration,
	)

/**
 * Carp which bites back, but doesn't look for targets and doesnt do as much damage
 * Still migrate and stuff
 */
/datum/ai_controller/basic_controller/carp/passive
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/require_traits,
		BB_FLEE_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_CARPS_FEAR_FISHERMAN = TRUE,
		BB_TARGET_ONLY_WITH_TRAITS = list(TRAIT_SCARY_FISHERMAN),
	)
	ai_traits = STOP_MOVING_WHEN_PULLED
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/simple_find_target/to_flee, // This should only find master fishermen because of the targeting strategy
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee/from_flee_key,
		/datum/ai_planning_subtree/make_carp_rift/panic_teleport/flee_key,
		/datum/ai_planning_subtree/flee_target/from_flee_key,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/make_carp_rift/aggressive_teleport,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/carp_migration,
	)
