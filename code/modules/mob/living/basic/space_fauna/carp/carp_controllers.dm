/**
 * AI controller for carp
 * Expected flow is:
 * * If we want to run away (injured, or a scary fisherman is near), flee or panic-teleport from our target.
 * * Otherwise hunt for something to attack, prioritising scary fishermen, and go bite it.
 * * When idle, migrate between destinations or wander.
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
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/carp/carp.bt.json"

///Megacarps. The only difference is that they don't flee from scary fishermen and prioritize them.
/datum/ai_controller/basic_controller/carp/mega
	blackboard = list(
		BB_BASIC_MOB_STOP_FLEEING = TRUE,
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_PET_TARGETING_STRATEGY = /datum/targeting_strategy/basic/not_friends,
		BB_TARGET_PRIORITY_TRAIT = TRAIT_SCARY_FISHERMAN,
		BB_CARPS_FEAR_FISHERMAN = FALSE,
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
	ai_traits = PASSIVE_AI_FLAGS
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/carp/carp_pet.bt.json"

/**
 * AI for carp with a spell.
 * Flow is basically the same as regular carp, except it will try and cast a spell at its target whenever possible and not fleeing.
 */
/datum/ai_controller/basic_controller/carp/ranged
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/carp/carp_ranged.bt.json"

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
	ai_traits = PASSIVE_AI_FLAGS
	behavior_tree_json = "code/modules/mob/living/basic/space_fauna/carp/carp_passive.bt.json"


/// Shared carp skeleton: escape -> pet command -> (flee / combat / migrate-or-idle) with a target-finding secondary.
/datum/bt_node/subtree/basic_carp_tree
	behavior_tree_json = "basic_carp_tree.bt.json"

/// Flee or panic-teleport away from a keyed target.
/datum/bt_node/subtree/carp_flee
	behavior_tree_json = "carp_flee.bt.json"

/// Attack our current target: cast a spell, teleport in, smash obstacles or bite.
/datum/bt_node/subtree/carp_combat
	behavior_tree_json = "carp_combat.bt.json"

/// Travel a migration path, riding or punching through rifts and walls along the way.
/datum/bt_node/subtree/carp_migration
	behavior_tree_json = "carp_migration.bt.json"

/// Hunting target finder: flee the nearest threat when injured, otherwise hunt prioritising scary fishermen.
/datum/bt_node/subtree/carp_target_selection
	behavior_tree_json = "carp_target_selection.bt.json"

/// Bite-back target finder: target whoever has attacked us.
/datum/bt_node/subtree/carp_retaliate_selection
	behavior_tree_json = "carp_retaliate_selection.bt.json"

/// Passive flee finder: flag scary fishermen and attackers as things to run away from.
/datum/bt_node/subtree/carp_passive_selection
	behavior_tree_json = "carp_passive_selection.bt.json"
