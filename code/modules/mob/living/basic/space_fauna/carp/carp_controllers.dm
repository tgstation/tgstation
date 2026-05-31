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
