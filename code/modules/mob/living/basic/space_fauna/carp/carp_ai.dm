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
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/allow_items(),
		BB_BASIC_MOB_FLEE_BELOW_HP_RATIO = 0.5,
		BB_BASIC_MOB_STOP_FLEE_AT_HP_RATIO = 1
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_if_unhealthy,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/carp,
	)

/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/carp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/while_healthy/carp

/datum/ai_behavior/basic_melee_attack/while_healthy/carp
	action_cooldown = 1.5 SECONDS

/**
 * Carp which bites back, but doesn't look for targets.
 * 'Not hunting targets' includes food (and can rings), because they have been well trained.
 */
/datum/ai_controller/basic_controller/carp/retaliate
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/ignore_faction(),
		BB_BASIC_MOB_FLEE_BELOW_HP_RATIO = 0.5,
		BB_BASIC_MOB_STOP_FLEE_AT_HP_RATIO = 1
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_if_unhealthy,
		/datum/ai_planning_subtree/find_nearest_thing_which_attacked_me_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/carp,
	)

/**
 * AI for carp with a spell.
 * Flow is basically the same as regular carp, except it will try and cast a spell at its target whenever possible and not fleeing.
 */
/datum/ai_controller/basic_controller/carp/ranged
	planning_subtrees = list(
		/datum/ai_planning_subtree/flee_if_unhealthy,
		/datum/ai_planning_subtree/simple_find_nearest_target_to_flee,
		/datum/ai_planning_subtree/flee_target,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/targetted_mob_ability/magicarp,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/magicarp,
	)

/datum/ai_planning_subtree/targetted_mob_ability/magicarp
	ability_key = BB_MAGICARP_SPELL

/// As basic attack tree but interrupt if your health gets low or if your spell is off cooldown
/datum/ai_planning_subtree/basic_melee_attack_subtree/while_healthy/magicarp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic

// This got too nested for me to think of how to make it generic in a way which wasn't stupid
/datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic

/datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic/setup(datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	if (!controller.blackboard[BB_MAGICARP_SPELL])
		return FALSE
	return ..()

/datum/ai_behavior/basic_melee_attack/while_healthy/carp/magic/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_MAGICARP_SPELL]
	if (!QDELETED(using_action) && using_action.IsAvailable())
		finish_action(controller, FALSE)
		return
	return ..()
