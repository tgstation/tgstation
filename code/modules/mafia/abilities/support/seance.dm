/**
 * Seance
 *
 * An ability that doesn't give you any actions, you instead
 * gain the ability to speak with the dead during the Night.
 * We overwrite perform_action_target's parent to ensure this is triggered automatically.
 */
/datum/mafia_ability/seance
	action_priority = COMSIG_MAFIA_SUNDOWN

/datum/mafia_ability/seance/perform_action_target(datum/mafia_controller/game, datum/mafia_role/day_target)
	ADD_TRAIT(host_role.body, TRAIT_SIXTHSENSE, MAFIA_TRAIT)

/datum/mafia_ability/seance/clean_action_refs(datum/mafia_controller/game)
	REMOVE_TRAIT(host_role.body, TRAIT_SIXTHSENSE, MAFIA_TRAIT)
	return ..()
