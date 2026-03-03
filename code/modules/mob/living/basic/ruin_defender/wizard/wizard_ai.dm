#define WIZARD_SPELL_COOLDOWN (1 SECONDS)

/**
 * Wizards run away from their targets while flinging spells at them and blinking constantly.
 */
/datum/ai_controller/basic_controller/wizard
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/maintain_distance/cover_minimum_distance,
		/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell/primary,
		/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell/secondary,
		/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell/blink,
	)

/**
 * Cast a wizard spell. There is a minimum cooldown between spellcasts to prevent overwhelming spam.
 *
 * Though only the primary spell is actually targeted, all spells use targeted behavior so that they
 * only get used in combat.
 */
/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell
	use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability/wizard_spell

/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (controller.blackboard[BB_WIZARD_SPELL_COOLDOWN] > world.time)
		return
	return ..()

/datum/ai_behavior/targeted_mob_ability/wizard_spell/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	. = ..()
	controller.set_blackboard_key(BB_WIZARD_SPELL_COOLDOWN, world.time + WIZARD_SPELL_COOLDOWN)

/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell/primary
	ability_key = BB_WIZARD_TARGETED_SPELL

/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell/secondary
	ability_key = BB_WIZARD_SECONDARY_SPELL

/datum/ai_planning_subtree/targeted_mob_ability/wizard_spell/blink
	ability_key = BB_WIZARD_BLINK_SPELL

/datum/ai_behavior/use_mob_ability/wizard_spell/perform(seconds_per_tick, datum/ai_controller/controller, ability_key)
	. = ..()
	controller.set_blackboard_key(BB_WIZARD_SPELL_COOLDOWN, world.time + WIZARD_SPELL_COOLDOWN)

#undef WIZARD_SPELL_COOLDOWN
