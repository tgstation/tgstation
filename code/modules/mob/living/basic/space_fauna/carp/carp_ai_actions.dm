#define MAGICARP_SPELL_TARGET_SEEK_RANGE 4

/datum/pet_command/use_ability/magicarp
	pet_ability_key = BB_MAGICARP_SPELL

/datum/ai_planning_subtree/attack_obstacle_in_path/carp
	attack_behaviour = /datum/ai_behavior/attack_obstructions/carp

/datum/ai_behavior/attack_obstructions/carp
	action_cooldown = 1.5 SECONDS

/// As basic attack tree but interrupt if your health gets low or if your spell is off cooldown
/datum/ai_planning_subtree/basic_melee_attack_subtree/magicarp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/magicarp

/// Interrupt your attack chain if: you have a spell, it's not on cooldown, and it has a target
/datum/ai_behavior/basic_melee_attack/magicarp

/datum/ai_behavior/basic_melee_attack/magicarp/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targeting_strategy_key, hiding_location_key, health_ratio_key)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_MAGICARP_SPELL]
	if (QDELETED(using_action))
		return ..()
	if (!controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETING] && using_action.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return ..()

/**
 * Find a target for the magicarp's spell
 * This gets weird because different spells want different targeting
 * but I didn't want a new ai controller for every different spell
 */
/datum/ai_planning_subtree/find_nearest_magicarp_spell_target

/datum/ai_planning_subtree/find_nearest_magicarp_spell_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_MAGICARP_SPELL]
	if (!using_action?.IsAvailable())
		return

	var/spell_targeting = controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETING]
	if (!spell_targeting)
		controller.queue_behavior(/datum/ai_behavior/find_potential_targets/nearest/magicarp, BB_MAGICARP_SPELL_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
		return

	switch(spell_targeting)
		if (MAGICARP_SPELL_CORPSES)
			controller.queue_behavior(/datum/ai_behavior/find_and_set/friendly_corpses, BB_MAGICARP_SPELL_TARGET, MAGICARP_SPELL_TARGET_SEEK_RANGE)
			return
		if (MAGICARP_SPELL_OBJECTS)
			controller.queue_behavior(/datum/ai_behavior/find_and_set/animatable, BB_MAGICARP_SPELL_TARGET, MAGICARP_SPELL_TARGET_SEEK_RANGE)
			return
		if (MAGICARP_SPELL_WALLS)
			controller.queue_behavior(/datum/ai_behavior/find_and_set/nearest_wall, BB_MAGICARP_SPELL_TARGET, MAGICARP_SPELL_TARGET_SEEK_RANGE)
			return

/// This subtype only exists because if you queue multiple of the same action with different arguments it deletes their stored arguments
/datum/ai_behavior/find_potential_targets/nearest/magicarp

/datum/ai_behavior/find_potential_targets/nearest/magicarp/pick_final_target(datum/ai_controller/controller, list/enemies_list)
	for(var/atom/atom as anything in enemies_list)
		if(HAS_TRAIT(atom, TRAIT_SCARY_FISHERMAN))
			enemies_list -= atom
	return ..()

/// Then use it on that target
/datum/ai_planning_subtree/targeted_mob_ability/magicarp
	ability_key = BB_MAGICARP_SPELL
	target_key = BB_MAGICARP_SPELL_TARGET
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/and_clear_target

#undef MAGICARP_SPELL_TARGET_SEEK_RANGE
