#define MAGICARP_SPELL_TARGET_SEEK_RANGE 4

/datum/pet_command/point_targetting/attack/carp
	attack_behaviour = /datum/ai_behavior/basic_melee_attack/carp

/datum/pet_command/point_targetting/use_ability/magicarp
	pet_ability_key = BB_MAGICARP_SPELL

/datum/ai_planning_subtree/basic_melee_attack_subtree/carp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/carp

/datum/ai_behavior/basic_melee_attack/carp
	action_cooldown = 1.5 SECONDS

/datum/ai_planning_subtree/attack_obstacle_in_path/carp
	attack_behaviour = /datum/ai_behavior/attack_obstructions/carp

/datum/ai_behavior/attack_obstructions/carp
	action_cooldown = 1.5 SECONDS

/// As basic attack tree but interrupt if your health gets low or if your spell is off cooldown
/datum/ai_planning_subtree/basic_melee_attack_subtree/magicarp
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/carp/magic

/// Interrupt your attack chain if: you have a spell, it's not on cooldown, and it has a target
/datum/ai_behavior/basic_melee_attack/carp/magic

/datum/ai_behavior/basic_melee_attack/carp/magic/perform(delta_time, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key, health_ratio_key)
	var/datum/action/cooldown/using_action = controller.blackboard[BB_MAGICARP_SPELL]
	if (QDELETED(using_action))
		return ..()
	if (!controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETTING] && using_action.IsAvailable())
		finish_action(controller, succeeded = FALSE)
		return
	return ..()

/**
 * Find a target for the magicarp's spell
 * This gets weird because different spells want different targetting
 * but I didn't want a new ai controller for every different spell
 */
/datum/ai_planning_subtree/find_nearest_magicarp_spell_target

/datum/ai_planning_subtree/find_nearest_magicarp_spell_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/datum/weakref/weak_action = controller.blackboard[BB_MAGICARP_SPELL]
	var/datum/action/cooldown/using_action = weak_action?.resolve()
	if (QDELETED(using_action))
		return
	if (!using_action.IsAvailable())
		return

	var/spell_targetting = controller.blackboard[BB_MAGICARP_SPELL_SPECIAL_TARGETTING]
	if (!spell_targetting)
		controller.queue_behavior(/datum/ai_behavior/find_potential_targets/nearest/magicarp, BB_MAGICARP_SPELL_TARGET, BB_TARGETTING_DATUM, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
		return

	switch(spell_targetting)
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

/// Then use it on that target
/datum/ai_planning_subtree/targeted_mob_ability/magicarp
	ability_key = BB_MAGICARP_SPELL
	target_key = BB_MAGICARP_SPELL_TARGET
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/and_clear_target
