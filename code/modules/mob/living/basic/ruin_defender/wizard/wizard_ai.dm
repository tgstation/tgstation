#define WIZARD_SPELL_COOLDOWN (1 SECONDS)

/**
 * Wizards run away from their targets while flinging spells at them and blinking constantly.
 */
/datum/ai_controller/basic_controller/wizard
	behavior_tree_json = "code/modules/mob/living/basic/ruin_defender/wizard/wizard.bt.json"
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
	)

	ai_movement = /datum/ai_movement/basic_avoidance



#undef WIZARD_SPELL_COOLDOWN
